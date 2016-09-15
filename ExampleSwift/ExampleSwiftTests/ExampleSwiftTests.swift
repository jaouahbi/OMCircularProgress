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
    
    func testCircleAngle() {
        let angle90 = OMCircleAngle.angleFromPoint(source:CGPoint.zero,target:CGPoint(x:0,y:1))
        XCTAssert(angle90 == 90,"angleFromPoint")
        let angle270 = OMCircleAngle.angleFromPoint(source:CGPoint(x:0,y:1),target:CGPoint.zero)
        XCTAssert(angle270 == 270,"angleFromPoint")
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
