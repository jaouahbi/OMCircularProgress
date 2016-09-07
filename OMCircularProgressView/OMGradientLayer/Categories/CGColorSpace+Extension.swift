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

import UIKit


extension CGColorSpaceModel {
    var name : String {
        switch self {
            case .Unknown:return "Unknown"
            case .Monochrome:return "Monochrome"
            case .RGB:return "RGB"
            case .CMYK:return "CMYK"
            case .Lab:return "Lab"
            case .DeviceN:return "DeviceN"
            case .Indexed:return "Indexed"
            case .Pattern:return "Pattern"
        }
    }
}


@available(iOS 9.0, *)
extension CGColorSpace {
    
    /// CGColorSpace for the generic CMYK color space.
    public static let GenericCMYK = CGColorSpaceCreateWithName(kCGColorSpaceGenericCMYK)
    
    /// CGColorSpace for the Adobe RGB (1998) color space.
    public static let AdobeRGB1998 = CGColorSpaceCreateWithName(kCGColorSpaceAdobeRGB1998)
    
    /// CGColorSpace for the SRGB color space.
    public static let SRGB = CGColorSpaceCreateWithName(kCGColorSpaceSRGB)
    
    /// CGColorSpace for the generic gray color space with a gamma value of 2.2.
    public static let GenericGrayGamma2_2 = CGColorSpaceCreateWithName(kCGColorSpaceGenericGrayGamma2_2)
    
    /// CGColorSpace for the generic gray color space.
    public static let GenericGray = CGColorSpaceCreateWithName(kCGColorSpaceGenericGray)
    
    /// CGColorSpace for the generic RGB color space.
    public static let GenericRGB = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB)
    
    /// CGColorSpace for the generic linear RGB color space.
    public static let GenericRGBLinear = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGBLinear)
    
    /// CGColorSpace for the generic XYZ color space.
    public static let GenericXYZ = CGColorSpaceCreateWithName(kCGColorSpaceGenericXYZ)
    
    /// CGColorSpace for the linear ACESCG color space.
    public static let ACESCGLinear = CGColorSpaceCreateWithName(kCGColorSpaceACESCGLinear)
    
    /// CGColorSpace for the ITUR_709 color space.
    public static let ITUR_709 = CGColorSpaceCreateWithName(kCGColorSpaceITUR_709)
    
    /// CGColorSpace for the ITUR_2020 color space.
    public static let ITUR_2020 = CGColorSpaceCreateWithName(kCGColorSpaceITUR_2020)
    
    /// CGColorSpace for the ROMMRGB color space.
    public static let ROMMRGB = CGColorSpaceCreateWithName(kCGColorSpaceROMMRGB)
}


extension CGColorSpace {
    var numberOfComponents:size_t {
        return CGColorSpaceGetNumberOfComponents(self)
    }
    var model:CGColorSpaceModel {
        return CGColorSpaceGetModel(self)
    }
    var isRGB : Bool {
        return model == .RGB
    }
    var isCMYK : Bool {
        return model == .CMYK
    }
    var isLab : Bool {
        return model == .Lab
    }
    var isMonochrome : Bool {
        return model == .Monochrome
    }
}