//
//  CGRectExtension.swift
//
//  Created by Jorge Ouahbi on 25/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit


extension CGRect{
    
    mutating func apply(t:CGAffineTransform) {
        self = CGRectApplyAffineTransform(self, t)
    }
}