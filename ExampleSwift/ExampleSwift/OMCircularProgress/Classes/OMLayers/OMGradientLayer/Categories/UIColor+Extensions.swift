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
            
            let w = (self.components?[0])!.format(true)
            let a = (self.components?[1])!.format(true)
            
            if let colorSpace = self.colorSpace {
                return "<\(colorSpace.model.name):\(w) \(a)>";
            }
            return "<\(w) \(a)>";
            
        } else {
            
            assert(numberOfComponents == 4)
            let r = (self.components?[0])!.format(true)
            let g = (self.components?[1])!.format(true)
            let b = (self.components?[2])!.format(true)
            let a = (self.components?[3])!.format(true)
            
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

extension UIColor
{
    // RGBA
    // linear interpolation
    public class func lerp(_ start:UIColor, end:UIColor, t:CGFloat) -> UIColor {
        
        let srgba = start.components
        let ergba = end.components
        
        return UIColor(red: Interpolation.lerp(srgba![0],y1: ergba![0],t: t),
                       green: Interpolation.lerp(srgba![1],y1: ergba![1],t: t),
                       blue: Interpolation.lerp(srgba![2],y1: ergba![2],t: t),
                       alpha: Interpolation.lerp(srgba![3],y1: ergba![3],t: t))
    }
    // cosine interpolate
    public class func coserp(_ start:UIColor, end:UIColor, t:CGFloat) -> UIColor {
        let srgba = start.components
        let ergba = end.components
        return UIColor(red: Interpolation.coserp(srgba![0],y1: ergba![0],t: t),
                       green: Interpolation.coserp(srgba![1],y1: ergba![1],t: t),
                       blue: Interpolation.coserp(srgba![2],y1: ergba![2],t: t),
                       alpha: Interpolation.coserp(srgba![3],y1: ergba![3],t: t))
    }
    
    // exponential interpolation
    public class func eerp(_ start:UIColor, end:UIColor, t:CGFloat) -> UIColor {
        let srgba = start.components
        let ergba = end.components
        
        let r = clamp(Interpolation.eerp(srgba![0],y1: ergba![0],t: t),lower: 0,upper: 1)
        let g = clamp(Interpolation.eerp(srgba![1],y1: ergba![1],t: t),lower: 0,upper: 1)
        let b = clamp(Interpolation.eerp(srgba![2],y1: ergba![2],t: t),lower: 0,upper: 1)
        let a = clamp(Interpolation.eerp(srgba![3],y1: ergba![3],t: t),lower: 0,upper: 1)
        
        assert(r <= 1.0 && g <= 1.0 && b <= 1.0 && a <= 1.0);
        
        return UIColor(red: r,
                       green: g,
                       blue: b,
                       alpha: a)
        
    }
    // bilinear interpolation
    public class func bilerp(_ start:[UIColor], end:[UIColor], t:[CGFloat]) -> UIColor {
        let srgba0 = start[0].components
        let ergba0 = end[0].components
        
        let srgba1 = start[1].components
        let ergba1 = end[1].components
        
        return UIColor(red: Interpolation.bilerp(srgba0![0], y01: ergba0![0], t1: t[0], y10: srgba1![0], y11: ergba1![0], t2: t[1]),
                       green: Interpolation.bilerp(srgba0![1], y01: ergba0![1], t1: t[0], y10: srgba1![1], y11: ergba1![1], t2: t[1]),
                       blue: Interpolation.bilerp(srgba0![2], y01: ergba0![2], t1: t[0], y10: srgba1![2], y11: ergba1![2], t2: t[1]),
                       alpha:  Interpolation.bilerp(srgba0![3], y01: ergba0![3], t1: t[0], y10: srgba1![3], y11: ergba1![3], t2: t[1]))
        
    }
}
