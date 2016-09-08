
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

//  OMAngle.swift
//
//  Created by Jorge Ouahbi on 24/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit


/**
 * Constants
 *
 */

let π     = M_PI
let π_2   = M_PI_2
let π_4   = M_PI_4

/**
 * Angle alignment
 *
 * start : Align to start of the angle
 * middle: Align to middle of the angle
 * end   : Align to the end of the angle
 */

public enum OMAngleAlign: Int
{
    case start
    case middle
    case end
    init() {
        self = .middle
    }
}

/**
 * Object that encapsulate a angle
 */

open class OMAngle : CustomDebugStringConvertible
{
    var start:Double = 0.0                // start of angle in radians
    var end:Double   = 0.0                // end of angle in radians
    
    // MARK: Contructors
    
    convenience init(startAngle:Double,endAngle:Double){
        self.init()
        start = startAngle
        end = endAngle;
    }
    
    convenience init(startAngle:Double,length:Double){
        self.init()
        start = startAngle
        end = startAngle+length;
    }
    
    /**
     * Get the angle arc length
     *
     * returns: return the angle arc length
     */
    func arc(_ radius:CGFloat) -> Double {
        return length() / Double(radius)
    }
    
    /**
     * Add radians to the angle
     */
    func add(_ len:Double){
        end += len;
    }
    
    /**
     * Get the middle angle length
     *
     * returns: return middle angle length in radians
     */
    
    func mid() -> Double {
        let len = length()
        return start + (len * 0.5)
    }
    
    /**
     * Get the angle length
     *
     * returns: return angle length in radians
     */
    
    func length() -> Double {
        return end - start
    }
    
    /**
     * Get the normalized angle
     *
     * returns: return angle length in radians
     */
    
    func norm() -> Double {
        return start / 𝜏
    }
    
    /**
     * Check if the angle is valid
     *
     * returns: return if the angle is valid
     */
    
    func valid() -> Bool {
        return length() > 0.0
    }
    
    /**
     * Check if the angle is in range +/- M_PI*2
     *
     * parameter angle: angle to check
     *
     * returns: return if the angle is in range
     */
    
    func angleInCircle() -> Bool {
        return (self.end > 𝜏 || self.start < -𝜏) == false
    }
    
    /**
     * Aling angle to OMAngleAlign
     *
     * parameter angle: angle object
     * parameter align: angle align
     *
     * returns: angle anligned to .OMAngleAlign
     */
    
    func align(_ align:OMAngleAlign) -> Double {
        var resultAngle: Double = self.mid()
        switch(align) {
        case .middle:
            resultAngle = self.mid()
            break;
        case .start:
            resultAngle = self.start
            break;
        case .end:
            resultAngle = self.end
            break;
        }
        return resultAngle;
    }

    // MARK: DebugPrintable protocol
    
    open var debugDescription: String {
        let sizeOfAngle = round(length().radiansToDegrees())
        let degreeS     = round(start.radiansToDegrees());
        let degreeE     = round(end.radiansToDegrees());
        return "[\(degreeS)° - \(degreeE)°] : \(sizeOfAngle)°"
    }

}
