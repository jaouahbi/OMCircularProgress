//
//  OMProgressImageLayer.swift
//
//  Created by Jorge Ouahbi on 26/3/15.
//  Copyright (c) 2015 Jorge Ouahbi. All rights reserved.
//
//  0.1 (29-03-2015) 
//      Added radial progress, grayscale mode and direction,
//      showing/hiding and update shadow copy layer options.
//      Now render the image in context
//      Update the layer when beginRadians is changed if the type is Circular
//

#if os(iOS)
    import UIKit
    #elseif os(OSX)
    import AppKit
#endif


public enum OMProgressType : Int
{
    case OMHorizontal
    case OMVertical
    case OMCircular
    case OMRadial
}

private struct OMProgressImageLayerProperties {
    static var Progress = "progress"
}

class OMProgressImageLayer: OMLayer
{
    // progress showing image or hiding
    
    var progressShowing:Bool = true
    {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // progress direction
    
    var clockwise:Bool = true
    {
        didSet {
            setNeedsDisplay()
        }
    }
    var image:UIImage?       = nil
    {
        didSet {
            setNeedsDisplay()
        }
    }
    var progress: Double     = 0.0
    {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // -90 degrees
    
    var beginRadians: Double = -M_PI_2
    {
        didSet {
            if(self.type == .OMCircular) {
                setNeedsDisplay()
            }
        }
    }
    
    var type:OMProgressType  = OMProgressType.OMVertical
        {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var grayScale:Bool = true
        {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    func animateProgress(fromValue:Double,toValue:Double,beginTime:NSTimeInterval,duration:NSTimeInterval, delegate:AnyObject?)
    {
        self.animateKeyPath(OMProgressImageLayerProperties.Progress,
            fromValue:fromValue,
            toValue:toValue,
            beginTime:beginTime,
            duration:duration,
            delegate:delegate)
    }
    
    
    override init(){
        super.init()
    }
    
    convenience init(image:UIImage){
        self.init()
        self.image = image
    }
    
    override init!(layer: AnyObject!) {
        super.init(layer: layer)
        if let other = layer as? OMProgressImageLayer {
            self.progress        = other.progress
            self.image           = other.image
            self.type            = other.type
            self.beginRadians    = other.beginRadians
            self.grayScale       = other.grayScale
            self.progressShowing = other.progressShowing
            self.clockwise       = other.clockwise
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override class func needsDisplayForKey(event: String!) -> Bool
    {
        if(event == OMProgressImageLayerProperties.Progress){
            return true
        }
        return super.needsDisplayForKey(event)
    }
    
    override func actionForKey(event: String!) -> CAAction!
    {
        if(event == OMProgressImageLayerProperties.Progress){
            let animation = CABasicAnimation(keyPath: event)
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.fromValue = self.presentationLayer().valueForKey(event);
            
            return animation
        }
        return super.actionForKey(event)
    }
    
    override func drawInContext(context: CGContext!) {

        var newImage:UIImage? = nil
        var newProgress:Double = self.progress
        
        if let presentationLayer: AnyObject = self.presentationLayer(){
            newProgress = presentationLayer.progress
        }
        
        // Core Text Coordinate System and Core Graphics are OSX style
        
        self.flipContextIfNeed(context)
        
        //self.rotateContextIfNeed(context)
        
//        var trans:CGAffineTransform = CGAffineTransformIdentity
//        
//        if(self.rotateAngle != 0.0){
//            trans = CGAffineTransformMakeRotation(CGFloat(self.rotateAngle))
//        }
        
        if(newProgress > 0)
        {
            switch(self.type)
            {
            case .OMRadial:
                
                let radius = image!.size.max() * CGFloat(newProgress)
                
                let center = image!.size.center()
                
                let path = UIBezierPath(arcCenter: center,
                    radius: radius ,
                    startAngle: 0,
                    endAngle: CGFloat(M_PI * 2.0),
                    clockwise: true)
                
                path.addLineToPoint(center)
                path.closePath()
                
                newImage = self.image!.maskImage(path)
                break
                
                
            case .OMCircular:
                
                let radius = image!.size.max()
                
                let center = image!.size.center()
                
                let startAngle = beginRadians
                
                let endAngle:Double
                
                if(self.clockwise == false){
                    endAngle  =  Double(M_PI * 2.0 * (1.0 - newProgress) + beginRadians)
                } else {
                    endAngle  =  Double(M_PI * 2.0 * newProgress + beginRadians)
                }
                
                let path = UIBezierPath(arcCenter: center,
                    radius: radius ,
                    startAngle: CGFloat(startAngle),
                    endAngle: CGFloat(endAngle),
                    clockwise: self.progressShowing)
                
                path.addLineToPoint(center)
                path.closePath()
                
                newImage = self.image!.maskImage(path)
                
                break;
                
            case .OMVertical:
                
                let newHeight = Double(self.bounds.size.height) * newProgress
                
                let path = UIBezierPath(rect: CGRect(x:0,y:0,width: self.bounds.size.width, height:CGFloat(newHeight)))
                
                newImage = self.image!.maskImage(path)
                break;
                
            case .OMHorizontal:
                
                let newWidth = Double(self.bounds.size.width) * newProgress
                
                let path = UIBezierPath(rect: CGRect(x:0,y:0,width: CGFloat(newWidth),height:self.bounds.size.height))
                
                newImage = self.image!.maskImage(path)
                
                break;
            }
        }
        

        
        if(newImage != nil) {
            
            let rect = CGRectMake(0, 0, newImage!.size.width, newImage!.size.height);
            
            if ( grayScale ){
                CGContextDrawImage(context, rect, self.image?.grayScaleImage().blendImage(newImage!).CGImage)
            }else{
                CGContextDrawImage(context, rect, newImage!.CGImage)
            }
        }
        
        //self.restoreRotatedContextIfNeed(context)
 
        
        // DEBUG
        // println("progress: \(newProgress)")
    }
}