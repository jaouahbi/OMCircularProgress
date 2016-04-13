
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