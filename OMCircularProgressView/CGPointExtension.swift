//
//  CGPointExtension.swift
//
//  Created by Jorge Ouahbi on 25/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit


/**
*  @brief  GPoint Extension
*/
extension CGPoint
{
    public func center(size:CGSize) -> CGPoint {
        return CGPoint(x:self.x - size.width  * 0.5, y:self.y - size.height * 0.5);
    }
    
    public func centerRect(size:CGSize) -> CGRect{
        return CGRect(origin: self.center(size), size:size)
    }
}