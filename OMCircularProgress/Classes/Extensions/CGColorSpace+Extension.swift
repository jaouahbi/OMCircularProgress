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
//  CGColorSpace+Extensions.swift
//
//  Created by Jorge Ouahbi on 13/5/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//
//  v 1.0

import UIKit

extension CGColorSpaceModel {
    var name : String {
        switch self {
        case .unknown:return "Unknown"
        case .monochrome:return "Monochrome"
        case .rgb:return "RGB"
        case .cmyk:return "CMYK"
        case .lab:return "Lab"
        case .deviceN:return "DeviceN"
        case .indexed:return "Indexed"
        case .pattern:return "Pattern"
        }
    }
}

extension CGColorSpace {
    var isUnknown: Bool {
        return model == .unknown
    }
    var isRGB : Bool {
        return model == .rgb
    }
    var isCMYK : Bool {
        return model == .cmyk
    }
    var isLab : Bool {
        return model == .lab
    }
    var isMonochrome : Bool {
        return model == .monochrome
    }
    var isDeviceN : Bool {
        return model == .deviceN
    }
    var isIndexed : Bool {
        return model == .indexed
    }
    var isPattern : Bool {
        return model == .pattern
    }
    
}
