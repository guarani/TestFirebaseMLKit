//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

struct TemplateElement: Codable {
    let key: String
    let label: String
    let vertices: [CGPoint]
}

class MyViewController : UIViewController {
    
    var templateElements = [TemplateElement]()
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .red
        imageView.frame = CGRect(x: 20, y: 20, width: 800, height: 800)
        imageView.image = UIImage(named: "IMG_8457.HEIC")
        view.addSubview(imageView)
        self.view = view
        
        guard let url = Bundle.main.url(forResource: "template", withExtension: "json") else { return }
        guard let jsonData = try? Data(contentsOf: url) else { return }
        guard let elements = try? JSONDecoder().decode([TemplateElement].self, from: jsonData) else { return }
        templateElements = elements
        
        imageView.image = annotate(image: imageView.image!)
        
    }
    
    func annotate(image: UIImage) -> UIImage? {
        
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: .zero)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        ctx.setLineWidth(10)
        UIColor.black.setStroke()
        
        for polygon in templateElements {
            guard let firstVertice = polygon.vertices.first else { continue }
            ctx.move(to: obtainCoordinateFrom(point: firstVertice, in: image))
            polygon.vertices.forEach {
                ctx.addLine(to: obtainCoordinateFrom(point: $0, in: image))
            }
            ctx.closePath()
            ctx.strokePath()
        }
        let annotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return annotatedImage
    }
    
    func obtainCoordinateFrom(point: CGPoint, in image: UIImage) -> CGPoint {
        return CGPoint(x: point.x * image.size.width, y: point.y * image.size.width)
    }
}
// Present the view controller in the Live View window
let viewController = MyViewController()
viewController.preferredContentSize = CGSize(width: 900, height: 900)
PlaygroundPage.current.liveView = viewController
