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
//  UIBezierPath+Subpaths.swift
//
//  Created by Jorge Ouahbi on 22/9/16.
//  Copyright © 2016 Jorge Ouahbi . All rights reserved.
//

import UIKit

extension CGPath {
    
    func forEach( body: @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        func callback(info: UnsafeMutableRawPointer?, element: UnsafePointer<CGPathElement>) {
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        OMLog.printi("Memory layout \(MemoryLayout.size(ofValue: body))")
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: callback)
    }
}

extension CGPathElement {
    func addToPath(path:UIBezierPath) {
        switch (self.type) {
        case .closeSubpath:
            path.close()
            break;
        case .moveToPoint:
            path.move(to: self.points[0])
            break;
        case .addLineToPoint:
            path.addLine(to: self.points[0])
            break;
        case .addQuadCurveToPoint:
            path.addQuadCurve(to: self.points[0],controlPoint:self.points[1]);
            break;
        case .addCurveToPoint:
            path.addCurve(to: self.points[0],controlPoint1:self.points[1], controlPoint2:self.points[2]);
            break;
        }
    }
}

extension UIBezierPath {
    func subpaths() -> NSArray? {
        let results = NSMutableArray()
        var current:UIBezierPath? = nil;
        
        self.cgPath.forEach { element in
            switch (element.type) {
            case .moveToPoint:
                if ((current) != nil){
                    results.add(current);
                }
                current = UIBezierPath()
                current!.move(to: element.points[0]);
                
            case .addQuadCurveToPoint, .addCurveToPoint, .addLineToPoint:
                if ((current) != nil){
                    element.addToPath(path: current!);
                }
            case .closeSubpath:
                current?.close()
                if ((current) != nil){
                    results.add(current!);
                }
                current = nil;
            }
        }
        
        if ((current) != nil){
            results.add(current!);
        }
        
        return results;
    }
}
