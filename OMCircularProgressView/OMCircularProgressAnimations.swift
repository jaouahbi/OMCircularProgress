//
//  OMCircularProgressAnimations.swift
//  Test
//
//  Created by Jorge on 26/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import Foundation


extension OMCircularProgress
{
    /// MARK: CAAnimation delegate
    
    override func animationDidStart(anim: CAAnimation){
        if DEBUG_ANIMATIONS {
            print("[.] animationDidStart:\((anim as! CABasicAnimation).keyPath) : \((anim as! CABasicAnimation).beginTime) ")
        }
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool){
        if DEBUG_ANIMATIONS {
            print("[.] animationDidStop:\((anim as! CABasicAnimation).keyPath)")
        }
    }
    
    //
    // Animate the shapeLayer and the image for the step
    //
    
    func stepAnimation(step:OMStepData, progress:Double) {
        
        // Remove all animations
        
        step.shapeLayer.removeAllAnimations()
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.fromValue =  0.0
        animation.toValue   =  progress
        
        animation.duration = (animationDuration / Double(numberOfSteps)) * progress
        
        animation.removedOnCompletion = false
        animation.additive = true
        animation.fillMode = kCAFillModeForwards
        animation.delegate = self
        
        if (progressStyle == .SequentialProgress) {
            
            // Current animation beginTime
            
            if  (newBeginTime != 0)  {
                animation.beginTime = newBeginTime
            }  else  {
                animation.beginTime = beginTime
            }
            
            // Calculate the next animation beginTime
            
            newBeginTime = animation.beginTime + animation.duration
        }
        
        //
        // Add animation to the stroke of the shape layer.
        //
        
        step.shapeLayer.addAnimation(animation, forKey: "strokeEnd")
        
        if let shapeLayerBorder = step.shapeLayerBorder {
            shapeLayerBorder.addAnimation(animation, forKey: "strokeEnd")
        }
        
        if let imgLayer = step.imageLayer {
            
            // Remove all animations
            imgLayer.removeAllAnimations()
            
            // Add animation to the image
            
            imgLayer.animateProgress(0.0,
                toValue:  progress,
                beginTime: animation.beginTime,
                duration: animation.duration ,
                delegate: self)
        }
    }
}