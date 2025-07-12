//
//  Expenses.swift
//  Expense Tracker App
//
//  Created by Techpedia Mac Mini on 7/11/25.
//

import Foundation
import UIKit
import CoreData
import FirebaseFirestore
import FirebaseAuth

class Expenses: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray
        interface()
    }
    
    let expenseTitle = UITextField()
    let expenseAmount = UITextField()
    let category = UITextField()
    let details = UITextField()
    let datePicker = UIDatePicker()
    
    var expenseToEdit: Expense?
    
    func interface() {
        
        //Label at Top
        let expenseLabel = UILabel()
        expenseLabel.text = "Add Expenses:"
        expenseLabel.font = UIFont.boldSystemFont(ofSize: 28)
        expenseLabel.textColor = .systemIndigo
        expenseLabel.textAlignment = .center
        expenseLabel.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 50)
        expenseLabel.layer.cornerRadius = 10
        expenseLabel.backgroundColor = UIColor.white
        view.addSubview(expenseLabel)
        
        //Input for expense title
        expenseTitle.placeholder = "Enter Title"
        expenseTitle.borderStyle = .roundedRect
        expenseTitle.keyboardType = .numberPad
        expenseTitle.frame = CGRect(x: 40, y: 180, width: view.frame.width - 80, height: 44)
        view.addSubview(expenseTitle)
        
        expenseAmount.placeholder = "Enter Expense"
        expenseAmount.borderStyle = .roundedRect
        expenseAmount.keyboardType = .numberPad
        expenseAmount.frame = CGRect(x: 40, y: 240, width: view.frame.width - 80, height: 44)
        view.addSubview(expenseAmount)
        
        category.placeholder = "Category"
        category.borderStyle = .roundedRect
        category.keyboardType = .numberPad
        category.frame = CGRect(x: 40, y: 300, width: view.frame.width - 80, height: 44)
        view.addSubview(category)
        
        details.placeholder = "Details"
        details.borderStyle = .roundedRect
        details.keyboardType = .numberPad
        details.frame = CGRect(x: 40, y: 360, width: view.frame.width - 80, height: 44)
        view.addSubview(details)
        
        let dateLabel = UILabel()
        dateLabel.text = "Select Date"
        dateLabel.font = UIFont.systemFont(ofSize: 18)
        dateLabel.textAlignment = .left
        dateLabel.frame = CGRect(x: 40, y: 420, width: view.frame.width - 40, height: 30)
        view.addSubview(dateLabel)
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.frame = CGRect(x: 40, y: 450, width: view.frame.width - 40, height: 150)
        view.addSubview(datePicker)
        
        let submitButton = UIButton()
        submitButton.setTitle("Save Expense", for: .normal)
        submitButton.frame = CGRect(x: 40, y: 650, width: view.frame.width - 80, height: 44)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.addTarget(self, action: #selector(addEditExpense), for: .touchUpInside)
        view.addSubview(submitButton)
        
        if let existing = expenseToEdit {
            expenseTitle.text = existing.title
            expenseAmount.text = "\(existing.amount)"
            category.text = existing.category
            details.text = existing.details
            if let date = existing.date {
                datePicker.date = date
            }
        }
    }
    
    @objc func addEditExpense() {
        guard
            let title = expenseTitle.text, !title.isEmpty,
            let textAmount = expenseAmount.text, let amount = Double(textAmount),
            let expenseCategory = category.text, !expenseCategory.isEmpty,
            let expenseDetails = details.text, !expenseDetails.isEmpty
        else { return }
        let expenseDate = datePicker.date
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newExpense = Expense(context: context)
        
        if let existing = expenseToEdit {
            // update existing
            existing.title = title
            existing.amount = amount
            existing.date = expenseDate
            existing.category = expenseCategory
            existing.details = expenseDetails
            // no need to update ID
        } else {
            // create new
            newExpense.title = title
            newExpense.amount = amount
            newExpense.date = expenseDate
            newExpense.category = expenseCategory
            newExpense.details = expenseDetails
            newExpense.id = UUID()
        }
        
        try? context.save()
        NotificationCenter.default.post(name: NSNotification.Name("Expense Added"), object: nil)
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user logged in!")
            return }
        
        let db = Firestore.firestore()
        
        let userRef = db.collection("users").document(uid)
        
        //Check if document of logged in user exists
        userRef.getDocument { doc, error in
            if let doc = doc, doc.exists {
                userRef.collection("Expense").addDocument(data: [
                    "title" : newExpense.title ?? "",
                    "amount": newExpense.amount,
                    "date": Timestamp(date: newExpense.date ?? Date()),
                    "category": newExpense.category ?? "",
                    "details": newExpense.details ?? "",
                    "id": newExpense.id?.uuidString ?? "",
                    "createdAt": FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        print("Failed to put data to Firestore: \(error)")
                    } else {
                        print("Expense successfully added to Firestore!")
                    }
                }
            } else {
                // user's document doesn't exist, so create doc and then add expense
                userRef.setData([
                    "createdAt": FieldValue.serverTimestamp()
                ]) {error in
                    if let error = error {
                        print("Failed to create user document: \(error)")
                    }
                    userRef.collection("Expense").addDocument(data: [
                        "title" : newExpense.title ?? "",
                        "amount": newExpense.amount,
                        "date": Timestamp(date: newExpense.date ?? Date()),
                        "category": newExpense.category ?? "",
                        "details": newExpense.details ?? "",
                        "id": newExpense.id?.uuidString ?? "",
                        "createdAt": FieldValue.serverTimestamp()
                    ]) {error in
                        if let error = error {
                            print("Failed to add expense to Firestore: \(error)")
                        } else {
                            print("Expense successfully added to Firestore after creating user!")
                        }
                    }
                }
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        
    }
}
