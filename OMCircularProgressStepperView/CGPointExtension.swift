//
//  CGPointExtension.swift
//  ExampleSwift
//
//  Created by Jorge Ouahbi on 22/2/15.
//  Copyright (c) 2015 Jorge Ouahbi. All rights reserved.
//

import CoreGraphics


/**
* Subtracts two CGPoint values and returns the result as a new CGPoint.
*/
public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}


extension CGPoint
{
    /**
    * Given an angle in radians, creates a vector of length 1.0 and returns the
    * result as a new CGPoint. An angle of 0 is assumed to point to the right.
    */
    public init(angle: CGFloat) {
        self.init(x: cos(angle), y: sin(angle))
    }

    /**
    * Returns the angle in radians of the vector described by the CGPoint.
    * The range of the angle is -π to π; an angle of 0 points to the right.
    */
    public var angle: CGFloat {
        return atan2(y, x)
    }
    
    /**
    * Returns the length (magnitude) of the vector described by the CGPoint.
    */
    public func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    /**
    * Calculates the distance between two CGPoints. Pythagoras!
    */
    public func distanceTo(point: CGPoint) -> CGFloat {
        return (self - point).length()
    }
    
}
