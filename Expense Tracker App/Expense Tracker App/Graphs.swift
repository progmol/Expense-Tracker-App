import UIKit
import CoreData

class PieChartViewController: UIViewController {
    
    // MARK: - Properties
    var circularView: PieChartCircular!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCircularView()
    }
    
    // MARK: - Setup Chart
    private func setupCircularView() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        let expenses = (try? context.fetch(fetchRequest)) ?? []
        
        guard !expenses.isEmpty else {
            print("No expenses found")
            return
        }
        
        var categoryTotals: [String: Double] = [:]
        for expense in expenses {
            let rawCategory = expense.category ?? "Other"
            let category = rawCategory.lowercased()
            categoryTotals[category, default: 0] += expense.amount
        }
        
        let grandTotal = categoryTotals.values.reduce(0, +)
        guard grandTotal > 0 else {
            print("Total amount is zero")
            return
        }
        
        var data: [PieChartData] = []
        for (category, totalAmount) in categoryTotals {
            let percentage = (totalAmount / grandTotal) * 100
            let color = getRandomColor() // keep random colors as required
            let displayCategory = category.capitalized
            data.append(PieChartData(percentage: percentage, color: color, category: displayCategory))
        }
        
        // Initialize and add PieChartCircular view
        circularView = PieChartCircular(data: data)
        circularView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(circularView)
        
        // Constraints
        NSLayoutConstraint.activate([
            circularView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circularView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            circularView.widthAnchor.constraint(equalToConstant: 250),
            circularView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    // MARK: - Helper
    private func getRandomColor() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
