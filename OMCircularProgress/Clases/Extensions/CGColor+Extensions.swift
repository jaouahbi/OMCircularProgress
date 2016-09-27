
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
//  CGColor+Rainbow.swift
//
//  Created by Jorge Ouahbi on 25/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit

extension CGColor
{
    class func rainbow(_ numberOfSteps:Int, hue:Double = 0.0) ->  Array<CGColor>!{
        var colors:Array<CGColor> = []
        
        let iNumberOfSteps = 1.0 / Double(numberOfSteps)
        var hue:Double = hue
        while hue < 1.0 {
            if(colors.count == numberOfSteps){
                break
            }
            
            let color = UIColor(hue: CGFloat(hue),
                                saturation:CGFloat(1.0),
                                brightness:CGFloat(1.0),
                                alpha:CGFloat(1.0));
            
            colors.append(color.cgColor)
            
            hue += iNumberOfSteps
        }
        //assert(colors.count == numberOfSteps, "Unexpected number of rainbow colors \(colors.count). Expecting \(numberOfSteps)")
        return colors
    }
}
