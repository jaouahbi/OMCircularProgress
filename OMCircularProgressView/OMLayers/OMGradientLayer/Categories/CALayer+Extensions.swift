//
//  CALayer+Extensions.swift
//
//  Created by Jorge Ouahbi on 24/8/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

import UIKit

extension CALayer
{
    func animatingRefreshes(_ flag:Bool) {
        if(flag) {
            self.actions = nil;
        } else {
            // Disable animating view refreshes
            self.actions = [
                "position"      :    NSNull(),
                "bounds"        :    NSNull(),
                "contents"      :    NSNull(),
                "shadowColor"   :    NSNull(),
                "shadowOpacity" :    NSNull(),
                "shadowOffset"  :    NSNull() ,
                "shadowRadius"  :    NSNull()]
        }
    }
}

extension CALayer
{
    /// Radians
    
    func concatTransformRotationZ(_ z:Double = 0.0) {
        self.transform = CATransform3DConcat(self.transform,  CATransform3DMakeRotation(CGFloat(z), 0.0, 0.0, 1.0))
    }
    func setTransformRotationZ(_ z:Double = 0.0) {
        self.transform = CATransform3DMakeRotation(CGFloat(z), 0.0, 0.0, 1.0)
    }
    
    func getTransformRotationZ() -> Double {
        return atan2(Double(transform.m12), Double(transform.m11))
    }
}


extension CATransformLayer
{
    /** This function performs the transformation on each plane **/
    func transformSublayers(angle:Double, prespective:CGFloat) {
        
        assert(self.isKind(of: CATransformLayer.self),"Unexpected layer")
        
        if !self.isKind(of: CATransformLayer.self) {
            // nothing to transform
            return ;
        }
        
        if let sublayers = self.sublayers {
            
            //Define the degrees needed for each plane to create a circle
            let degForPlane:Double = Double(M_PI * 2) / Double(sublayers.count)
            
            //The current angle offset (initially it is 0... it will change through the pan function)
            var theAngle = angle;
            
            for (_, layer) in sublayers.enumerated() {
                
                layer.isDoubleSided = true
                //Create the Matrix identity
                var  newTransform = CATransform3DIdentity;
                //Setup the perspective modifying the matrix elementat [3][4]
                newTransform.m34 = prespective
                //Perform rotate on the matrix identity
                newTransform = CATransform3DRotate(newTransform,
                                                   CGFloat(theAngle),
                                                   CGFloat(0.0),
                                                   CGFloat(0.1),
                                                   CGFloat(0.0));
            
                //concat the transform with the current layer transform.
                layer.transform = CATransform3DConcat(layer.transform, newTransform)
                //Add the degree needed for the next plane
                theAngle += degForPlane;
            }
        }
    }
}

// from: https://nachbaur.com/2010/11/16/fun-shadow-effects-using-custom-calayer-shadowpaths/

extension CALayer {

    func setRectangularShadow(_ color:UIColor =  UIColor.black,
                              offset:CGSize = CGSize(width: 10.0, height: 10.0),
                              opacity:Float = 0.7,
                              radius:CGFloat = 5.0) {
        self.shadowColor = color.cgColor
        self.shadowOpacity = opacity;
        self.shadowOffset = offset;
        self.shadowRadius = radius;
        self.masksToBounds = false;
        let path = UIBezierPath(rect:self.bounds)
        self.shadowPath = path.cgPath;
    }
    
    func setEllipticalShadow(_ color:UIColor =  UIColor.black,
        offset:CGSize = CGSize(width: 10.0, height: 10.0),
        opacity:Float = 0.7,
        radius:CGFloat = 5.0) {
        self.shadowColor = color.cgColor
        self.shadowOpacity = opacity;
        self.shadowOffset = offset;
        self.shadowRadius = radius;
        self.masksToBounds = false;
        let size = self.bounds.size;
        let ovalRect = CGRect(x: 0.0, y: size.height + 5, width: size.width - 10, height: 15);
        let path = UIBezierPath (ovalIn: ovalRect)
        self.shadowPath = path.cgPath;
    }
    
    func setTrapezoidalShadow(_ color:UIColor =  UIColor.black,
                              offset:CGSize = CGSize(width: 10.0, height: 10.0),
                              opacity:Float = 0.7,
                              radius:CGFloat = 5.0) {
        self.shadowColor = color.cgColor
        self.shadowOpacity = opacity;
        self.shadowOffset = offset;
        self.shadowRadius = radius;
        self.masksToBounds = false;
        let size = self.bounds.size;
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size.width * 0.33, y: size.height * 0.66))
        path.addLine(to: CGPoint(x: size.width * 0.66, y: size.height * 0.66))
        path.addLine(to: CGPoint(x: size.width * 1.15, y: size.height * 1.15))
        path.addLine(to: CGPoint(x: size.width * -0.15, y: size.height * 1.15))
        self.shadowPath = path.cgPath;
    }
    
    func setPaperCurlShadow(_ color:UIColor =  UIColor.black,
                            offset:CGSize = CGSize(width: 10.0, height: 10.0),
                            opacity:Float = 0.7,
                            radius:CGFloat = 5.0) {
        self.shadowColor = color.cgColor
        self.shadowOpacity = opacity;
        self.shadowOffset = offset;
        self.shadowRadius = radius;
        self.masksToBounds = false;
        let size = self.bounds.size;
        let curlFactor:CGFloat = 15.0;
        let shadowDepth:CGFloat = 5.0;
        let path = UIBezierPath();
        path.move(to: CGPoint.zero);
        path.addLine(to: CGPoint(x: size.width, y: 0.0));
        path.addLine(to: CGPoint(x: size.width, y: size.height + shadowDepth));
        path.addCurve(to: CGPoint(x: 0.0, y: size.height + shadowDepth),
                      controlPoint1:CGPoint(x: size.width - curlFactor, y: size.height + shadowDepth - curlFactor),
                      controlPoint2:CGPoint(x: curlFactor, y: size.height + shadowDepth - curlFactor))
        self.shadowPath = path.cgPath;
    }
    
    func correctedShadowOffsetForRotatedViewWithAngle(_ anAngle:Double,anOffset:CGSize)-> CGSize {
        let x = anOffset.height*CGFloat(sin(anAngle)) + anOffset.width*CGFloat(cos(anAngle));
        let y = anOffset.height*CGFloat(cos(anAngle)) - anOffset.width*CGFloat(sin(anAngle));
        return CGSize(width: x, height: y)
    }
    
    func setPlainShadow() {
        shadowColor = UIColor.black.cgColor
        shadowOffset = CGSize(width: 0, height: 10)
        shadowOpacity = 0.4
        shadowRadius = 5
    }
    
    func setHoverShadow() {
        let size = self.bounds.size
        let width = size.width
        let height = size.height
        
        let ovalRect = CGRect(x: 5, y: height + 5, width: width - 10, height: 15)
        let path = UIBezierPath(roundedRect: ovalRect, cornerRadius: 10)
        
        
        shadowPath = path.cgPath
        shadowColor = UIColor.black.cgColor
        shadowOpacity = 0.2
        shadowRadius = 5
        shadowOffset = CGSize(width: 0, height: 0)
    }
    
    func setCurvedShadow(radius:CGFloat = 1,
                         depth:CGFloat = 11.0,
                         curvyness:CGFloat = 1,
                         opacity:CGFloat = 0.5,
                         offset:CGSize = CGSize(width: 0, height: -3),
                         color:UIColor = UIColor.black) {
        let size = bounds.size
        let width = size.width
        let height = size.height
        let lessDepth = 0.8 * depth

        let path = UIBezierPath()
        
        // top left
        path.move(to: CGPoint(x: radius, y: height))
        
        // top right
        path.addLine(to: CGPoint(x: width - 2*radius, y: height))
        
        // bottom right + a little extra
        path.addLine(to: CGPoint(x: width - 2*radius, y: height + depth))
        
        // path to bottom left via curve
        path.addCurve(to: CGPoint(x: radius, y: height + depth),
                      controlPoint1: CGPoint(x: width - curvyness, y: height + lessDepth - curvyness),
                      controlPoint2: CGPoint(x: curvyness, y: height + lessDepth - curvyness))
        
        shadowPath      = path.cgPath
        shadowColor     = color.cgColor
        shadowOpacity   = Float(opacity)
        shadowRadius    = radius
        shadowOffset    = offset
        //shadowOffset    = correctedShadowOffsetForRotatedViewWithAngle(getTransformRotationZ(),
        //                                                            anOffset: offset)
        
    }
    
//    func setInnerShadow()
//    {
//        
//        let shadowLayer = CAShapeLayer()
//        shadowLayer.frame=bounds
//        
//        // Standard shadow stuff
//        shadowLayer.shadowColor = UIColor(white:0, alpha:1).cgColor;
//        shadowLayer.shadowOffset = CGSize(width:0.0, height:0.0);
//        shadowLayer.shadowOpacity = 1.0;
//        shadowLayer.shadowRadius = 5;
//        
//        // Causes the inner region in this example to NOT be filled.
//        shadowLayer.fillRule = kCAFillRuleEvenOdd;
//        
//        // Create the larger rectangle path.
//        let path = CGMutablePath();
//        path.addRect( bounds.insetBy(dx: -42, dy: -42));
//        
//        let someInnerPath = CGMutablePath();
//        someInnerPath.addRect( bounds);
//        
//        // Add the inner path so it's subtracted from the outer path.
//        // someInnerPath could be a simple bounds rect, or maybe
//        // a rounded one for some extra fanciness.
//        path.addPath(someInnerPath);
//        path.closeSubpath();
//        
//        shadowLayer.path = path
//        
//        self.addSublayer(shadowLayer)
//        
//        let maskLayer = CAShapeLayer()
//        maskLayer.path = someInnerPath
//        shadowLayer.mask = maskLayer;
//    }
    
}


