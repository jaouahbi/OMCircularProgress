//
//  GTMNSBezierPath+Shading.m
//
//  Category for radial and axial stroke and fill functions for NSBezierPaths
//
//  Copyright 2006-2008 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//
import UIKit


//
////  Fills a CGPathRef either axially or radially with the given shading.
////
////  Args:
////    path: path to fill
////    axially: if YES fill axially, otherwise fill radially
////    asStroke: if YES, clip to the stroke of the path, otherwise
////                        clip to the fill
////    from: where to shade from
////    fromRadius: in a radial fill, the radius of the from circle
////    to: where to shade to
////    toRadius: in a radial fill, the radius of the to circle
////    extendingStart: if true, extend the fill with the first color of the shade
////                    beyond |from| away from |to|
////    extendingEnd: if true, extend the fill with the last color of the shade
////                    beyond |to| away from |from|
////    shading: the shading to use for the fill
////
//- (void)gtm_fillCGPath:(CGPathRef)path
//               axially:(BOOL)axially
//              asStroke:(BOOL)asStroke
//                  from(fromPoint:CGPoint fromRadius:(CGFloat)fromRadius
//                    to:(NSPoint)toPoint toRadius:(CGFloat)toRadius
//        extendingStart:(BOOL)extendingStart extendingEnd:(BOOL)extendingEnd
//               shading:(id<GTMShading>)shading;
//
////  Returns the point which is the projection of a line from point |pointA|
////  to |pointB| by length
////
////  Args:
////    pointA: first point
////    pointB: second point
////    length: distance to project beyond |pointB| which is in line with
////            |pointA| and |pointB|
////
////  Returns:
////    the projected point
//- (NSPoint)gtm_projectLineFrom:(NSPoint)pointA
//                            to:(NSPoint)pointB
//                            by:(CGFloat)length;

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
            from = projectLineFrom(toPoint,pointB: fromPoint,length: halfWidth)
            to   = projectLineFrom(fromPoint,pointB: toPoint,length: -halfWidth)
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
    
    
    func projectLineFrom(pointA :CGPoint,
                         pointB :CGPoint,
                         length:CGFloat) -> CGPoint  {
        var newPoint = CGPointMake(pointB.x, pointB.y)
        let x = (pointB.x - pointA.x);
        let y = (pointB.y - pointA.y);
        if (fpclassify(x) == Int(FP_ZERO)) {
            newPoint.y += length;
        } else if (fpclassify(y) == Int(FP_ZERO)) {
            newPoint.x += length;
        } else {
            #if CGFLOAT_IS_DOUBLE
                let angle = atan(y / x);
                newPoint.x += sin(angle) * length;
                newPoint.y += cos(angle) * length;
            #else
                let angle = atanf(Float(y) / Float(x));
                newPoint.x += CGFloat(sinf(angle) * Float(length));
                newPoint.y += CGFloat(cosf(angle) * Float(length));
            #endif
        }
        return newPoint;
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
