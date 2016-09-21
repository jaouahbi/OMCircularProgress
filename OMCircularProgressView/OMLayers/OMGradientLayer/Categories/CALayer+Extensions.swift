//
//  CALayer+Extensions.swift
//
//  Created by Jorge Ouahbi on 24/8/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

import UIKit

extension CALayer
{
    func animatingRefreshes(_ flag:Bool) {
        if(flag) {
            self.actions = nil;
        } else {
            // Disable animating view refreshes
            self.actions = [
                "position"      :    NSNull(),
                "bounds"        :    NSNull(),
                "contents"      :    NSNull(),
                "shadowColor"   :    NSNull(),
                "shadowOpacity" :    NSNull(),
                "shadowOffset"  :    NSNull() ,
                "shadowRadius"  :    NSNull()]
        }
    }
}

extension CALayer
{
    /// Radians
    
    func concatTransformRotationZ(_ z:Double = 0.0) {
        self.transform = CATransform3DConcat(self.transform,  CATransform3DMakeRotation(CGFloat(z), 0.0, 0.0, 1.0))
    }
    func setTransformRotationZ(_ z:Double = 0.0) {
        self.transform = CATransform3DMakeRotation(CGFloat(z), 0.0, 0.0, 1.0)
    }
    
    func getTransformRotationZ() -> Double {
        return atan2(Double(transform.m12), Double(transform.m11))
    }
}


