//
//  BP.swift
//  ExampleSwift
//
//  Created by Jorge on 30/3/15.
//  Copyright (c) 2015 none. All rights reserved.
//

import UIKit

extension UIBezierPath {
    
    func drawInnerShadowInContext(context:CGContextRef,shadowColor:CGColorRef,offset:CGSize,blur:CGFloat)
    {
        assert(blur >= 0, "Must be a non-negative number")
        
        CGContextSaveGState(context);
        
        CGContextAddPath(context, self.CGPath);
        CGContextClip(context);
        
        let opaqueShadowColor = CGColorCreateCopyWithAlpha(shadowColor, 1.0);
        
        CGContextSetAlpha(context, CGColorGetAlpha(shadowColor));
        CGContextBeginTransparencyLayer(context, nil);
        CGContextSetShadowWithColor(context, offset, blur, opaqueShadowColor);
        CGContextSetBlendMode(context, kCGBlendModeSourceOut);
        CGContextSetFillColorWithColor(context, opaqueShadowColor);
        CGContextAddPath(context, self.CGPath);
        CGContextFillPath(context);
        CGContextEndTransparencyLayer(context);
        
        CGContextRestoreGState(context);
    }
    
    func containsPoint(point:CGPoint, inFillArea:Bool) -> Bool
    {
        let rect = CGPathGetPathBoundingBox(self.CGPath)
        
        UIGraphicsBeginImageContext(rect.size);
        
        let context = UIGraphicsGetCurrentContext();
        let cgPath = self.CGPath;
        var isHit:Bool = false;
    
        // Determine the drawing mode to use. Default to
        // detecting hits on the stroked portion of the path.
        var mode:CGPathDrawingMode = kCGPathStroke
        
        if (inFillArea) {
            // Look for hits in the fill area of the path instead.
            if (self.usesEvenOddFillRule){
                mode = kCGPathEOFill;
            }else{
                mode = kCGPathFill;
            }
        }
    
        // Save the graphics state so that the path can be
        // removed later.
        CGContextSaveGState(context);
        CGContextAddPath(context, cgPath);
    
        // Do the hit detection.
        isHit = CGContextPathContainsPoint(context, point, mode);
        
        CGContextRestoreGState(context);
        
        UIGraphicsEndImageContext(); // ADD THIS
        
        return isHit;
    }
}
