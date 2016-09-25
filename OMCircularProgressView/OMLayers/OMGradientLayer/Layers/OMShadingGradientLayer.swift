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

open class OMShadingGradientLayer : OMGradientLayer {
    
    convenience public init(type:OMGradientType) {
        self.init()
        self.gradientType  = type;
        
        if(type == .radial) {
            self.startPoint = CGPoint(x: 0.5,y: 0.5)
            self.endPoint   = CGPoint(x: 0.5,y: 0.5)
        }
    }
    
    // MARK: - Object Overrides
    override public  init() {
        super.init()
    }
    
    open var slopeFunction: EasingFunction  = Linear {
        didSet {
            self.setNeedsDisplay();
        }
    }
    open var function: GradientFunction = .linear {
        didSet {
            self.setNeedsDisplay();
        }
    }
    
    override public  init(layer: Any) {
        super.init(layer: layer as AnyObject)
        if let other = layer as? OMShadingGradientLayer {
            self.slopeFunction = other.slopeFunction;
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
            
            OMLog.printv("\(self.name ?? "") drawing presentationLayer \(player)")
            
            colors       = player.colors
            locations    = player.locations
            startPoint   = player.startPoint
            endPoint     = player.endPoint
            startRadius  = player.startRadius
            endRadius    = player.endRadius
            
        } else {
           OMLog.printv("\(self.name ?? "") drawing modelLayer \(self)")
        }
        
        if (isDrawable()) {
            
            ctx.saveGState()
            // The starting point of the axis, in the shading's target coordinate space.
            var start:CGPoint = startPoint * self.bounds.size
            // The ending point of the axis, in the shading's target coordinate space.
            var end:CGPoint  = endPoint   * self.bounds.size
            // The context must be clipped before scale the matrix.
            addPathAndClipIfNeeded(ctx)
            
            if (self.isAxial) {
                if(self.stroke) {
                    if(self.path != nil) {
                        // if we are using the stroke, we offset the from and to points
                        // by half the stroke width away from the center of the stroke.
                        // Otherwise we tend to end up with fills that only cover half of the
                        // because users set the start and end points based on the center
                        // of the stroke.
                        let hw = self.lineWidth * 0.5;
                        start  = end.projectLine(start,length: hw)
                        end    = start.projectLine(end,length: -hw)
                    }
                }
                
                ctx.scaleBy(x: self.bounds.size.width,
                            y: self.bounds.size.height );
                
                start  = start / self.bounds.size
                end    = end   / self.bounds.size
            }
            else
            {
                // The starting circle has radius `startRadius' and is centered at
                // `start', specified in the shading's target coordinate space. The ending
                // circle has radius `endRadius' and is centered at `end', specified in the
                // shading's target coordinate space.
                
            }
            
            var shading:OMShadingGradient = OMShadingGradient(colors: colors,
                                                              locations: locations,
                                                              startPoint: start ,
                                                              startRadius: startRadius * minRadius(self.bounds.size),
                                                              endPoint:end ,
                                                              endRadius: endRadius * minRadius(self.bounds.size),
                                                              extendStart: self.extendsBeforeStart,
                                                              extendEnd: self.extendsPastEnd,
                                                              gradientType: self.gradientType,
                                                              functionType: self.function,
                                                              slopeFunction: self.slopeFunction)
            ctx.drawShading(shading.shadingHandle);
            ctx.restoreGState();
        }
    }
    
    override open var description:String {
        get {
            var currentDescription:String = super.description
            if  (self.function == .linear)  {
                currentDescription += " linear interpolation"
            } else if(self.function == .exponential) {
                currentDescription += " exponential interpolation"
            } else if(self.function == .cosine) {
                currentDescription += " cosine interpolation"
            }
            //currentDescription += " \(self.slopeFunction.1)"
            return currentDescription
        }
    }
}
