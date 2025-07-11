//
//  Home.swift
//  Expense Tracker App
//
//  Created by Techpedia Mac Mini on 7/9/25.
//

import UIKit
import CoreData

class Home: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray
        homeView()
        expenseView()
        fetchTargetAndUpdateUI()
    }
    
    //Home View and its variables!!
    
    let targetLabel = UILabel()
    let targetField = UITextField()
    let editButton = UIButton(type: .system)
    var currentTarget: MonthlyTarget?
    var isEditingTarget = false
    let expenseButton = UIButton(type: .system)

    func homeView(){
        
        targetLabel.text = "Your Monthly Target: -"
        targetLabel.font = UIFont.boldSystemFont(ofSize: 28)
        targetLabel.textColor = .systemIndigo
        targetLabel.textAlignment = .center
        targetLabel.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 50)
        targetLabel.layer.cornerRadius = 10
        targetLabel.backgroundColor = UIColor.white
        view.addSubview(targetLabel)
        
        targetField.placeholder = "Enter target"
        targetField.borderStyle = .roundedRect
        targetField.keyboardType = .numberPad
        targetField.frame = CGRect(x: 40, y: 180, width: view.frame.width - 80, height: 44)
        view.addSubview(targetField)
        
        editButton.setTitle("Add Target", for: .normal)
        editButton.frame = CGRect(x: 40, y: 240, width: view.frame.width - 80, height: 44)
        editButton.backgroundColor = .systemBlue
        editButton.setTitleColor(.white, for: .normal)
        editButton.layer.cornerRadius = 8
        editButton.addTarget(self, action: #selector(handleAddOrEdit), for: .touchUpInside)
        view.addSubview(editButton)
        
    }
    
    func fetchTargetAndUpdateUI(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<MonthlyTarget> = MonthlyTarget.fetchRequest()
        request.predicate = NSPredicate(format: "month == %@", getCurrentMonth())
        
        if let targets = try? context.fetch(request), let target = targets.first {
            currentTarget = target
            targetLabel.text = "Monthly Target: \(target.amount)"
            targetField.isHidden = true
            editButton.setTitle("Edit Target", for: .normal)
            editButton.addTarget(self, action: #selector(handleAddOrEdit), for: .touchUpInside)
        } else {
            currentTarget = nil
            targetLabel.text = "Set Your Monthly Target: "
            targetField.isHidden = false
            editButton.setTitle("Add Target", for: .normal)
        }
    }
    
    @objc func handleAddOrEdit() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        if isEditingTarget {
            // User wants to update
            guard let text = targetField.text, let value = Double(text), let target = currentTarget else { return }
            target.amount = value
            try? context.save()
            targetLabel.text = "Monthly Target: \(value)"
            targetField.isHidden = true
            editButton.setTitle("Edit Target", for: .normal)
            isEditingTarget = false
        } else {
            if currentTarget != nil {
                // Switch to edit mode
                targetField.isHidden = false
                targetField.text = "\(currentTarget?.amount ?? 0)"
                editButton.setTitle("Update Target", for: .normal)
                isEditingTarget = true
            } else {
                // Add new target
                guard let text = targetField.text, let value = Double(text) else { return }
                let newTarget = MonthlyTarget(context: context)
                newTarget.id = UUID().uuidString
                newTarget.amount = value
                newTarget.month = getCurrentMonth()
                currentTarget = newTarget
                try? context.save()
                targetLabel.text = "Monthly Target: \(value)"
                targetField.isHidden = true
                editButton.setTitle("Edit Target", for: .normal)
            }
        }
    }

    func getCurrentMonth() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        return(f.string(from: Date()))
    }
    
    
    // Expenses And its variables!!
    
    func expenseView() {
        
        expenseButton.setTitle("Add Expense", for: .normal)
        expenseButton.frame = CGRect(x: 40, y: 300, width: view.frame.width - 80, height: 44)
        expenseButton.backgroundColor = .systemBlue
        expenseButton.setTitleColor(.white, for: .normal)
        expenseButton.layer.cornerRadius = 8
        expenseButton.addTarget(self, action: #selector(addExpense), for: .touchUpInside)
        view.addSubview(expenseButton)
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        
        let allExpenses = try? context.fetch(request)
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 360, width: view.frame.width, height: view.frame.height - 300))
        view.addSubview(scrollView)
        
        var yOffset: CGFloat = 20
        
        allExpenses?.forEach { expense in
            let card = UIView(frame: CGRect(x: 20, y: yOffset, width: scrollView.frame.width - 40, height: 120))
            card.backgroundColor = .white
            card.layer.cornerRadius = 10
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.1
            card.layer.shadowOffset = CGSize(width: 0, height: 2)
            
            let titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: card.frame.width - 20, height: 20))
            titleLabel.text = "Title: \(expense.title ?? "")"
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            card.addSubview(titleLabel)
            
            let amountLabel = UILabel(frame: CGRect(x: 10, y: 35, width: card.frame.width - 20, height: 20))
            amountLabel.text = "Amount: \(expense.amount)"
            amountLabel.font = UIFont.systemFont(ofSize: 14)
            card.addSubview(amountLabel)
            
            let categoryLabel = UILabel(frame: CGRect(x: 10, y: 60, width: card.frame.width - 20, height: 20))
            categoryLabel.text = "Category: \(expense.category ?? "")"
            categoryLabel.font = UIFont.systemFont(ofSize: 14)
            card.addSubview(categoryLabel)
            
            let dateLabel = UILabel(frame: CGRect(x: 10, y: 85, width: card.frame.width - 20, height: 20))
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            if let date = expense.date {
                dateLabel.text = "Date: \(formatter.string(from: date))"
            } else {
                dateLabel.text = "Date: -"
            }
            dateLabel.font = UIFont.systemFont(ofSize: 14)
            card.addSubview(dateLabel)
            
            scrollView.addSubview(card)
            yOffset += 140 // move down for next card
        }
        
        // After loop, set scroll view content size so it can scroll:
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: yOffset + 20)
        
    }

    @objc func addExpense() {
        let expensePage = Expenses()
        present(expensePage, animated: true)
    }
}

