//
//  OMLayerShadow.swift
//  Test
//
//  Created by Jorge on 7/12/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import Foundation


extension OMLayer
{
    
    func correctedShadowOffsetForRotatedViewWithAngle(anAngle:Double,anOffset:CGSize)-> CGSize {
        let x = anOffset.height*CGFloat(sin(anAngle)) + anOffset.width*CGFloat(cos(anAngle));
        let y = anOffset.height*CGFloat(cos(anAngle)) - anOffset.width*CGFloat(sin(anAngle));
        return CGSize(width: x, height: y)
    }
    
    func setPlainShadow() {
        shadowColor = UIColor.blackColor().CGColor
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
        
        
        shadowPath = path.CGPath
        shadowColor = UIColor.blackColor().CGColor
        shadowOpacity = 0.2
        shadowRadius = 5
        shadowOffset = CGSize(width: 0, height: 0)
    }
    
    func setCurvedShadow() {
        let size = bounds.size
        let width = size.width
        let height = size.height
        let depth = CGFloat(11.0)
        let lessDepth = 0.8 * depth
        let curvyness = CGFloat(5)
        let radius = CGFloat(1)
        
        let path = UIBezierPath()
        
        // top left
        path.moveToPoint(CGPoint(x: radius, y: height))
        
        // top right
        path.addLineToPoint(CGPoint(x: width - 2*radius, y: height))
        
        // bottom right + a little extra
        path.addLineToPoint(CGPoint(x: width - 2*radius, y: height + depth))
        
        // path to bottom left via curve
        path.addCurveToPoint(CGPoint(x: radius, y: height + depth),
            controlPoint1: CGPoint(x: width - curvyness, y: height + lessDepth - curvyness),
            controlPoint2: CGPoint(x: curvyness, y: height + lessDepth - curvyness))
        
        shadowPath = path.CGPath
        shadowColor = UIColor.blackColor().CGColor
        shadowOpacity = 0.3
        shadowRadius = radius
        shadowOffset = correctedShadowOffsetForRotatedViewWithAngle(self.angleOrientation,
            anOffset: CGSize(width: 0, height: -3))

    }
    
    override var bounds : CGRect {
        didSet {
            super.bounds = bounds
            //setCurvedShadow()
        }
    }
}