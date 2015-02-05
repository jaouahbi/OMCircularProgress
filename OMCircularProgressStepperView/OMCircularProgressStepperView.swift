//
//  OMCircularProgressView.swift
//
//  Created by Jorge Ouahbi on 19/1/15.
//  Copyright (c) 2015  Jorge Ouahbi. All rights reserved.
//

import UIKit

func clamp<T: Comparable>(value:T,lower:T,upper:T) -> T{
    return min(upper, max(lower, value))
}


class Angular
{
    class func degreesToRadians (value:Double) -> Double {
        return value * 0.01745329252
    }
    class func radiansToDegrees (value:Double) -> Double {
        return value * 57.29577951;
    }
}

class Circle
{
    class var RadiansInCircle: Double { return M_PI * 2.0 }
    
    class func arcAngle(arcLength:Double, radius:Double) -> Double{
        
        return arcLength / radius;
    }
    
    class func arcLength(angle:Double, radius:Double) -> Double{
        
        return angle * radius;
    }
    
    class func arcPoint(angle:Double, radius:Double, center:CGPoint) -> CGPoint
    {
        //
        // Given a radius length r and an angle in radians and a circle's center (x,y),
        // calculate the coordinates of a point on the circumference
        //
        
        return CGPoint(x: center.x + CGFloat(radius) * cos(CGFloat(angle)), y: center.y + CGFloat(radius) * sin(CGFloat(angle)))
    }
}


class OMStepData
{
    var startAngle:Double = 0.0
    var endAngle:Double = 0.0
    var hypotAngleHalf:Double = 0.0          // angle of arclength of image hypotenuse in radians
    
    var color:UIColor!;
    var shapeLayer:CAShapeLayer?
    var wellLayer:CAShapeLayer?
    var gradientLayer:CAGradientLayer?
    var imageLayer:CALayer?
    var image : UIImage?                     // optional image
    var gradient:Bool = true
    var wellColor:UIColor? = UIColor.lightGrayColor()
    
    required convenience init(startAngle:Double,
        percent:Double,
        color:UIColor!,
        image:UIImage? = nil,gradient: Bool = true)
    {
        self.init(startAngle:startAngle,
            endAngle: startAngle + (Circle.RadiansInCircle * percent),
            color:color,
            image:image,gradient:gradient)
    }
    
    init(startAngle:Double,
        endAngle:Double,
        color:UIColor!,
        image:UIImage? = nil,
        gradient: Bool = true)
    {
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.color = color
        self.image = image
        self.gradient = gradient;
    }
}

@IBDesignable class OMCircularProgressStepperView: UIView {
    
    var roundedHead : Bool = false {
        didSet
        {
            if(self.thicknessRatio >= 0.2){
                roundedHead = false;
            }
            
            if(oldValue != roundedHead){
                setNeedsLayout();
            }
        }
    }
    var startAngle : Double = Angular.degreesToRadians(-90)
    var animationDuration : NSTimeInterval = 1.0
    
    private(set) var dataSteps: NSMutableArray = []
    private var maxImageSize : CGSize = CGSizeZero
    private var newBeginTime: NSTimeInterval = 0;
    private var imageLayer:CALayer?                // center image layer
    
    
    var lineWidth:CGFloat
    {
        get { return  thicknessRatio * radius() }
    }
    @IBInspectable var shadowLayer : Bool = true
    {
        didSet {setNeedsLayout(); }
    }
    @IBInspectable var shadowRadius: CGFloat = 2
    {
        didSet { setNeedsLayout();}
    }
    @IBInspectable var shadowOpacity: Float  = 1
    {
        didSet { setNeedsLayout(); }
    }
    @IBInspectable var shadowOffset : CGSize = CGSizeZero
    {
        didSet { setNeedsLayout();}
    }
    
    @IBInspectable var thicknessRatio : CGFloat = 0.1
    {
        didSet {
            thicknessRatio = clamp(thicknessRatio, 0.0,1.0)
            if(oldValue != thicknessRatio){
                setNeedsLayout();
            }
        }
    }
    
    @IBInspectable var image: UIImage?
    {
        didSet
        {
            if let img = image?
            {
                imageLayer = CALayer()
                
                imageLayer?.frame = CGRect(origin:
                    CGPoint(x:center.x -  img.size.width * 0.5,
                    y:center.y -  img.size.height * 0.5),
                    size: img.size)
                
                imageLayer?.contents = img.getGrayScale()?.CGImage
                
                // This layer is the index 0
                
                self.layer.insertSublayer(imageLayer, atIndex:0)
            }

        }
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func radius() -> CGFloat {
        return (bounds.size.min() * 0.5) - (maxImageSize.max() * 0.5) ;
    }
    
    func setProgress(progress:Double)
    {
        CATransaction.begin()

        for var i = 0; i < self.dataSteps.count  ; ++i
        {
            let index = Double(i+1)
            let mod = ( progress % index)
            let current =  mod == 0 ? 1.0 : mod
        
            self.setProgressAtIndex(i, progress:current)
        
            if(current < 1.0){
                break;
            }
        }
        
        CATransaction.commit()
    }
    
    func setProgressAtIndex(index:Int, progress:Double) {
        
        let step = self.dataSteps[index] as OMStepData
        
        if let layer = step.shapeLayer? {
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            
            animation.fromValue =  0.0
            animation.toValue   =  progress

            animation.duration = self.animationDuration

            animation.removedOnCompletion = false
            animation.additive = true
            animation.fillMode = kCAFillModeForwards
              
            if (newBeginTime != 0) {
                animation.beginTime = newBeginTime
            }else{
                animation.beginTime = CACurrentMediaTime()
            }

            newBeginTime = animation.beginTime + animation.duration

            layer.addAnimation(animation, forKey: "strokeEnd")
        }
    }
    
    
    func addProgressStepWithAngle(startAngle:Double,
        endAngle:Double,
        color:UIColor!,
        image:UIImage? = nil, gradient:Bool = true) {
            
        if let img = image?{
            maxImageSize = img.size.max(maxImageSize)
        }
            
        // Save the step
        self.dataSteps.addObject(OMStepData(startAngle:startAngle,
                endAngle:endAngle,
                color:color,
                image:image,
                gradient: gradient))
            
    }
    
    
    func addProgressStepWithAngle(
        angle:Double,
        color:UIColor!,
        image:UIImage?  = nil,
        gradient:Bool = true) {
            
            var startAngle = self.getStartAngle()
            
            // Save the step
            
            addProgressStepWithAngle(startAngle,
                                     endAngle:startAngle + angle,
                                     color:color,
                                     image:image,
                                     gradient: gradient);
            
    }
    
    
    func addProgressStepWithPercent(startAngle:Double,
        percent:Double,
        color:UIColor!,
        image:UIImage? = nil,
        gradient:Bool = true)
    {
        let percent = clamp(percent, 0.0, 1.0)
        
        if let img = image?{
            maxImageSize = img.size.max(maxImageSize)
        }
        
        // Save the step
        self.dataSteps.addObject(OMStepData(startAngle:startAngle,
            percent:percent,
            color:color,
            image:image,
            gradient: gradient))
            
    }
    
    func addProgressStepWithPercent(percent:Double,
        color:UIColor!,
        image:UIImage? = nil,
        gradient:Bool = true) {
        
        addProgressStepWithPercent(self.getStartAngle(), percent: percent, color: color, image: image,
        gradient: gradient);
        
    }
    
    
    private func getStartAngle() -> Double
    {
        var startAngle = self.startAngle;
        
        if(self.dataSteps.count > 0){
            // the new startAngle is the last endAngle
            startAngle  = (self.dataSteps[self.dataSteps.count - 1] as OMStepData).endAngle
        }
        return startAngle;
    }


    private func setupLayers(step:OMStepData, startAngle:Double, endAngle:Double, color:UIColor)
    {
        if (step.gradient) {
        
            // Setup the gradient layer
            
            step.gradientLayer =  CAGradientLayer()
            step.gradientLayer?.frame = bounds
            
            step.gradientLayer?.locations = [0.0, 1.0]
            
            let colorTop: AnyObject = color.lighterColor(1.0).CGColor
            let colorBottom: AnyObject = color.darkerColor(7.0).CGColor
            
            let arrayOfColors: [AnyObject] = [colorTop, colorBottom]
            
            step.gradientLayer?.colors = arrayOfColors
        }
        
        step.shapeLayer = CAShapeLayer()
        
        let halfLineWidth = (self.lineWidth * 0.5)
        
        let newRadius = CGFloat(radius() - halfLineWidth)
        
        var radiansForRoundedHead :Double = 0.0
        
        if (roundedHead) {
            radiansForRoundedHead = Circle.arcAngle(Double(lineWidth * 0.5), radius: Double(radius()))
        }
        
        let bezier = UIBezierPath(arcCenter:center,
            radius: newRadius,
            startAngle:CGFloat(startAngle + radiansForRoundedHead ),
            endAngle:CGFloat(endAngle - radiansForRoundedHead ),
            clockwise: true)
        
        
         step.shapeLayer?.path = bezier.CGPath
         step.shapeLayer?.backgroundColor = UIColor.clearColor().CGColor
         step.shapeLayer?.fillColor = nil
         step.shapeLayer?.strokeColor = (step.gradient) ? UIColor.blackColor().CGColor : color.CGColor
         step.shapeLayer?.lineWidth = self.lineWidth
        
         if(roundedHead){
            step.shapeLayer?.lineCap = "round"
         }
        
         step.shapeLayer?.strokeStart = 0.0
         step.shapeLayer?.strokeEnd = 0.0
        
        if(self.shadowLayer){
            
             step.shapeLayer?.shadowColor  = color.darkerColor(1.0).CGColor
             step.shapeLayer?.shadowRadius = self.shadowRadius
             step.shapeLayer?.shadowOpacity = self.shadowOpacity
             step.shapeLayer?.shadowOffset = self.shadowOffset
        }
        
        if let g = step.gradientLayer? {
            
           g.mask = step.shapeLayer
          
            if(self.layer.sublayers != nil){
                self.layer.insertSublayer(g, above:self.imageLayer)
            }else{
              self.layer.addSublayer( g)
            }
        }else{
            self.layer.addSublayer(step.shapeLayer)
        }
        
        if let wcolor = step.wellColor? {
            
            step.wellLayer = CAShapeLayer()
            
            step.wellLayer?.path = bezier.CGPath
            
            step.wellLayer?.backgroundColor = UIColor.clearColor().CGColor
            step.wellLayer?.fillColor   = nil
            step.wellLayer?.strokeColor = wcolor.CGColor
            step.wellLayer?.lineWidth = self.lineWidth
            
            if(roundedHead){
                step.wellLayer?.lineCap = "round"
            }
            
            if(self.layer.sublayers != nil){
                self.layer.insertSublayer(step.wellLayer, above:self.imageLayer)
            }else{
                self.layer.addSublayer(step.wellLayer)
            }
        }
    }
 
    private func removeAllSublayersFromSuperlayer()
    {
        for var i = 0; i < self.dataSteps.count ; ++i
        {
            let step = (self.dataSteps[i] as OMStepData)
            
            // Remove the gradient layer

            step.gradientLayer?.removeFromSuperlayer()
            
            step.wellLayer?.removeFromSuperlayer()
            
            step.shapeLayer?.removeFromSuperlayer()
            
            step.imageLayer?.removeFromSuperlayer()
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.removeAllSublayersFromSuperlayer()
        
        // Recalculate the layers.
        
        let r = Double(radius() * 2.0)  // avoid to divide by 2 each s0 element calculation
        
        for var index = 0; index < self.dataSteps.count ; ++index
        {
            let step = self.dataSteps[index] as OMStepData
            
            let halfLineWidth = (self.lineWidth * 0.5)
            
            let point  = Circle.arcPoint(step.startAngle,radius: Double(radius() - halfLineWidth),center:self.center);
            
            var frame:CGRect = CGRectZero
            
            step.hypotAngleHalf = 0.0
            
            if let img = step.image? {
                let h = Double(img.size.hypot() );
                step.hypotAngleHalf = Double(h / r)
                frame = CGRect(origin: CGPoint(x:point.x - img.size.width / 2, y:point.y - img.size.height / 2),size:img.size)
            }
            
            if(index + 1 < self.dataSteps.count){
                let nextStep = self.dataSteps[index+1] as OMStepData
                setupLayers(step, startAngle: step.startAngle + step.hypotAngleHalf,
                    endAngle: step.endAngle - nextStep.hypotAngleHalf,
                    color: step.color)
            }else{
                let firstStep = self.dataSteps.firstObject as OMStepData
                setupLayers(step, startAngle:step.startAngle + step.hypotAngleHalf,
                    endAngle: step.endAngle - firstStep.hypotAngleHalf,
                    color: step.color)
            }
            
            if let img = step.image? {
                step.imageLayer = CALayer()!
                step.imageLayer?.frame = frame
                step.imageLayer?.contents = step.image?.getGrayScale()?.CGImage
                self.layer.insertSublayer(step.imageLayer,above:self.imageLayer!)
            }
        }
    }
}
