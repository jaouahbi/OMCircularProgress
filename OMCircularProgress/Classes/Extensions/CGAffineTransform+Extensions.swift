//
//  CGAffineTransform+Extensions.swift
//  ExampleSwift
//
//  Created by Jorge Ouahbi on 8/10/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

import UIKit

public extension CGAffineTransform {
    static func randomRotate() -> CGAffineTransform {
        return CGAffineTransform(rotationAngle: CGFloat((drand48() * 360.0).degreesToRadians()))
    }
    static func randomScale(scaleXMax:CGFloat = 16,scaleYMax:CGFloat = 16) -> CGAffineTransform {
        let scaleX  = (CGFloat(drand48()) *  scaleXMax) +  1.0
        let scaleY  = (CGFloat(drand48()) *  scaleYMax) +  1.0
        
        let flip:CGFloat = drand48() < 0.5 ? -1 : 1
        return CGAffineTransform(scaleX: scaleX, y:scaleY * flip)
    }
}
