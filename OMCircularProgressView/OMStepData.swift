
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
//  OMStepData.swift
//
//  Created by Jorge Ouahbi on 24/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit

/**
 *
 *  The OMStepData object represent each step element data in the circular progress control
 *
 */

open class OMStepData {
    /// Basic step data
    var angle:OMCircleAngle!                                // step angle
    var color:UIColor!                                      // step color
    internal var shapeLayer:CAShapeLayer = CAShapeLayer()   // progress shape
    var maskLayer:CALayer? = nil                            // optional layer mask
    // Optional border.
    internal var shapeLayerBorder:CAShapeLayer? = nil       // optional border layer
    var borderColor:UIColor = UIColor.lightGray             // border layer color. Default: lightGray
    var borderRatio:Double  = 0.2                           // border layer ratio. Default: 20%
    // Optional well layer.
    var wellLayer:CAShapeLayer?                             // optional well layer
    var wellColor:UIColor?  = UIColor(white: 0.9, alpha: 0.8)             // optional well layer color
    // Optional text
    var text:String? = nil                                   // optional step text
    internal var textLayer:OMTextLayer? = nil                // optional layer for the text
    var textAlign:OMAlign = .middle                          // text align. Default : .Middle
    var textOrientationToAngle  : Bool = true                // is the text oriented to the step angle. Default : true
    var textAngleAlign : OMAngleAlign = .middle              // text angle align. Default : .Middle
    var textRadius : CGFloat = 0.0                           // text radius. Default : 0.0
    // Text font
    var fontName : String = "Helvetica";                     // text font name. Default : Helvetica
    var fontColor : UIColor = UIColor.black                  // text font color. Default : black
    var fontSize : CGFloat = 9                               // text font size. Default : 9
    var fontBackgroundColor : UIColor = UIColor.clear        // text font backgound color. Default : clear
    var fontStrokeWidth : Float = 0                          // text font stroke width. Default : 0
    var fontStrokeColor : UIColor = UIColor.clear            // text font stroke color. Default : clear
    // Optional step image
    var image : UIImage?                                     // optional image
    internal var imageScaled:UIImage? = nil                  // real image used to draw
    internal var imageLayer : OMProgressImageLayer? = nil    // optional image layer
    var imageAlign : OMAlign = .border                       // image align. Default : .Border
    var imageOrientationToAngle  : Bool = true               // is the imagen oriented to the step angle. Default : true
    var imageAngleAlign : OMAngleAlign = .start              // image angle align. Default : .Start
    

    /**
     * OMStepData convenience constructor.
     *
     * parameter startAngle: step start angle in radians
     * parameter percent:    percent of circle
     * parameter color:      color step
     *
     */
    
    required convenience public init(startAngle:Double, percent:Double, color:UIColor!){
        self.init(startAngle:startAngle,
            endAngle: startAngle + (𝜏 * percent),
            color:color)
    }
    /**
     *
     * OMStepData constructor.
     *
     * parameter angle:      angle object
     * parameter color:      color step
     *
     */
    
    convenience init(startAngle:Double, endAngle:Double, color:UIColor!) {
        let angle = OMCircleAngle(startAngle:startAngle, endAngle:endAngle)
        self.init(angle:angle, color:color)
    }

    /**
     *
     * OMStepData constructor.
     *
     * parameter startAngle: step start angle in radians
     * parameter endAngle:   step end angle in radians
     * parameter color:      color step
     *
     */
    
    init(angle:OMCircleAngle, color:UIColor!) {
        assert(angle.valid())
        self.angle = angle
        self.color = color
    }
    
    /**
     *  Set/Get the step progress
     */
    
    var progress:Double {
        set {
            shapeLayer.strokeEnd = CGFloat(newValue)
            if let shapeLayerBorder = shapeLayerBorder {
                // update the border layer too
                shapeLayerBorder.strokeEnd = CGFloat(newValue)
            }
        }
        get {
            return Double(shapeLayer.strokeEnd)
        }
    }
}
