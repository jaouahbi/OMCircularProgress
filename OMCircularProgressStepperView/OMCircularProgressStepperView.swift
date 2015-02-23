//
//  OMCircularProgressView.swift
//
//  Created by Jorge Ouahbi on 19/1/15.
//  Copyright (c) 2015 Jorge Ouahbi. All rights reserved.
//


import UIKit


let DEBUG_LAYERS = false


func clamp<T: Comparable>(value:T,lower:T,upper:T) -> T{
    return min(upper, max(lower, value))
}


enum ImageAlign : Int
{
    case AlignCenter
    case AlignMid
    case AlignBorder
    init()
    {
        self = AlignMid
    }
}


class OMStepData : DebugPrintable
{
    var startAngle:Double = 0.0
    var endAngle:Double = 0.0
    var hypotAngleHalf:Double = 0.0          // angle of arclength of image hypotenuse in radians

    var shapeLayer:CAShapeLayer?
    var color:UIColor!;
    var gradient:Bool = true
    var gradientLayer:CAGradientLayer?       // optional gradient layer mask
    
    var wellLayer:CAShapeLayer?              //
    var wellColor:UIColor?
    
    var imageLayer:CALayer?                  // optional image layer
    var image : UIImage?                     // optional image
    var imageOnTop : Bool = false
    var imageAlign : ImageAlign = .AlignBorder

    
    required convenience init(startAngle:Double,
        percent:Double,
        color:UIColor!,
        wellColor:UIColor? = UIColor.lightGrayColor(),
        image:UIImage? = nil,
        gradient: Bool = true)
    {
        self.init(startAngle:startAngle,
            endAngle: startAngle + (OMCircle.RadiansInCircle * percent),
            color:color,
            image:image,gradient:gradient)
    }
    
    init(startAngle:Double,
        endAngle:Double,
        color:UIColor!,
        wellColor:UIColor? = UIColor.lightGrayColor(),
        image:UIImage? = nil,
        gradient: Bool = true)
    {
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.color = color
        self.image = image
        self.gradient = gradient;
        self.wellColor = wellColor
    }
    
    var debugDescription : String {
        let degreeS = round(startAngle.radiansToDegrees());
        let degreeE = round(endAngle.radiansToDegrees());
        
        return "from \(degreeS) to \(degreeE) color \(color) well color \(wellColor) gradient \(gradient) with image \(image)  hypotAngle \(hypotAngleHalf)"
    }
}

@IBDesignable class OMCircularProgressStepperView: UIView {
    
    private(set) var dataSteps: NSMutableArray = []
    private var maxImageSize : CGSize = CGSizeZero
    private var newBeginTime: NSTimeInterval = 0;
    private var imageLayer:CALayer?                // center image layer
    
    var roundedHeadThicknessThreshold: CGFloat = 0.2
    var startAngle : Double = -90.degreesToRadians()
    var animationDuration : NSTimeInterval = 1.0
    
    var progress: Double = 0.0 {
        didSet {
            self.animateProgress()
        }
    }
    
    var roundedHead : Bool = false {
        didSet{
            roundedHead = ( self.thicknessRatio < self.roundedHeadThicknessThreshold );
            setNeedsLayout();
        }
    }

    var radius : CGFloat {
        get {
            return (bounds.size.min() * 0.5) - (maxImageSize.max() * 0.5) ;
        }
    }
    
    var lineWidth : CGFloat {
        get {
            return thicknessRatio * radius
        }
    }
    
    @IBInspectable var thicknessRatio : CGFloat = 0.1
    {
        didSet {
            thicknessRatio = clamp(thicknessRatio, 0.0, 1.0)
            setNeedsLayout();
        }
    }
    
    
    @IBInspectable var image: UIImage?
    {
        didSet {
            if image != nil {
                imageLayer = CALayer()
                //imageLayer?.contents = image!.getGrayScale()?.CGImage
                imageLayer?.contents = image!.CGImage
            }
        }
    }


    required override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func animateProgress()
    {
        //DEBUG
        //println("begin animateProgress (progress: \(progress))")

        if(progress == 0.0) {
            return;
        }
        
        let numberOfSteps = self.dataSteps.count
        
        //DEBUG
        //precondition(progress <= Double(numberOfSteps),"unexpected progress \(progress) max \(numberOfSteps) ")
        
        let claped_progress = clamp(progress, 0.0, Double(numberOfSteps))
        
        CATransaction.begin()
        
        let stepsDone   = Int(self.progress);
        let curStep = self.progress - floor(self.progress);
        
        for var index = 0; index < Int(numberOfSteps) ; ++index
        {
            //DEBUG
            //println("for \(index) of \(numberOfSteps) in  \(progress) :  done:\(stepsDone) current:\(curStep)")
            
            if(index < stepsDone) {
                self.setProgressAtIndex(Int(index), progress:1.0)
            } else {
                self.setProgressAtIndex(Int(index), progress: curStep)
                break;
            }
        }
        
        CATransaction.commit()
    }
    
    func setProgressAtIndex(index:Int, progress:Double) {
        
        //DEBUG
        //println("begin setProgressAtIndex (index : \(index) progress: \(progress))")
        
        let step = self.dataSteps[index] as! OMStepData
        
        if let layer = step.shapeLayer {
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            
            animation.fromValue =  0.0
            animation.toValue   =  progress

            animation.duration = self.animationDuration * progress

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
            
        if image != nil {
            maxImageSize = image!.size.max(maxImageSize)
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
        
        if (image != nil) {
            maxImageSize = image!.size.max(maxImageSize)
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
            startAngle  = (self.dataSteps[self.dataSteps.count - 1] as! OMStepData).endAngle
        }
        return startAngle;
    }


    private func setupLayers(step:OMStepData, startAngle:Double, endAngle:Double, color:UIColor)
    {
        
        if (step.gradient) {
            
            // Setup the gradient layer
            
            step.gradientLayer =  CAGradientLayer()
            
            if ( DEBUG_LAYERS ){
                step.gradientLayer?.name = "step \(self.dataSteps.indexOfObject(step)) gradient"
            }
            
            step.gradientLayer?.frame = frame
            
            step.gradientLayer?.locations = [0.0, 1.0]
            
            let colorTop: AnyObject = color.lighterColor(1.0).CGColor
            let colorBottom: AnyObject = color.darkerColor(7.0).CGColor
            
            let arrayOfColors: [AnyObject] = [colorTop, colorBottom]
            
            step.gradientLayer?.colors = arrayOfColors
        }
        
        step.shapeLayer = CAShapeLayer()
        
        if ( DEBUG_LAYERS ){
            step.shapeLayer?.name = "step \(self.dataSteps.indexOfObject(step)) shape"
        }
    
        
        var radiansForRoundedHead :Double = 0.0
        
        if (roundedHead) {
            radiansForRoundedHead = OMCircle.arcAngle(Double(lineWidth * 0.5), radius: Double(radius))
        }
        
        let newRadius = CGFloat(radius - (self.lineWidth * 0.5))
        
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
        
        if (roundedHead) {
            step.shapeLayer?.lineCap = "round"
        }
        
        step.shapeLayer?.strokeStart = 0.0
        step.shapeLayer?.strokeEnd = 0.0
    
        
        if step.gradientLayer != nil {
            
            // When setting the mask to a new layer, the new layer must have a nil superlayer
            
            step.gradientLayer?.mask = step.shapeLayer
            
            if self.layer.sublayers != nil {
                self.layer.insertSublayer(step.gradientLayer, above:self.imageLayer)
            }else{
                self.layer.addSublayer(step.gradientLayer)
            }
        }else{
            self.layer.addSublayer(step.shapeLayer)
        }
        
        if let stepWellColor = step.wellColor {
            
            step.wellLayer = CAShapeLayer()
            if ( DEBUG_LAYERS ){
                step.wellLayer?.name = "step \(self.dataSteps.indexOfObject(step)) well"
            }
            
            step.wellLayer?.path = bezier.CGPath
            
            step.wellLayer?.backgroundColor = UIColor.clearColor().CGColor
            step.wellLayer?.fillColor   = nil
            step.wellLayer?.strokeColor = stepWellColor.CGColor
            step.wellLayer?.lineWidth = self.lineWidth
            
            if(roundedHead){
                step.wellLayer?.lineCap = "round"
            }
            
            if(self.layer.sublayers != nil){
                self.layer.insertSublayer(step.wellLayer, atIndex:0)
            }else{
                self.layer.addSublayer(step.wellLayer)
            }
        }
    }
 
    private func removeAllSublayersFromSuperlayer()
    {
        for var i = 0; i < self.dataSteps.count ; ++i
        {
            let step = (self.dataSteps[i] as! OMStepData)
            
            // Remove the gradient layer

            step.gradientLayer?.removeFromSuperlayer()
            
            step.wellLayer?.removeFromSuperlayer()
            
            step.imageLayer?.removeFromSuperlayer()
            
            step.shapeLayer?.removeFromSuperlayer()
        }
        
        self.imageLayer?.removeFromSuperlayer()
    }
    
    func dumpLayers(level:UInt ,layer:CALayer)
    {
        for var index = 0; index < layer.sublayers?.count ; ++index{
    
            let l = layer.sublayers[index] as! CALayer
    
            println("[\(level)] \(l.name)")
    
            if(l.sublayers != nil){
                dumpLayers(level+1, layer: l);
            }
        }
    }

    
    override func layoutSubviews()
    {
        //DEBUG
        //println("[\(self)] enter layoutSubviews()")
        
        super.layoutSubviews()

        self.removeAllSublayersFromSuperlayer()
        
        if ( DEBUG_LAYERS ){
            self.dumpLayers(0,layer:self.layer)
        }
        
        // Recalculate the layers.
        
        let r = Double(radius * 2.0)  // avoid to divide by 2 each s0 element calculation
        
        for var index = 0; index < self.dataSteps.count ; ++index
        {
            let step = self.dataSteps[index] as! OMStepData
            
            var frame:CGRect = CGRectZero
            
            step.hypotAngleHalf = 0.0
            
            if step.image != nil {
                
                let halfLineWidth = (self.lineWidth * 0.5)
                
                var newRadius:Double = Double(radius - halfLineWidth)
                
                if(step.imageAlign == .AlignMid) {
                    
                }else if(step.imageAlign == .AlignCenter){
                
                    if(self.image != nil){
                        newRadius = Double( self.image!.size.max() )
                    }else{
                        newRadius = Double(maxImageSize.max())
                    }
                    
                }else if(step.imageAlign == .AlignBorder){
                    
                    newRadius = Double( radius )
                
                }else{
                    
                    assertionFailure("Unexpected image align \(step.imageAlign)")
                    
                }
                
                let c = OMCircle(center: self.center,radius:newRadius);

                
                let stepImagePoint  = c.arcPoint( step.startAngle);
          
                
                let h = Double(step.image!.size.hypot() );
                
                step.hypotAngleHalf = Double(h / r)
                
                
                frame = CGRect(origin: CGPoint(x:stepImagePoint.x - step.image!.size.width / 2,
                    y:stepImagePoint.y - step.image!.size.height / 2),
                    size:step.image!.size)
            }
            
            
            if(step.imageOnTop == false){
                if(index + 1 < self.dataSteps.count){
                    let nextStep = self.dataSteps[index+1] as! OMStepData
                    setupLayers(step, startAngle: step.startAngle + step.hypotAngleHalf,
                        endAngle: step.endAngle - nextStep.hypotAngleHalf,
                    color: step.color)
                }else{
                    let firstStep = self.dataSteps.firstObject as! OMStepData
                    setupLayers(step, startAngle:step.startAngle + step.hypotAngleHalf,
                        endAngle: step.endAngle - firstStep.hypotAngleHalf,
                        color: step.color)
                }
            } else {
                setupLayers(step, startAngle:step.startAngle,
                    endAngle: step.endAngle,
                    color: step.color)
            }
            
            if let img = step.image {
                step.imageLayer = CALayer()!
                step.imageLayer?.frame = frame
                //step.imageLayer?.contents = step.image?.getGrayScale()?.CGImage
                step.imageLayer?.contents = step.image?.CGImage
            }
        
        }
        
        // Add the center image
        if (self.imageLayer != nil){
            imageLayer!.frame = CGRect(origin:
                CGPoint(x:center.x -  self.image!.size.width * 0.5,
                    y:center.y -  self.image!.size.height * 0.5),
                size: self.image!.size)
            
            if ( DEBUG_LAYERS ){
                self.imageLayer!.name = "center image"
            }
            
            self.layer.addSublayer(self.imageLayer)
        }
        
        // Add all steps image
        for var index = 0; index < self.dataSteps.count ; ++index{
            let step = self.dataSteps[index] as! OMStepData
            if(step.imageLayer != nil){
                if ( DEBUG_LAYERS ){
                    step.imageLayer!.name = "step \(index) image"
                }
                self.layer.addSublayer(step.imageLayer)
            }
        }
        
        self.animateProgress();
    }
}
