
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
//  CPStepData.swift
//
//  Created by Jorge Ouahbi on 24/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit

open class CPElement<T:CALayer> {
    var radiusPosition : CPCRadiusAlignment = .border       // element position in radius. Default : .Border
    var orientationToAngle  : Bool = true                   // is the imagen oriented to the step angle. Default : true
    var anglePosition : CPCAnglePosition = .start           // element position in angle. Default : .start
    
    func correctedShadowOffsetForTransformRotationZ(_ angle:Double,offset:CGSize)-> CGSize {
        let x = offset.height*CGFloat(sin(angle)) + offset.width*CGFloat(cos(angle));
        let y = offset.height*CGFloat(cos(angle)) - offset.width*CGFloat(sin(angle));
        return CGSize(width: x, height: y)
    }
    
    var shadow:Bool = false {
        didSet(newValue) {
            if (newValue) {
                layer.shadowOpacity = 1.0
                layer.shadowRadius  = kDefaultElementShadowRadius
                layer.shadowColor   = kDefaultElementShadowColor
                layer.shadowOffset  = kDefaultElementShadowOffset
                
                if orientationToAngle {
                    let angle = layer.getTransformRotationZ()
                    layer.shadowOffset = correctedShadowOffsetForTransformRotationZ(angle, offset: layer.shadowOffset)
                    print("DEBUG(\(layer.name ?? "")):shadowOffset: \(layer.shadowOffset) angle:\(round((angle).radiansToDegrees())))")
                }
            } else {
                layer.shadowOpacity = 0
            }
        }
    }
    
    internal var internalLayer:T? = nil                // layer for the text
    lazy var layer : T! = {
        if self.internalLayer  == nil {
            self.internalLayer = T()
        }
        return self.internalLayer!
    }()
    
}

/**
 *
 *  The CPStepData object represent each step element data in the circular progress control
 *
 */

open class CPStepData : CustomDebugStringConvertible {
    /// Basic step data
    var angle:CPCAngle!                                       // step angle
    var color:UIColor!                                       // step color
    internal var shapeLayer:CAShapeLayer = CAShapeLayer()    // progress shape
    var maskLayer:CALayer? = nil                             // optional layer mask
    
    // Optional step image
    //internal var imageLayer : OMProgressImageLayer? = nil    // optional image layer
    //lazy var image : OMProgressImageLayer! = {
    //    if self.imageLayer  == nil {
    //        self.imageLayer = OMProgressImageLayer()
    //    }
    //    return self.imageLayer!
    //}()
    
    //var imageAlign : OMAlign = .border                       // image align. Default : .Border
    //var imageOrientationToAngle  : Bool = true               // is the imagen oriented to the step angle. Default : true
    //var imageAngleAlign : PositionInAngle = .start              // image angle align. Default : .start
    
    var ie:CPElement<OMProgressImageLayer> = CPElement<OMProgressImageLayer>()
    var te:CPElement<OMTextLayer> = CPElement<OMTextLayer>()

    /*
    fileprivate func setUpStepLayerGeometry(element:CPElement<CALayer>, sizeOf:CGSize) {
        print("DEBUG(\(element.layer.name ?? "")) : setUpStepLayerGeometry(\(self))")
        if self.te.layer.string != nil {
            // Reset the angle orientation before sets the new frame
            self.te.layer.setTransformRotationZ(0.0)
//            let sizeOf = self.te.layer.frameSize();
            let angle:Double = self.angle.align(self.te.positionInAngle)
            print("DEBUG(\(element.layer.name ?? "")): Angle \(round(angle.radiansToDegrees())) text aling:\(element.positionInAngle)")
            let anglePoint = CPCAngle.point(angle:angle,
                                           center:bounds.size.center(),
                                           radius: CGFloat(alignInRadius(align: element.align, size: sizeOf)))
            
            
            print("DEBUG(\(element.layer.name ?? "")): Position in angle \(anglePoint) Align:\(element.align)")
            let positionInAngle = anglePoint.centerRect(sizeOf)
            print("VERBOSE(\(element.layer.name ?? "")): Frame \(positionInAngle.integral) from the aligned step angle \(angle) and the text size \(sizeOf.integral()))")
            self.te.layer.frame = positionInAngle
            if self.te.orientationToAngle {
                let rotationZ = (angle - startAngle)
                print("VERBOSE(\(element.layer.name ?? "")): Image will be oriented to angle: \(round(rotationZ.radiansToDegrees()))")
                element.layer.setTransformRotationZ( rotationZ )
            }
        }
    }
    */
    
    
    /*
     * Text
     */
    
    /*var textAlign:OMAlign = .middle                          // text align. Default : .Middle
    var textOrientationToAngle  : Bool = true                // is the text oriented to the step angle. Default : true
    var textAngleAlign : PositionInAngle = .middle              // text angle align. Default : .middle
    internal var textLayer:OMTextLayer? = nil                // layer for the text
    lazy var text : OMTextLayer! = {
        if self.textLayer  == nil {
           self.textLayer = OMTextLayer()
        }
        return self.textLayer!
    }()
  */
    
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
     * CPStepData convenience constructor.
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
     * CPStepData constructor.
     *
     * parameter angle:      angle object
     * parameter color:      color step
     *
     */
    
    convenience init(start:Double, end:Double, color:UIColor!) {
        let angle = CPCAngle(start:start, end:end)
        self.init(angle:angle, color:color)
    }

    /**
     *
     * CPStepData constructor.
     *
     * parameter start: step start angle in radians
     * parameter end:   step end angle in radians
     * parameter color:      color step
     *
     */
    
    init(angle:CPCAngle, color:UIColor!) {
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
        let str = "[\(angle!) \(color.shortDescription) \(progress) \(borderRatio)]"
        return str
    }
}
