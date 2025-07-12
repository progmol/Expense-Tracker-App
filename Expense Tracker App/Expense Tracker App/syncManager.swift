//
//  SyncManager.swift
//  Expense Tracker App
//
//  Created by Expert designer
//
//Learn whole file on Monday!!


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
                print("[SyncManager] Network reachable, syncing pending expenses...")
                self?.syncPendingExpenses()
            } else {
                print("[SyncManager] Offline — will sync later.")
            }
        }
        monitor.start(queue: queue)
    }
    
    /// Public method to manually trigger sync if needed
    func syncIfNeeded() {
        syncPendingExpenses()
    }
    
    private func syncPendingExpenses() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("[SyncManager] No user logged in, skipping sync.")
            return
        }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "needsSync == YES")
        
        do {
            let unsyncedExpenses = try context.fetch(fetchRequest)
            print("[SyncManager] Found \(unsyncedExpenses.count) expenses to sync.")
            
            for expense in unsyncedExpenses {
                uploadExpense(expense, forUser: uid, context: context)
            }
        } catch {
            print("[SyncManager] Failed to fetch unsynced expenses: \(error)")
        }
    }
    
    private func uploadExpense(_ expense: Expense, forUser uid: String, context: NSManagedObjectContext) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        let data: [String: Any] = [
            "title": expense.title ?? "",
            "amount": expense.amount,
            "date": Timestamp(date: expense.date ?? Date()),
            "category": expense.category ?? "",
            "details": expense.details ?? "",
            "id": expense.id?.uuidString ?? "",
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        userRef.getDocument { doc, error in
            if let doc = doc, doc.exists {
                // User doc exists, add expense
                userRef.collection("Expense").addDocument(data: data) { error in
                    if let error = error {
                        print("[SyncManager] Failed to sync expense: \(error)")
                    } else {
                        expense.needsSync = false
                        try? context.save()
                        print("[SyncManager] Expense synced successfully!")
                    }
                }
            } else {
                // Create user doc first, then add expense
                userRef.setData(["createdAt": FieldValue.serverTimestamp()]) { error in
                    if let error = error {
                        print("[SyncManager] Failed to create user document: \(error)")
                    } else {
                        userRef.collection("Expense").addDocument(data: data) { error in
                            if let error = error {
                                print("[SyncManager] Failed to add expense after creating user: \(error)")
                            } else {
                                expense.needsSync = false
                                try? context.save()
                                print("[SyncManager] Expense synced after creating user!")
                            }
                        }
                    }
                }
            }
        }
    }
}
