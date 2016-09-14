
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
    
    func arcLength(_ radius:Double) -> Double {
        return perimeter(radius) * self.length() / π
    }
    
    
    // http://planetcalc.com/1421/
    //
    //    func calcChord( radius : Double, angle : Double )
    //    {
    //    let rad = angle;
    //    let r2=radius*radius;
    //    let area = ( r2/2.0 * (rad-sin( rad ) ) );
    //    let chord = 2.0*radius*sin(rad/2);
    //    let arclen = rad*radius;
    //    let perimeter = ( area + chord );
    //    let height = radius*(1.0-cos(rad/2.0))
    //    };

    
    func arcChord( radius : Double ) -> Double {
        return 2.0 * radius * sin(self.length() / 2.0);
    }

    func chordHeight( radius : Double ) -> Double {
        return radius * (1.0-cos(self.length()/2.0))
    };
    
    func chordPerimeter( radius : Double) -> Double {
        let r2=radius*radius;
        let rad = self.length()
        let area = ( r2/2.0 * (rad-sin( rad ) ) );
        let chord = 2.0*radius*sin(rad/2);
        return ( area + chord );
    };
    
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
