
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
//  CAShapeLayer+HitTest.swift
//  Created by Jorge Ouahbi on 24/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit
import CoreGraphics

extension CAShapeLayer
{
    override open func contains(_ p:CGPoint) -> Bool {
        let eoFill:Bool = (self.fillRule == "even-odd")
        
        if((self.path != nil)){
            return self.path!.contains(p, using: eoFill ? .evenOdd : .winding)
        }
        return false
    }
    
    func pathBoundingBox() -> CGRect {
        if((self.path != nil)){
            return self.path!.boundingBox
        }
        return CGRect.zero
    }
}
