//
//  OMCircularProgressNumberLayers.swift
//
//  Created by Jorge Ouahbi on 26/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit


extension OMCircularProgress
{
    // MARK: Text layer
    
    func updateNumericalLayer()
    {
        if let numberLayer = numberLayer {
            
            numberLayer.fontStrokeWidth = fontStrokeWidth
            numberLayer.fontStrokeColor = fontStrokeColor
            numberLayer.backgroundColor = fontBackgroundColor.CGColor;
            numberLayer.formatStyle = numberStyle()
            numberLayer.setFont(fontName, fontSize:fontSize)
            numberLayer.foregroundColor = fontColor
            
            // The percent is represented from 0.0 to 1.0
            
            let numberToRepresent = ( percentText ) ? 1 : dataSteps.count;
            
            let size = numberLayer.frameSizeLengthFromNumber(numberToRepresent)
            
            numberLayer.frame = bounds.size.center().centerRect( size )
            
            // Shadow for center text
            
            if shadowText {
                
                numberLayer.shadowOpacity = shadowOpacity
                numberLayer.shadowOffset  = shadowOffset
                numberLayer.shadowRadius  = shadowRadius
                numberLayer.shadowColor   = shadowColor.CGColor
            }
        }
    }
    
    /**
     <#Description#>
     
     - returns: <#return value description#>
     */
    
    func numberStyle() -> CFNumberFormatterStyle {
        return  percentText  ? .PercentStyle : .DecimalStyle
    }
    
    
    /**
     Setup the numerical layer
     */
    
    func setUpNumericalLayer() {
        if numberLayer == nil {
            
            // with the text centered
            numberLayer = OMNumberLayer(number: 0, formatStyle: numberStyle(), alignmentMode: "center")
            
            if DEBUG_LAYERS  {
                numberLayer?.name = "text layer"
            }
        }
        
        updateNumericalLayer()
    }
}