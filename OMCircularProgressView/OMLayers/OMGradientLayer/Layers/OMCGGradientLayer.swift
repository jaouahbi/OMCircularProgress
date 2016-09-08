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

open class OMCGGradientLayer : OMGradientLayer {
    
    convenience public init(type:OMGradientType) {
        self.init()
        self.gradientType = type
    }
    
    // MARK: - Object Overrides
    override public init() {
        super.init()
    }
    
    //Defaults to 0. Animatable.
    open  var options: CGGradientDrawingOptions = CGGradientDrawingOptions(rawValue:0) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    // MARK: - Object Helpers
    override open var extendsBeforeStart : Bool  {
        set(newValue) {
            let isBitSet = (self.options.rawValue & CGGradientDrawingOptions.drawsBeforeStartLocation.rawValue ) != 0
            if (newValue != isBitSet) {
                if newValue {
                    // add bits to mask
                    let newOptions = (self.options.rawValue | CGGradientDrawingOptions.drawsBeforeStartLocation.rawValue)
                    self.options   = CGGradientDrawingOptions(rawValue:newOptions);
                } else {
                    // remove bits from mask
                    let newOptions  = (self.options.rawValue & ~CGGradientDrawingOptions.drawsBeforeStartLocation.rawValue)
                    self.options    = CGGradientDrawingOptions(rawValue:newOptions);
                }
                self.setNeedsDisplay();
            }
        }
        get {
            return (self.options.rawValue & CGGradientDrawingOptions.drawsBeforeStartLocation.rawValue) != 0
        }
    }
    
    override open var extendsPastEnd:Bool {
        set(newValue) {
            let isBitSet = (self.options.rawValue & CGGradientDrawingOptions.drawsAfterEndLocation.rawValue ) != 0
            if (newValue != isBitSet) {
                if newValue {
                    let newOptions = (self.options.rawValue | CGGradientDrawingOptions.drawsAfterEndLocation.rawValue)
                    self.options   = CGGradientDrawingOptions(rawValue:newOptions);
                } else {
                    let newOptions = (self.options.rawValue & ~CGGradientDrawingOptions.drawsAfterEndLocation.rawValue)
                    self.options   = CGGradientDrawingOptions(rawValue:newOptions);
                }
                setNeedsDisplay();
            }
        }
        get {
            return (self.options.rawValue & CGGradientDrawingOptions.drawsAfterEndLocation.rawValue) != 0
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override init(layer: Any) {
        super.init(layer: layer as AnyObject)
        if let other = layer as? OMCGGradientLayer {
            self.gradientType        = other.gradientType
            self.options     = other.options
        }
    }
    
    override open func draw(in ctx: CGContext) {
        
        super.draw(in: ctx)
        
        var locations   :[CGFloat]? = self.locations
        var colors      :[UIColor]  = self.colors
        var startPoint  : CGPoint   = self.startPoint
        var endPoint    : CGPoint   = self.endPoint
        var startRadius : CGFloat   = self.startRadius
        var endRadius   : CGFloat   = self.endRadius
        
        let player = self.presentation()
        
        if let player = player {
            SpeedLog.print("drawing presentationLayer\n\(player)")
            
            colors       = player.colors
            locations    = player.locations
            startPoint   = player.startPoint
            endPoint     = player.endPoint
            startRadius  = player.startRadius
            endRadius    = player.endRadius
            
        } else {
            SpeedLog.print("drawing modelLayer\n\(self)")
        }
    
        if (isDrawable()) {
            
            var gradient = OMGradient(colors: colors, locations: locations)
            
            if let gradient = gradient.gradient {
                ctx.saveGState()
                addPathAndClipIfNeeded(ctx)
                if (self.isRadial) {
                    // The starting circle has radius `startRadius' and is centered at
                    // `start', specified in the shading's target coordinate space. The ending
                    // circle has radius `endRadius' and is centered at `end', specified in the
                    // shading's target coordinate space.
                    let startCenter = startPoint * self.bounds.size
                    let endCenter   = endPoint   * self.bounds.size
                    ctx.drawRadialGradient(gradient,
                                                startCenter: startCenter,
                                                startRadius: startRadius ,
                                                endCenter: endCenter,
                                                endRadius: endRadius ,
                                                options: self.options );
                } else {
                    ctx.scaleBy(x: self.bounds.size.width,
                                      y: self.bounds.size.height );
                    
                    ctx.drawLinearGradient(gradient,
                                                start: startPoint,
                                                end: endPoint,
                                                options: self.options);
                }
                // restore the context
                ctx.restoreGState();
            }
        }
    }    
}
