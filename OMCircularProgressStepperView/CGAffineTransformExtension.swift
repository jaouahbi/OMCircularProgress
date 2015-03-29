//
//  CGAffineTransformExtension.swift
//  ExampleSwift
//
//  Created by Jorge Ouahbi on 29/3/15.
//  Copyright (c) 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit


extension CGAffineTransform : Printable, DebugPrintable
{
    public var description: String
    {
        get
        {
            return NSStringFromCGAffineTransform(self) as String
        }
    }
    
    public var debugDescription: String
    {
        get
        {
            return description
        }
    }
    
}