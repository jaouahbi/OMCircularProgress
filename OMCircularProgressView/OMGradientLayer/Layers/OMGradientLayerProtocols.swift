
//
//  OMGradientLayerProtocol.swift
//
//  Created by Jorge Ouahbi on 19/8/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

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


import UIKit

let kOMDefaultStartPoint = CGPoint(x: 0.0, y: 0.5) //CGPoint(x: 0.5,y: 0.0)
let kOMDefaultEndPoint   = CGPoint(x: 1.0, y: 0.5) //CGPoint(x: 0.5,y: 1.0)
let kOMDefaultStrokeLineWidth:CGFloat  = 1.0


public enum OMGradientType : Int {
    case Axial
    case Radial
}

// Animatable Properties
public struct OMGradientLayerProperties {
    
    // OMGradientLayerProtocol
    static var startPoint   = "startPoint"
    static var startRadius  = "startRadius"
    static var endPoint     = "endPoint"
    static var endRadius    = "endRadius"
    static var colors       = "colors"
    static var locations    = "locations"
    
    // OMShapeableLayerProtocol
    static var lineWidth    = "endRadius"
    static var stroke       = "colors"
    static var path         = "path"
    
};

public protocol OMShapeableLayerProtocol {
    // The path stroke line width.
    // Defaults to 1.0. Animatable.
    var lineWidth : CGFloat  {get set}
    // The strokeable flag.
    // Defaults to false. Animatable.
    var stroke : Bool  {get set}
    // The path.
    // Defaults to nil. Animatable.
    var path : CGPath?  {get set}
}

public protocol OMColorsAndLocationsProtocol {
    // The array of UIColor objects defining the color of each gradient
    // stop. Defaults to nil. Animatable.
    var colors: [UIColor] {get set}
    // An optional array of CGFloat objects defining the location of each
    // gradient stop as a value in the range [0,1]. The values must be
    // monotonically increasing. If a nil array is given, the stops are
    // assumed to spread uniformly across the [0,1] range. When rendered,
    // the colors are mapped to the output colorspace before being
    // interpolated. Defaults to nil. Animatable.
    var locations : [CGFloat]?  {get set}
}

// Axial Gradient layer Protocol
public protocol OMGradientLayerProtocol : OMShapeableLayerProtocol, OMColorsAndLocationsProtocol {

    //Defaults to CGPoint(x: 0.5,y: 0.0). Animatable.
    var startPoint: CGPoint   {get set}
    //Defaults to CGPoint(x: 0.5,y: 1.0). Animatable.
    var endPoint: CGPoint  {get set}
    var extendsBeforeStart : Bool  {get set}
    var extendsPastEnd:Bool {get set}
    var gradientType : OMGradientType  {get set}
    // Radial
    var startRadius:CGFloat  {get set}
    var endRadius: CGFloat   {get set}
}


