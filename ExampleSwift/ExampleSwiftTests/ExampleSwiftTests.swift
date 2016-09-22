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
//  ExampleSwiftTests.swift
//  ExampleSwiftTests
//
//  Created by Jorge Ouahbi on 19/1/15.
//

import UIKit
import XCTest

class ExampleSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }

    func testCPCAngle() {
        let angel1 = CPCAngle(start: 0, end: M_PI * 2);
        let angel2 = CPCAngle(start: M_PI, length: M_PI * 2)
        
        let angel3 = CPCAngle(start: -0, end: M_PI * 2);
        let angel4 = CPCAngle(start: -M_PI, length: M_PI * 2)
        
        let radius10:CGFloat = 10
        let radius1 :CGFloat = 1
       
        XCTAssert(angel1.valid() && angel2.valid())
        XCTAssert(angel3.valid() && angel4.valid())

        let arcAngle  = angel1.arcAngle(radius1)
        let arcLength = angel1.arcLength(radius1)
        
        XCTAssert(arcAngle == arcLength);
    
        let angelArc   = CPCAngle(start: 0, end: M_PI_2)
        let arcLength1 = angelArc.arcLength(radius10)
        let arcAngle1  = angelArc.arcAngle(radius10)
        let arcAngleDegree = arcAngle1.radiansToDegrees()
       
        XCTAssert(arcAngleDegree == 8.9999999995158309)
        XCTAssert(arcLength1     == 15.707963267948966)
        
        // add one degree
        let oneDegree = 1.0.degreesToRadians()
        angel1.add(oneDegree)
        angel2.add(oneDegree)
        angel3.add(oneDegree)
        angel4.add(oneDegree)
        
        XCTAssert(angel1.valid() == false &&
                  angel2.valid() == false &&
                  angel3.valid() == false &&
                  angel4.valid() == false)
        
        angel1.sub(oneDegree)
        angel2.sub(oneDegree)
        angel3.sub(oneDegree)
        angel4.sub(oneDegree)
        
        XCTAssert(angel1.valid() &&
                  angel2.valid() &&
                  angel3.valid() &&
                  angel4.valid())
        
        XCTAssert(CPCAngle.inRange(angle: M_PI * 3)      == false)
        XCTAssert(CPCAngle.inRange(angle: M_PI * 3 * -1) == false)
        
        XCTAssert(CPCAngle.ratio(elements: M_PI * 2.0) == 1.0)
        
    }
    func testCircleAngle() {
        //let angle90 = CPCAngle.angleFromPoint(source:CGPoint.zero,target:CGPoint(x:0.0,y:1.0))
        //XCTAssert(angle90 == 90,"angleFromPoint")
        //let angle270 = CPCAngle.angleFromPoint(source:CGPoint(x:0.0,y:1.0),target:CGPoint.zero)
        //XCTAssert(angle270 == 270,"angleFromPoint")
        
        /*
        let circle = OMCircleAngle(startDegree:0, lengthDegree: 45)

        let perimeter = circle.perimeter(1)
        let arc       = circle.arc(1)
        let arcLength = circle.arcLength(1)

        let perimeterChord = circle.chordPerimeter(radius: 1)
        let chordHeight = circle.chordHeight(radius: 1)
        let arcChord = circle.arcChord(radius: 1)
        
        XCTAssert(arc == 20.8,"angleFromPoint")
 */
        
    }
    
}
