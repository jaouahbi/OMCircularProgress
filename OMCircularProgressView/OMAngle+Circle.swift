
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


import Darwin

let 𝜏 = 2.0 * π

open class OMCircleAngle : OMAngle {
    
    func perimeter(_ radius:Double) -> Double {
        return 𝜏 * radius
    }
    
    func area(_ radius:Double) -> Double {
        return π * radius * radius
    }
    
    func arcLength(_ radius:Double, theta: OMAngle) -> Double {
        return perimeter(radius) * theta.length() / π
    }
    
    /**
     * Get the normalized angle
     *
     * returns: return angle length in radians
     */
    
    func norm() -> Double {
        return self.start / 𝜏
    }
    
    static func step(elements:Double) -> Double {
        return 𝜏 / elements
    }
    
    /**
     * Check if the angle is in range +/- 𝜏
     *
     * returns: return if the angle is in range
     */
    
    func range() -> Bool {
        return (self.end > 𝜏 || self.start < -𝜏) == false
    }
    
    static func range(angle:Double) -> Bool {
        return (angle > 𝜏 || angle < -𝜏) == false
    }
    
    public override func valid() -> Bool {
        return super.valid() && range()
    }
    
}
