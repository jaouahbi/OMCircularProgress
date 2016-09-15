
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
//  OMCircularProgress+Steps.swift
//
//  Created by Jorge Ouahbi on 26/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit


extension OMCircularProgress
{
    /**
     * Get the number of steps
     */
    var numberOfSteps : Int {
        return self.dataSteps.count;
    }

    /**
     * Step to index in the steps array
     */
    func stepIndex(_ step:OMStepData) -> Int {
        return self.dataSteps.index(of: step)
    }

    /**
     *  Get/Set the step data, subscripted by index from the list of steps
     */
    
    subscript(stepIndex: Int) -> OMStepData? {
        get {
            assert(stepIndex < numberOfSteps, "out of bounds. \(stepIndex) max: \(numberOfSteps)")
            if stepIndex < numberOfSteps {
                return dataSteps[stepIndex] as? OMStepData
            }
            return nil
        }

        set(newStep) {
            assert(stepIndex < numberOfSteps, "out of bounds. \(stepIndex) max: \(numberOfSteps)")
            if stepIndex < numberOfSteps {
                dataSteps[Int(stepIndex)] = newStep!
            }
        }
    }
    
    /**
     * Create a new progress step.
     *
     * Each progress step is represented by the object OMStepData
     *
     * parameter start: step start angle
     * parameter end:   step end angle
     * parameter color:      step color
     *
     * returns: return a OMStepData object.
     */
    
    func addStep(_ start:Double, end:Double, color:UIColor!) -> OMStepData? {
        let angle = OMCircleAngle(start:start,end:end)
        let valid = angle.valid()
        assert(valid,"Invalid angle:\(angle). range in radians : -(2*PI)/+(2*PI)")
        if(!valid) {
            WARNING("Invalid angle :\(angle)")
            return nil;
        }
        // Create the step
        let step = OMStepData(angle: angle, color:color)
        if isOverflow(lenght: angle.length()) {
            return nil
        }
        // Save the step
        dataSteps.add(step)
        return step
    }
    
    /**
     * Remove all steps.
     */
    
    func removeAllSteps() {
        self.dataSteps.removeAllObjects()
        removeSublayers()
        layoutSubviews()
    }
    
    /**
     * Check steps overflow
     */
    
    internal func isOverflow(lenght:Double) -> Bool {
        let numberOfRad = numberOfRadians() + lenght
        let diference   = numberOfRad - 𝜏
        if diference > Double(FLT_EPSILON) {
            WARNING("Out of radians: can't create the step. overflow by \(𝜏 - numberOfRad) radians")
            return true
        }
        return false
    }
    /**
     * Create a new step progress.
     *
     * parameter angle:   step end angle
     * parameter color:      step color
     *
     * returns: return a OMStepData object.
     */
    
    func addStep(_ angle:Double, color:UIColor!) -> OMStepData? {
        let startAngle = getStartAngle()
        return addStep( startAngle, end:startAngle + angle, color:color );
    }
    
    /**
     * Create a new step progress.
     *
     * parameter startAngle: step start angle
     * parameter percent:    step end angle expresed as percent of complete circle.
     * parameter color:      step color
     *
     * returns: return a OMStepData object.
     */
    
    func  addStepWithPercent(_ start:Double, percent:Double, color:UIColor!) -> OMStepData? {
        assert(OMCircleAngle.range(angle: start),
               "Invalid angle:\(startAngle). range in radians : -(2*PI)/+(2*PI)")
        
        // clap the percent.
        let step = OMStepData(start:start,
                              percent:clamp(percent, lower: 0.0,upper: 1.0),
                              color:color)
        
        if isOverflow(lenght: step.angle.length()) {
            return nil
        }
        
        dataSteps.add(step)
        return step
    }
    
    /**
     * Create a new step progress.
     *
     * parameter percent:   step angle expresed as percent of complete circle.
     * parameter color:     step color
     *
     * returns: return a OMStepData object.
     */
    
    func addStepWithPercent(_ percent:Double, color:UIColor!) -> OMStepData? {
        return addStepWithPercent(getStartAngle(), percent: percent, color: color);
    }
}
