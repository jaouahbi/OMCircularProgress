
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
//  OMShapeLayerWithHitTest.swift
//  Created by Jorge Ouahbi on 24/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit


@objc class OMShapeLayerWithHitTest : CAShapeLayer
{
    override init(){
        super.init()
  
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
    }
    
//    override func drawInContext(ctx: CGContext) {
//        
//        
//        super.drawInContext(ctx)
//        
//
//        if let path = self.path{
//            CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 1.0, 1.0)
//            CGContextAddPath(ctx,path)
//            CGContextStrokePath(ctx)
//        }
//        
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func containsPoint(p:CGPoint) -> Bool {
        let eoFill:Bool = (self.fillRule == "even-odd")
        
        if((self.path != nil)){
            return CGPathContainsPoint(self.path, nil, p, eoFill)
        }
        return false
    }
    
    func pathBoundingBox() -> CGRect {
        if((self.path != nil)){
            return CGPathGetBoundingBox(self.path)
        }
        return CGRectZero
    }
}