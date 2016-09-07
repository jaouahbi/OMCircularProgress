
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

public class OMGradient {
    
    var locations : [CGFloat]? = nil
    var colors    : [UIColor]  = []
    
    init(colors:[UIColor], locations:[CGFloat]?) {
        self.colors     = colors
        self.locations  = locations
    }
    
    lazy var CGGradient : CGGradientRef! = {
        var colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()!
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
            
            #if (DEBUG_VERBOSE)
                print("\(numberOfLocations) locations")
            #endif
            #if (DEBUG_VERBOSE)
                if self.locations != nil {
                print(" \(self.locations!)")
                }
            #endif
            
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
                    components = [CGFloat](count: numberOfLocations * numberOfComponents, repeatedValue: 0.0)
                    for locationIndex in 0 ..< numberOfLocations {
                        let color = self.colors[locationIndex]
                        // sanity check
                        assert(numberOfComponents == color.numberOfComponents)
                        assert(color.colorSpace?.model == colorSpace.model);
                        
                        let colorComponents = color.components;
                        
                        for componentIndex in 0 ..< numberOfComponents {
                            components?[numberOfComponents * locationIndex + componentIndex] = colorComponents[componentIndex]
                        }
                    }
                    
                    // If locations is NULL, the first color in colors is assigned to location 0, the last color incolors is assigned
                    // to location 1, and intervening colors are assigned locations that are at equal intervals in between.
                    var gradient:CGGradientRef?
                    if (useLocations) {
                        assert(self.locations != nil && self.locations!.count > 0)
                        gradient = CGGradientCreateWithColorComponents(colorSpace,
                                                                       UnsafePointer<CGFloat>(components!),
                                                                       UnsafePointer<CGFloat>(self.locations!),
                                                                       numberOfLocations);
                    } else {
                        assert(!(self.locations != nil && self.locations!.count > 0))
                        gradient = CGGradientCreateWithColorComponents(colorSpace,
                                                                       UnsafePointer<CGFloat>(components!),
                                                                       nil,
                                                                       numberOfLocations);
                    }
                    
                    return gradient;
                }
            }
        }
        return nil
    }()
}
