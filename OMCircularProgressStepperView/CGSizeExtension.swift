//
//  CGSizeExtension.swift
//
//  Created by Jorge Ouahbi  on 4/2/15.
//  Copyright (c) 2015 Jorge Ouahbi . All rights reserved.
//

import QuartzCore

extension CGSize
{
    func min() -> CGFloat
    {
        return Swift.min(height,width);
    }
    
    func max() -> CGFloat
    {
        return Swift.max(height,width);
    }
    
    func max(other : CGSize) -> CGSize
    {
        return self.max() >= other.max()  ? self : other;
    }
    
    func hypot() -> CGFloat
    {
        return CoreGraphics.hypot(height,width)
    }
    
}