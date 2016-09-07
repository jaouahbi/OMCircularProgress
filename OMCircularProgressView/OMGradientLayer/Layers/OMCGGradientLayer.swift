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

public class OMCGGradientLayer : OMGradientLayer {
    
    convenience public init(type:OMGradientType) {
        self.init()
        self.gradientType = type
    }
    
    // MARK: - Object Overrides
    override public init() {
        super.init()
    }
    
    //Defaults to 0. Animatable.
    public  var options: CGGradientDrawingOptions = CGGradientDrawingOptions(rawValue:0) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    // MARK: - Object Helpers
    override public var extendsBeforeStart : Bool  {
        set(newValue) {
            let isBitSet = (self.options.rawValue & CGGradientDrawingOptions.DrawsBeforeStartLocation.rawValue ) != 0
            if (newValue != isBitSet) {
                if newValue {
                    // add bits to mask
                    let newOptions = (self.options.rawValue | CGGradientDrawingOptions.DrawsBeforeStartLocation.rawValue)
                    self.options   = CGGradientDrawingOptions(rawValue:newOptions);
                } else {
                    // remove bits from mask
                    let newOptions  = (self.options.rawValue & ~CGGradientDrawingOptions.DrawsBeforeStartLocation.rawValue)
                    self.options    = CGGradientDrawingOptions(rawValue:newOptions);
                }
                self.setNeedsDisplay();
            }
        }
        get {
            return (self.options.rawValue & CGGradientDrawingOptions.DrawsBeforeStartLocation.rawValue) != 0
        }
    }
    
    override public var extendsPastEnd:Bool {
        set(newValue) {
            let isBitSet = (self.options.rawValue & CGGradientDrawingOptions.DrawsAfterEndLocation.rawValue ) != 0
            if (newValue != isBitSet) {
                if newValue {
                    let newOptions = (self.options.rawValue | CGGradientDrawingOptions.DrawsAfterEndLocation.rawValue)
                    self.options   = CGGradientDrawingOptions(rawValue:newOptions);
                } else {
                    let newOptions = (self.options.rawValue & ~CGGradientDrawingOptions.DrawsAfterEndLocation.rawValue)
                    self.options   = CGGradientDrawingOptions(rawValue:newOptions);
                }
                setNeedsDisplay();
            }
        }
        get {
            return (self.options.rawValue & CGGradientDrawingOptions.DrawsAfterEndLocation.rawValue) != 0
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
        if let other = layer as? OMCGGradientLayer {
            self.gradientType        = other.gradientType
            self.options     = other.options
        }
    }
    
    override public func drawInContext(ctx: CGContext) {
        
        super.drawInContext(ctx)
        
        var locations   :[CGFloat]? = self.locations
        var colors      :[UIColor]  = self.colors
        var startPoint  : CGPoint   = self.startPoint
        var endPoint    : CGPoint   = self.endPoint
        var startRadius : CGFloat   = self.startRadius
        var endRadius   : CGFloat   = self.endRadius
        
        if let player = presentationLayer() as? OMCGGradientLayer {
            #if DEBUG_VERBOSE
                print("drawing presentationLayer\n\(player)")
            #endif
            
            colors       = player.colors
            locations    = player.locations
            startPoint   = player.startPoint
            endPoint     = player.endPoint
            startRadius  = player.startRadius
            endRadius    = player.endRadius
            
        } else {
            #if DEBUG_VERBOSE
                print("drawing modelLayer\n\(self)")
            #endif
        }
    
        if (canDrawGradient()) {
            if (startRadius == endRadius && self.isRadial) {
                // nothing to do
                #if VERBOSE
                    print("Start radius and end radius are equal. \(startRadius) \(endRadius)")
                #endif
                return
            }

            if let gradient = OMGradient(colors: colors, locations: locations).CGGradient {
                CGContextSaveGState(ctx)
                addPathAndClipIfNeeded(ctx)
                if (self.isRadial) {
                    // The location 0 of `gradient' corresponds to a circle centered at
                    //`startCenter' with radius `startRadius'
                    let startCenter = startPoint * self.bounds.size
                    let endCenter   = endPoint   * self.bounds.size
                    CGContextDrawRadialGradient(ctx,
                                                gradient,
                                                startCenter,
                                                startRadius ,
                                                endCenter,
                                                endRadius ,
                                                self.options );
                } else {
                    CGContextScaleCTM(ctx,
                                      self.bounds.size.width,
                                      self.bounds.size.height );
                    
                    CGContextDrawLinearGradient(ctx,
                                                gradient,
                                                startPoint,
                                                endPoint,
                                                self.options);
                }
                // restore the context
                CGContextRestoreGState(ctx);
            }
        }
    }    
}
