
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
//  OMCircularProgressNumberLayers.swift
//
//  Created by Jorge Ouahbi on 26/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit

// MARK: Center numerical text layer extension

extension OMCircularProgress
{
    /**
     * Update the center numerical layer
     */

    func updateCenterNumericalLayer() {
        
        if let numberLayer = centerNumberLayer {
            
            numberLayer.fontStrokeWidth = fontStrokeWidth
            numberLayer.fontStrokeColor = fontStrokeColor
            numberLayer.backgroundColor = fontBackgroundColor.cgColor;
            numberLayer.formatStyle     = numberStyle()
            numberLayer.font            = UIFont( name: fontName, size: fontSize)
            numberLayer.foregroundColor = fontColor
            
            // The percent is represented from 0.0 to 1.0
            
            let numberToRepresent = NSNumber(value:Int32(( percentText ) ? 1 : dataSteps.count));
            
            let size = numberLayer.frameSizeLengthFromNumber(numberToRepresent)
            
            numberLayer.frame = bounds.size.center().centerRect(size)
            
            // Shadow for center text
            if shadowText {
                
                numberLayer.shadowOpacity = shadowOpacity
                numberLayer.shadowOffset  = shadowOffset
                numberLayer.shadowRadius  = shadowRadius
                numberLayer.shadowColor   = shadowColor.cgColor
            }
        }
    }
    
    /**
     * Format style for the númerical layer
     *
     * returns: return the number style (CFNumberFormatterStyle)
     */
    
    func numberStyle() -> CFNumberFormatterStyle {
        return  percentText  ? .percentStyle : .decimalStyle
    }
    
    /**
     * Create/Update the numerical text layer
     */
    
    func setUpCenterNumericalTextLayer() {
        if centerNumberLayer == nil {
            // create the numerical text layer with the text centered
            let alignmentMode = "center"
            centerNumberLayer = OMNumberLayer(number: 0, formatStyle: numberStyle(), alignmentMode: alignmentMode)
            #if TAG_LAYERS
                centerNumberLayer?.name = "text layer"
            #endif
        }
        
        updateCenterNumericalLayer()
    }
}
