//
//  CGAffineTransformExtension.swift
//
//  Created by Jorge Ouahbi on 25/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit



extension CGAffineTransform : CustomDebugStringConvertible {
    public var debugDescription: String {
        return NSStringFromCGAffineTransform(self)
    }
}