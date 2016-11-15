//
//  OMGradientLayer.swift
//
//  Created by Jorge Ouahbi on 19/8/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

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


import UIKit


open class OMGradientLayer : CALayer, OMGradientLayerProtocol {
    
    // MARK: - OMColorsAndLocationsProtocol
    
    open var colors: [UIColor] = [] {
        didSet {
            // if only exist one color, duplicate it.
            if (colors.count == 1) {
                let color = colors.first!
                colors = [color, color];
            }
            
            // map monochrome colors to rgba colors
            colors = colors.map({
                return ($0.colorSpace?.model == .monochrome) ?
                    UIColor(red: $0.components[0],
                            green : $0.components[0],
                            blue  : $0.components[0],
                            alpha : $0.components[1]) : $0
            })
            
            self.setNeedsDisplay()
        }
    }
    open var locations : [CGFloat]? = nil {
        didSet {
            if locations != nil{
                locations!.sort { $0 < $1 }
            }
            self.setNeedsDisplay()
        }
    }
    
    open var isAxial : Bool {
        return (gradientType == .axial)
    }
    open var isRadial : Bool {
        return (gradientType == .radial)
    }
    
    // MARK: - OMAxialGradientLayerProtocol
    
    open var gradientType :OMGradientType = .axial {
        didSet {
            self.setNeedsDisplay();
        }
    }
    
    open var startPoint: CGPoint  = CGPoint(x: 0.0, y: 0.5) {
        didSet {
            self.setNeedsDisplay();
        }
    }
    open var endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5) {
        didSet{
            self.setNeedsDisplay();
        }
    }
    
    open var extendsBeforeStart : Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    open var extendsPastEnd : Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - OMRadialGradientLayerProtocol
    open var startRadius: CGFloat = 0 {
        didSet {
            startRadius = clamp(startRadius, lower: 0, upper: 1.0)
            self.setNeedsDisplay();
        }
    }
    open var endRadius: CGFloat = 0 {
        didSet {
            endRadius = clamp(endRadius, lower: 0, upper: 1.0)
            self.setNeedsDisplay();
        }
    }
    
    // MARK: OMMaskeableLayerProtocol
    open var lineWidth : CGFloat = 1.0  {
        didSet {
            self.setNeedsDisplay()
        }
    }
    open var stroke : Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    open var path : CGPath? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    //  Here's a method that creates a view that allows 360 degree rotation of its two-colour
    //  gradient based upon input from a slider (or anything). The incoming slider value
    //  ("x" variable below) is between 0.0 and 1.0.
    //
    //  At 0.0 the gradient is horizontal (with colour A on top, and colour B below), rotating
    //  through 360 degrees to value 1.0 (identical to value 0.0 - or a full rotation).
    //
    //  E.g. when x = 0.25, colour A is left and colour B is right. At 0.5, colour A is below
    //  and colour B is above, 0.75 colour A is right and colour B is left. It rotates anti-clockwise
    //  from right to left.
    //
    //  It takes four arguments: frame, colourA, colourB and the input value (0-1).
    //
    //  from: http://stackoverflow.com/a/29168654/6387073
    

    public class func pointsFromNormalizedAngle(_ normalizedAngle:Double) -> (CGPoint,CGPoint) {
        
        //x is between 0 and 1, eg. from a slider, representing 0 - 360 degrees
        //colour A starts on top, with colour B below
        //rotations move anti-clockwise
        
        //create coordinates
        let r = 2*M_PI
        let a = pow(sin((r*((normalizedAngle+0.75)/2))),2);
        let b = pow(sin((r*((normalizedAngle+0.0)/2))),2);
        let c = pow(sin((r*((normalizedAngle+0.25)/2))),2);
        let d = pow(sin((r*((normalizedAngle+0.5)/2))),2);
        
        //set the gradient direction
        return (CGPoint(x: a, y: b),CGPoint(x: c, y: d))
    }
    
    // MARK: - Object constructors
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    convenience public init(type:OMGradientType) {
        self.init()
        self.gradientType  = type
    }
    
    // MARK: - Object Overrides
    override public  init() {
        super.init()
        self.allowsEdgeAntialiasing     = true
        self.contentsScale              = UIScreen.main.scale
        self.needsDisplayOnBoundsChange = true;
        self.drawsAsynchronously        = true;
    }
    
    override public  init(layer: Any) {
        super.init(layer: layer)
        
        if let other = layer as? OMGradientLayer {
            
            // common
            self.colors             = other.colors
            self.locations          = other.locations
            self.gradientType       = other.gradientType
            
            // axial gradient properties
            self.startPoint         = other.startPoint
            self.endPoint           = other.endPoint
            self.extendsBeforeStart = other.extendsBeforeStart
            self.extendsPastEnd     = other.extendsPastEnd
            
            // radial gradient properties
            self.startRadius        = other.startRadius
            self.endRadius          = other.endRadius
        }
    }
    
    // MARK: - Functions
    override open class func needsDisplay(forKey event: String) -> Bool {
        if (event == OMGradientLayerProperties.startPoint  ||
            event == OMGradientLayerProperties.locations   ||
            event == OMGradientLayerProperties.colors      ||
            event == OMGradientLayerProperties.endPoint     ||
            event == OMGradientLayerProperties.startRadius ||
            event == OMGradientLayerProperties.endRadius) {
            return true
        }
        
        return super.needsDisplay(forKey: event)
    }
    
    override open func action(forKey event: String) -> CAAction? {
        if (event == OMGradientLayerProperties.startPoint ||
            event == OMGradientLayerProperties.locations   ||
            event == OMGradientLayerProperties.colors      ||
            event == OMGradientLayerProperties.endPoint    ||
            event == OMGradientLayerProperties.startRadius ||
            event == OMGradientLayerProperties.endRadius) {
            return animationActionForKey(event);
        }
        return super.action(forKey: event)
    }
    
    override open func draw(in ctx: CGContext) {
        //        super.drawInContext(ctx) do nothing
        let clipBoundingBox = ctx.boundingBoxOfClipPath
        ctx.clear(clipBoundingBox);
        ctx.clip(to: clipBoundingBox)
    }
    
    
    func addPathAndClipIfNeeded(_ ctx:CGContext) {
        if (self.path != nil) {
            ctx.addPath(self.path!);
            if (self.stroke) {
                ctx.setLineWidth(self.lineWidth);
                ctx.replacePathWithStrokedPath();
            }
            ctx.clip();
        }
    }
    
    func isDrawable() -> Bool {
        if (colors.count == 0) {
            // nothing to do
               #if LOG
            OMLog.printv("\(self.name ?? "")) Unable to do the shading without colors.")
                #endif
            return false
        }
        if (startPoint.isZero && endPoint.isZero) {
            // nothing to do
               #if LOG
            OMLog.printv("\(self.name ?? "")) Start point and end point are {x:0, y:0}.")
                #endif
            return false
        }
        if (startRadius == endRadius && self.isRadial) {
            // nothing to do
               #if LOG
            OMLog.printv("\(self.name ?? "")) Start radius and end radius are equal. \(startRadius) \(endRadius)")
                #endif
            return false
        }
        return true;
    }
    
    override open var description:String {
        get {
            var currentDescription:String = "type: \((self.isAxial ? "Axial" : "Radial")) "
            if let locations = locations {
                if(locations.count == colors.count) {
                    _ = zip(colors,locations).flatMap { currentDescription += "color: \($0.shortDescription) location: \($1) " }
                } else {
                    if (locations.count > 0) {
                        _ = locations.map({currentDescription += "\($0) "})
                    }
                    if (colors.count > 0) {
                        _ = colors.map({currentDescription += "\($0.shortDescription) "})
                    }
                }
            }
            if (self.isRadial) {
                currentDescription += "center from : \(startPoint) to \(endPoint), radius from : \(startRadius) to \(endRadius)"
            } else if (self.isAxial) {
                currentDescription += "from : \(startPoint) to \(endPoint)"
            }
            if  (self.extendsPastEnd)  {
                currentDescription += " draws after end location "
            }
            if  (self.extendsBeforeStart)  {
                currentDescription += " draws before start location "
            }
            return currentDescription
        }
    }
}
