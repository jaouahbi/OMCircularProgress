//
//  CGSizeExtension.swift
//
//  Created by Jorge Ouahbi on 25/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit

/**
*  @brief  CGSize Extension
*/
extension CGSize
{
    func min() -> CGFloat {
        return Swift.min(height,width);
    }
    
    func max() -> CGFloat {
        return Swift.max(height,width);
    }
    
    func max(other : CGSize) -> CGSize {
        return self.max() >= other.max()  ? self : other;
    }
    
    func hypot() -> CGFloat {
        return CoreGraphics.hypot(height,width)
    }
    
    func center() -> CGPoint {
        return CGPoint(x:width * 0.5,y:height * 0.5)
    }
}