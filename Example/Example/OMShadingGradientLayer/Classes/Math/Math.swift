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



// Clamp a number between lowerValue and upperValue.
public func clamp<T>(_ value: T, lowerValue: T, upperValue: T) -> T where T : Comparable {
    return min(max(value, lowerValue), upperValue)
}

// Check if the number is between lower and upper.
public func between<T: Comparable>(_ value: T, lower: T, upper: T , include: Bool = true) -> Bool {
    let left = min(lower, upper)
    let right = max(lower, upper)
    return include ? (value >= left && value <= right) : (value > left && value < right)
}

// min radius from rectangle
public func minRadius(_ size: CGSize) -> CGFloat {
    assert(size != CGSize.zero)
    return size.min() * 0.5;
}

// max radius from a rectangle (pythagoras)
public func maxRadius(_ size: CGSize) -> CGFloat {
    assert(size != CGSize.zero)
    return 0.5 * sqrt(size.width * size.width + size.height * size.height)
}

// monotonically increasing function
public func monotonic(_ numberOfElements:Int) -> [CGFloat] {
    assert(numberOfElements > 0)
    var monotonicFunction:[CGFloat] = []
    let numberOfLocations:CGFloat = CGFloat(numberOfElements - 1)
    for locationIndex in 0 ..< numberOfElements  {
         monotonicFunction.append(CGFloat(locationIndex) / numberOfLocations)
    }
    return monotonicFunction
}

// redistributes values on a slope (ease-in ease-out)
public func slope( x:Float, A:Float) -> Float {
    let p = powf(x,A);
    return p/(p + powf(1.0-x, A));
}

//TODO: use Generics

public func map(input:CGFloat,input_start:CGFloat,input_end:CGFloat,output_start:CGFloat,output_end:CGFloat)-> CGFloat {
    let slope = 1.0 * (output_end - output_start) / (input_end - input_start)
    return output_start + round(slope * (input - input_start))
}

public func linlin( val:Double,  inMin:Double,  inMax:Double,  outMin:Double,  outMax:Double) -> Double {
    return ((val - inMin) / (inMax - inMin) * (outMax - outMin)) + outMin;
}

public func  linexp( val:Double,  inMin:Double,  inMax:Double,  outMin:Double,  outMax:Double) -> Double {
    //TODO: use clamp
    //clipping
    let valclamp = max(min(val, inMax), inMin);
    return pow((outMax / outMin), (valclamp - inMin) / (inMax - inMin)) * outMin;
}
public func explin(val:Double,  inMin:Double,  inMax:Double,  outMin:Double,  outMax:Double) -> Double {
    //TODO: use clamp
    //clipping
    let valclamp = max(min(val, inMax), inMin);
    return (log(valclamp/inMin) / log(inMax/inMin) * (outMax - outMin)) + outMin;
}
