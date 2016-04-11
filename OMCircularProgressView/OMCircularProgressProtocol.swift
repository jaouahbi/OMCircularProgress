//
//  OMCircularProgressProtocol.swift
//
//  Created by Jorge Ouahbi on 26/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit

////////////////////////////////////////////////////////////////////////////////
//
// The OMCircularProgress delegate Protocol
//
////////////////////////////////////////////////////////////////////////////////

@objc protocol OMCircularProgressProtocol
{
    /**
     
     Notificate the layer hit
     
     - parameter ctl:      The object caller
     - parameter layer:    The layer hitted
     - parameter location: The CGPoint where the layer was hitted
     */
    @objc optional func layerHit(ctl:UIControl, layer:CALayer, location:CGPoint)
}
