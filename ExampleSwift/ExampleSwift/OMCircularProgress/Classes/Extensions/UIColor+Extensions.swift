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
// v 1.0 Merged files
// v 1.1 Some clean


import UIKit

///  Attributes

let kLuminanceDarkCutoff:CGFloat = 0.6;

extension UIColor
{
    ///  chroma RGB
    var croma : CGFloat {
        
        let comp  = components!
        let min1  = min(comp[1], comp[2])
        let max1  = max(comp[1], comp[2])
        
        return max(comp[0], max1) - min(comp[0], min1);
        
    }
    // luma RGB
    // WebKit
    // luma = (r * 0.2125 + g * 0.7154 + b * 0.0721) * ((double)a / 255.0);
    
    var luma : CGFloat {
        let comp      = components!
        let lumaRed   = 0.2126 * Float(comp[0])
        let lumaGreen = 0.7152 * Float(comp[1])
        let lumaBlue  = 0.0722 * Float(comp[2])
        let luma      = Float(lumaRed + lumaGreen + lumaBlue)
        
        return CGFloat(luma * Float(components![3]))
    }
    
    var luminance : CGFloat {
        let comp      = components!
        let fmin = min(min(comp[0],comp[1]),comp[2])
        let fmax = max(max(comp[0],comp[1]),comp[2])
        return (fmax + fmin) / 2.0;
    }
    
    
    var isLight : Bool {
        return self.luma >= kLuminanceDarkCutoff
    }
    
    var isDark : Bool {
        return self.luma < kLuminanceDarkCutoff;
    }
}


extension UIColor {
    
    /// Returns an array of `CGFloat`s containing four elements with `self`'s:
    /// * r (index `0`)
    /// * g (index `1`)
    /// * b (index `2`)
    /// * a (index `3`)
    /// or
    /// * w (index `0`)
    /// * a (index `1`)
    var components : [CGFloat]? {
        return self.cgColor.components
    }
    /// number of color components
    var numberOfComponents : size_t {
        return self.cgColor.numberOfComponents
    }
    /// color space
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
    
    var alpha : CGFloat {
        return self.cgColor.alpha
    }
    
    var hue: CGFloat {
        return  hsbaComponents[0];
    }
    
    var saturation: CGFloat {
        
        return  hsbaComponents[1];
    }
    
    var brightness: CGFloat {
        return  hsbaComponents[2];
    }
    
    
    /// Returns a lighter color by the provided percentage
    ///
    /// - param: lighting percent percentage
    /// - returns: lighter UIColor
    
    func lighterColor(percent : Double) -> UIColor {
        return colorWithBrightnessFactor(factor: CGFloat(1 + percent));
    }
    
    /// Returns a darker color by the provided percentage
    ///
    /// - param: darking percent percentage
    /// - returns: darker UIColor
    
    func darkerColor(percent : Double) -> UIColor {
        return colorWithBrightnessFactor(factor: CGFloat(1 - percent));
    }
    
    /// Return a modified color using the brightness factor provided
    ///
    /// - param: factor brightness factor
    /// - returns: modified color
    
    func colorWithBrightnessFactor(factor: CGFloat) -> UIColor {
        
        return UIColor(hue: hsbaComponents[0],
                       saturation: hsbaComponents[1],
                       brightness: hsbaComponents[2] * factor,
                       alpha: hsbaComponents[3])
        
    }
    
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
    
    /// Short description
    var shortDescription:String {
        
        let comp   = components!
        if (numberOfComponents == 2) {
            let w = String(format: "%.1f", comp[0])
            let a = String(format: "%.1f", comp[1])
            if let colorSpace = self.colorSpace {
                return "<\(colorSpace.model.name):\(w) \(a)>";
            }
            return "<\(w) \(a)>";
            
        } else {
            
            assert(numberOfComponents == 4)
            
            let r = String(format: "%.1f",comp[0])
            let g = String(format: "%.1f",comp[1])
            let b = String(format: "%.1f",comp[2])
            let a = String(format: "%.1f",comp[3])
            
            if let colorSpace = self.colorSpace {
                return "<\(colorSpace.model.name):\(r) \(g) \(b) \(a)>";
            }
            return "<\(r) \(g) \(b) \(a)>";
        }
    }
}


/// UIColor Extension that generate next UIColor

let kNumberOfHueSteps:Double = 7

extension UIColor : IteratorProtocol
{
    // Required to adopt `GeneratorType`
    
    public typealias Element = UIColor
    
    // Required to adopt `GeneratorType`
    
    public func next() -> UIColor?
    {
        let increment = 360.0 / kNumberOfHueSteps
        
        let hue = (Double(self.hue) * 360.0)
        
        // make it circular
        
        let degrees =  (hue + increment).truncatingRemainder(dividingBy: 360.0)
        
        return UIColor(hue: CGFloat(1.0 * degrees / 360.0),
                       saturation: saturation,
                       brightness: brightness,
                       alpha: alpha)
    }
    
    
    public func prev() -> UIColor?
    {
        let increment = 360.0 / kNumberOfHueSteps
        
        let hue = (Double(self.hue) * 360.0)
        
        // make it circular
        
        let degrees =  (hue - increment).truncatingRemainder(dividingBy: 360.0)
        
        return UIColor(hue: CGFloat(1.0 * degrees / 360.0),
                       saturation: saturation,
                       brightness: brightness,
                       alpha: alpha)
    }
    
    class public func random() -> UIColor?
    {
        let r = CGFloat(drand48())
        let g = CGFloat(drand48())
        let b = CGFloat(drand48())
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

/// Rainbow

extension UIColor
{
    /// Returns a array of the complete hue color spectre (0 - 360)
    ///
    /// - param: number of hue UIColor steps
    /// - param: start UIColor hue
    /// - returns: UIColor array
    
    
    class func rainbow(_ numberOfSteps:Int, hue:Double = 0.0) -> [UIColor]!{
        
        var colors:[UIColor] = []
        
        let iNumberOfSteps =  1.0 / Double(numberOfSteps)
        var hue:Double = hue
        while hue < 1.0 {
            if(colors.count == numberOfSteps){
                break
            }
            
            let color = UIColor(hue: CGFloat(hue),
                                saturation:CGFloat(1.0),
                                brightness:CGFloat(1.0),
                                alpha:CGFloat(1.0));
            
            colors.append(color)
            hue += iNumberOfSteps
        }
        
        // assert(colors.count == numberOfSteps, "Unexpected number of rainbow colors \(colors.count). Expecting \(numberOfSteps)")
        
        return colors
    }
}



