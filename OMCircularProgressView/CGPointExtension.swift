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

//
//  CGPointExtension.swift
//
//  Created by Jorge Ouahbi on 22/2/15.
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
    
    public func center(size:CGSize) -> CGPoint {
        return CGPoint(x:self.x - size.width  * 0.5, y:self.y - size.height * 0.5);
    }
    
    public func centerRect(size:CGSize) -> CGRect{
        
        return CGRect(origin: self.center(size), size:size)
    }
}
