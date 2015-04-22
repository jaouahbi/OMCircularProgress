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
//  UIColorExtension.swift
//
//  Created by Jorge Ouahbi on 4/2/15.
//

import UIKit
import QuartzCore

extension UIColor
{
    var red : CGFloat
    {
        let components = CGColorGetComponents(self.CGColor)
        return components[0]
    }
    
    var green : CGFloat
    {
        let components = CGColorGetComponents(self.CGColor)
        return components[1]
    }
    
    var blue : CGFloat
    {
        let components = CGColorGetComponents(self.CGColor)
        return components[2]
    }
    
    var alpha : CGFloat
    {
        return CGColorGetAlpha(self.CGColor)
    }
    
    var hue: CGFloat
    {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
    
        if ( getHue(&hue, saturation:&saturation, brightness:&brightness, alpha:&alpha)) {
            return hue
        }
        
        return 1.0;
    }
    
    
    var saturation: CGFloat
    {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
    
        if ( getHue(&hue, saturation:&saturation, brightness:&brightness, alpha:&alpha)) {
            return saturation
        }
        
        return 1.0;
    }
    
    var brightness: CGFloat
    {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
    
        if ( getHue(&hue, saturation:&saturation, brightness:&brightness, alpha:&alpha)) {
            return brightness
        }
        
        return 1.0;
    }
    
    func isClearColor() -> Bool
    {
        return self.isEqual(UIColor.clearColor())
    }
    
    func isLighterColor() -> Bool
    {
        let components = CGColorGetComponents(self.CGColor);
        return (components[0]+components[1]+components[2])/3 >= 0.5
    }
    
    func lighterColor(percent : Double) -> UIColor!{
        return colorWithBrightnessFactor(CGFloat(1.0 + percent));
    }
    
    func darkerColor(percent : Double) -> UIColor!{
        return colorWithBrightnessFactor(CGFloat(1.0 - percent));
    }
    
    class func rainbowColors(numberOfSteps:Int) -> NSArray!{
        let colors = NSMutableArray()
        
        let iNumberOfSteps =  1.0 / Double(numberOfSteps)
        
        for (var hue:Double = 0.0; hue < 1.0; hue += iNumberOfSteps)
        {
            let color = UIColor(hue: CGFloat(hue),saturation:CGFloat(1.0),brightness:CGFloat(1.0),alpha:CGFloat(1.0));
            colors.addObject(color)
        }
        
        assert(colors.count == numberOfSteps, "Unexpected number of rainbow colors \(colors.count). Expecting \(numberOfSteps)")
        
        return colors
    }
    
//    func colorsFromColor() -> AnyObject {
//        var colors:NSMutableArray = NSMutableArray()
//        
//        for (var deg:Double = 0.0; deg <= 360.0; deg += 5.0) {
//            let f = CGFloat(1.0 * deg / 360.0)
//            colors.addObject( self.colorWithBrightnessFactor( f ).CGColor);
//        }
//        
//        return colors;
//    }
    

    
    
    
//    func nextColorsFromColor() -> AnyObject {
//        var colors:NSMutableArray = NSMutableArray()
//        
//        for (var deg:Double = 0.0; deg <= 360.0; deg += 5.0) {
//            let f = CGFloat(1.0 * deg / 360.0)
//            colors.addObject( self.colorWithBrightnessFactor( f ).CGColor);
//        }
//        return colors;
//    }
    
    
    func colorWithAlpha(alpha:CGFloat) -> UIColor!
    {
        return  UIColor(CGColor: CGColorCreateCopyWithAlpha(self.CGColor, alpha))
    }
    
    func colorWithBrightnessFactor(factor: CGFloat) -> UIColor {
        
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        var white : CGFloat = 0
        
        
        if (self.isEqual(UIColor.whiteColor())) {
            return UIColor(white: 0.9999, alpha: 1.0) ;
        }
        if (self.isEqual(UIColor.blackColor())) {
            return UIColor(white: 0.0001, alpha: 1.0) ;
        }
        if (self.getHue(&hue, saturation:&saturation, brightness:&brightness, alpha:&alpha)) {
            return UIColor( hue: hue,saturation:saturation, brightness: brightness * factor,alpha:alpha);
            
        } else if (self.getWhite(&white, alpha:&alpha)) {
            return UIColor(white: white * factor,alpha:alpha);
        }
        
        return self
    }
}



extension UIColor : GeneratorType
{
    // Required to adopt `GeneratorType`
    
    typealias Element = UIColor
    
    // Required to adopt `GeneratorType`
    
    public func next() -> UIColor?
    {
        let increment = 360.0 / 14
        let hue = (Double(self.hue) * 360.0)
        
        // make it circular
        let degrees =  (hue + increment) % 360.0
        
        return UIColor(hue: CGFloat(1.0 * degrees / 360.0),
                saturation: saturation,
                brightness: brightness,
                     alpha: alpha)
    }
}
