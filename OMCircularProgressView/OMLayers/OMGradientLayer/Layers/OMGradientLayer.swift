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


public class OMGradientLayer : CALayer, OMGradientLayerProtocol {
    
    // MARK: - OMColorsAndLocationsProtocol

    public var colors: [UIColor] = [] {
        didSet {
            // if only exist one color, duplicate it.
            if (colors.count == 1) {
                let color = colors.first!
                colors = [color, color];
            }
            
            // map monochrome colors to rgba colors
            colors = colors.map({
                return ($0.colorSpace?.model == .Monochrome) ?
                    UIColor(red: $0.components[0],
                        green : $0.components[0],
                        blue  : $0.components[0],
                        alpha : $0.components[1]) : $0
            })
            
            self.setNeedsDisplay()
        }
    }
    public var locations : [CGFloat]? = nil {
        didSet {
            if locations != nil{
                locations!.sortInPlace { $0 < $1 }
            }
            self.setNeedsDisplay()
        }
    }
    
    public var isAxial : Bool {
        return (gradientType == .Axial)
    }
    public var isRadial : Bool {
        return (gradientType == .Radial)
    }
    
    // MARK: - OMAxialGradientLayerProtocol
    
    public var gradientType :OMGradientType = .Axial {
        didSet {
            self.setNeedsDisplay();
        }
    }
    
    
    public var startPoint: CGPoint  = CGPoint(x: 0.0, y: 0.5) {
        didSet {
            self.setNeedsDisplay();
        }
    }
    public var endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5) {
        didSet{
            self.setNeedsDisplay();
        }
    }

    public var extendsBeforeStart : Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    public var extendsPastEnd : Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }

    // MARK: - OMRadialGradientLayerProtocol
    
    public var startRadius: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay();
        }
    }
    public var endRadius: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay();
        }
    }
    
    // MARK: OMMaskeableLayerProtocol
    public var lineWidth : CGFloat = 1.0  {
        didSet {
            self.setNeedsDisplay()
        }
    }
    public var stroke : Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    public var path : CGPath? {
        didSet {
            self.setNeedsDisplay()
        }
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
        self.contentsScale              = UIScreen.mainScreen().scale
        self.needsDisplayOnBoundsChange = true;
        self.drawsAsynchronously        = true;
    }
    
    override public  init(layer: AnyObject) {
        super.init(layer: layer)
        if let other = layer as? OMGradientLayer {
            // common
            self.colors      = other.colors
            self.locations   = other.locations
            self.gradientType        = other.gradientType
            
            // axial gradient properties
            self.startPoint         = other.startPoint
            self.endPoint           = other.endPoint
            self.extendsBeforeStart = other.extendsBeforeStart
            self.extendsPastEnd     = other.extendsPastEnd
            
            // radial gradient properties
            self.startRadius  = other.startRadius
            self.endRadius = other.endRadius
        }
    }
    
    // MARK: - Functions
    override public class func needsDisplayForKey(event: String) -> Bool {
        if (event == OMGradientLayerProperties.startPoint  ||
            event == OMGradientLayerProperties.locations   ||
            event == OMGradientLayerProperties.colors      ||
            event == OMGradientLayerProperties.endPoint     ||
            event == OMGradientLayerProperties.startRadius ||
            event == OMGradientLayerProperties.endRadius) {
            return true
        }
        
        return super.needsDisplayForKey(event)
    }
    
    override public func actionForKey(event: String) -> CAAction? {
        if (event == OMGradientLayerProperties.startPoint ||
            event == OMGradientLayerProperties.locations   ||
            event == OMGradientLayerProperties.colors      ||
            event == OMGradientLayerProperties.endPoint    ||
            event == OMGradientLayerProperties.startRadius ||
            event == OMGradientLayerProperties.endRadius) {
            return animationActionForKey(event);
        }
        return super.actionForKey(event)
    }
    
    override public func drawInContext(ctx: CGContext) {
//        super.drawInContext(ctx) do nothing
        let clipBoundingBox = CGContextGetClipBoundingBox(ctx)
        CGContextClearRect(ctx,clipBoundingBox);
        CGContextClipToRect(ctx,clipBoundingBox)
    }
    
    
    func addPathAndClipIfNeeded(ctx:CGContext) {
        if (self.path != nil) {
            CGContextAddPath(ctx,self.path);
            if (self.stroke) {
                CGContextSetLineWidth(ctx, self.lineWidth);
                CGContextReplacePathWithStrokedPath(ctx);
            }
            CGContextClip(ctx);
        }
    }
    
    func canDrawGradient() -> Bool {
        if (colors.count == 0) {
            // nothing to do
            #if VERBOSE
                print("Unable to do the shading without colors.")
            #endif
            return false
        }
        
        if (startPoint.isZero && endPoint.isZero) {
            // nothing to do
            #if (VERBOSE)
                print("Start point and end point are {x:0, y:0}.")
            #endif
            return false
        }
        
        return true;
    }
    
    override public var description:String {
        get {
            var currentDescription:String = "type: \((self.isAxial ? "Axial" : "Radial"))\n"
            if let locations = locations {
                if(locations.count == colors.count) {
                    _ = zip(colors,locations).flatMap { currentDescription += "color: \($0.shortDescription) location: \($1)\n" }
                } else {
                    if (locations.count > 0) {
                        _ = locations.map({currentDescription += "\($0)\n"})
                    }
                    if (colors.count > 0) {
                        _ = colors.map({currentDescription += "\($0.shortDescription)\n"})
                    }
                }
            }
            if (self.isRadial) {
                currentDescription += "center from : \(startPoint) to \(endPoint), radius from : \(startRadius) to \(endRadius)"
            } else if (self.isAxial) {
                currentDescription += "from : \(startPoint) to \(endPoint)"
            }
            if  (self.extendsPastEnd)  {
                currentDescription += "\ndraws after end location"
            }
            if  (self.extendsBeforeStart)  {
                currentDescription += "\ndraws before start location"
            }
            return currentDescription
        }
    }
}
