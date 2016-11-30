
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
//  UIColor+Interpolation.swift
//
//  Created by Jorge Ouahbi on 27/4/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//


import UIKit

extension UIColor
{
    // RGBA

    /// Linear interpolation
    ///
    /// - Parameters:
    ///   - start: start UIColor
    ///   - end: start UIColor
    ///   - t:  alpha
    /// - Returns: return UIColor
    
    public class func lerp(_ start:UIColor, end:UIColor, t:CGFloat) -> UIColor {
        
        let srgba = start.components
        let ergba = end.components
        
        return UIColor(red: Interpolation.lerp(srgba[0],y1: ergba[0],t: t),
                       green: Interpolation.lerp(srgba[1],y1: ergba[1],t: t),
                       blue: Interpolation.lerp(srgba[2],y1: ergba[2],t: t),
                       alpha: Interpolation.lerp(srgba[3],y1: ergba[3],t: t))
    }
    
    /// Cosine interpolate
    ///
    /// - Parameters:
    ///   - start: start UIColor
    ///   - end: start UIColor
    ///   - t:  alpha
    /// - Returns: return UIColor
    public class func coserp(_ start:UIColor, end:UIColor, t:CGFloat) -> UIColor {
        let srgba = start.components
        let ergba = end.components
        return UIColor(red: Interpolation.coserp(srgba[0],y1: ergba[0],t: t),
                       green: Interpolation.coserp(srgba[1],y1: ergba[1],t: t),
                       blue: Interpolation.coserp(srgba[2],y1: ergba[2],t: t),
                       alpha: Interpolation.coserp(srgba[3],y1: ergba[3],t: t))
    }
    
    /// Exponential interpolation
    ///
    /// - Parameters:
    ///   - start: start UIColor
    ///   - end: start UIColor
    ///   - t:  alpha
    /// - Returns: return UIColor
    
    public class func eerp(_ start:UIColor, end:UIColor, t:CGFloat) -> UIColor {
        let srgba = start.components
        let ergba = end.components
        
        let r = clamp(Interpolation.eerp(srgba[0],y1: ergba[0],t: t), lowerValue: 0,upperValue: 1)
        let g = clamp(Interpolation.eerp(srgba[1],y1: ergba[1],t: t),lowerValue: 0, upperValue: 1)
        let b = clamp(Interpolation.eerp(srgba[2],y1: ergba[2],t: t), lowerValue: 0, upperValue: 1)
        let a = clamp(Interpolation.eerp(srgba[3],y1: ergba[3],t: t), lowerValue: 0,upperValue: 1)
        
        assert(r <= 1.0 && g <= 1.0 && b <= 1.0 && a <= 1.0);
        
        return UIColor(red: r,
                       green: g,
                       blue: b,
                       alpha: a)
        
    }
    
    
    /// Bilinear interpolation
    ///
    /// - Parameters:
    ///   - start: start UIColor
    ///   - end: start UIColor
    ///   - t:  alpha
    /// - Returns: return UIColor
    
    public class func bilerp(_ start:[UIColor], end:[UIColor], t:[CGFloat]) -> UIColor {
        let srgba0 = start[0].components
        let ergba0 = end[0].components
        
        let srgba1 = start[1].components
        let ergba1 = end[1].components
        
        return UIColor(red: Interpolation.bilerp(srgba0[0], y1: ergba0[0], t1: t[0], y2: srgba1[0], y3: ergba1[0], t2: t[1]),
                       green: Interpolation.bilerp(srgba0[1], y1: ergba0[1], t1: t[0], y2: srgba1[1], y3: ergba1[1], t2: t[1]),
                       blue: Interpolation.bilerp(srgba0[2], y1: ergba0[2], t1: t[0], y2: srgba1[2], y3: ergba1[2], t2: t[1]),
                       alpha:  Interpolation.bilerp(srgba0[3], y1: ergba0[3], t1: t[0], y2: srgba1[3], y3: ergba1[3], t2: t[1]))
        
    }
}

