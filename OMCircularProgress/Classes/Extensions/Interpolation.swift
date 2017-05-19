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
//  Interpolation.swift
//
//  Created by Jorge Ouahbi on 13/5/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

import UIKit

/// Interpolation type
///
/// - linear: <#linear description#>
/// - exponential: <#exponential description#>
/// - cosine: <#cosine description#>
/// - cubic: <#cubic description#>
/// - bilinear: <#bilinear description#>

enum InterpolationType {
    case linear
    case exponential
    case cosine
    case cubic
    case bilinear
}

class Interpolation
{
    /// Cubic Interpolation
    ///
    /// - Parameters:
    ///   - y0: element 0
    ///   - y1: element 1
    ///   - y2: element 2
    ///   - y3: element 3
    ///   - t: alpha
    /// - Returns: the interpolate value
    /// - Note:
    /// Paul Breeuwsma proposes the following coefficients for a smoother interpolated curve,
    /// which uses the slope between the previous point and the next as the derivative at the current point.
    /// This results in what are generally referred to as Catmull-Rom splines.
    ///  a0 = -0.5*y0 + 1.5*y1 - 1.5*y2 + 0.5*y3;
    ///  a1 = y0 - 2.5*y1 + 2*y2 - 0.5*y3;
    ///  a2 = -0.5*y0 + 0.5*y2;
    ///  a3 = y1;
    
    class func cubicerp(_ y0:CGFloat,y1:CGFloat,y2:CGFloat,y3:CGFloat,t:CGFloat) -> CGFloat {
        var a0:CGFloat
        var a1:CGFloat
        var a2:CGFloat
        var a3:CGFloat
        var t2:CGFloat
        
        assert(t >= 0.0 && t <= 1.0);
        
        t2 = t*t;
        a0 = y3 - y2 - y0 + y1;
        a1 = y0 - y1 - a0;
        a2 = y2 - y0;
        a3 = y1;
        
        return(a0*t*t2+a1*t2+a2*t+a3);
    }

    /// Exponential Interpolation
    ///
    /// - Parameters:
    ///   - y0: element 0
    ///   - y1: element 1
    ///   - t: alpha
    /// - Returns: the interpolate value

    class func eerp(_ y0:CGFloat,y1:CGFloat,t:CGFloat) -> CGFloat {
        assert(t >= 0.0 && t <= 1.0);
        let end    = log(max(Double(y0), 0.01))
        let start  = log(max(Double(y1), 0.01))
        return   CGFloat(exp(start - (end + start) * Double(t)))
    }
    

    
    /// Linear Interpolation
    ///
    /// - Parameters:
    ///   - y0: element 0
    ///   - y1: element 1
    ///   - t: alpha
    /// - Returns: the interpolate value
    /// - Note:
    ///  Imprecise method which does not guarantee v = v1 when t = 1, due to floating-point arithmetic error.
    ///  This form may be used when the hardware has a native Fused Multiply-Add instruction.
    ///  return v0 + t*(v1-v0);
    ///
    ///  Precise method which guarantees v = v1 when t = 1.
    ///  (1-t)*v0 + t*v1;
    
    class func lerp(_ y0:CGFloat,y1:CGFloat,t:CGFloat) -> CGFloat {
        assert(t >= 0.0 && t <= 1.0);
        let inverse = 1.0 - t;
        return inverse * y0 + t * y1
    }
    
    /// Bilinear Interpolation
    ///
    /// - Parameters:
    ///   - y0: element 0
    ///   - y1: element 1
    ///   - t1: alpha
    ///   - y2: element 2
    ///   - y3: element 3
    ///   - t2: alpha
    /// - Returns: the interpolate value
    
    class func bilerp(_ y0:CGFloat,y1:CGFloat,t1:CGFloat,y2:CGFloat,y3:CGFloat,t2:CGFloat) -> CGFloat {
        assert(t1 >= 0.0 && t1 <= 1.0);
        assert(t2 >= 0.0 && t2 <= 1.0);

        let x = lerp(y0, y1: y1, t: t1)
        let y = lerp(y2, y1: y3, t: t2)
        
        return lerp(x, y1: y, t: 0.5)
    }
    
    /// Cosine Interpolation
    ///
    /// - Parameters:
    ///   - y0: element 0
    ///   - y1: element 1
    ///   - t: alpha
    /// - Returns: the interpolate value
    
    class func coserp(_ y0:CGFloat,y1:CGFloat,t:CGFloat) -> CGFloat {
        assert(t >= 0.0 && t <= 1.0);
        let mu2 = CGFloat(1.0-cos(Double(t) * .pi))/2;
        return (y0*(1.0-mu2)+y1*mu2);
    }
}
