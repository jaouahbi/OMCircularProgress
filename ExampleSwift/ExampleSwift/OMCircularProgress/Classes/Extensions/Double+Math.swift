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

//  DoubleExtension.swift
//
//  Created by Jorge Ouahbi on 25/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit

/// Double Extension for conversion from/to degrees/radians and clamp/map

public func clamp(_ value:Double,lowerValue: Double, upperValue: Double) -> Double{
    return Swift.min(Swift.max(value, lowerValue), upperValue)
}

public func map(input:Double,input_start:Double,input_end:Double,output_start:Double,output_end:Double)-> Double {
    let slope = 1.0 * (output_end - output_start) / (input_end - input_start)
    return output_start + round(slope * (input - input_start))
}

public extension Double {
    
    func degreesToRadians () -> Double {
        return self * 0.01745329252
    }
    func radiansToDegrees () -> Double {
        return self * 57.29577951
    }
    mutating func clamp(toLowerValue lowerValue: Double, upperValue: Double){
        self = min(max(self, lowerValue), upperValue)
    }
}
