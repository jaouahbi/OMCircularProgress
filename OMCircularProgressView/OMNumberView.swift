//
//  OMNumberView.swift
//  ExampleSwift
//
//  Created by Jorge Ouahbi on 13/4/15.
//  Copyright (c) 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit
import QuartzCore

class OMNumberView : UIView {
    
    override class func layerClass() -> AnyClass {
        return OMNumberLayer.self
    }
    
}

