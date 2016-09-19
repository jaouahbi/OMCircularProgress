
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

open class OMStepData : CustomDebugStringConvertible {
    /// Basic step data
    var angle:OMCircleAngle!                                 // step angle
    var color:UIColor!                                       // step color
    internal var shapeLayer:CAShapeLayer = CAShapeLayer()    // progress shape
    var maskLayer:CALayer? = nil                             // optional layer mask
    
    // Optional step image
    //internal var imageScaled:UIImage? = nil                  // real image used to draw
    internal var imageLayer : OMProgressImageLayer? = nil    // optional image layer
    lazy var image : OMProgressImageLayer! = {
        if self.imageLayer  == nil {
            self.imageLayer = OMProgressImageLayer()
        }
        return self.imageLayer!
    }()
    
    var imageAlign : OMAlign = .border                       // image align. Default : .Border
    var imageOrientationToAngle  : Bool = true               // is the imagen oriented to the step angle. Default : true
    var imageAngleAlign : OMAngleAlign = .start              // image angle align. Default : .Start

    /*
     * Text
     */
    var textAlign:OMAlign = .middle                          // text align. Default : .Middle
    var textOrientationToAngle  : Bool = true                // is the text oriented to the step angle. Default : true
    var textAngleAlign : OMAngleAlign = .middle              // text angle align. Default : .Middle
    var textRadius : CGFloat = 0.0                           // text radius. Default : 0.0
    internal var textLayer:OMTextLayer? = nil                // layer for the text
    lazy var text : OMTextLayer! = {
        if self.textLayer  == nil {
           self.textLayer = OMTextLayer()
        }
        return self.textLayer!
    }()
    
    /*
     * Border
     */
    var borderRatio:Double  = 0.0                            // border layer ratio. Default: 0%
    var borderShadow:Bool  = true                            // border layer shadow. Default: true
    internal var shapeLayerBorder:CAShapeLayer? = nil        // layer for the border
    lazy var border : CAShapeLayer! = {
        if self.shapeLayerBorder == nil {
            self.shapeLayerBorder = CAShapeLayer()
        }
        return self.shapeLayerBorder!;
    }()
    
    /*
     * Well layer.
     */
    
    internal var wellLayer:CAShapeLayer?                     // optional well layer
    lazy var well : CAShapeLayer! = {
        if self.wellLayer == nil {
            self.wellLayer = CAShapeLayer()
        }
        return self.wellLayer!;
    }()
    
    /**
     * OMStepData convenience constructor.
     *
     * parameter start: step start angle in radians
     * parameter percent:    percent of circle
     * parameter color:      color step
     *
     */
    
    required convenience public init(start:Double, percent:Double, color:UIColor!){
        self.init(start:start,
            end: start + (𝜏 * percent),
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
    
    convenience init(start:Double, end:Double, color:UIColor!) {
        let angle = OMCircleAngle(start:start, end:end)
        self.init(angle:angle, color:color)
    }

    /**
     *
     * OMStepData constructor.
     *
     * parameter start: step start angle in radians
     * parameter end:   step end angle in radians
     * parameter color:      color step
     *
     */
    
    init(angle:OMCircleAngle, color:UIColor!) {
        assert(angle.valid())
        self.angle = angle
        self.color = color
    }
    
    /**
     *  Set/Get the step progress from the shape layer
     */
    
    var progress:Double = 0.0 {
        didSet(newValue) {
            shapeLayer.strokeEnd = CGFloat(newValue)
            if let shapeLayerBorder = border {
                // update the border layer too
                shapeLayerBorder.strokeEnd = CGFloat(newValue)
            }
        }
    }
    
    public var debugDescription: String {
        var str = "[\(angle!) \(color.shortDescription) \(progress) \(borderRatio)]"
        //str += "[layers] mask: \(maskLayer) shape: \(shapeLayer) image: \(imageLayer) text:\(textLayer) border:\(shapeLayerBorder)"
        return str
    }
}
