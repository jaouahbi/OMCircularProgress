//
//  DoubleExtension.swift
//
//  Created by Jorge Ouahbi on 25/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit

/**
*  Double Extension for conversion from/to degrees/radians and clamp
*/

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
