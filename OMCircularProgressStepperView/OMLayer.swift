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
//  Added
//

import UIKit


class OMLayer: CALayer {
    
    /// Radians
    
    var angleOrientation:Double = 0.0
    {
        didSet {
            
            let affineTransform = CGAffineTransformMakeRotation(CGFloat(angleOrientation))
            
            setAffineTransform(affineTransform)
            
            setNeedsDisplay()
        }
    }
    
    override init()
    {
        super.init()
        self.contentsScale = UIScreen.mainScreen().scale
        self.needsDisplayOnBoundsChange = true;
        
        // DEBUG
//        self.borderColor = UIColor.yellowColor().CGColor!
//        self.borderWidth = 1
    }
    
    
    override init!(layer: AnyObject!) {
        super.init(layer: layer)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    
    func flipContextIfNeed(context:CGContext!)
    {
        // Core Text Coordinate System and Core Graphics are OSX style
        
        #if os(iOS)
            CGContextTranslateCTM(context, 0, self.bounds.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
        #endif
    }
    
    
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
