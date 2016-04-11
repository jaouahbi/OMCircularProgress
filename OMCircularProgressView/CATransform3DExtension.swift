//
//  CATransform3DExtension.swift
//
//  Created by Jorge Ouahbi on 25/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit


public extension CATransform3D {
    func affine() -> CGAffineTransform {
        return CATransform3DGetAffineTransform(self)
    }
}