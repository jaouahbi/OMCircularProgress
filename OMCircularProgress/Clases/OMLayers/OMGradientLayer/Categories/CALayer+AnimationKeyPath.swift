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
//  CALayer+AnimationKeyPath.swift
//
//  Created by Jorge Ouahbi on 26/3/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//
// v1.0

import UIKit

public extension CALayer {

    // MARK: - CALayer Animation Helpers
    
    public func animationActionForKey(_ event:String!) -> CABasicAnimation! {
        let animation = CABasicAnimation(keyPath: event)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = self.presentation()!.value(forKey: event);
        return animation
    }
    
    public func animateKeyPath(_ keyPath : String,
                        fromValue : AnyObject?,
                        toValue:AnyObject?,
                        beginTime:TimeInterval,
                        duration:TimeInterval,
                        delegate:AnyObject?)
    {
        let animation = CABasicAnimation(keyPath:keyPath);
        
        var currentValue: AnyObject? = self.presentation()?.value(forKey: keyPath) as AnyObject?
        
        if (currentValue == nil) {
            currentValue = fromValue
        }
        
        animation.fromValue = currentValue
        animation.toValue   = toValue
        animation.delegate  = delegate as! CAAnimationDelegate?
        
        if(duration > 0.0){
            animation.duration = duration
        }
        if(beginTime > 0.0){
            animation.beginTime = beginTime
        }
        
        animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear)
        animation.setValue(self,forKey:keyPath)
        self.add(animation, forKey:keyPath)
        self.setValue(toValue,forKey:keyPath)
    }
}
