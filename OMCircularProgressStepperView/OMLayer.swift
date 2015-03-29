//
//  OMLayer.swift
//  ExampleSwift
//
//  Created by Jorge Ouahbi on 26/3/15.
//  Copyright (c) 2015 Jorge Ouahbi. All rights reserved.
//
//  Description:
//  Simple derived CALayer class used as base class
//
//  Versión 0.1 (29-3-2015)
//
//  Added context flip
//

import UIKit


class OMLayer: CALayer {
    
    /// Radians
    
//    var rotateAngle:Double = 0.0 //-M_PI / 2.f
//    {
//        didSet{
//            setNeedsDisplay()
//        }
//    }
    
    override init()
    {
        super.init()
        self.contentsScale = UIScreen.mainScreen().scale
        self.needsDisplayOnBoundsChange = true;
        
        
        //DEBUG
//        self.borderColor = UIColor.yellowColor().CGColor!
//        self.borderWidth = 1
    }
    
    
    override init!(layer: AnyObject!) {
        super.init(layer: layer)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
//    func restoreRotatedContextIfNeed(context:CGContext!)
//    {
//        assert(context != nil, "nil context")
//        if(context == nil){
//            return
//        }
//        
//        if(self.rotateAngle != 0.0) {
//            
//            // Restore Graphic State for context rotation
//            
//            CGContextRestoreGState(context);
//            
//            CGContextRestoreGState(context);
//        }
//    }
    
    
    func flipContextIfNeed(context:CGContext!)
    {
        // Core Text Coordinate System and Core Graphics are OSX style
        
        #if os(iOS)
            CGContextTranslateCTM(context, 0, self.bounds.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
        #endif
    }
    
//    func rotateTransfom(rect:CGRect) -> CGAffineTransform!
//    {
//        assert(self.rotateAngle != 0.0, "cannot rotate 0 degrees")
//        
//        if(self.rotateAngle == 0.0) {
//            return CGAffineTransformIdentity;
//        }
//        
//        var trans:CGAffineTransform = CGAffineTransformMakeTranslation(rect.size.width / 2.0, rect.size.height / 2.0)
//    
//        trans = CGAffineTransformRotate(trans, CGFloat(rotateAngle));
//        trans = CGAffineTransformTranslate(trans,-rect.size.width / 2.0, -rect.size.height / 2.0)
//        
//        return trans;
//    }
//    
//    /// Transform (rotate) context
//    
//    func rotateContextIfNeed(context:CGContext!)
//    {
//        assert(context != nil, "nil context")
//        
//        if(context == nil){
//            return
//        }
//        
//        if(self.rotateAngle != 0.0){
//            
//            //DEBUG
//            //println("rotating \(self.name) \(self.rotateAngle.radiansToDegrees()) degrees")
//            
//            CGContextSaveGState(context); // save Graphic State for context rotation
//        
//            let trans = rotateTransfom(self.bounds)
//            
//            CGContextConcatCTM(context, trans);
//            
//            CGContextSaveGState(context);
//        }
//    }
    
    
    func animateKeyPath(keyPath : String, fromValue : Double, toValue:Double, beginTime:NSTimeInterval,duration:NSTimeInterval, delegate:AnyObject?)
    {
        let animation = CABasicAnimation(keyPath:keyPath);
        
        var currentValue: AnyObject? = self.presentationLayer()?.valueForKey(keyPath)
        
        if (currentValue == nil) {
            currentValue = fromValue
        }
        
        animation.fromValue = currentValue
        animation.toValue = toValue
        animation.delegate = delegate
        
        if(duration > 0.0){
            animation.duration = duration
        }
        if(beginTime > 0.0){
            animation.beginTime = beginTime
        }
        
        animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear)
        animation.setValue(self,forKey:keyPath)
        self.addAnimation(animation, forKey:keyPath)
        
        ///
        
        self.setValue(toValue,forKey:keyPath)
    }
    
    //DEBUG
    override func display() {
        super.display()
        if(self.bounds.isEmpty) {
            println("WARNING: empty layer.")
        }
    }
}
