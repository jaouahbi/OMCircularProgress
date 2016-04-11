//
//  OMCircularProgressSteps.swift
//
//  Created by Jorge Ouhahi on 26/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit


extension OMCircularProgress
{
    /// Get the number of steps
    
    var numberOfSteps : Int {
        return self.dataSteps.count;
    }
    /// step to index
    func stepIndex(step:OMStepData) -> Int {
        return self.dataSteps.indexOfObject(step)
    }
    
    /**
     Create a new progress step.
     Each progress step is represented by the object OMStepData
     
     - parameter startAngle: step start angle
     - parameter endAngle:   step end angle
     - parameter color:      step color
     
     - returns: return a OMStepData object.
     */
    
    func newStep(startAngle:Double, endAngle:Double, color:UIColor!) -> OMStepData?
    {
        assert(isAngleInCircleRange(endAngle), "Invalid angle:\(endAngle). range in radians : -(2*PI)/+(2*PI)")
        assert(isAngleInCircleRange(startAngle), "Invalid angle:\(startAngle). range in radians : -(2*PI)/+(2*PI)")
        
        let step = OMStepData(startAngle:startAngle,endAngle:endAngle,color:color)
        
        let numberOfRad = numberOfRadians() + step.angle.length()
        
        let diference = numberOfRad - (2 * M_PI)
        if diference > Double(FLT_EPSILON) {
            //
            print("Out of radians: can't create the step. overflow by \((2 * M_PI) - numberOfRad) radians")
            return nil
        }
        
        dataSteps.addObject(step)
        
        return step
    }
    
    /**
     Append a new step progress.
     
     - parameter color:     step color
     - returns: return a OMStepData object.
     
     - notes: only for test
     */
    func appendStep(color:UIColor!) -> OMStepData? {
        
        let percentConsumed = 1.0 - percentDone()
        return newStepWithPercent( percentConsumed - (percentConsumed / 2), color: color)
    }
    
    
    /**
     Remove all layers from the superlayer.
     */
    private func removeAllSublayersFromSuperlayer()
    {
        for (_, layer) in self.layer.sublayers!.enumerate() {
            layer.removeAllAnimations()
            layer.removeFromSuperlayer()
        }
        
//        for (_, step) in dataSteps.enumerate() {
//            let curStep = step as! OMStepData
//            
//            // Remove the layer mask
//            
//            curStep.maskLayer?.removeFromSuperlayer()
//            
//            curStep.wellLayer?.removeFromSuperlayer()
//            
//            curStep.imageLayer?.removeFromSuperlayer()
//            
//            curStep.textLayer?.removeFromSuperlayer()
//            
//            curStep.shapeLayer.removeFromSuperlayer()
//        }
//        
//        // Remove the center image layer
//        
//        imageLayer?.removeFromSuperlayer()
//        
//        // Remove the number layer
//        
//        numberLayer?.removeFromSuperlayer()
    }
    
    
    func removeAllSteps() {
        self.dataSteps.removeAllObjects()
        removeAllSublayersFromSuperlayer()
        layoutSubviews()
    }
    
    /**
     Create a new step progress.
     
     - parameter angle:   step end angle
     - parameter color:      step color
     
     - returns: return a OMStepData object.
     */
    func newStep(angle:Double, color:UIColor!) -> OMStepData? {
        
        let startAngle = getStartAngle()
        
        return newStep( startAngle, endAngle:startAngle + angle, color:color );
    }
    
    /**
     Create a new step progress.
     
     - parameter startAngle: step start angle
     - parameter percent:    step end angle expresed as percent of complete circle.
     - parameter color:      step color
     
     - returns: return a OMStepData object.
     */
    func  newStepWithPercent(startAngle:Double, percent:Double, color:UIColor!) -> OMStepData?
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
        
        dataSteps.addObject(step)
        
        return step
    }
    /**
     Create a new step progress.
     
     - parameter percent:   step angle expresed as percent of complete circle.
     - parameter color:     step color
     
     - returns: return a OMStepData object.
     */
    func newStepWithPercent(percent:Double, color:UIColor!) -> OMStepData? {
        
        return newStepWithPercent(getStartAngle(),percent: percent, color: color);
    }

    
    /// Get the last step data added to the list of steps
    
    var lastStepData : OMStepData? {
        
        get {
            if numberOfSteps > 0 {
                return dataSteps.lastObject as? OMStepData
            }
            if(DEBUG_VERBOSE){
                print("[!] Found 0 steps.")
            }
            return nil;
        }
    }
    
    // Get the step data by index from the list of steps
    
    subscript(stepIndex: Int) -> OMStepData? {
        get {
            assert(stepIndex <= numberOfSteps, "out of bounds. \(stepIndex) max: \(numberOfSteps)")
            if(stepIndex > numberOfSteps) {
                return nil
            }
            return dataSteps[stepIndex] as? OMStepData
        }
        set(newStep) {
            dataSteps[Int(stepIndex)] = newStep!
        }
    }
    
    /**
     Find the OMStepData that cantains the layer
     
     - parameter layer: layer to find
     - returns: the OMStepData owns the layer.
     */
    
    func stepByLayer(layer:CALayer!) -> OMStepData? {
        for (_, step) in dataSteps.enumerate() {
            let step = (step as! OMStepData)
            if(layer == step.shapeLayer) {
                return step
            }
            if let wellLayer = step.wellLayer {
                if(layer == wellLayer) {
                    return step
                }
            }
        }
        return nil;
    }
    
    /**
     Find the step angle with max length.
     
     - returns: return maximun angle length
     */
    
    func maxAngleLength() -> Double{
        var maxAngle:Double = 0
        for (_, step) in dataSteps.enumerate() {
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
        for (_, step) in dataSteps.enumerate() {
            minAngle = min((step as! OMStepData).angle.length(),minAngle)
        }
        return minAngle
    }
    
    /**
     Find the step image with max size.
     
     - returns: return maximun image size
     */
    
    func maxImageSize() -> CGSize {
        var maxSize:CGSize = CGSizeZero
        for (_, step) in dataSteps.enumerate() {
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
        for (_, step) in dataSteps.enumerate() {
            if let txt = (step as! OMStepData).textLayer{
                maxHeight = max(txt.bounds.size.height,maxHeight)
            }
        }
        return maxHeight
    }
}
