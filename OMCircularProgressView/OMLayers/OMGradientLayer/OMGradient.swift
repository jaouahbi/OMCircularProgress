
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
//  OMGradient.swift
//
//  Created by Jorge Ouahbi on 20/4/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


struct OMGradient {
    
    var locations : [CGFloat]? = nil
    var colors    : [UIColor]  = []
    
    init(colors:[UIColor], locations:[CGFloat]?) {
        self.colors     = colors
        self.locations  = locations
    }
    
    lazy var gradient : CGGradient? = {
        var colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        var numberOfComponents:Int   = 4 // RGBA
        var components:Array<CGFloat>?
        let numberOfLocations:Int
        var useLocations:Bool = false
        
        if (self.colors.count > 0) {
            
            if self.locations != nil && self.locations?.count > 0 {
                numberOfLocations = min(self.locations!.count, self.colors.count)
                useLocations      = true
            } else {
                // If a nil array is given, the stops are assumed to spread uniformly across the [0,1] range
                numberOfLocations = self.colors.count
            }
            
            SpeedLog.print("\(numberOfLocations) locations")
            
            if self.locations != nil {
                SpeedLog.print(" \(self.locations!)")
            }
            
            if (numberOfLocations > 0) {
                // Analize one color
                if let color  = self.colors.first {
                    numberOfComponents = color.numberOfComponents
                    colorSpace         = color.colorSpace!
                } else {
                    // color not found
                    numberOfComponents = 0
                }
                
                if (numberOfComponents > 0) {
                    components = [CGFloat](repeating: 0.0, count: numberOfLocations * numberOfComponents)
                    for locationIndex in 0 ..< numberOfLocations {
                        let color = self.colors[locationIndex]
                        // sanity check
                        assert(numberOfComponents == color.numberOfComponents)
                        assert(color.colorSpace?.model == colorSpace.model);
                        
                        let colorComponents = color.components;
                        
                        for componentIndex in 0 ..< numberOfComponents {
                            components?[numberOfComponents * locationIndex + componentIndex] = (colorComponents?[componentIndex])!
                        }
                    }
                    
                    // If locations is NULL, the first color in colors is assigned to location 0, the last color incolors is assigned
                    // to location 1, and intervening colors are assigned locations that are at equal intervals in between.
                    var gradient:CGGradient?
                    if (useLocations) {
                        assert(self.locations != nil && self.locations!.count > 0)
                        return  CGGradient(colorSpace: colorSpace,
                                         colorComponents: UnsafePointer<CGFloat>(components!),
                                               locations: UnsafePointer<CGFloat>(self.locations!),
                                                   count: numberOfLocations);
                    } else {
                        assert(!(self.locations != nil && self.locations!.count > 0))
                        return  CGGradient(colorSpace: colorSpace,
                                         colorComponents: UnsafePointer<CGFloat>(components!),
                                               locations: nil,
                                                   count: numberOfLocations);
                    }
                }
            }
        }
        return nil
    }()
}
