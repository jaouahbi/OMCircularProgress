
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
*  Object that represent each step element data.
*
*/

public class OMStepData : CustomDebugStringConvertible
{
    /// Basic
    
    var angle:OMAngle! // step angle
    var color:UIColor!                                                    // step color
    var shapeLayer:CAShapeLayer! = CAShapeLayer()   // progress shape
    var shapeLayerBorder:CAShapeLayer? = nil
    
    var maskLayer:CALayer?                         // optional layer mask
    
    /// Well layer.
    
    var wellLayer:CAShapeLayer?         //
    var wellColor:UIColor?  = nil                  // without well color
    
    /// Text
    
    var text:String?                                // optional step text
    var textLayer:OMTextLayer?                      // layer for the text
    var textAlign:OMAlign = .Middle               // text align
    var textOrientationToAngle  : Bool = true       // is text oriented to the step angle
    var textAngleAlign : OMAngleAlign = .Middle
    var textRadius : CGFloat = 0.0                  // text radius
    
    
    /// Font
    
    var fontName : String = "Helvetica";
    var fontColor : UIColor = UIColor.blackColor()
    var fontSize : CGFloat = 9
    var fontBackgroundColor : UIColor = UIColor.clearColor()
    var fontStrokeWidth : Float = 0
    var fontStrokeColor : UIColor = UIColor.clearColor()
    
    /// Optional Step image
    
    var image : UIImage?
    var imageScaled:UIImage? = nil                           //
    var imageLayer : OMProgressImageLayer? = nil              // optional image layer
    var imageAlign : OMAlign = .Border
    var imageOrientationToAngle  : Bool = true
    var imageAngleAlign : OMAngleAlign = .Start
    // var imageIsSeparator : Bool = true
    // var shadowImage : Bool = false
    // private var imageShadow : UIImage? = nil
    
    
    //{
    //set {
    //if (shadowImage) {
    //    if let img = newValue {
    //        imageShadow = img.addOutterShadowColor()
    //    }
    //}else{
    //    imageShadow = newValue
    //}
    //}
    //get {
    //    return imageShadow
    //}
    //}
    
    var borderColor:UIColor = UIColor.lightGrayColor()      //
    var borderRatio:Double  = 0.2
    
 
    
    //var separatorAngleHalf:Double = 0.0                 // angle of arclength of image hypotenuse in radians
    
    /**
    OMStepData convenience constructor.
    
    - parameter startAngle: step start angle
    - parameter percent:    percent of circle
    - parameter color:      color step
    
    */
    required convenience public init(startAngle:Double,percent:Double,color:UIColor!){
        self.init(startAngle:startAngle,
            endAngle: startAngle + (2.0 * M_PI * percent),
            color:color)
    }
    /**
    
    OMStepData constructor.
    
    - parameter startAngle: step start angle
    - parameter endAngle:   step end angle
    - parameter color:      color step
    
    */
    init(startAngle:Double,endAngle:Double,color:UIColor!) {
        
        self.angle = OMAngle(startAngle:startAngle, endAngle:endAngle)
        
        self.color = color
        
        if (DEBUG_NO_WELL  == true) {
            wellColor = nil
        }
    }
    
    var progress:Double {                                                 // set/get step progress
        set{
            shapeLayer.strokeEnd = CGFloat(newValue)
            if let shapeLayerBorder = shapeLayerBorder {
                shapeLayerBorder.strokeEnd = shapeLayer.strokeEnd
            }
        }
        get{
            return Double(shapeLayer.strokeEnd)
        }
    }
    
    
    /// CustomDebugStringConvertible  protocol
    public var debugDescription: String {
        
        let angleStr = ""//round(separatorAngleHalf.radiansToDegrees());
        let maskStr  = ( self.maskLayer != nil ) ? "mask" :""
        
        let wellStr  = (wellColor != nil) ? "+well" : ""
        let imgStr   = (image != nil) ? "+image" : ""
        let txtStr   = (text != nil) ? "+text" : ""
        
        return "\(angle) separator:\(angleStr)° properties:(\(maskStr)\(wellStr)\(imgStr)\(txtStr))"
    }
    
}
