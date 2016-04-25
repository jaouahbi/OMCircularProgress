
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
//  UIColor+Rainbow.swift
//
//  Created by Jorge Ouahbi on 25/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit


/**
*  UIColor Extension that generate next UIColor
*
*/

extension UIColor : GeneratorType
{
    var alpha : CGFloat {
        return CGColorGetAlpha(self.CGColor)
    }

    var hue: CGFloat {

        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0

        if ( getHue(&hue, saturation:&saturation, brightness:&brightness, alpha:&alpha)) {
            return hue
        }

        return 1.0;
    }


    var saturation: CGFloat {

        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0

        if ( getHue(&hue, saturation:&saturation, brightness:&brightness, alpha:&alpha)) {
            return saturation
        }

        return 1.0;
    }

    var brightness: CGFloat {

        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0

        if ( getHue(&hue, saturation:&saturation, brightness:&brightness, alpha:&alpha)) {
            return brightness
        }

        return 1.0;
    }

    // Required to adopt `GeneratorType`

    public typealias Element = UIColor

    // Required to adopt `GeneratorType`

    public func next() -> UIColor?
    {
        let increment = 360.0 / 7

        let hue = (Double(self.hue) * 360.0)

        // make it circular

        let degrees =  (hue + increment) % 360.0

        return UIColor(hue: CGFloat(1.0 * degrees / 360.0),
            saturation: saturation,
            brightness: brightness,
            alpha: alpha)
    }
    
    
    public func prev() -> UIColor?
    {
        let increment = 360.0 / 7
        
        let hue = (Double(self.hue) * 360.0)
        
        // make it circular
        
        let degrees =  (hue - increment) % 360.0
        
        return UIColor(hue: CGFloat(1.0 * degrees / 360.0),
                       saturation: saturation,
                       brightness: brightness,
                       alpha: alpha)
    }
    
    class public func random() -> UIColor?
    {
        let frndr = CGFloat(drand48())
        let frndg = CGFloat(drand48())
        let frndb = CGFloat(drand48())
        
        return UIColor(red: frndr, green: frndg, blue: frndb, alpha: 1.0)
        
    }
}