
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

//
//  UIColor+Extensions.swift
//
//  Created by Jorge Ouahbi on 27/4/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//


import UIKit

//
//  Attributes
//
let kLuminanceDarkCutoff:CGFloat = 0.6;

extension UIColor
{
    var croma : CGFloat {
        // calculate chroma
        let min1  = min((components?[1])!, (components?[2])!)
        let max1  = max((components?[1])!, (components?[2])!)
        return max(components![0], max1) - min(components![0], min1);
        
    }
    // luma RGB
    var luma : CGFloat {
        
        let lumaRed   = 0.2126 * Float((components?[0])!)
        let lumaGreen = 0.7152 * Float((components?[1])!)
        let lumaBlue  = 0.0722 * Float((components?[2])!)
        let luma      = Float(lumaRed + lumaGreen + lumaBlue)
        
        return CGFloat(luma * Float(components![3]))
    }
    
    var luminance : CGFloat
    {
        let fmin = min(min((components?[0])!, (components?[1])!), (components?[2])!);
        let fmax = max(max((components?[0])!, (components?[1])!), (components?[2])!);
        return (fmax + fmin) / 2.0;
    }
    
    // WebKit
    // luma = (r * 0.2125 + g * 0.7154 + b * 0.0721) * ((double)a / 255.0);
    
    var isLight : Bool {
        return self.luma >= kLuminanceDarkCutoff
    }
    
    var isDark : Bool {
        return self.luma < kLuminanceDarkCutoff;
    }
}


import UIKit

extension UIColor {
    var components : [CGFloat]? {
        return self.cgColor.components
    }
    var numberOfComponents : size_t {
        return self.cgColor.numberOfComponents
    }
    var colorSpace : CGColorSpace? {
        return self.cgColor.colorSpace
    }
    
    /// Returns an array of `CGFloat`s containing four elements with `self`'s:
    /// * hue (index `0`)
    /// * saturation (index `1`)
    /// * brightness (index `2`)
    /// * alpha (index `3`)
    var hsbaComponents: [CGFloat] {
        // Constructs the array in which to store the HSBA-components.
        var components = [CGFloat](repeating: 0.0, count: 4)
        
        // Stores `self`'s HSBA-component values in `components`.
        getHue(       &(components[0]),
                      saturation: &(components[1]),
                      brightness: &(components[2]),
                      alpha:      &(components[3])
        )
        
        return components
    }
    
    var shortDescription:String {
        
        if (numberOfComponents == 2) {
            
            let w = String(format: "%.1f", (self.components?[0])!)
            let a = String(format: "%.1f", (self.components?[1])!)
            
            if let colorSpace = self.colorSpace {
                return "<\(colorSpace.model.name):\(w) \(a)>";
            }
            return "<\(w) \(a)>";
            
        } else {
            
            assert(numberOfComponents == 4)
            let r = String(format: "%.1f", (self.components?[0])!)
            let g = String(format: "%.1f", (self.components?[1])!)
            let b = String(format: "%.1f", (self.components?[2])!)
            let a = String(format: "%.1f", (self.components?[3])!)
            
            if let colorSpace = self.colorSpace {
                return "<\(colorSpace.model.name):\(r) \(g) \(b) \(a)>";
            }
            return "<\(r) \(g) \(b) \(a)>";
        }
    }
}

extension UIColor {
    
    func difference(fromColor: UIColor) -> Int {
        // get the current color's red, green, blue and alpha values
        let red:CGFloat = self.components![0]
        let green:CGFloat = self.components![1]
        let blue:CGFloat = self.components![2]
        //var alpha:CGFloat = self.components![3]
        
        // get the fromColor's red, green, blue and alpha values
        let fromRed:CGFloat = fromColor.components![0]
        let fromGreen:CGFloat = fromColor.components![1]
        let fromBlue:CGFloat = fromColor.components![2]
        //var fromAlpha:CGFloat = fromColor.components![3]
        
        let redValue = (max(red, fromRed) - min(red, fromRed)) * 255
        let greenValue = (max(green, fromGreen) - min(green, fromGreen)) * 255
        let blueValue = (max(blue, fromBlue) - min(blue, fromBlue)) * 255
        
        return Int(redValue + greenValue + blueValue)
    }
    
    func brightnessDifference(fromColor: UIColor) -> Int {
        // get the current color's red, green, blue and alpha values
        let red:CGFloat = self.components![0]
        let green:CGFloat = self.components![1]
        let blue:CGFloat = self.components![2]
        //var alpha:CGFloat = self.components![3]
        let brightness = Int((((red * 299) + (green * 587) + (blue * 114)) * 255) / 1000)
        
        // get the fromColor's red, green, blue and alpha values
        let fromRed:CGFloat = fromColor.components![0]
        let fromGreen:CGFloat = fromColor.components![1]
        let fromBlue:CGFloat = fromColor.components![2]
        //var fromAlpha:CGFloat = fromColor.components![3]
        
        let fromBrightness = Int((((fromRed * 299) + (fromGreen * 587) + (fromBlue * 114)) * 255) / 1000)
        
        return max(brightness, fromBrightness) - min(brightness, fromBrightness)
    }
}

