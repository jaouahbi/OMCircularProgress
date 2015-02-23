//
//  DoubleExtension.swift
//  ExampleSwift
//
//  Created by Jorge Ouahbi on 22/2/15.
//  Copyright (c) 2015 Jorge Ouahbi. All rights reserved.
//

import Foundation

public extension Double {
    
    func degreesToRadians () -> Double {
        return self * 0.01745329252
    }
    func radiansToDegrees () -> Double {
        return self * 57.29577951
    }
}