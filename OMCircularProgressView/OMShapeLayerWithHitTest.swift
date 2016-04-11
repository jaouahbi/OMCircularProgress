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