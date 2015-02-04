//
//  UIColorExtension.swift
//
//  Created by Jorge Ouahbi on 4/2/15.
//  Copyright (c) 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit

extension UIColor
{
    func lighterColor(percent : Double) -> UIColor!{
        return colorWithBrightnessFactor(CGFloat(1.0 + percent));
    }
    
    func darkerColor(percent : Double) -> UIColor!{
        return colorWithBrightnessFactor(CGFloat(1.0 - percent));
    }
    
    private func colorWithBrightnessFactor(factor: CGFloat) -> UIColor {
        
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        var white : CGFloat = 0
        
        if (self.isEqual(UIColor.whiteColor())) {
            return UIColor(white: 0.99, alpha: 1.0) ;
        }
        if (self.isEqual(UIColor.blackColor())) {
            return UIColor(white: 0.01, alpha: 1.0) ;
        }
        if (self.getHue(&hue, saturation:&saturation, brightness:&brightness, alpha:&alpha)) {
            return UIColor( hue: hue,saturation:saturation, brightness: brightness * factor,alpha:alpha);
            
        } else if (self.getWhite(&white, alpha:&alpha)) {
            return UIColor(white: white * factor,alpha:alpha);
        }
        
        return self
    }
}