import UIKit

struct OpenRatesResponse: Codable {
    let rates: [String: Double]
    let base: String
    let timestamp: Int
}

class exchangeViewController: UIViewController, UITableViewDataSource {
    
    let tableView = UITableView()
    var baseAmount: Double?
    var convertedRates: [(currency: String, amount: Double)] = []
    
    let apiKey = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Exchange Rates"
        
        tableView.frame = view.bounds
        tableView.backgroundColor = .systemBackground
        tableView.dataSource = self
        view.addSubview(tableView)
        
        fetchExchangeRates()
    }
    
    func fetchExchangeRates() {
        // Free plan uses USD as base; we get rates vs USD
        let urlString = "https://openexchangerates.org/api/latest.json?app_id=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching: \(error)")
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(OpenRatesResponse.self, from: data)
                
                // Get USD to PKR rate
                guard let usdToPKR = decoded.rates["PKR"] else {
                    print("PKR rate missing")
                    return
                }
                
                // Pick 5 target currencies
                let targetCurrencies = ["USD", "EUR", "GBP", "JPY", "CNY"]
                
                var tempResults: [(String, Double)] = []
                
                guard let amount = self.baseAmount else {
                    print("Base amount not set")
                    return
                }
                
                for currency in targetCurrencies {
                    if currency == "USD" {
                        let amountInPKR = amount / usdToPKR
                        tempResults.append((currency, amountInPKR))
                    } else if let usdToTarget = decoded.rates[currency] {
                        let targetPerPKR = usdToTarget / usdToPKR
                        let convertedAmount = targetPerPKR * amount
                        tempResults.append((currency, convertedAmount))
                    } else {
                        print("Rate missing for \(currency)")
                    }
                }
                
                DispatchQueue.main.async {
                    self.convertedRates = tempResults
                    self.tableView.reloadData()
                }
                
            } catch {
                print("Failed to parse JSON: \(error)")
            }
        }
        task.resume()
    }
    
    // MARK: TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return convertedRates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = convertedRates[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.backgroundColor = .secondarySystemBackground
        cell.textLabel?.textColor = .label
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.textLabel?.text = "\(data.currency): \(String(format: "%.2f", data.amount))"
        cell.detailTextLabel?.text = "For PKR \(baseAmount ?? 0.0)"
        return cell
    }
}
