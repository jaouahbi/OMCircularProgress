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
    var shortDescription:String {
        
        let r = self.components?[0].format(true)
        let g = self.components?[1].format(true)
        let b = self.components?[2].format(true)
        let a = self.components?[3].format(true)

        if let colorSpace = self.colorSpace {
            return "<\(colorSpace.model.name):\(r) \(g) \(b) \(a)>";
        }
        
        return "<\(r) \(g) \(b) \(a)>";
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
        return UIColor(red: Interpolation.eerp(srgba![0],y1: ergba![0],t: t),
                       green: Interpolation.eerp(srgba![1],y1: ergba![1],t: t),
                       blue: Interpolation.eerp(srgba![2],y1: ergba![2],t: t),
                       alpha: Interpolation.eerp(srgba![3],y1: ergba![3],t: t))
        
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
