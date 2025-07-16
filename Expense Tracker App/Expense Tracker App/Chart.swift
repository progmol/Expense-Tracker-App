import UIKit

// Model for each pie chart slice
struct PieChartData {
    let percentage: Double
    let color: UIColor
    let category: String
}

open class PieChartCircular: UIView {
    
    private var data: [PieChartData]
    private var lineWidth: CGFloat

    // MARK: - Init
     init(data: [PieChartData], lineWidth: CGFloat = 10.0) {
        self.data = data
        self.lineWidth = lineWidth
        super.init(frame: .zero)
        self.backgroundColor = .clear
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Draw
    override public func draw(_ rect: CGRect) {
        var startAngle: CGFloat = -CGFloat.pi / 2
        
        for item in data {
            let endAngle = startAngle + CGFloat(item.percentage / 100.0) * 2 * CGFloat.pi
            
            // Draw slice
            let path = UIBezierPath()
            path.move(to: CGPoint(x: rect.midX, y: rect.midY))
            path.addArc(withCenter: CGPoint(x: rect.midX, y: rect.midY),
                        radius: rect.width / 2,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: true)
            path.close()
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = item.color.cgColor
            shapeLayer.path = path.cgPath
            layer.addSublayer(shapeLayer)
            
            // Calculate label position (middle angle)
            let midAngle = (startAngle + endAngle) / 2
            let radius = rect.width / 4 // half of the radius to place label inside
            let labelCenter = CGPoint(x: rect.midX + radius * cos(midAngle),
                                      y: rect.midY + radius * sin(midAngle))
            
            // Create label
            let label = UILabel()
            label.text = item.category
            label.font = UIFont.systemFont(ofSize: 10)
            label.sizeToFit()
            label.center = labelCenter
            addSubview(label)
            
            startAngle = endAngle
        }
    }
}
