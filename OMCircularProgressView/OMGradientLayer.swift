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
//  OMRadialGradientLayer.swift
//
//  Created by Jorge Ouahbi on 4/3/15.
//
//  0.1 (15-04-2015)
//      Now, all the properties are animatables.
//

import UIKit


private struct OMGradientLayerProperties {
    static var startCenter = "startCenter"
    static var startRadius = "startRadius"
    static var endCenter = "endCenter"
    static var endRadius = "endRadius"
    static var colors = "colors"
    static var locations = "locations"
    //static var startPoint = "startPoint"
    //static var endPoint = "endPoint"
};


let kOMGradientLayerRadial: String = "radial"
//let kOMGradientLayerAxial: String = "axial"
let kOMGradientLayerOval: String = "oval"

class OMRadialGradientLayer : CALayer, Printable, DebugPrintable
{
    private(set) var gradient:CGGradientRef?
    
    /* The start and end points of the gradient when drawn into the layer's
    * coordinate space. The start point corresponds to the first gradient
    * stop, the end point to the last gradient stop. Both points are
    * defined in a unit coordinate space that is then mapped to the
    * layer's bounds rectangle when drawn. (I.e. [0,0] is the bottom-left
    * corner of the layer, [1,1] is the top-right corner.) The default values
    * are [.5,0] and [.5,1] respectively. Both are animatable. */
    
    //var startPoint: CGPoint = CGPoint(x:0.5,y:0)
    //var endPoint: CGPoint = CGPoint(x:0.5,y:1.0)
    

    
    var startCenter: CGPoint = CGPoint(x:0,y:0)
    var endCenter: CGPoint = CGPoint(x:0,y:0)
    var startRadius: CGFloat = 0
    var endRadius: CGFloat = 0
    
    var options: CGGradientDrawingOptions = CGGradientDrawingOptions(kCGGradientDrawsBeforeStartLocation)|CGGradientDrawingOptions(kCGGradientDrawsAfterEndLocation)
    
    
    /* The array of CGColorRef objects defining the color of each gradient
    * stop. Defaults to nil. Animatable. */
    
    var colors: [AnyObject]!
    {
        didSet {
            updateGradient()
        }
    }
    
    /* An optional array of NSNumber objects defining the location of each
    * gradient stop as a value in the range [0,1]. The values must be
    * monotonically increasing. If a nil array is given, the stops are
    * assumed to spread uniformly across the [0,1] range. When rendered,
    * the colors are mapped to the output colorspace before being
    * interpolated. Defaults to nil. Animatable. */
    
    var locations : [AnyObject]!
    {
        didSet {
            updateGradient()
        }
    }
    
//    override var position : CGPoint
//    {
//        get {
//            return super.position
//        }
//        set {
//            super.position = position
//            println("position: \(position)")
//        }
//    }
//    
//    override var frame:CGRect
//    {
//        didSet {
//            super.frame = frame
//            println("frame: \(frame)")
//        }
//    }
    
    /* The kind of gradient that will be drawn. Default value is `axial' */
    
    var type : String!
    {
        didSet {
            
            updateGradient()
        }
    }
    
    override init!(layer: AnyObject!) {
        super.init(layer: layer)
        if let other = layer as? OMRadialGradientLayer {
            
            // common
            self.colors = other.colors
            self.locations = other.locations
            self.type = other.type
            
            // radial and oval
            self.startCenter = other.startCenter
            self.startRadius = other.startRadius
            self.endCenter = other.endCenter
            self.endRadius = other.endRadius
            self.options = other.options
            
            // axial
            //            self.startPoint = other.startPoint
            //self.endPoint   = other.endPoint

        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    
    convenience init(type:String!)
    {
        self.init()
        self.type = type
    }
    
    override init()
    {
        super.init()
        
        self.contentsScale = UIScreen.mainScreen().scale
        self.needsDisplayOnBoundsChange = true;
        //self.masksToBounds = false
        self.allowsEdgeAntialiasing = true
        //self.backgroundColor = UIColor.clearColor().CGColor
        //self.borderWidth = 0
        //self.borderColor = UIColor.clearColor().CGColor
    }
    
    override class func needsDisplayForKey(event: String!) -> Bool
    {
        if(event == OMGradientLayerProperties.startCenter ||
            event == OMGradientLayerProperties.startRadius ||
            event == OMGradientLayerProperties.locations ||
            event == OMGradientLayerProperties.colors     ||
            event == OMGradientLayerProperties.endCenter  ||
            event == OMGradientLayerProperties.endRadius
        //||
        //    event == OMGradientLayerProperties.endPoint  ||
        //    event == OMGradientLayerProperties.startPoint
            )
        {
            return true
        }
        
        return super.needsDisplayForKey(event)
    }
    
    
    override func actionForKey(event: String!) -> CAAction!
    {
        if(event == OMGradientLayerProperties.startCenter ||
            event == OMGradientLayerProperties.startRadius ||
            event == OMGradientLayerProperties.locations ||
            event == OMGradientLayerProperties.colors     ||
            event == OMGradientLayerProperties.endCenter  ||
            event == OMGradientLayerProperties.endRadius
        //||
        //event == OMGradientLayerProperties.endPoint  ||
        //event == OMGradientLayerProperties.startPoint
        //
            )
        {
            let animation = CABasicAnimation(keyPath: event)
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.fromValue = self.presentationLayer()?.valueForKey(event);
            return animation
            
        }
        return super.actionForKey(event)
    }
    
    
    private func updateGradient()
    {
        //if(self.locations == nil) {
          self.updateGradientWithColors()
        //} else {
        //    self.updateGradientWithColorsAndLocations()
        //}
    }
    
    private func assertColor(color:CGColorRef)
    {
        // if the next line crash then color is not a CGColorRef
        
        CGColorGetNumberOfComponents(color)
    }
    
    
    private func updateGradientWithColors()
    {
        if(self.colors == nil) {
            // Nothing to update
            return
        }
        
        var colorSpace: CGColorSpaceRef! = CGColorSpaceCreateDeviceRGB()
        
        var gradientComponents:Array<CGFloat>?
        
        let numberOfColors:Int = self.colors.count
        
        if (numberOfColors > 0)
        {
            let colorRef = self.colors[0] as! CGColorRef
            
            let numbOfComponents = Int(CGColorGetNumberOfComponents(colorRef))
            
            colorSpace = CGColorGetColorSpace(colorRef);
            
            if (numbOfComponents > 0) {
                
                gradientComponents = [CGFloat](count: numberOfColors * numbOfComponents, repeatedValue: 0.0)
                
                for (var locationIndex = 0; locationIndex < numberOfColors; locationIndex++)
                {
                    let clr = self.colors[locationIndex] as! CGColorRef
                    
                    assertColor(clr)
                    
                    let colorComponents = CGColorGetComponents(clr);
                    
                    for (var componentIndex = 0; componentIndex < numbOfComponents; componentIndex++) {
                        gradientComponents?[numbOfComponents * locationIndex + componentIndex] = colorComponents[componentIndex]
                    }
                }
                
                //
                // If locations is NULL, the first color in colors is assigned to location 0, the last color incolors is assigned
                // to location 1, and intervening colors are assigned locations that are at equal intervals in between.
                
                
                self.gradient = CGGradientCreateWithColorComponents(colorSpace,
                    UnsafePointer<CGFloat>(gradientComponents!),
                    nil,
                    numberOfColors);
            }
        }
    }
    
    private func updateGradientWithColorsAndLocations()
    {
        if(self.colors == nil) {
            // Nothing to update
            return
        }
        
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
            monotonicIncrement = 1.0 / Double(numberOfLocations - 1)
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
                    
                    let clr = self.colors[locationIndex] as! CGColorRef
                    
                    assertColor(clr)
                    
                    let colorComponents = CGColorGetComponents(clr);
                    
                    for (var componentIndex = 0; componentIndex < numbOfComponents; componentIndex++) {
                        gradientComponents?[numbOfComponents * locationIndex + componentIndex] = colorComponents[componentIndex]
                    }
                }
//DEBUG: dump the locations
                
//       
//                for (var locationIndex = 0; locationIndex < numberOfLocations; locationIndex++){
//                    println("\(locationIndex) \(gradientLocations?[locationIndex])")
//                }
                
                
                //
                // If locations is NULL, the first color in colors is assigned to location 0, the last color incolors is assigned
                // to location 1, and intervening colors are assigned locations that are at equal intervals in between.
                
                self.gradient = CGGradientCreateWithColorComponents(colorSpace,
                    UnsafePointer<CGFloat>(gradientComponents!),
                    UnsafePointer<CGFloat>(gradientLocations!),
                    numberOfLocations);
            }
        }
    }
    
    
    func drawOval(ctx: CGContext!)
    {
//        CGContextRef ctx = UIGraphicsGetCurrentContext();
//        
//        // Create gradient
//        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//        CGFloat locations[] = {0.0, 1.0};
//        
//        UIColor *centerColor = [UIColor orangeColor];
//        UIColor *edgeColor = [UIColor purpleColor];
//        
//        NSArray *colors = [NSArray arrayWithObjects:(__bridge id)centerColor.CGColor, (__bridge id)edgeColor.CGColor, nil];
//        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
        
        // Scaling transformation and keeping track of the inverse
        let scaleT = CGAffineTransformMakeScale(2, 1.0);
        let invScaleT = CGAffineTransformInvert(scaleT);
        
        // Extract the Sx and Sy elements from the inverse matrix
        // (See the Quartz documentation for the math behind the matrices)
        let invS = CGPoint(x:invScaleT.a, y:invScaleT.d);
        
        // Transform center and radius of gradient with the inverse
        let center = CGPointMake((self.bounds.size.width / 2) * invS.x, (self.bounds.size.height / 2) * invS.y);
        let radius = (self.bounds.size.width / 2) * invS.x;
        
        // Draw the gradient with the scale transform on the context
        CGContextScaleCTM(ctx, scaleT.a, scaleT.d);
        CGContextDrawRadialGradient(ctx, self.gradient, center, 0, center, radius, self.options);
        
        // Reset the context
        CGContextScaleCTM(ctx, invS.x, invS.y);
        
        // Continue to draw whatever else ...
        
//        // Clean up the memory used by Quartz
//        CGGradientRelease(gradient);
//        CGColorSpaceRelease(colorSpace);
    
    }
 
    
    override func drawInContext(ctx: CGContext!) {
    
        if (self.gradient == nil) {
            updateGradient()
        }
        
        if(self.type == kOMGradientLayerRadial){
            
//            println("\(bounds) \(frame) \(position) \(transform)")
//            println("\(superlayer.bounds) \(superlayer.frame) \(superlayer.position) \(superlayer.transform)")
            
            var startCenter:CGPoint = self.startCenter
            var startRadius:CGFloat = self.startRadius
            var endCenter:CGPoint   = self.endCenter
            var endRadius:CGFloat   = self.endRadius

            if let player: OMRadialGradientLayer = self.presentationLayer() as? OMRadialGradientLayer {
                
                // Presentation layer
                
                if(player.startCenter != startCenter) {
                    startCenter  = player.startCenter
                }
                
                if(player.endCenter != endCenter) {
                    endCenter  = player.endCenter
                }
                
                if(player.startRadius != startRadius) {
                    startRadius  = player.startRadius
                }
                
                if(player.endRadius != endRadius) {
                    endRadius  = player.endRadius
                }
            }
        
            //println("gradient: center from :\(startCenter) to \(endCenter) , radius from :\(startRadius) to \(endRadius)")
    
            
            //
            // Draw the radial gradient
            //
          
            CGContextDrawRadialGradient(ctx,
                gradient,
                startCenter,
                startRadius,
                endCenter,
                endRadius,
                options);
            
        } else if( self.type == kOMGradientLayerOval) {
            
        }
//        else
//        {
//            var startPoint:CGPoint = self.startPoint
//            var endPoint:CGPoint    = self.endPoint
//
//            
//            if let player: OMRadialGradientLayer = self.presentationLayer() as? OMRadialGradientLayer {
//                
//                // Presentation layer
//                
//                if(player.startPoint != startPoint) {
//                   startPoint  = player.startPoint
//                }
//                
//                if(player.endPoint != endPoint) {
//                    endPoint  = player.endPoint
//                }
//            }
//            
//        
//            //
//            // Draw the axial gradient
//            //
//            
//            CGContextDrawLinearGradient(ctx,
//                gradient,
//                startPoint,
//                endPoint,
//                options);
//        }
    }
    
    override var debugDescription: String
    {
        get {
            return self.description
        }
    }
    
    override var description:String
    {
        get {
            if(self.type == kOMGradientLayerRadial || self.type == kOMGradientLayerOval) {
                
                var str:String = "\(self.type)"
                
                if (frame.isEmpty == false) {
                    str += "\(frame)"
                }
                
                if (locations != nil) {
                    str += "\(locations)"
                }
                
                if (colors != nil) {
                    str += "\(colors)"
                }
                
                str += super.description +  " center from : \(startCenter) to \(endCenter) , radius from : \(startRadius) to \(endRadius)"
                
                if  (  self.options == CGGradientDrawingOptions(kCGGradientDrawsAfterEndLocation)  )  {
                    str += " (Draws after end location)"
                } else {
                    str += " (Draws before start location)"
                }
                
                return str
                
//            }else if(self.type == kOMGradientLayerAxial) {
//                var str:String = "\(self.type)"
//                
//                if (frame.isEmpty == false) {
//                    str += "\(frame)"
//                }
//                
//                if (locations != nil) {
//                    str += "\(locations)"
//                }
//                
//                if (colors != nil) {
//                    str += "\(colors)"
//                }
//                
//                str += super.description +  " from : \(startPoint) to \(endPoint)"
//            
//                return str
                
            }else{
                return super.description
            }
        }
    }
}
