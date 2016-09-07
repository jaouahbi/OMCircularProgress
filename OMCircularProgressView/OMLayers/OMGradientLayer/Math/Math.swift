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
//  Math.swift
//
//  Created by Jorge Ouahbi on 9/5/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

import UIKit

//let π  = M_PI
//let π2 = M_PI * 2.0

public func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
}

public func between<T: Comparable>(value: T, lower: T, upper: T , include: Bool = true) -> Bool {
    let left = min(lower, upper)
    let right = max(lower, upper)
    return include ? (value >= left && value <= right) : (value > left && value < right)
}

public func degreesToRadians(degrees:CGFloat) -> CGFloat {
    return degrees * 0.017453292519943295
}

public func radiansToDegrees(radians:CGFloat) -> CGFloat{
    return radians * 57.29577951
}

public func degreesToRadians(degrees:Double) -> Double {
    return degrees * 0.017453292519943295
}

public func radiansToDegrees(radians:Double) -> Double{
    return radians * 57.29577951
}

public func minRadius(size: CGSize) -> CGFloat {
    return min(size.height,size.width) * 0.5;
}

public func maxRadius(size: CGSize) -> CGFloat {
    let longerSide = max(size.width, size.height)
    return longerSide * CGFloat(M_SQRT2) * 0.5
}
// monotonically increasing function
public func monotonic(numberOfElements:Int) -> [CGFloat] {
    var monotonicFunction:[CGFloat] = []
    let numberOfLocations:CGFloat = CGFloat(numberOfElements - 1)
    for locationIndex in 0 ..< numberOfElements  {
         monotonicFunction.append(CGFloat(locationIndex) / numberOfLocations)
    }
    return monotonicFunction
}



