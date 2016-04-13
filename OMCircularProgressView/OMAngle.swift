
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
Angles alignment

- AngleStart: Align to start of the angle
- AngleMid:   Align to middle of the angle
- AngleEnd:   Align to the end of the angle
*/
public enum OMAngleAlign: Int
{
    case AngleStart
    case AngleMid
    case AngleEnd
    init() {
        self = AngleMid
    }
}


/**
Object that encapsulate a angle
*/

@objc public class OMAngle : NSObject
{
    let TWO_PI:Double = 2.0 * M_PI
    
    var start:Double = 0.0                // start of angle in radians
    var end:Double   = 0.0                // end of angle in radians
    
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
    // angle arc
    func arc(radius:CGFloat) -> Double {
        return length() / Double(radius)
    }
    
    func add(len:Double){
        end += len;
    }
    
    // middle of the angle
    func mid() -> Double {
        let len = length()
        return start + (len * 0.5)
    }
    
    // angle length in radians
    func length() -> Double {
        return end - start
    }
    
    func valid() -> Bool {
        return length() > 0.0
    }
    
    /**
    Check if the angle is in range +/- M_PI*2
    
    - parameter angle: angle to check
    
    - returns: return if the angle is in range
    */
    func angleInCircle() -> Bool {
        return (self.end > TWO_PI || self.start < -TWO_PI) == false
    }
    
    /**
     Aling angle to OMAngleAlign
    
    - parameter angle: angle object
    - parameter align: angle align
    
    - returns: angle anligned to .OMAngleAlign
    */
    
    func align(align:OMAngleAlign) -> Double
    {
        var resultAngle: Double = self.mid()
        
        switch(align) {
            
        case .AngleMid:
            resultAngle = self.mid()
            break;
        case .AngleStart:
            resultAngle = self.start
            break;
        case .AngleEnd:
            resultAngle = self.end
            break;
        }
        
        return resultAngle;
    }
    
   
// atan() returns an angle in the interval 0 <= theta <= pi/2. You probably want an angle in the interval 0 <= theta <= 2*pi.
// If your X and Y are always greater than 0 you can ignore this post ;) 
    
//    func polarFromCartesian() {
//        
//        R = Sqrt(x2 + y2);
//        Theta = ArcTan(Y / X);
//        
//    }
    
//
//    func CartesianFromPolar(){
//    
//        X = R * cos(Theta)
//        Y = R * sin(Theta)
//    }
    

    // Normalize the angle between 0 and 2pi
    func normalizeAngle(var value:Double) ->Double {
        while ( value < 0.0 ){
            value += TWO_PI;
        }
        while ( value >= TWO_PI ){
            value -= TWO_PI;
        }
        return value;
    }

// Compute the polar angle from the cartesian point
    func polarAngle(point:CGPoint) -> Double {
        
        var value = 0.0;
        if ( point.x > 0.0 ){
            value = atan(Double(point.y / point.x));
        } else if ( point.x < 0.0 ) {
            if ( point.y >= 0.0 ){
                value = Double(point.y / point.x) + M_PI
            }else{
                 value = Double(point.y / point.x) - M_PI
            }
        } else {
            if ( point.y > 0.0 ) {
                value =  M_PI_2;
            }else if ( point.y < 0.0 ){
                value =  -M_PI_2;
            }else{
                value = 0.0;
            }
        }
        return normalizeAngle(value);
    }


    /// DebugPrintable protocol
    override public var debugDescription : String {
        let sizeOfAngle = round(length().radiansToDegrees())
        let degreeS     = round(start.radiansToDegrees());
        let degreeE     = round(end.radiansToDegrees());
        return "[\(degreeS)° - \(degreeE)°] : \(sizeOfAngle)°"
    }
    /// Printable protocol
//    override public var description: String {
//        return debugDescription;
//    }
}