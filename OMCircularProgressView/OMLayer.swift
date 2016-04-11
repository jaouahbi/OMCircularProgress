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
//
//  Versión 0.1 (29-3-2015)
//  Added context flip
//  Versión 0.11 (22-4-2015)
//  Changed CGAffineTransform for CATransform3DMakeRotation
//  Versión 0.112 (29-4-2015)
//  Added the shadow funcs


import UIKit


/*

func degree2radian(a:CGFloat)->CGFloat {
    let b = CGFloat(M_PI) * a/180
    return b
}

func polygonPointArray(sides:Int,x:CGFloat,y:CGFloat,radius:CGFloat,adjustment:CGFloat=0)->[CGPoint] {
    let angle = degree2radian(360/CGFloat(sides))
    let cx = x // x origin
    let cy = y // y origin
    let r  = radius // radius of circle
    var i = sides
    var points = [CGPoint]()
    while points.count <= sides {
        let xpo = cx - r * cos(angle * CGFloat(i)+degree2radian(adjustment))
        let ypo = cy - r * sin(angle * CGFloat(i)+degree2radian(adjustment))
        points.append(CGPoint(x: xpo, y: ypo))
        i--;
    }
    return points
} Next there's the code for creating the CGPath of a star by creating the two arrays of points contained within polygons of two different sizes: 
func starPath(#x:CGFloat, #y:CGFloat, #radius:CGFloat, #sides:Int,pointyness:CGFloat) -> CGPathRef {
    let adjustment = 360/sides/2
    let path = CGPathCreateMutable()
    let points = polygonPointArray(sides,x,y,radius)
    var cpg = points[0]
    let points2 = polygonPointArray(sides,x,y,radius*pointyness,adjustment:CGFloat(adjustment))
    var i = 0
    CGPathMoveToPoint(path, nil, cpg.x, cpg.y)
    for p in points {
        CGPathAddLineToPoint(path, nil, points2[i].x, points2[i].y)
        CGPathAddLineToPoint(path, nil, p.x, p.y)
        i++
    }
    CGPathCloseSubpath(path)
    return path
} Finally there's a function for creating a UIBezierPath from the CGPath, so that we can experiment with this in a playground environment: 
func drawStarBezier(#x:CGFloat, #y:CGFloat, #radius:CGFloat, #sides:Int, #pointyness:CGFloat)->UIBezierPath {
    let path = starPath(x: x, y: y, radius: radius, sides: sides,pointyness)
    let bez = UIBezierPath(CGPath: path)
    return bez
} All this code cut and pasted into a playground enables us to then write this: 
for i in 5...10 {
    drawStarBezier(x: 0, y: 0, radius: 30, sides: i,  pointyness:2)
    
}

*/

//@objc class CALayerWithHitTest : CALayer
//{
//    override func containsPoint(p:CGPoint) -> Bool
//    {
//        let boundsContains = CGRectContainsPoint(self.bounds, p); // must be BOUNDS because Apple pre-converts the point to local co-ords before running the test
//        
//        if( boundsContains )
//        {
//            var atLeastOneChildContainsPoint:Bool = false;
//            
//            for (index, subLayer) in enumerate(self.sublayers)
//            {
//                let curLayer = subLayer as! CALayerWithHitTest
//                
//                // must pre-convert the point to local co-ords before running the test because Apple defines "containsPoint" in that fashion
//                
//                let pointInSubLayer = self.convertPoint(p,toLayer:curLayer)
//                
//                if( subLayer.containsPoint(pointInSubLayer)) {
//                    atLeastOneChildContainsPoint = true;
//                    break;
//                }
//            }
//            
//            return atLeastOneChildContainsPoint;
//        }
//        
//        return false;
//    }
//}






/*

/** Shadow properties. **/
var shadowColor: CGColor!

/* The opacity of the shadow. Defaults to 0. Specifying a value outside the
* [0,1] range will give undefined results. Animatable. */

var shadowOpacity: Float

/* The shadow offset. Defaults to (0, -3). Animatable. */

var shadowOffset: CGSize

/* The blur radius used to create the shadow. Defaults to 3. Animatable. */

var shadowRadius: CGFloat

/* When non-null this path defines the outline used to construct the
* layer's shadow instead of using the layer's composited alpha
* channel. The path is rendered using the non-zero winding rule.
* Specifying the path explicitly using this property will usually
* improve rendering performance, as will sharing the same path
* reference across multiple layers. Defaults to null. Animatable. */

var shadowPath: CGPath!

*/

@objc class OMLayer : CALayer
{
    
//layer?.layoutManager = CAConstraintLayoutManager.layoutManager()
//    documentLayer.addConstraint(CAConstraint(attribute: CAConstraintAttribute.Width, relativeTo: "superlayer", attribute: CAConstraintAttribute.Width, scale: 0.5, offset: 0.0))
//    documentLayer.addConstraint(CAConstraint(attribute: CAConstraintAttribute.Height, relativeTo: "superlayer", attribute: CAConstraintAttribute.Height, scale: 0.5, offset: 0.0))
//    documentLayer.addConstraint(CAConstraint(attribute: CAConstraintAttribute.MidX, relativeTo: "superlayer", attribute: CAConstraintAttribute.MidX, scale: 1.0, offset: 0.0))
//    documentLayer.addConstraint(CAConstraint(attribute: CAConstraintAttribute.MidY, relativeTo: "superlayer", attribute: CAConstraintAttribute.MidY, scale: 1.0, offset: 0.0))
//    
//    layer?.addSublayer(documentLayer)
//
    
    var maskingPath : CGPathRef?
    
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
        //self.borderColor = UIColor.yellowColor().CGColor
        //self.borderWidth = 0.5
        
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
    
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    
    func flipContextIfNeed(context:CGContext!) {
        // Core Text Coordinate System and Core Graphics are OSX style
        
        #if os(iOS)
            CGContextTranslateCTM(context, 0, self.bounds.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
        #endif
    }
    
    
    func animationActionForKey(event:String!) -> CABasicAnimation!
    {
        let animation = CABasicAnimation(keyPath: event)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = self.presentationLayer()!.valueForKey(event);
        return animation
    }
    
    
    func animateKeyPath(keyPath : String, fromValue : Double, toValue:Double, beginTime:NSTimeInterval, duration:NSTimeInterval, delegate:AnyObject?)
    {
        let animation = CABasicAnimation(keyPath:keyPath);
        
        var currentValue: AnyObject? = self.presentationLayer()?.valueForKey(keyPath)
        
        if (currentValue == nil) {
            currentValue = fromValue
        }
        
        animation.fromValue = currentValue
        animation.toValue   = toValue
        animation.delegate  = delegate
        
        if(duration > 0.0){
            animation.duration = duration
        }
        if(beginTime > 0.0){
            animation.beginTime = beginTime
        }
        
        animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear)
        animation.setValue(self,forKey:keyPath)
        
        self.addAnimation(animation, forKey:keyPath)
        
        self.setValue(toValue,forKey:keyPath)
    }
    
    // Sets the clipping path of the given graphics context to mask the content.
    
    func applyMaskToContext(ctx: CGContext!) {
        
        if let maskPath = self.maskingPath {
            CGContextAddPath(ctx, maskPath);
            CGContextClip(ctx);
        }
    }
    
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
