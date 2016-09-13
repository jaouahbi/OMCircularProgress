
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
//  OMCircularProgressDebug.swift
//
//  Created by Jorge Ouahbi on 6/12/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit

extension OMCircularProgress
{
    // MARK: Debug functions
    
    /**
     * Debug print all steps
     */
    func dumpAllSteps() {
        for (index, step) in dataSteps.enumerated() {
            VERBOSE("\(index): \(step as! OMStepData)")
        }
    }
    
    /**
     * Debug print all layers
     *
     * parameter level: recursion level
     * parameter layer: layer to debug print
     */
    
    func dumpLayers(_ level:UInt, layer:CALayer) {
        if (layer.sublayers != nil) {
            for (_, curLayer) in layer.sublayers!.enumerated() {
                VERBOSE("[\(level):\(layer)] \(curLayer.name) \(curLayer)")
                if(curLayer.sublayers != nil){
                    dumpLayers(level+1, layer: curLayer)
                }
            }
        }
    }
    
    // MARK: Consistency functions

    
    /// debug description
    
    override var debugDescription: String
    {
            let str : String = "Radius : \(radius) Inner Radius: \(innerRadius) Outer Radius: \(outerRadius) Mid Radius: \(midRadius) Border : \(borderWidth)"
            
            return str;
    }

}
