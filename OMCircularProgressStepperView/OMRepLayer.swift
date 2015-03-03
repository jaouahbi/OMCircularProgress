//
//  OMRepLayer.swift
//  ExampleSwift
//
//  Created by Jorge on 3/3/15.
//  Copyright (c) 2015 none. All rights reserved.
//

import UIKit
import CoreText
import CoreFoundation

class OMARepLayer : CAReplicatorLayer {
    
    var instanceLayer:CALayer!
    var alphaOffset:Bool = false
    var redOffset:Bool = true
    var greenOffset:Bool = false
    var blueOffset:Bool = false
    let lengthMultiplier: CGFloat = 3.0
    let layerWidth:CGFloat = 4.0
    let whiteColor = UIColor.whiteColor().CGColor
    let fadeAnimation = CABasicAnimation(keyPath: "opacity")

    
    convenience init(rect:CGRect, count : Int) {
        
        self.init()
        
        self.frame = rect
        self.instanceCount = count
        self.preservesDepth = false
        self.instanceColor = whiteColor
        self.instanceRedOffset = redOffset ? 0.0 : -0.05
        self.instanceGreenOffset = greenOffset ? 0.0 : -0.05
        self.instanceBlueOffset = blueOffset ? 0.0 : -0.05
        self.instanceAlphaOffset = alphaOffset ? -1.0 / Float(count) : 0.0
        let angle = Float(M_PI * 2.0) / Float(count)
        self.instanceTransform = CATransform3DMakeRotation(CGFloat(angle), 0.0, 0.0, 1.0)
    }
    
    func setUpLayerFadeAnimation() {
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.repeatCount = Float(Int.max)
    }
    
   convenience init(rect:CGRect, count : Int, instanceLayer:CALayer?) {
        self.init(rect: rect, count: count)
    
        if(instanceLayer == nil){
            self.instanceLayer = CALayer()
        }
    
        let midX = CGRectGetMidX(self.bounds) - layerWidth / 2.0
        self.instanceLayer.frame = CGRect(x: midX, y: 0.0, width: layerWidth, height: layerWidth * lengthMultiplier)
        self.instanceLayer.backgroundColor = whiteColor
    
        self.addSublayer(self.instanceLayer)
        setUpLayerFadeAnimation()
        self.newInstanceDelay(1.0)
    }
    
    func newInstanceCount(count:Int) {
        self.instanceCount = count
        self.instanceAlphaOffset = alphaOffset ? -1.0 / Float(count) : 0.0
    }
    
    func newInstanceDelay(instanceDelay:Float)
    {
        if instanceDelay > 0.0 {
            self.instanceDelay = CFTimeInterval(instanceDelay / Float(self.instanceCount))
            self.setLayerFadeAnimation()
        } else {
            self.instanceDelay = 0.0
            self.instanceLayer.opacity = 1.0
            self.instanceLayer.removeAllAnimations()
        }
    }
    
    
    func newLayerSize(layerSize:CGFloat) {
        instanceLayer.bounds = CGRect(origin: CGPointZero, size: CGSize(width: layerSize, height: layerSize * lengthMultiplier))
    }


    func setLayerFadeAnimation() {
        instanceLayer.opacity = 0.0
        fadeAnimation.duration = CFTimeInterval(self.instanceDelay * CFTimeInterval(self.instanceCount))
        instanceLayer.addAnimation(fadeAnimation, forKey: "FadeAnimation")
    }
    
}
