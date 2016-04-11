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
//  0.2 (13-05-2015)
//      Added the oval type
//      Fixed error condition. When the locations count was less than the colors count.
//
//
import UIKit


private struct OMRadialGradientLayerProperties {
    static var startCenter = "startCenter"
    static var startRadius = "startRadius"
    static var endCenter = "endCenter"
    static var endRadius = "endRadius"
    static var colors = "colors"
    static var locations = "locations"
};


let kOMGradientLayerRadial: String = "radial"
let kOMGradientLayerOval: String =  "oval"

@objc class OMRadialGradientLayer : OMLayer, CustomDebugStringConvertible
{
    private(set) var gradient:CGGradientRef?
    
    var startCenterRatio: CGPoint = CGPoint(x:0,y:0)
    var endCenterRatio: CGPoint = CGPoint(x:0,y:0)
    
    var startRadiusRatio : Double = 0
    var endRadiusRatio   : Double = 0
    
    
    var startCenter: CGPoint = CGPoint(x:0,y:0)
    {
        didSet
        {
            startCenterRatio.x = startCenter.x / bounds.size.width;
            startCenterRatio.y = startCenter.y / bounds.size.height;
        }
    }
    
    var endCenter: CGPoint = CGPoint(x:0,y:0)
    {
        didSet
        {
            endCenterRatio.x = endCenter.x / bounds.size.width;
            endCenterRatio.y = endCenter.y / bounds.size.height;
        }
    }
    var startRadius: CGFloat = 0
    {
        didSet
        {
            startRadiusRatio = Double(startRadius / bounds.size.min());
        }
    }
    var endRadius: CGFloat = 0
    {
        didSet
        {
            endRadiusRatio = Double(endRadius / bounds.size.min());
        }
    }

    var extendsPastStart: Bool  {
        set(newValue) {
            let isSet = (self.options.rawValue & CGGradientDrawingOptions.DrawsBeforeStartLocation.rawValue ) != 0 ;
            if (newValue !=  isSet)
            {
                self.options  = CGGradientDrawingOptions(rawValue:self.options.rawValue | CGGradientDrawingOptions.DrawsBeforeStartLocation.rawValue);
            
                self.setNeedsDisplay();
            }
        }
        get
        {
            return (self.options.rawValue & CGGradientDrawingOptions.DrawsBeforeStartLocation.rawValue) != 0;
        }
    }
    
    
    var extendsPastEnd:Bool
    {
        set(newValue)
        {
            let isSet = (self.options.rawValue & CGGradientDrawingOptions.DrawsAfterEndLocation.rawValue ) != 0 ;
            
            if (newValue !=  isSet) {
                self.options  = CGGradientDrawingOptions(rawValue:self.options.rawValue | CGGradientDrawingOptions.DrawsAfterEndLocation.rawValue);
                
                self.setNeedsDisplay();
            }
        }
        get
            {
                return (self.options.rawValue & CGGradientDrawingOptions.DrawsAfterEndLocation.rawValue) != 0;
        }
    }
    
    var options: CGGradientDrawingOptions = CGGradientDrawingOptions(rawValue:
        CGGradientDrawingOptions.DrawsBeforeStartLocation.rawValue|CGGradientDrawingOptions.DrawsAfterEndLocation.rawValue)
    
    
   /* The array of CGColorRef objects defining the color of each gradient
    * stop. Defaults to nil. Animatable. */
    
    var colors: [AnyObject]? = nil
    {
        didSet {
            self.gradient =  OMRadialGradientLayer.newGradient(self.colors as? [CGColorRef],locations: self.locations as? [CGFloat])
        }
    }
    
   /* An optional array of NSNumber objects defining the location of each
    * gradient stop as a value in the range [0,1]. The values must be
    * monotonically increasing. If a nil array is given, the stops are
    * assumed to spread uniformly across the [0,1] range. When rendered,
    * the colors are mapped to the output colorspace before being
    * interpolated. Defaults to nil. Animatable. */
    
    var locations : [AnyObject]? = nil
    {
        didSet {
            self.gradient = OMRadialGradientLayer.newGradient(self.colors as? [CGColorRef],locations: self.locations as? [CGFloat])
        }
        
    }
    
    /* The kind of gradient that will be drawn. Default value is `radial' */
    
    var type : String! = kOMGradientLayerRadial
    
    override init(layer: AnyObject) {
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

        }
    }
    
    required init?(coder aDecoder: NSCoder) {
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
        self.allowsEdgeAntialiasing = true
    }
    
    override class func needsDisplayForKey(event: String) -> Bool
    {
        if(event == OMRadialGradientLayerProperties.startCenter ||
            event == OMRadialGradientLayerProperties.startRadius ||
            event == OMRadialGradientLayerProperties.locations ||
            event == OMRadialGradientLayerProperties.colors     ||
            event == OMRadialGradientLayerProperties.endCenter  ||
            event == OMRadialGradientLayerProperties.endRadius)
        {
            return true
        }
        
        return super.needsDisplayForKey(event)
    }
    
    
    override func actionForKey(event: String) -> CAAction?
    {
        if(event == OMRadialGradientLayerProperties.startCenter ||
            event == OMRadialGradientLayerProperties.startRadius ||
            event == OMRadialGradientLayerProperties.locations ||
            event == OMRadialGradientLayerProperties.colors     ||
            event == OMRadialGradientLayerProperties.endCenter  ||
            event == OMRadialGradientLayerProperties.endRadius)
        {
            return animationActionForKey(event);

        }
        return super.actionForKey(event)
    }
    
    //DEBUG
    class private func assertColor(color:CGColorRef)
    {
        // if the next line crash then color is not a CGColorRef
        
        CGColorGetNumberOfComponents(color)
    }
    
    
//    override var bounds:CGRect
//    {
//        set(newValue) {
//            if(!bounds.isEmpty)
//            {
//            let x = super.bounds.size.height / newValue.size.height
//            let y = super.bounds.size.width / newValue.size.width
//            
//            
//            let newBounds = CGRect(x: 0, y: 0, width: newValue.size.width * y, height: newValue.size.height * x)
//            super.bounds = newBounds
//            
//            println("-> \(bounds)")
//            }
//            else
//            {
//                super.bounds = newValue
//            }
//            
////            let invrad = 1.0 / Double(self.bounds.size.min())
////            radius_start  = Double(startRadius) * invrad
////            radius_end  = Double(endRadius) * invrad
////            println("-> \(radius_start)")
////            println("-> \(radius_end)")
////            
////            startCenter   = newValue.size.center()
////            endCenter     = newValue.size.center()
//        }
//        
//        get { return super.bounds }
//    }
    
    private func updateGradientWithColors()
    {
        if(self.colors == nil) {
            // Nothing to update
            return
        }
        
        var colorSpace: CGColorSpaceRef! = CGColorSpaceCreateDeviceRGB()
        
        var gradientComponents:Array<CGFloat>?
        
        let numberOfColors:Int = self.colors!.count
        
        if (numberOfColors > 0)
        {
            let colorRef = self.colors![0] as! CGColorRef
            
            let numbOfComponents = Int(CGColorGetNumberOfComponents(colorRef))
            
            colorSpace = CGColorGetColorSpace(colorRef);
            
            if (numbOfComponents > 0) {
                
                gradientComponents = [CGFloat](count: numberOfColors * numbOfComponents, repeatedValue: 0.0)
                
                for (var locationIndex = 0; locationIndex < numberOfColors; locationIndex++)
                {
                    let clr = self.colors![locationIndex] as! CGColorRef
                    
                    OMRadialGradientLayer.assertColor(clr)
                    
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
    
    class func newGradient(colors:[CGColorRef]?, locations:[CGFloat]?) -> CGGradientRef?
    {
        if(colors != nil && colors?.count  > 0) {
            
            var colorSpace: CGColorSpaceRef! = CGColorSpaceCreateDeviceRGB()
            
            var numbOfComponents:Int  = 4 // RGBA
            
            var gradientLocations:Array<CGFloat>?
            var gradientComponents:Array<CGFloat>?
            
            let numberOfLocations:Int
            let monotonicIncrement:Double
            
            if locations != nil {
                numberOfLocations = min(locations!.count,colors!.count)
                monotonicIncrement = 0.0
            } else {
                // If a nil array is given, the stops are assumed to spread uniformly across the [0,1] range
                numberOfLocations = colors!.count
                monotonicIncrement = 1.0 / Double(numberOfLocations - 1)
            }
            
            if (numberOfLocations > 0)
            {
                if (colors!.count > 0)
                {
                    let colorRef = colors![0]
                    numbOfComponents = Int(CGColorGetNumberOfComponents(colorRef))
                    colorSpace = CGColorGetColorSpace(colorRef);
                }
                
                gradientLocations = Array(count: numberOfLocations, repeatedValue: 0.0)
                
                if (numbOfComponents > 0) {
                    
                    gradientComponents = [CGFloat](count: numberOfLocations * numbOfComponents, repeatedValue: 0.0)
                    
                    for (var locationIndex = 0; locationIndex < numberOfLocations; locationIndex++)
                    {
                        if locations != nil {
                            gradientLocations?[locationIndex] = locations![locationIndex]
                        } else {
                            gradientLocations?[locationIndex] = CGFloat(monotonicIncrement * Double(locationIndex))
                        }
                        
                        let currentColor = colors![locationIndex]
                        
                        OMRadialGradientLayer.assertColor(currentColor)
                        
                        let colorComponents = CGColorGetComponents(currentColor);
                        
                        for (var componentIndex = 0; componentIndex < numbOfComponents; componentIndex++) {
                            gradientComponents?[numbOfComponents * locationIndex + componentIndex] = colorComponents[componentIndex]
                        }
                    }
                    
                    //
                    // If locations is NULL, the first color in colors is assigned to location 0, the last color incolors is assigned
                    // to location 1, and intervening colors are assigned locations that are at equal intervals in between.
                    
                    return CGGradientCreateWithColorComponents(colorSpace,
                        UnsafePointer<CGFloat>(gradientComponents!),
                        UnsafePointer<CGFloat>(gradientLocations!),
                        numberOfLocations);
                }
            }
        }
        
        return nil
    }
    
    
    // Returns an appropriate starting point for the demonstration of a linear gradient
    func demoLGStart(bounds:CGRect) -> CGPoint
    {
        return CGPointMake(bounds.origin.x, bounds.origin.y + bounds.size.height * 0.25);
    }
    
    // Returns an appropriate ending point for the demonstration of a linear gradient
    func demoLGEnd(bounds:CGRect) -> CGPoint
    {
        return CGPointMake(bounds.origin.x, bounds.origin.y + bounds.size.height * 0.75);
    }
    
    
    // Returns the center point for for the demonstration of the radial gradient
    func demoRGCenter(bounds:CGRect) -> CGPoint
    {
        return CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    }
    
    
    // Returns an appropriate inner radius for the demonstration of the radial gradient
    func RGInnerRadius(bounds:CGRect) -> CGFloat
    {
        let r = bounds.size.width < bounds.size.height ? bounds.size.width : bounds.size.height;
        return r * 0.125;
    }
    
    // Returns an appropriate outer radius for the demonstration of the radial gradient
    func RGOuterRadius(bounds:CGRect) -> CGFloat
    {
        let r = bounds.size.width < bounds.size.height ? bounds.size.width : bounds.size.height;
        return r * 0.5;
    }
    
    
    override func drawInContext(ctx: CGContext) {
    
        super.drawInContext(ctx)
        
        var startCenter:CGPoint = self.startCenter
        var startRadius:CGFloat = self.startRadius
        var endCenter:CGPoint   = self.endCenter
        var endRadius:CGFloat   = self.endRadius
        
        if let player: OMRadialGradientLayer = self.presentationLayer() as? OMRadialGradientLayer {
            
            self.gradient = OMRadialGradientLayer.newGradient(player.colors as? [CGColorRef],locations: player.locations as? [CGFloat])
            
            startCenter  = player.startCenter
            endCenter   = player.endCenter
            startRadius  = player.startRadius
            endRadius  = player.endRadius
        }
        
        
        if (self.type == kOMGradientLayerRadial) {
            
            //
            // Draw the radial gradient
            //
          
            let startX = bounds.size.width  * startCenterRatio.x;
            let startY = bounds.size.height * startCenterRatio.y;
            
            let endX = bounds.size.width  * endCenterRatio.x;
            let endY = bounds.size.height * endCenterRatio.y;
            
            let minRadius = startRadius * CGFloat(startRadiusRatio);
            let maxRadius = endRadius * CGFloat(endRadiusRatio);
            
            CGContextDrawRadialGradient(ctx,
                gradient,
                CGPoint(x: startX,y: startY),
                minRadius ,
                CGPoint(x: endX,y: endY),
                maxRadius ,
                options);
            
        }
        else if( self.type == kOMGradientLayerOval)
        {
            // Scaling transformation and keeping track of the inverse
            
            let scaleT    = CGAffineTransformMakeScale(2, 1.0);
            let invScaleT = CGAffineTransformInvert(scaleT);
            
            // Extract the Sx and Sy elements from the inverse matrix
            // (See the Quartz documentation for the math behind the matrices)
            let invS = CGPoint(x:invScaleT.a, y:invScaleT.d);
            
            // Transform center and radius of gradient with the inverse
            let ovalStartCenter = CGPointMake(startCenter.x * invS.x, startCenter.y * invS.y);
            let ovalEndCenter = CGPointMake(endCenter.x * invS.x, endCenter.y * invS.y);
            let ovalStartRadius = startRadius * invS.x;
            let ovalEndRadius = endRadius * invS.x;
            
            // Draw the gradient with the scale transform on the context
            CGContextScaleCTM(ctx, scaleT.a, scaleT.d);
            CGContextDrawRadialGradient(ctx, gradient,
                ovalStartCenter,
                ovalStartRadius,
                ovalEndCenter,
                ovalEndRadius,
                options);
            
            // Reset the context
            
            CGContextScaleCTM(ctx, invS.x, invS.y);
        }
    }
    
    override var debugDescription: String {
        get {
            return self.description
        }
    }
    
    override var description:String {
        
        get {
            
            if (self.type == kOMGradientLayerRadial || self.type == kOMGradientLayerOval) {
                
                var str:String =  super.description + "type: \(self.type)"
                
                if (locations != nil) {
                    str += "\(locations)"
                }
                
                if (colors != nil) {
                    str += "\(colors)"
                }
                
                str += " center from : \(startCenter) to \(endCenter) , radius from : \(startRadius) to \(endRadius)"

                if  (self.extendsPastEnd)  {
                    str += " (Draws after end location)"
                }
                if  (self.extendsPastStart)  {
                    str += " (Draws before start location)"
                }
                
                return str
                
            } else {
                return super.description
            }
        }
    }
}
