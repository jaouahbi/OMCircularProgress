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
//  CGRect+Extension.swift
//
//  Created by Jorge Ouahbi on 25/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit

/// CGRect Extension

extension CGRect{
    
    /// Apply affine transform
    ///
    /// - parameter t: affine transform
    mutating func apply(_ t:CGAffineTransform) {
        self = self.applying(t)
    }
    /// Center in rect
    ///
    /// - parameter mainRect: main rect
    ///
    /// - returns: center CGRect in main rect
    func center(_ mainRect:CGRect) -> CGRect{
        let dx = mainRect.midX - self.midX
        let dy = mainRect.midY - self.midY
        return self.offsetBy(dx: dx, dy: dy);
    }
    /// Construct with size
    ///
    /// - parameter size: CGRect size
    ///
    /// - returns: CGRect
    public init(_ size:CGSize) {
        self.init(origin: CGPoint.zero,size: size)
    }
    /// Construct with origin
    ///
    /// - parameter origin: CGRect origin
    ///
    /// - returns: CGRect
    public init(_ origin:CGPoint) {
        self.init(origin: origin,size: CGSize.zero)
    }
    
    /// Min radius from rectangle
    public var minRadius:CGFloat {
        return size.min() * 0.5;
    }
    
    /// Max radius from a rectangle (pythagoras)
    public var maxRadius:CGFloat {
        return 0.5 * sqrt(size.width * size.width + size.height * size.height)
    }
    
    /// Construct with points
    ///
    /// - parameter point1: CGPoint
    /// - parameter point2: CGPoint
    ///
    /// - returns: CGRect
    public init(_ point1:CGPoint,point2:CGPoint) {
        self.init(point1)
        size.width  = fabs(point2.x-self.origin.x)
        size.height = fabs(point2.y-self.origin.y)
    }
    
}
