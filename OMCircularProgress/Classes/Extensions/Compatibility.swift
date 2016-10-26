//
//  Compatibility.swift
//  ExampleSwift
//
//  Created by Jorge Ouahbi on 12/9/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

import Foundation


#if os(OSX)
    import Cocoa
    public typealias BezierPath         = NSBezierPath
    public typealias ViewController     = NSViewController
    public typealias View               = NSView
    public typealias Image              = NSImage
    public typealias Font               = NSFont
    public typealias GestureRecognizer  = NSGestureRecognizer
    public typealias TapRecognizer      = NSClickGestureRecognizer
    public typealias PanRecognizer      = NSPanGestureRecognizer
    public typealias Button             = NSButton
#else
    import UIKit
    public typealias BezierPath         = UIBezierPath
    public typealias ViewController     = UIViewController
    public typealias View               = UIView
    public typealias Image              = UIImage
    public typealias Font               = UIFont
    public typealias GestureRecognizer  = UIGestureRecognizer
    public typealias TapRecognizer      = UITapGestureRecognizer
    public typealias PanRecognizer      = UIPanGestureRecognizer
    public typealias Button             = UIButton
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
