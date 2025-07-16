//
//  Home.swift
//  Expense Tracker App
//
//  Created by Techpedia Mac Mini on 7/9/25.
//

import UIKit
import CoreData

class Home: UIViewController {

    // MARK: - Variables
    let targetLabel = UILabel()
    let targetField = UITextField()
    let editButton = UIButton(type: .system)
    let expenseButton = UIButton(type: .system)
    let graphButton = UIButton(type: .system)
    var currentTarget: MonthlyTarget?
    var isEditingTarget = false

    var collectionView: UICollectionView!
    var allExpenses: [Expense]? = []

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray

        homeView()
        expenseButtonView()
        graphButtonView()
        setupCollectionView()
        fetchTargetAndUpdateUI()
        fetchExpenses()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshExpenses), name: NSNotification.Name("Expense Added"), object: nil)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        limitNotification()
//    }


    // MARK: - Home target view
    func homeView(){
        targetLabel.text = "Your Monthly Target: -"
        targetLabel.font = UIFont.boldSystemFont(ofSize: 28)
        targetLabel.textColor = .systemIndigo
        targetLabel.textAlignment = .center
        targetLabel.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 50)
        targetLabel.layer.cornerRadius = 10
        targetLabel.backgroundColor = UIColor.white
        targetLabel.layer.masksToBounds = true
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

    // MARK: - Expenses Add button
    func expenseButtonView() {
        expenseButton.setTitle("Add Expense", for: .normal)
        expenseButton.frame = CGRect(x: 40, y: 300, width: view.frame.width - 80, height: 44)
        expenseButton.backgroundColor = .systemBlue
        expenseButton.setTitleColor(.white, for: .normal)
        expenseButton.layer.cornerRadius = 8
        expenseButton.addTarget(self, action: #selector(addExpense), for: .touchUpInside)
        view.addSubview(expenseButton)
    }
    
    // MARK: - Graph View button
    func graphButtonView() {
        graphButton.setTitle("View Charts", for: .normal)
        graphButton.frame = CGRect(x: 40, y: 360, width: view.frame.width - 80, height: 44)
        graphButton.backgroundColor = .systemBlue
        graphButton.setTitleColor(.white, for: .normal)
        graphButton.layer.cornerRadius = 8
        graphButton.addTarget(self, action: #selector(viewGraph), for: .touchUpInside)
        view.addSubview(graphButton)
    }

    // MARK: - Collection view setup
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.itemSize = CGSize(width: view.frame.width - 40, height: 120)

        collectionView = UICollectionView(frame: CGRect(x: 0, y: 420, width: view.frame.width, height: view.frame.height - 420), collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(collectionView)
    }

    // MARK: - Fetch target
    func fetchTargetAndUpdateUI(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<MonthlyTarget> = MonthlyTarget.fetchRequest()
        request.predicate = NSPredicate(format: "month == %@", getCurrentMonth())

        if let targets = try? context.fetch(request), let target = targets.first {
            currentTarget = target
            targetLabel.text = "Monthly Target: \(target.amount)"
            targetField.isHidden = true
            editButton.setTitle("Edit Target", for: .normal)
        } else {
            currentTarget = nil
            targetLabel.text = "Set Your Monthly Target: "
            targetField.isHidden = false
            editButton.setTitle("Add Target", for: .normal)
        }
    }

    // MARK: - Fetch expenses
    func fetchExpenses() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        allExpenses = try? context.fetch(request)
        limitNotification()
        collectionView.reloadData()
    }

    // MARK: - Add / Edit target
    @objc func handleAddOrEdit() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        if isEditingTarget {
            guard let text = targetField.text, let value = Double(text), let target = currentTarget else { return }
            target.amount = value
            try? context.save()
            targetLabel.text = "Monthly Target: \(value)"
            targetField.isHidden = true
            editButton.setTitle("Edit Target", for: .normal)
            isEditingTarget = false
        } else {
            if currentTarget != nil {
                targetField.isHidden = false
                targetField.text = "\(currentTarget?.amount ?? 0)"
                editButton.setTitle("Update Target", for: .normal)
                isEditingTarget = true
            } else {
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

    // MARK: - Add Expense
    @objc func addExpense() {
        let expensePage = Expenses()
        present(expensePage, animated: true)
    }
    

    // MARK: - Delete Expense
    @objc func deleteExpenseFromCollection(_ sender: UIButton) {
        let index = sender.tag
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if let expenseToDelete = allExpenses?[index] {
            expenseToDelete.needsDelete = true // mark for delete
            try? context.save()
            SyncManager.shared.syncIfNeeded()
            allExpenses?.remove(at: index)
            collectionView.reloadData()
        }
    }

    @objc func refreshExpenses() {
        fetchExpenses()
    }

    @objc func viewGraph(){
        let graphPage = PieChartViewController()
        present(graphPage, animated: true)
    }
    
    func getCurrentMonth() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        return(f.string(from: Date()))
    }
    
    // MARK: - Edit Expense
    @objc func editExpenseFromCollection(_ sender: UIButton) {
        let index = sender.tag
        guard  let expense = allExpenses?[index] else {return}
        let editViewController = Expenses()
        editViewController.expenseToEdit = expense
        present(editViewController, animated: true)
    }
    
    
    // MARK: - Notification when user is exceeding the limit
    
    func limitNotification(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let targetRequest: NSFetchRequest<MonthlyTarget> = MonthlyTarget.fetchRequest()
        targetRequest.predicate = NSPredicate(format: "month == %@", getCurrentMonth())
        
        var targetAmount = 0.0
        
        if let targets = try? context.fetch(targetRequest), let target = targets.first {
            targetAmount = target.amount
        }
        
        guard targetAmount != 0 else {
            print("No monthly target set")
            return
        }
        
        let limitRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        let expenses = (try? context.fetch(limitRequest)) ?? []
        let total = expenses.reduce(0.0) { $0 + $1.amount }
        
        let percentage = (total / targetAmount) * 100
        print("Target: \(targetAmount), Total spent: \(total), Percentage: \(percentage)")
        
        if percentage >= 80 {
            DispatchQueue.main.async {
                    self.showAlert("You are exceeding your monthly limit")
                }
        }
    }

    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    // MARK: - Exchange Rates Function

        @objc func showExchangeRates(_ sender: UIButton){
            let index = sender.tag
            guard  let expense = allExpenses?[index] else {return}
            let amount = expense.amount
            let exchangeVC = exchangeViewController()
            exchangeVC.baseAmount = amount
            present(exchangeVC, animated: true)
        }
}



// MARK: - Collection view data source & delegate --- It should be learn afterwards!!
extension Home: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allExpenses?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let expense = allExpenses![indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        // Remove old views
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        cell.backgroundColor = .white
        cell.layer.cornerRadius = 10
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.1
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)

        let titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: cell.frame.width - 70, height: 20))
        titleLabel.text = "Title: \(expense.title ?? "")"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        cell.contentView.addSubview(titleLabel)

        let amountLabel = UILabel(frame: CGRect(x: 10, y: 35, width: cell.frame.width - 20, height: 20))
        amountLabel.text = "Amount: \(expense.amount)"
        amountLabel.font = UIFont.systemFont(ofSize: 14)
        cell.contentView.addSubview(amountLabel)

        let categoryLabel = UILabel(frame: CGRect(x: 10, y: 60, width: cell.frame.width - 20, height: 20))
        categoryLabel.text = "Category: \(expense.category ?? "")"
        categoryLabel.font = UIFont.systemFont(ofSize: 14)
        cell.contentView.addSubview(categoryLabel)

        let dateLabel = UILabel(frame: CGRect(x: 10, y: 85, width: cell.frame.width - 20, height: 20))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateLabel.text = "Date: \(expense.date != nil ? formatter.string(from: expense.date!) : "-")"
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        cell.contentView.addSubview(dateLabel)

        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        deleteButton.frame = CGRect(x: cell.frame.width - 60, y: 10, width: 50, height: 30)
        deleteButton.tag = indexPath.item
        deleteButton.addTarget(self, action: #selector(deleteExpenseFromCollection(_:)), for: .touchUpInside)
        cell.contentView.addSubview(deleteButton)
        
        let editExpense = UIButton(type: .system)
        editExpense.setTitle("Edit", for: .normal)
        editExpense.setTitleColor(.blue, for: .normal)
        editExpense.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        editExpense.frame = CGRect(x: cell.frame.width - 60, y: 40, width: 50, height: 30)
        editExpense.tag = indexPath.item
        editExpense.addTarget(self, action: #selector(editExpenseFromCollection(_:)), for: .touchUpInside)
        cell.contentView.addSubview(editExpense)

        let exchangeButton = UIButton(type: .system)
        exchangeButton.setTitleColor(.blue, for: .normal)
        exchangeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        exchangeButton.frame = CGRect(x: cell.frame.width - 60, y: 70, width: 50, height: 30)
        exchangeButton.tag = indexPath.item
        exchangeButton.setTitle("Exchange", for: .normal)
        exchangeButton.addTarget(self, action: #selector(showExchangeRates(_:)), for: .touchUpInside)
        cell.contentView.addSubview(exchangeButton)
        
        return cell
    }
}
