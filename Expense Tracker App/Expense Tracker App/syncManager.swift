//
//  SyncManager.swift
//  Expense Tracker App
//
//  Created by Expert designer
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import CoreData
import Network

final class SyncManager {

    static let shared = SyncManager()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private init() {
        startNetworkMonitor()
    }
    
    private func startNetworkMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                print("[SyncManager] Online — syncing...")
                self?.syncPendingExpenses()
            } else {
                print("[SyncManager] Offline, will sync later.")
            }
        }
        monitor.start(queue: queue)
    }
    
    func syncIfNeeded() {
        syncPendingExpenses()
    }
    
    private func syncPendingExpenses() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("[SyncManager] No user logged in.")
            return
        }
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchUnsynced: NSFetchRequest<Expense> = Expense.fetchRequest()
        fetchUnsynced.predicate = NSPredicate(format: "needsSync == YES")
        
        let fetchToDelete: NSFetchRequest<Expense> = Expense.fetchRequest()
        fetchToDelete.predicate = NSPredicate(format: "needsDelete == YES")
        
        do {
            let unsynced = try context.fetch(fetchUnsynced)
            let toDelete = try context.fetch(fetchToDelete)
            
            for expense in unsynced {
                uploadOrUpdateExpense(expense, forUser: uid, context: context)
            }
            
            for expense in toDelete {
                deleteExpense(expense, forUser: uid, context: context)
            }
        } catch {
            print("[SyncManager] Fetch error: \(error)")
        }
    }
    
    private func uploadOrUpdateExpense(_ expense: Expense, forUser uid: String, context: NSManagedObjectContext) {
        guard let expenseId = expense.id?.uuidString else {
            print("[SyncManager] Missing ID.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        let expenseRef = userRef.collection("Expense")
        
        let data: [String: Any] = [
            "title": expense.title ?? "",
            "amount": expense.amount,
            "date": Timestamp(date: expense.date ?? Date()),
            "category": expense.category ?? "",
            "details": expense.details ?? "",
            "id": expenseId,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        userRef.getDocument { doc, error in
            if let doc = doc, doc.exists {
                // Check if expense exists by id, then update; else add
                expenseRef.whereField("id", isEqualTo: expenseId).getDocuments { snapshot, error in
                    if let error = error {
                        print("[SyncManager] Lookup error: \(error)")
                        return
                    }
                    if let existingDoc = snapshot?.documents.first {
                        existingDoc.reference.updateData(data) { error in
                            if let error = error {
                                print("[SyncManager] Update error: \(error)")
                            } else {
                                expense.needsSync = false
                                try? context.save()
                                print("[SyncManager] Expense updated.")
                            }
                        }
                    } else {
                        expenseRef.addDocument(data: data) { error in
                            if let error = error {
                                print("[SyncManager] Add error: \(error)")
                            } else {
                                expense.needsSync = false
                                try? context.save()
                                print("[SyncManager] Expense added.")
                            }
                        }
                    }
                }
            } else {
                userRef.setData(["createdAt": FieldValue.serverTimestamp()]) { error in
                    if let error = error {
                        print("[SyncManager] User doc create error: \(error)")
                    } else {
                        expenseRef.addDocument(data: data) { error in
                            if let error = error {
                                print("[SyncManager] Add after create error: \(error)")
                            } else {
                                expense.needsSync = false
                                try? context.save()
                                print("[SyncManager] Added after user doc creation.")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func deleteExpense(_ expense: Expense, forUser uid: String, context: NSManagedObjectContext) {
        guard let expenseId = expense.id?.uuidString else {
            print("[SyncManager] Missing ID to delete.")
            return
        }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        userRef.collection("Expense").whereField("id", isEqualTo: expenseId).getDocuments { snapshot, error in
            if let error = error {
                print("[SyncManager] Delete lookup error: \(error)")
                return
            }
            guard let doc = snapshot?.documents.first else {
                print("[SyncManager] Expense not found to delete.")
                return
            }
            doc.reference.delete { error in
                if let error = error {
                    print("[SyncManager] Delete error: \(error)")
                } else {
                    context.delete(expense)
                    try? context.save()
                    print("[SyncManager] Deleted.")
                }
            }
        }
    }
}
