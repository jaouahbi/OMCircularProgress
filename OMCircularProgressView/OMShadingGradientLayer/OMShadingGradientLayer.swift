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
//  OMShadingGradientLayer.swift
//
//  Created by Jorge Ouahbi on 4/3/15.
//
//  0.1.0 (13-06-2016)
//      Now, all the properties are animatables
//      Fixed error condition. When the locations count was less than the colors count.
//      Removed the oval type
//
//

import UIKit

// Animatable Properties
private struct OMShadingGradientLayerProperties {
    
    static var startPoint   = "startPoint"
    static var startRadius  = "startRadius"
    static var endPoint     = "endPoint"
    static var endRadius    = "endRadius"
    static var colors       = "colors"
    static var locations    = "locations"
};


@objc class OMShadingGradientLayer : CALayer
{
    
    var lineWidth : CGFloat = 1.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var stroke : Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var path : CGPath?{
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // The array of CGColorRef objects defining the color of each gradient
    // stop. Defaults to nil. Animatable.
    var colors: [CGColor] = [] {
        didSet {
            self.setNeedsDisplay()
        }
    }
    // An optional array of CGFloat objects defining the location of each
    // gradient stop as a value in the range [0,1]. The values must be
    // monotonically increasing. If a nil array is given, the stops are
    // assumed to spread uniformly across the [0,1] range. When rendered,
    // the colors are mapped to the output colorspace before being
    // interpolated. Defaults to nil. Animatable.
    var locations : [CGFloat]? = nil {
        didSet {
            self.setNeedsDisplay()
        }
    }
    // The kind of gradient that will be drawn. Default value is `radial'
    var type : GradientType = .Radial {
        didSet {
            self.setNeedsDisplay();
        }
    }
    //Defaults to CGPointZero. Animatable.
    var startPoint: CGPoint = CGPointZero {
        didSet {
            self.setNeedsDisplay();
        }
    }
    //Defaults to CGPointZero. Animatable.
    var endPoint: CGPoint = CGPointZero {
        didSet{
            self.setNeedsDisplay();
        }
    }
    //Defaults to 0. Animatable.
    var startRadius: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay();
        }
    }
    //Defaults to 0. Animatable.
    var endRadius: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay();
        }
    }
    
    var extendsPastStart : Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var extendsPastEnd:Bool  = false{
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var slopeFunction: (Double) -> Double  = LinearInterpolation {
        didSet {
            self.setNeedsDisplay();
        }
    }
    
    var function: GradientFunction = .Linear {
        didSet {
            self.setNeedsDisplay();
        }
    }
    
    
    private var cachedColors : OMGradientShadingColors  = OMGradientShadingColors(colorStart: UIColor.greenColor(), colorEnd: UIColor.greenColor())
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    convenience init(type:GradientType!) {
        self.init()
        self.type = type
    }
    
    // MARK: - Object Overrides
    override init() {
        super.init()
        self.allowsEdgeAntialiasing     = true
        self.contentsScale              = UIScreen.mainScreen().scale
        self.needsDisplayOnBoundsChange = true;
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
        if let other = layer as? OMShadingGradientLayer {
            
            // common
            self.colors      = other.colors
            self.locations   = other.locations
            self.type        = other.type
            
            // radial gradient properties
            self.startPoint  = other.startPoint
            self.startRadius = other.startRadius
            
            // axial gradient properties
            self.endPoint    = other.endPoint
            self.endRadius   = other.endRadius
            self.extendsPastStart    = other.extendsPastStart
            self.extendsPastEnd   = other.extendsPastEnd
            
            self.slopeFunction = other.slopeFunction;
        }
    }
    
    override class func needsDisplayForKey(event: String) -> Bool {
        if (event == OMShadingGradientLayerProperties.startPoint ||
            event == OMShadingGradientLayerProperties.startRadius ||
            event == OMShadingGradientLayerProperties.locations   ||
            event == OMShadingGradientLayerProperties.colors      ||
            event == OMShadingGradientLayerProperties.endPoint   ||
            event == OMShadingGradientLayerProperties.endRadius) {
            return true
        }
        
        return super.needsDisplayForKey(event)
    }
    
    override func actionForKey(event: String) -> CAAction? {
        if (event == OMShadingGradientLayerProperties.startPoint ||
            event == OMShadingGradientLayerProperties.startRadius ||
            event == OMShadingGradientLayerProperties.locations   ||
            event == OMShadingGradientLayerProperties.colors      ||
            event == OMShadingGradientLayerProperties.endPoint   ||
            event == OMShadingGradientLayerProperties.endRadius) {
            return animationActionForKey(event);
        }
        return super.actionForKey(event)
    }
    
    override func drawInContext(ctx: CGContext) {
        super.drawInContext(ctx)
        
        if let player = self.presentationLayer() as? OMShadingGradientLayer {
            #if DEBUG
                print("drawing presentationLayer\n\(player)")
            #endif
            cachedColors  = OMGradientShadingColors(colorStart: player.colors.first!, colorEnd: player.colors.last!)
            
            locations    = player.locations
            startPoint   = player.startPoint
            endPoint     = player.endPoint
            startRadius  = player.startRadius
            endRadius    = player.endRadius
            
        } else {
            cachedColors  = OMGradientShadingColors(colorStart: colors.first!, colorEnd: colors.last!)
        }
        
        #if DEBUG
            print("Drawing \(self.type) gradient\nstarCenter: \(startCenter)\nendCenter: \(endCenter)\nstartRadius: \(startRadius)\n endRadius: \(endRadius)\nbounds: \(self.bounds.integral)\nanchorPoint: \(self.anchorPoint)")
        #endif
        
        if (self.path != nil) {
            
            let axially = (self.type == .Radial) ? false : true
            ctx.fill( self.path!,
                      colors: self.cachedColors,
                      axially: axially,
                      asStroke: self.stroke,
                      lineWidth:self.lineWidth,
                      fromPoint: startPoint, fromRadius: startRadius, toPoint: endPoint, toRadius: endRadius, extendingStart: self.extendsPastStart, extendingEnd: self.extendsPastEnd,functionType:
                self.function,
                      slopeFunction: self.slopeFunction);
        } else {
            var shading = OMShadingGradient(startColor: cachedColors.colorStart,
                                            endColor: cachedColors.colorEnd,
                                            from: startPoint,
                                            startRadius: startRadius,
                                            to:endPoint,
                                            endRadius: endRadius,
                                            extendStart: extendsPastStart,
                                            extendEnd: extendsPastEnd,
                                            functionType: self.function,
                                            gradientType: self.type ,
                                            slopeFunction: slopeFunction)
            
            CGContextDrawShading(ctx, shading.CGShading);
        }
        
    }
    
    override var description:String {
        get {
            var str:String = "type: \(self.type)"
            if (locations != nil) {
                str += "\(locations)"
            }
            if (colors.count > 0) {
                str += "\(colors)"
            }
            if (self.type == .Radial) {
                str += " start from : \(startPoint) to \(endPoint), radius from : \(startRadius) to \(endRadius)"
            }
            if  (self.extendsPastEnd)  {
                str += " draws after end location"
            }
            if  (self.extendsPastStart)  {
                str += " draws before start location"
            }
            if  (self.function == .Linear)  {
                str += " linear interpolation"
            }else{
                str += " exponential interpolation"
            }
            //if  (self.slopeFunction)  {
            //    str += " \(slopeFunction)"
            //}
            return str
        }
    }
    
//    // MARK: - CALayer Animation Helpers
//    
//    override func animationActionForKey(event:String!) -> CABasicAnimation! {
//        let animation = CABasicAnimation(keyPath: event)
//        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
//        animation.fromValue = self.presentationLayer()!.valueForKey(event);
//        return animation
//    }
//    
//    override func animateKeyPath(keyPath : String, fromValue : AnyObject?, toValue:AnyObject?, beginTime:NSTimeInterval, duration:NSTimeInterval, delegate:AnyObject?)
//    {
//        let animation = CABasicAnimation(keyPath:keyPath);
//        
//        var currentValue: AnyObject? = self.presentationLayer()?.valueForKey(keyPath)
//        
//        if (currentValue == nil) {
//            currentValue = fromValue
//        }
//        
//        animation.fromValue = currentValue
//        animation.toValue   = toValue
//        animation.delegate  = delegate
//        
//        if(duration > 0.0){
//            animation.duration = duration
//        }
//        if(beginTime > 0.0){
//            animation.beginTime = beginTime
//        }
//        
//        animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear)
//        animation.setValue(self,forKey:keyPath)
//        
//        self.addAnimation(animation, forKey:keyPath)
//        
//        self.setValue(toValue,forKey:keyPath)
//    }
}
