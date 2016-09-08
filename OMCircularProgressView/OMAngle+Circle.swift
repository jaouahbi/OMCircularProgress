
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

extension OMAngle {
    
    func circlePerimeter(_ radius:Double) -> Double {
        return 𝜏 * radius
    }
    
    func circleArea(_ radius:Double) -> Double {
        return π * radius * radius
    }
    
    func circleArcLength(_ radius:Double, theta: OMAngle) -> Double {
        return circlePerimeter(radius) * theta.length() / π
    }
}
