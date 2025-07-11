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
        fetchTargetAndUpdateUI()
    }
    
    let targetLabel = UILabel()
    let targetField = UITextField()
    let editButton = UIButton(type: .system)
    var currentTarget: MonthlyTarget?
    
    func homeView(){
        
        targetLabel.text = "Your Monthly Target: -"
        targetLabel.font = UIFont.boldSystemFont(ofSize: 28)
        targetLabel.textColor = .systemIndigo
        targetLabel.textAlignment = .center
        targetLabel.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 50)
        targetLabel.layer.cornerRadius = 10
        targetLabel.layer.masksToBounds = true
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
            targetLabel.text = "Your Monthly Target: \(target.amount)"
            targetField.isHidden = true
            editButton.setTitle("Edit Amount", for: .normal)
        } else {
            currentTarget = nil
            targetLabel.text = "Set Your Monthly Target: "
            targetField.isHidden = false
            editButton.setTitle("Add Target", for: .normal)
        }
    }
    
    @objc func handleAddOrEdit(){
        guard let text = targetField.text, let value = Double(text) else { return }
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if let target = currentTarget {
            target.amount = value
        } else {
            let newTarget = MonthlyTarget(context: context)
            newTarget.id = UUID().uuidString
            newTarget.amount = value
            newTarget.month = getCurrentMonth()
            currentTarget = newTarget
        }
        try? context.save()
//        targetLabel.text = "Your Monthly Target: \(value)"
//        targetField.isHidden = true
//        editButton.setTitle("Edit Target", for: .normal)
    }
    
    func getCurrentMonth() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        return(f.string(from: Date()))
    }
}
