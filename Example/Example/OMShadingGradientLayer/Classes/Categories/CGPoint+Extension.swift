
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
//  CGPoint+Extension.swift
//
//  Created by Jorge Ouahbi on 26/4/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

// v1.0

import UIKit


public func ==(lhs: CGPoint, rhs: CGPoint) -> Bool {
    return lhs.equalTo(rhs)
}

public func *(lhs: CGPoint, rhs: CGSize) -> CGPoint {
    return CGPoint(x:lhs.x*rhs.width,y: lhs.y*rhs.height)
}

public func *(lhs: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x:lhs.x*scalar,y: lhs.y*scalar)
}
public func /(lhs: CGPoint, rhs: CGSize) -> CGPoint {
    return CGPoint(x:lhs.x/rhs.width,y: lhs.y/rhs.height)
}


extension CGPoint : Hashable  {
    
    public var hashValue: Int {
        return self.x.hashValue << MemoryLayout<CGFloat>.size ^ self.y.hashValue
        
    }
    var isZero : Bool {
        return self.equalTo(CGPoint.zero)
    }
    
    func distance(_ point:CGPoint) -> CGFloat {
        let diff = CGPoint(x: self.x - point.x, y: self.y - point.y);
        return CGFloat(sqrtf(Float(diff.x*diff.x + diff.y*diff.y)));
    }
    
    
    func projectLine( _ point:CGPoint, length:CGFloat) -> CGPoint  {
        
        var newPoint = CGPoint(x: point.x, y: point.y)
        let x = (point.x - self.x);
        let y = (point.y - self.y);
        if (x.floatingPointClass == .negativeZero) {
            newPoint.y += length;
        } else if (y.floatingPointClass == .negativeZero) {
            newPoint.x += length;
        } else {
            #if CGFLOAT_IS_DOUBLE
                let angle = atan(y / x);
                newPoint.x += sin(angle) * length;
                newPoint.y += cos(angle) * length;
            #else
                let angle = atanf(Float(y) / Float(x));
                newPoint.x += CGFloat(sinf(angle) * Float(length));
                newPoint.y += CGFloat(cosf(angle) * Float(length));
            #endif
        }
        return newPoint;
    }
}
