import Foundation
import UIKit
import CoreGraphics

/// Apply a circle mask on a target view. You can customize radius, color and opacity of the mask.
class OMCircleMaskView {
    
    private var fillLayer = CAShapeLayer()
    var target: UIView?
    
    var fillColor: UIColor = UIColor.grayColor() {
        didSet {
            self.fillLayer.fillColor = self.fillColor.CGColor
        }
    }
    
    var radius: CGFloat? {
        didSet {
            self.draw()
        }
    }
    
    var opacity: Float = 0.5 {
        didSet {
            self.fillLayer.opacity = self.opacity
        }
    }
    
    /**
     Constructor
     
     - parameter drawIn: target view
     
     - returns: object instance
     */
    init(drawIn: UIView) {
        self.target = drawIn
    }
    
    /**
     Draw a circle mask on target view
     */
    func draw() {
        if let target = target{
        
        var rad: CGFloat = 0
        let size = target.frame.size
        if let r = self.radius {
            rad = r
        } else {
            rad = min(size.height, size.width)
        }
        
        let path = UIBezierPath(roundedRect: CGRectMake(0, 0, size.width, size.height), cornerRadius: 0.0)
        let circlePath = UIBezierPath(roundedRect: CGRectMake(size.width / 2.0 - rad / 2.0, 0, rad, rad), cornerRadius: rad)
        path.appendPath(circlePath)
        path.usesEvenOddFillRule = true
        
        fillLayer.path = path.CGPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = self.fillColor.CGColor
        fillLayer.opacity = self.opacity
        self.target!.layer.addSublayer(fillLayer)
    }
    }
    
    /**
     Remove circle mask
     */
    
    
    func remove() {
        self.fillLayer.removeFromSuperlayer()
    }
    
}
