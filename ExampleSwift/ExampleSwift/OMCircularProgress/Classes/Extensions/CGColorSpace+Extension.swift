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


@available(iOS 9.0, *)
extension CGColorSpace {
    
    /// CGColorSpace for the generic CMYK color space.
    public static let GenericCMYK = CGColorSpace(name: CGColorSpace.genericCMYK)
    
    /// CGColorSpace for the Adobe RGB (1998) color space.
    public static let AdobeRGB1998 = CGColorSpace(name: CGColorSpace.adobeRGB1998)
    
    /// CGColorSpace for the SRGB color space.
    public static let SRGB = CGColorSpace(name: CGColorSpace.sRGB)
    
    /// CGColorSpace for the generic gray color space with a gamma value of 2.2.
    public static let GenericGrayGamma2_2 = CGColorSpace(name: CGColorSpace.genericGrayGamma2_2)
    
    /// CGColorSpace for the generic gray color space.
    //public static let GenericGray = CGColorSpace(name: CGColorSpace.genericGray)
    
    /// CGColorSpace for the generic linear RGB color space.
    public static let GenericRGBLinear = CGColorSpace(name: CGColorSpace.genericRGBLinear)
    
    /// CGColorSpace for the generic RGB color space.
    public static let GenericRGB = GenericRGBLinear
    
    /// CGColorSpace for the generic XYZ color space.
    public static let GenericXYZ = CGColorSpace(name: CGColorSpace.genericXYZ)
    
    /// CGColorSpace for the linear ACESCG color space.
    public static let ACESCGLinear = CGColorSpace(name: CGColorSpace.acescgLinear)
    
    /// CGColorSpace for the ITUR_709 color space.
    public static let ITUR_709 = CGColorSpace(name: CGColorSpace.itur_709)
    
    /// CGColorSpace for the ITUR_2020 color space.
    public static let ITUR_2020 = CGColorSpace(name: CGColorSpace.itur_2020)
    
    /// CGColorSpace for the ROMMRGB color space.
    public static let ROMMRGB = CGColorSpace(name: CGColorSpace.rommrgb)
}


extension CGColorSpace {
    var numberOfComponents:size_t {
        return self.numberOfComponents
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
}
