//
//  OMCircularProgressDebug.swift
//  Test
//
//  Created by Jorge on 6/12/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import Foundation

extension OMCircularProgress
{
    // MARK: Debug functions
    
    /**
    Debug print all steps
    */
    func dumpAllSteps()
    {
        for (index, step) in dataSteps.enumerate() {
            print("\(index): \(step as! OMStepData)")
        }
    }
    
    /**
     Debug print all layers
     
     - parameter level: recursion level
     - parameter layer: layer to debug print
     */
    func dumpLayers(level:UInt, layer:CALayer) {
        if (layer.sublayers != nil) {
            for (_, curLayer) in layer.sublayers!.enumerate() {
                print("[\(level):\(layer)] \(curLayer.name) \(curLayer)")
                
                if(curLayer.sublayers != nil){
                    dumpLayers(level+1, layer: curLayer)
                }
            }
        }
    }
    
    // MARK: Consistency functions
    
    /**
    Check if the angle is in range +/- M_PI*2
    
    - parameter angle: angle to check
    
    - returns: return if the angle is in range
    */
    func isAngleInCircleRange(angle:Double) -> Bool{
        return (angle > (M_PI * 2) || angle < -(M_PI * 2)) == false
    }
    
    /**
     Get the total number of radians
     
     - returns: number of radians
     */
    func numberOfRadians() -> Double {
        
        let rads = dataSteps.reduce(0){
            $0 + ($1 as! OMStepData).angle.length()
        }
        
        //        var rads = 0.0
        //        for var index = 0; index < dataSteps.count ; ++index{
        //            rads +=  (dataSteps[index] as! OMStepData).angle.length()
        //        }
        //
        return rads
    }
    
    /// debug description
    
    override var debugDescription: String
        {
            let str : String = "Radius : \(radius) Inner Radius: \(innerRadius) Outer Radius: \(outerRadius) Mid Radius: \(midRadius) Border : \(borderWidth)"
            
            return str;
    }

}