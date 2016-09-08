
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
//  OMCircularProgressSteps.swift
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
     *  Get the last step data added to the list of steps
     */
    var last : OMStepData? {
        get {
            if numberOfSteps > 0 {
                return dataSteps.lastObject as? OMStepData
            }
            SpeedLog.print("Found 0 steps.")
            return nil;
        }
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
     * Find the OMStepData that cantains the layer
     *
     * parameter layer: layer to find
     *
     * returns: the OMStepData owns the layer.
     */
    
//    func stepByLayer(layer:CALayer!) -> OMStepData? {
//        for (_, step) in dataSteps.enumerate() {
//            let step = (step as! OMStepData)
//            if(layer == step.shapeLayer) {
//                return step
//            }
//            if let wellLayer = step.wellLayer {
//                if(layer == wellLayer) {
//                    return step
//                }
//            }
//        }
//        return nil;
//    }
    
    /**
     Find the step angle with max length.
     
     - returns: return maximun angle length
     */
    
    func maxAngleLength() -> Double{
        var maxAngle:Double = 0
        for (_, step) in dataSteps.enumerated() {
            maxAngle = max((step as! OMStepData).angle.length(),maxAngle)
        }
        return maxAngle
    }
    
    /**
     Find the step angle with min length.
     
     - returns: return minimun angle length
     */
    func minAngleLength() -> Double{
        var minAngle:Double = M_PI * 2
        for (_, step) in dataSteps.enumerated() {
            minAngle = min((step as! OMStepData).angle.length(),minAngle)
        }
        return minAngle
    }
    
    /**
     Find the step image with max size.
     
     - returns: return maximun image size
     */
    
    func maxImageSize() -> CGSize {
        var maxSize:CGSize = CGSize.zero
        for (_, step) in dataSteps.enumerated() {
            if let img = (step as! OMStepData).image{
                maxSize = img.size.max(maxSize)
            }
        }
        return maxSize
    }
    /**
     Find the step text with max height.
     
     - returns: return maximun text height
     */
    func maxTextHeight() -> CGFloat {
        var maxHeight:CGFloat = 0
        for (_, step) in dataSteps.enumerated() {
            if let txt = (step as! OMStepData).textLayer{
                maxHeight = max(txt.bounds.size.height,maxHeight)
            }
        }
        return maxHeight
    }
    
    /**
     Create a new progress step.
     Each progress step is represented by the object OMStepData
     
     - parameter startAngle: step start angle
     - parameter endAngle:   step end angle
     - parameter color:      step color
     
     - returns: return a OMStepData object.
     */
    
    func addStep(_ startAngle:Double, endAngle:Double, color:UIColor!) -> OMStepData? {
        assert(isAngleInCircleRange(endAngle), "Invalid angle:\(endAngle). range in radians : -(2*PI)/+(2*PI)")
        assert(isAngleInCircleRange(startAngle), "Invalid angle:\(startAngle). range in radians : -(2*PI)/+(2*PI)")
        // Create the step
        let step = OMStepData(startAngle:startAngle,endAngle:endAngle,color:color)
        let numberOfRad = numberOfRadians() + step.angle.length()
        let diference   = numberOfRad - 𝜏
        if diference > Double(FLT_EPSILON) {
            SpeedLog.print("Out of radians: can't create the step. overflow by \(𝜏 - numberOfRad) radians")
            return nil
        }
        // Save the step
        dataSteps.add(step)
        return step
    }
    
    /**
     * Append a new step progress.
     *
     * parameter color: step color
     * returns: return a OMStepData object.
     *
     *  notes: only for test
     */
    func appendStep(_ color:UIColor!) -> OMStepData? {
        let percentConsumed = 1.0 - percentDone()
        return addStepWithPercent( percentConsumed - (percentConsumed / 2), color: color)
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
     Create a new step progress.
     
     - parameter angle:   step end angle
     - parameter color:      step color
     
     - returns: return a OMStepData object.
     */
    func addStep(_ angle:Double, color:UIColor!) -> OMStepData? {
        let startAngle = getStartAngle()
        return addStep( startAngle, endAngle:startAngle + angle, color:color );
    }
    
    /**
     Create a new step progress.
     
     - parameter startAngle: step start angle
     - parameter percent:    step end angle expresed as percent of complete circle.
     - parameter color:      step color
     
     - returns: return a OMStepData object.
     */
    func  addStepWithPercent(_ startAngle:Double, percent:Double, color:UIColor!) -> OMStepData?
    {
        var tempPercent = percent
        
        tempPercent.clamp(toLowerValue: 0.0,upperValue: 1.0)
        
        assert(isAngleInCircleRange(startAngle), "Invalid angle:\(startAngle). range in radians : -(2*PI)/+(2*PI)")
        
        let step = OMStepData(startAngle:startAngle,percent:tempPercent,color:color)
        
        let numberOfRad = numberOfRadians() + step.angle.length()
        
        if (numberOfRad > 2 * M_PI) {
            // can't create the step
            return nil
        }
        
        dataSteps.add(step)
        
        return step
    }
    /**
     Create a new step progress.
     
     - parameter percent:   step angle expresed as percent of complete circle.
     - parameter color:     step color
     
     - returns: return a OMStepData object.
     */
    func addStepWithPercent(_ percent:Double, color:UIColor!) -> OMStepData? {
        return addStepWithPercent(getStartAngle(),percent: percent, color: color);
    }
}
