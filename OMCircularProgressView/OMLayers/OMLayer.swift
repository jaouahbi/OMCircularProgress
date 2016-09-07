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
//  OMLayer.swift
//
//  Created by Jorge Ouahbi on 26/3/15.
//
//  Description:
//  Simple derived CALayer class used as base class


import UIKit

@objc class OMLayer : CALayer
{
    //var maskingPath : CGPathRef?
    
    /// Radians
    
    var angleOrientation:Double = 0.0 {
        didSet {
            self.transform = CATransform3DMakeRotation(CGFloat(angleOrientation), 0.0, 0.0, 1.0)
        }
    }
    
    override init() {
        
        super.init()
        
        self.contentsScale = UIScreen.mainScreen().scale
        self.needsDisplayOnBoundsChange = true;
        
        // https://github.com/danielamitay/iOS-App-Performance-Cheatsheet/blob/master/QuartzCore.md
        
        //self.shouldRasterize = true
        self.drawsAsynchronously = true
        self.allowsGroupOpacity  = false
        
        // DEBUG
        //self.borderColor = UIColor.redColor().CGColor
        //self.borderWidth = 5
    }
    
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func disableAimatingRefreshes() {
        // Disable animating view refreshes
        self.actions = [
            "position"      :    NSNull(),
            "bounds"        :    NSNull(),
            "contents"      :    NSNull(),
            "shadowColor"   :    NSNull(),
            "shadowOpacity" :    NSNull(),
            "shadowOffset"  :    NSNull() ,
            "shadowRadius"  :    NSNull()]
    }
    
    func flipContextIfNeed(context:CGContext!) {
        // Core Text Coordinate System and Core Graphics are OSX style
        
        #if os(iOS)
            CGContextTranslateCTM(context, 0, self.bounds.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
        #endif
    }
    
    // Sets the clipping path of the given graphics context to mask the content.
    
//    func applyMaskToContext(ctx: CGContext!) {
//        
//        if let maskPath = self.maskingPath {
//            CGContextAddPath(ctx, maskPath);
//            CGContextClip(ctx);
//        }
//    }
    
    override func drawInContext(ctx: CGContext) {
        
        // Clear the layer
        
        CGContextClearRect(ctx, CGContextGetClipBoundingBox(ctx));
        
        //applyMaskToContext(ctx)
    }
    
    //DEBUG
    override func display() {
        if ( self.hidden ) {
            print("[!] WARNING: hidden layer. \(self.name)")
        } else {
            if(self.bounds.isEmpty) {
                print("[!]WARNING: empty layer. \(self.name)")
            }else{
                super.display()
            }
        }
    }
}
