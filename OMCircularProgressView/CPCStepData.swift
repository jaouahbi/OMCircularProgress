
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

open class CPCElement<T:CALayer> {
    var radiusPosition      : CPCRadiusAlignment = .border  // element position in radius. Default : .border
    var anglePosition       : CPCAnglePosition   = .start   // element position in angle. Default : .start
    var orientationToAngle  : Bool = true                   // is the imagen oriented to the step angle. Default : true
    func correctedShadowOffsetForTransformRotationZ(_ angle:Double,offset:CGSize)-> CGSize {
        return CGSize(width :offset.height*CGFloat(sin(angle)) + offset.width*CGFloat(cos(angle)),
                      height:offset.height*CGFloat(cos(angle)) - offset.width*CGFloat(sin(angle)))
    }
    var shadow:Bool = false {
        didSet {
            if (shadow) {
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
    
    // CPElements
    
    var ie:CPCElement<OMProgressImageLayer> = CPCElement<OMProgressImageLayer>()
    var te:CPCElement<OMTextLayer>          = CPCElement<OMTextLayer>()
    
    
    // CGFloat(alignInRadius(align: element.radiusPosition, size: sizeOf))
    
    func setUpStepLayerGeometry(element:CPCElement<CALayer>,
                                      radius:CGFloat,
                                      rect:CGRect,
                                      sizeOf:CGSize,
                                      startAngle:Double  = -90.0.degreesToRadians() ) {
        
        CPStepData.setUpStepLayerGeometry(element: element,
                                          angle: self.angle,
                                          radius:radius,
                                          rect:rect,
                                          sizeOf:sizeOf,
                                          startAngle:startAngle );
    
    }
    
    class func setUpStepLayerGeometry(element:CPCElement<CALayer>,
                                                  angle:CPCAngle,
                                                  radius:CGFloat,
                                                  rect:CGRect,
                                                  sizeOf:CGSize,
                                                  startAngle:Double  = -90.0.degreesToRadians() ) {
        
        let debugHeader = "DEBUG(\(element.layer.name ?? ""))"
        print("\(debugHeader): setUpStepLayerGeometry(\(self))")
        // Reset the angle orientation before sets the new frame
        element.layer.setTransformRotationZ(0.0)
        let angle:Double = angle.angle(element.anglePosition)
        print("\(debugHeader) : Angle \(round(angle.radiansToDegrees())) position in angle :\(element.anglePosition)")
        let anglePoint = CPCAngle.point(angle, center:rect.size.center(), radius: radius)
        print("\(debugHeader) : Position in angle \(anglePoint) position in radius :\(element.radiusPosition)")
        let positionInAngle = anglePoint.centerRect(sizeOf)
        print("\(debugHeader) : Frame \(positionInAngle.integral) from the aligned step angle \(angle) and the text size \(sizeOf.integral()))")
        element.layer.frame = positionInAngle
        if element.orientationToAngle {
            let rotationZ = (angle - startAngle)
            print("\(debugHeader): Image will be oriented to angle: \(round(rotationZ.radiansToDegrees()))")
            element.layer.setTransformRotationZ( rotationZ )
        }
    }
    
    
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
            // if exist border
            if self.borderRatio > 0.0 {
                // update the border layer too
                border.strokeEnd = CGFloat(newValue)
            }
        }
    }
    
    /**
     *  MARK : CustomDebugStringConvertible protocol
     */
    
    public var debugDescription: String {
        let str = "[\(angle!) \(color.shortDescription) \(progress) \(borderRatio)]"
        return str
    }
}
