//
//    Copyright 2015 - Jorge Ouahbi
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

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
