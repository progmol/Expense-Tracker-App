//
//  Expenses.swift
//  Expense Tracker App
//
//  Created by Techpedia Mac Mini on 7/11/25.
//

import Foundation
import UIKit
import CoreData

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
        submitButton.addTarget(self, action: #selector(addExpense), for: .touchUpInside)
        view.addSubview(submitButton)
    }
    
    @objc func addExpense() {
        guard
            let title = expenseTitle.text, !title.isEmpty,
            let textAmount = expenseAmount.text, let amount = Double(textAmount),
            let expenseCategory = category.text, !expenseCategory.isEmpty,
            let expenseDetails = details.text, !expenseDetails.isEmpty
        else { return }
        let expenseDate = datePicker.date

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newExpense = Expense(context: context)
        newExpense.title = title
        newExpense.amount = amount
        newExpense.date = expenseDate
        newExpense.category = expenseCategory
        newExpense.details = expenseDetails
        try? context.save()
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
