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
//  OMGradientLayer.swift
//
//  Created by Jorge Ouahbi on 4/3/15.
//

import UIKit


 private struct OMGradientLayerProperties {
    static var startCenter = "startCenter"
    static var startRadius = "startRadius"
    static var endCenter = "endCenter"
    static var endRadius = "endRadius"
    static var colors = "colors"
    static var locations = "locations"
};


let kOMGradientLayerRadial: String = "radial"

class OMGradientLayer : CAGradientLayer
{
    var startCenter: CGPoint = CGPoint(x:0,y:0)
    var startRadius: CGFloat = 0
    var endCenter: CGPoint = CGPoint(x:0,y:0)
    var endRadius: CGFloat = 0
    //var options: CGGradientDrawingOptions = CGGradientDrawingOptions(kCGGradientDrawsAfterEndLocation)
    var options: CGGradientDrawingOptions = CGGradientDrawingOptions(kCGGradientDrawsBeforeStartLocation)
    

    
    private(set) var gradientRadial:CGGradientRef?
    
  
    override var colors: [AnyObject]!
    {
        didSet {
            if(self.type == kOMGradientLayerRadial){
                setUpRadial()
            }
        }
    }
    
    override var locations : [AnyObject]!
    {
        didSet {
            if(self.type == kOMGradientLayerRadial){
                setUpRadial()
            }
        }
    }

    override class func needsDisplayForKey(event: String!) -> Bool
    {
        if(event == OMGradientLayerProperties.startCenter ||
            event == OMGradientLayerProperties.startRadius ||
            event == OMGradientLayerProperties.locations ||
            event == OMGradientLayerProperties.colors     ||
            event == OMGradientLayerProperties.endCenter  ||
            event == OMGradientLayerProperties.endRadius)
        {
            return true
        }
        
        return CALayer.needsDisplayForKey(event)
    }
    
    
    override func actionForKey(event: String!) -> CAAction!
    {
        if(event == OMGradientLayerProperties.startCenter ||
            event == OMGradientLayerProperties.startRadius ||
            event == OMGradientLayerProperties.locations ||
            event == OMGradientLayerProperties.colors     ||
            event == OMGradientLayerProperties.endCenter  ||
            event == OMGradientLayerProperties.endRadius)
        {
            let animation = CABasicAnimation(keyPath: event)
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.fromValue = self.presentationLayer()?.valueForKey(event);
            return animation
            
        }
        return super.actionForKey(event)
    }
    
    
    private func setUpRadial()
    {
        var colorSpace: CGColorSpaceRef! = CGColorSpaceCreateDeviceRGB()
        
        var numbOfComponents:Int  = 4 // RGBA
        
        var gradientLocations:Array<CGFloat>?
        var gradientComponents:Array<CGFloat>?
        
        let numberOfLocations:Int
        let monotonicIncrement:Double
        
        if self.locations != nil {
            numberOfLocations = self.locations.count
            monotonicIncrement = 0.0
        } else {
            // If a nil array is given, the stops are assumed to spread uniformly across the [0,1] range
            numberOfLocations = self.colors.count
            monotonicIncrement = 1.0 / Double(numberOfLocations)
        }
        
        if (numberOfLocations > 0)
        {
            if (self.colors.count > 0)
            {
                let colorRef = self.colors[0] as! CGColorRef
                numbOfComponents = Int(CGColorGetNumberOfComponents(colorRef))
                colorSpace = CGColorGetColorSpace(colorRef);
            }
            
            gradientLocations = Array(count: numberOfLocations, repeatedValue: 0.0)
            
            if (numbOfComponents > 0) {
                
                gradientComponents = [CGFloat](count: numberOfLocations * numbOfComponents, repeatedValue: 0.0)
                
                for (var locationIndex = 0; locationIndex < numberOfLocations; locationIndex++)
                {
                    if self.locations != nil {
                       gradientLocations?[locationIndex] = self.locations[locationIndex] as! CGFloat
                    } else {
                       gradientLocations?[locationIndex] = CGFloat(monotonicIncrement * Double(locationIndex))
                    }
                    
                    let colorComponents = CGColorGetComponents(self.colors[locationIndex] as! CGColorRef);
                    
                    for (var componentIndex = 0; componentIndex < numbOfComponents; componentIndex++) {
                       gradientComponents?[numbOfComponents * locationIndex + componentIndex] = colorComponents[componentIndex]
                    }
                }
                
               self.gradientRadial = CGGradientCreateWithColorComponents(colorSpace,
                    UnsafePointer<CGFloat>(gradientComponents!),
                    UnsafePointer<CGFloat>(gradientLocations!),
                    UInt(numberOfLocations));
            }
        }
    }
    
    override func drawInContext(ctx: CGContext!) {
        
        if(self.type == kOMGradientLayerRadial){

            if(self.gradientRadial != nil){
                // draw the radial gradient
                CGContextDrawRadialGradient(ctx,
                self.gradientRadial,
                self.startCenter,
                self.startRadius,
                self.endCenter,
                self.endRadius,
                self.options);
            }
            else
            {
                // draw the linear gradient
                super.drawInContext(ctx)
            }
        }
    }
}
