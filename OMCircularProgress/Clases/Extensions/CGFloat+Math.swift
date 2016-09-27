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

//  CGFloat+Math.swift
//
//  Created by Jorge Ouahbi on 25/11/15.
//  Copyright d© 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit

/**
 *  CGFloat Extension for conversion from/to degrees/radians and clamp
 */

public extension CGFloat {
    
    func degreesToRadians () -> CGFloat {
        return self * CGFloat(0.01745329252)
    }
    func radiansToDegrees () -> CGFloat {
        return self * CGFloat(57.29577951)
    }
    
    mutating func clamp(toLowerValue lowerValue: CGFloat, upperValue: CGFloat){
        self = Swift.min(Swift.max(self, lowerValue), upperValue)
    }
}
