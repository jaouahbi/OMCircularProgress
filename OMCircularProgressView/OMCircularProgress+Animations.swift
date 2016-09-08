
//
//    Copyright 2015 - Jorge Ouahbi
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//


//
//  OMCircularProgressAnimations.swift
//
//  Created by Jorge Ouahbi on 26/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit


extension OMCircularProgress : CAAnimationDelegate
{
    /// MARK: CAAnimation delegate
    
    func animationDidStart(_ anim: CAAnimation){
        SpeedLog.print("START:\((anim as! CABasicAnimation).keyPath) : \((anim as! CABasicAnimation).beginTime) ")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool){
        if flag {
            SpeedLog.print("END:\((anim as! CABasicAnimation).keyPath)")
        }
    }
    
    //
    // Animate the shapeLayer and the image for the step
    //
    
    func stepAnimation(_ step:OMStepData, progress:Double) {
        
        assert(progress >= 0);
        
        // Remove all animations
        step.shapeLayer.removeAllAnimations()
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.fromValue =  0.0
        animation.toValue   =  progress
        
        animation.duration = (animationDuration / Double(numberOfSteps)) * progress
        
        animation.isRemovedOnCompletion = false
        animation.isAdditive = true
        animation.fillMode = kCAFillModeForwards
        animation.delegate = self
        
        if (progressStyle == .sequentialProgress) {
            
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
        
        step.shapeLayer.add(animation, forKey: "strokeEnd")
        
        if let shapeLayerBorder = step.shapeLayerBorder {
            shapeLayerBorder.add(animation, forKey: "strokeEnd")
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
