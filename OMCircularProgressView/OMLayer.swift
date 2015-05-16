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
class OMLayer: CALayer {

    
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
    
    override init()
    {
        super.init()
        
        self.contentsScale = UIScreen.mainScreen().scale
        self.needsDisplayOnBoundsChange = true;
        
        // https://github.com/danielamitay/iOS-App-Performance-Cheatsheet/blob/master/QuartzCore.md
        
        //self.shouldRasterize = true
        self.drawsAsynchronously = true
        self.allowsGroupOpacity  = false
        
        // DEBUG
        //self.borderColor = UIColor.blueColor().CGColor!
        //self.borderWidth = 0.5
        
        // Disable animating view refreshes
        //self.actions = ["contents" as! NSString : NSNull()]
    }
    
    
    override init!(layer: AnyObject!) {
        super.init(layer: layer)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func setPlainShadow() {
        shadowColor = UIColor.blackColor().CGColor
        shadowOffset = CGSize(width: 0, height: 10)
        shadowOpacity = 0.4
        shadowRadius = 5
    }
    
    func setHoverShadow() {
        let size = self.bounds.size
        let width = size.width
        let height = size.height
        
        var ovalRect = CGRect(x: 5, y: height + 5, width: width - 10, height: 15)
        var path = UIBezierPath(roundedRect: ovalRect, cornerRadius: 10)
        

        shadowPath = path.CGPath
        shadowColor = UIColor.blackColor().CGColor
        shadowOpacity = 0.2
        shadowRadius = 5
        shadowOffset = CGSize(width: 0, height: 0)
    }
    
    func setCurvedShadow() {
        let size = bounds.size
        let width = size.width
        let height = size.height
        let depth = CGFloat(11.0)
        let lessDepth = 0.8 * depth
        let curvyness = CGFloat(5)
        let radius = CGFloat(1)
        
        var path = UIBezierPath()
        
        // top left
        path.moveToPoint(CGPoint(x: radius, y: height))
        
        // top right
        path.addLineToPoint(CGPoint(x: width - 2*radius, y: height))
        
        // bottom right + a little extra
        path.addLineToPoint(CGPoint(x: width - 2*radius, y: height + depth))
        
        // path to bottom left via curve
        path.addCurveToPoint(CGPoint(x: radius, y: height + depth),
            controlPoint1: CGPoint(x: width - curvyness, y: height + lessDepth - curvyness),
            controlPoint2: CGPoint(x: curvyness, y: height + lessDepth - curvyness))
        
        shadowPath = path.CGPath
        shadowColor = UIColor.blackColor().CGColor
        shadowOpacity = 0.3
        shadowRadius = radius
        shadowOffset = CGSize(width: 0, height: -3)
    }
    
//    override var bounds : CGRect
//    {
//        didSet
//        {
//            super.bounds = bounds
//            setCurvedShadow()
//        }
//    }
    
    
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
        animation.fromValue = self.presentationLayer().valueForKey(event);
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
        
        ///
        
        self.setValue(toValue,forKey:keyPath)
    }
    
    // Sets the clipping path of the given graphics context to mask the content.
    
    func applyMaskToContext(ctx: CGContext!) {
        if let maskPath = self.maskingPath {
            CGContextAddPath(ctx, maskPath);
            CGContextClip(ctx);
        }
    }
    
    override func drawInContext(ctx: CGContext!) {
        super.drawInContext(ctx)
    }
    
    //DEBUG
    
    override func display() {
        if ( self.hidden ) {
            println("WARNING: hidden layer. \(self.name)")
        } else {
            if(self.bounds.isEmpty) {
                println("WARNING: empty layer. \(self.name)")
            }else{
                super.display()
            }
        }
    }
}
