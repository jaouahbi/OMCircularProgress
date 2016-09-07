//
//  CALayer+Shadow.swift
//
//  Created by Jorge Ouahbi on 24/8/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

import UIKit


// from: https://nachbaur.com/2010/11/16/fun-shadow-effects-using-custom-calayer-shadowpaths/

extension CALayer {
    
    func setShadow(color:UIColor =  UIColor.blackColor(),
                  offset:CGSize = CGSizeMake(10.0, 10.0),
                 opacity:Float = 0.7,
                  radius:CGFloat = 5.0) {
        self.shadowColor = color.CGColor
        self.shadowOpacity = opacity;
        self.shadowOffset = offset;
        self.shadowRadius = radius;
        self.masksToBounds = false;
    }
    
    func setRectangularShadow() {
        setShadow()
        let path = UIBezierPath(rect:self.bounds)
        self.shadowPath = path.CGPath;
    }
    
    func setEllipticalShadow() {
        setShadow()
        let size = self.bounds.size;
        let ovalRect = CGRectMake(0.0, size.height + 5, size.width - 10, 15);
        let path = UIBezierPath (ovalInRect: ovalRect)
        self.shadowPath = path.CGPath;
    }
    
    func setTrapezoidalShadow() {
        setShadow()
        let size = self.bounds.size;
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(size.width * 0.33, size.height * 0.66))
        path.addLineToPoint(CGPointMake(size.width * 0.66, size.height * 0.66))
        path.addLineToPoint(CGPointMake(size.width * 1.15, size.height * 1.15))
        path.addLineToPoint(CGPointMake(size.width * -0.15, size.height * 1.15))
        self.shadowPath = path.CGPath;
    }
    
    func setPaperCurlShadow() {
        setShadow()
        let size = self.bounds.size;
        let curlFactor:CGFloat = 15.0;
        let shadowDepth:CGFloat = 5.0;
        let path = UIBezierPath();
        path.moveToPoint(CGPointZero);
        path.addLineToPoint(CGPointMake(size.width, 0.0));
        path.addLineToPoint(CGPointMake(size.width, size.height + shadowDepth));
        path.addCurveToPoint(CGPointMake(0.0, size.height + shadowDepth),
            controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor),
            controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor))
        self.shadowPath = path.CGPath;
    }
}


