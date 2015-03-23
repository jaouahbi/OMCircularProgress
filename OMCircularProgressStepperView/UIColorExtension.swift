//
//  UIColorExtension.swift
//
//  Created by Jorge Ouahbi on 4/2/15.
//  Copyright (c) 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit
import QuartzCore

extension UIColor
{
    var red : CGFloat
    {
        get
        {
            let components = CGColorGetComponents(self.CGColor)
            return components[0]
        }
    }
    
    var green : CGFloat
    {
        get
        {
            let components = CGColorGetComponents(self.CGColor)
            return components[1]
        }
    }
    
    var blue : CGFloat
    {
        get
        {
            let components = CGColorGetComponents(self.CGColor)
            return components[2]
        }
    }
    
    var alpha : CGFloat
    {
        get
        {
            return CGColorGetAlpha(self.CGColor)
        }
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
    
    class func rainbowColors() -> NSArray!{
        let colors = NSMutableArray()
        for (var hue:CGFloat = 0.0; hue < 1.0; hue += 0.05) {
            let color = UIColor(hue: hue,saturation:CGFloat(1.0),brightness:CGFloat(1.0),alpha:CGFloat(1.0));
            colors.addObject(color)
        }
        return colors
    }
    
    func colorsFromColor() -> AnyObject {
        var colors:NSMutableArray = NSMutableArray()
        
        for (var deg:Double = 0.0; deg <= 360.0; deg += 5.0) {
            let f = CGFloat(1.0 * deg / 360.0)
            colors.addObject( self.colorWithBrightnessFactor( f ).CGColor);
        }
        return colors;
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