
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

//  CPCAngle.swift
//
//  Created by Jorge Ouahbi on 24/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit


/**
 * Constants
 */

let π   = M_PI
let 𝜏   = 2.0 * π

/**
 * Angle position
 *
 * start : start of the angle
 * middle: middle of the angle
 * end   : end of the angle
 */

public enum CPCAnglePosition : Int
{
    case start
    case middle
    case end
    init() {
        self = .middle
    }
}

/// <#Description#>
///
/// - parameter left:  <#left description#>
/// - parameter right: <#right description#>
///
/// - returns: <#return value description#>
func + (left: CPCAngle, right: CPCAngle) -> CPCAngle {
    return CPCAngle(start:left.start,length:left.end+right.length())
}

/// <#Description#>
///
/// - parameter left:  <#left description#>
/// - parameter right: <#right description#>
///
/// - returns: <#return value description#>
func - (left: CPCAngle, right: CPCAngle) -> CPCAngle {
    return CPCAngle(start:left.start,length:left.end-right.length())
}

/// <#Description#>
///
/// - parameter left:  <#left description#>
/// - parameter right: <#right description#>
///
/// - returns: <#return value description#>
func == (left: CPCAngle, right: CPCAngle) -> Bool {
    return left.start ==  right.start &&  left.end ==  right.end
}


/**
 * Object that encapsulate a angle
 */

open class CPCAngle : CustomDebugStringConvertible {
    
    var start:Double = 0.0                // start of angle in radians
    var end:Double   = 0.0                // end of angle in radians
    
    // MARK: Contructors
    
    /// <#Description#>
    ///
    /// - parameter start: <#start description#>
    /// - parameter end:   <#end description#>
    ///
    /// - returns: <#return value description#>
    convenience init(start:Double, end:Double){
        self.init()
        self.start = start
        self.end   = end;
        
        assert(valid())
    }
    
    /// <#Description#>
    ///
    /// - parameter start:  <#start description#>
    /// - parameter length: <#length description#>
    ///
    /// - returns: <#return value description#>
    convenience init(start:Double, length:Double){
        self.init()
        self.start = start
        self.end   = start+length;
        
        assert(valid())
    }

    /// <#Description#>
    ///
    /// - parameter startDegree: <#startDegree description#>
    /// - parameter endDegree:   <#endDegree description#>
    ///
    /// - returns: <#return value description#>
    convenience init(startDegree:Double, endDegree:Double){
        self.init()
        self.start = startDegree.degreesToRadians()
        self.end   = endDegree.degreesToRadians()
        
        if(!valid()) {
            OMLog.printw("(CPCAngle): Angle overflow. \(self)")
        }
    }
    
    /// <#Description#>
    ///
    /// - parameter startDegree:  <#startDegree description#>
    /// - parameter lengthDegree: <#lengthDegree description#>
    ///
    /// - returns: <#return value description#>
    convenience init(startDegree:Double, lengthDegree:Double){
        self.init()
        let start = startDegree
        let end   = startDegree+lengthDegree
        
        // convert to radians
        self.start =  start.degreesToRadians();
        self.end   =  end.degreesToRadians();
        
        if(!valid()) {
            OMLog.printw("(CPCAngle): Angle overflow. \(self)")
        }
    }
    
    
    /**
     * Get the angle arc length
     *
     * returns: return the angle arc length
     * info   : arc angle = θ / r
     */
    public func arcAngle(_ radius:CGFloat) -> Double {
        return length() / Double(radius)
    }
    
    /**
     * Get angle arc length
     *
     * returns: return the angle arc length
     * info   : arc length = θ × r
     */
    
    public func arcLength(_ radius:CGFloat) -> Double {
        return length() * Double(radius)
    }
    
    /**
     * Add radians to the angle
     */
    public func add(_ len:Double){
        end += len;
        if(!valid()) {
            OMLog.printw("(CPCAngle): Angle overflow. \(self)")
        }
    }
    
    /**
     * Add radians to the angle
     */
    public func sub(_ len:Double){
        end -= len;
        if(!valid()) {
            OMLog.printw("(CPCAngle): Angle overflow. \(self)")
        }
    }
    
    /**
     * Get the middle angle length
     *
     * returns: return middle angle length in radians
     */
    
    public func mid() -> Double {
        let len = length()
        return start + (len * 0.5)
    }
    
    /**
     * Get the angle length
     *
     * returns: return angle length in radians
     */
    
    public func length() -> Double {
        return end - start
    }
    
    /**
     * Check if the angle is valid
     *
     * returns: return if the angle is valid
     */
    
    public func valid() -> Bool {
        let len = length()
        return len >= 0.0 && len <= 𝜏
    }
    
    /// <#Description#>
    ///
    /// - parameter angle: <#angle description#>
    ///
    /// - returns: <#return value description#>
    static func inRange(angle:Double) -> Bool {
        return (angle > 𝜏 || angle < -𝜏) == false
    }
    
    /**
     * Get the normalized angle
     *
     * returns: return angle length in radians
     */
    
    func norm() -> Double {
        return self.start / 𝜏
    }
    
    /// <#Description#>
    ///
    /// - parameter elements: <#elements description#>
    ///
    /// - returns: <#return value description#>
    static func ratio(elements:Double) -> Double {
        return 𝜏 / elements
    }
    
    /// Aling angle to CPCAnglePosition
    ///
    /// - parameter position: position in angle
    ///
    /// - returns: angle anligned to PositionInAngle
    public func angle(_ position:CPCAnglePosition) -> Double {
        switch(position) {
        case .middle:
            return self.mid()
        case .start:
            return self.start
        case .end:
            return self.end
        }
    }
    
    /// <#Description#>
    ///
    /// - parameter angle: <#angle description#>
    ///
    /// - returns: <#return value description#>
    public class func format(_ angle:Double) -> String {
        return "\(round(angle.radiansToDegrees()))°"
    }
    
    
    /// <#Description#>
    ///
    /// - parameter angle:  <#angle description#>
    /// - parameter center: <#center description#>
    /// - parameter radius: <#radius description#>
    ///
    /// - returns: <#return value description#>
    public class func rectOfAngle(_ angle:CPCAngle, center:CGPoint, radius: CGFloat) -> CGRect{
        let p1  = CPCAngle.pointOfAngle(angle.start, center: center, radius: radius)
        let p2  = CPCAngle.pointOfAngle(angle.end, center: center, radius: radius)
        return CGRect(x:min(p1.x, p2.x),
                      y:min(p1.y, p2.y),
                      width:fabs(p1.x - p2.x),
                      height:fabs(p1.y - p2.y));
    }
    
    /// <#Description#>
    ///
    /// - parameter angle:  <#angle description#>
    /// - parameter center: <#center description#>
    /// - parameter radius: <#radius description#>
    ///
    /// - returns: <#return value description#>
    public class func pointOfAngle(_ angle:Double, center:CGPoint, radius: CGFloat) -> CGPoint {
        
        // Given a radius length r and an angle in radians and a circle's center (x,y),
        // calculate the coordinates of a point on the circumference
        
        let theta = CGFloat( angle )
        
        // Cartesian angle to polar.
        
        return CGPoint(x: center.x + CGFloat(radius) * cos(theta), y: center.y + CGFloat(radius) * sin(theta))
    }

    // MARK: DebugPrintable protocol
    
    open var debugDescription: String {
        let sizeOfAngle = CPCAngle.format(length())
        let degreeS     = CPCAngle.format(start)
        let degreeE     = CPCAngle.format(end)
        return "[\(degreeS) \(degreeE)] \(sizeOfAngle)"
    }
}
