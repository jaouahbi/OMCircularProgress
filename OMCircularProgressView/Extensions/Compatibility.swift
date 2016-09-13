//
//  Compatibility.swift
//  ExampleSwift
//
//  Created by Jorge on 12/9/16.
//  Copyright © 2016 none. All rights reserved.
//

import Foundation

#if os(OSX)
    import Cocoa
    public typealias BezierPath = NSBezierPath
#else
    import UIKit
    public typealias BezierPath = UIBezierPath
#endif

#if os(OSX)
    // UIKit Compatibility
    extension NSBezierPath {
        open func addLine(to point: CGPoint) {
            self.line(to: point)
        }
        
        open func addCurve(to point: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
            self.curve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
        
        open func addQuadCurve(to point: CGPoint, controlPoint: CGPoint) {
            self.curve(to: point, controlPoint1: controlPoint, controlPoint2: controlPoint)
        }
    }
#endif
