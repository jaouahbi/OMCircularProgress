//
//  OMCircularProgressEvents.swift
//
//  Created by Jorge Ouahbi on 25/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit

extension OMCircularProgress
{
    /**
     Get the correct layer for the location
     
     - parameter location: point location in the view
     - returns: return the layer that contains the point
     */
    
    func layerForLocation( location:CGPoint ) -> CALayer?
    {
        // hitTest Returns the farthest descendant of the layer (Copy of layer)
        
        if let player = self.layer.presentationLayer()
        {
            let hitPresentationLayer = player.hitTest(location)
            
            if let hitplayer = hitPresentationLayer {
                
                // Real layer
                
                return hitplayer.modelLayer() as? CALayer
            }
            
            print("[!] Unable to locate the layer that contains the location \(location)")
        }
        
        return nil;
    }
    
    // MARK: UIResponder
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let touch = touches.first {
            
            var location:CGPoint = touch.locationInView(self);
            
            location = self.convertPoint(location, toView:nil)
            
            if let la = self.layerForLocation(location) {
                
                if((self.delegate) != nil && (self.delegate!.layerHit) != nil) {
                    self.delegate!.layerHit!(self, layer: la, location: location)
                }
            }
        }
        
        super.touchesBegan(touches , withEvent:event)
    }
}