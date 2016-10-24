
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

extension CGContext
{
    func fill( path : CGPath,
               colors:OMGradientShadingColors,
               axially:Bool,
               asStroke:Bool,
               lineWidth:CGFloat,
               fromPoint:CGPoint,
               fromRadius:CGFloat,
               toPoint:CGPoint,
               toRadius:CGFloat,
               extendingStart:Bool,
               extendingEnd:Bool,
               functionType: GradientFunction,
               slopeFunction: (Double) -> Double)
    {
        
        var from:CGPoint = fromPoint
        var to:CGPoint = toPoint
        
        CGContextSaveGState(self);
        CGContextSetLineWidth(self, lineWidth);
        if (asStroke) {
            // if we are using the stroke, we offset the from and to points
            // by half the stroke width away from the center of the stroke.
            // Otherwise we tend to end up with fills that only cover half of the
            // because users set the start and end points based on the center
            // of the stroke.
            let halfWidth = lineWidth * 0.5;
            from = toPoint.projectLine(fromPoint,length: halfWidth)
            to   = fromPoint.projectLine(toPoint,length: -halfWidth)
        }
        
        var shading = OMShadingGradient(startColor: colors.colorStart,
                                        endColor: colors.colorEnd,
                                        from: from,
                                        startRadius: fromRadius,
                                        to:to,
                                        endRadius: toRadius,
                                        extendStart: extendingStart,
                                        extendEnd: extendingEnd,
                                        functionType: .Linear,
                                        gradientType: axially ? .Axial: .Radial,
                                        slopeFunction: LinearInterpolation)
        
        
        CGContextAddPath(self,path);
        if(asStroke) {
            CGContextReplacePathWithStrokedPath(self);
        }
        CGContextClip(self);
        CGContextDrawShading(self, shading.CGShading);
        CGContextRestoreGState(self);
        
    }

    func strokeAxiallyFrom( path : CGPath,
                            colors:OMGradientShadingColors,
                            lineWidth:CGFloat,
                            fromPoint:CGPoint,
                            toPoint:CGPoint,
                            extendingStart:Bool,
                            extendingEnd:Bool)
    {
        fill(path,colors:colors, axially:true, asStroke:true,lineWidth:lineWidth,
             fromPoint:fromPoint, fromRadius:0.0,
             toPoint:toPoint, toRadius:0.0,
             extendingStart:extendingStart, extendingEnd:extendingEnd, functionType: .Linear,slopeFunction: LinearInterpolation);
    }
    
    
    func fillAxiallyFrom( path : CGPath,
                          colors:OMGradientShadingColors,
                          fromPoint:CGPoint,
                          toPoint:CGPoint,
                          extendingStart:Bool,
                          extendingEnd:Bool)
    {
        fill(path, colors:colors, axially:true, asStroke:false,lineWidth:0,
             fromPoint:fromPoint, fromRadius:0.0,
             toPoint:toPoint, toRadius:0.0,
             extendingStart:extendingStart, extendingEnd:extendingEnd, functionType: .Linear,slopeFunction: LinearInterpolation);
    }
    
    func strokeRadiallyFrom( path : CGPath,
                             colors:OMGradientShadingColors,
                             lineWidth:CGFloat,
                             fromPoint:CGPoint,
                             fromRadius:CGFloat,
                             toPoint:CGPoint,
                             toRadius:CGFloat,
                             extendingStart:Bool,
                             extendingEnd:Bool)
    {
        fill(path, colors:colors, axially:false, asStroke:true,lineWidth:lineWidth,
             fromPoint:fromPoint, fromRadius:fromRadius,
             toPoint:toPoint, toRadius:toRadius,
             extendingStart:extendingStart, extendingEnd:extendingEnd, functionType: .Linear,slopeFunction: LinearInterpolation);
    }
    
    
    func fillRadiallyFrom( path : CGPath,
                           colors:OMGradientShadingColors,
                           fromPoint:CGPoint,
                           fromRadius:CGFloat,
                           toPoint:CGPoint,
                           toRadius:CGFloat,
                           extendingStart:Bool,
                           extendingEnd:Bool)
    {
        fill(path, colors:colors, axially:false, asStroke:false,lineWidth:0,
             fromPoint:fromPoint, fromRadius:fromRadius,
             toPoint:toPoint, toRadius:toRadius,
             extendingStart:extendingStart, extendingEnd:extendingEnd,
             functionType: .Linear,slopeFunction: LinearInterpolation);
    }
}
