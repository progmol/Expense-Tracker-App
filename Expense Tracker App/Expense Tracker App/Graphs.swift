import UIKit
import CoreData

class PieChartViewController: UIViewController {
    
    var circularView: PieChartCircular!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCircularView()
    }

    private func setupCircularView() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        let expenses = (try? context.fetch(request)) ?? []
        
        let total = expenses.reduce(0.0) { $0 + $1.amount }
        
        // Build chart data
        var chartData: [PieChartData] = []
        
        for expense in expenses {
            guard total > 0 else { continue }
            let percentage = (expense.amount / total) * 100
            let color = getRandomColor()
            let category = expense.category ?? "Unknown"
            chartData.append(PieChartData(percentage: percentage, color: color, category: category))
        }
        
        // Init chart
        circularView = PieChartCircular(data: chartData)
        circularView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(circularView)
        
        NSLayoutConstraint.activate([
            circularView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circularView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            circularView.widthAnchor.constraint(equalToConstant: 200),
            circularView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func getRandomColor() -> UIColor {
        let red: CGFloat = CGFloat(drand48())
        let green: CGFloat = CGFloat(drand48())
        let blue: CGFloat = CGFloat(drand48())
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
