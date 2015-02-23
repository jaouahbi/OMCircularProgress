//
//  Circle.swift
//  ExampleSwift
//
//  Created by Jorge Ouahbi on 22/2/15.
//  Copyright (c) 2015 Jorge Ouahbi. All rights reserved.
//

import CoreGraphics


class OMCircle
{
    var center : CGPoint = CGPointZero
    var radius : Double = 0.0
    
    class var RadiansInCircle: Double { return M_PI * 2.0 }
    
    
    required convenience init(center : CGPoint,radius : Double)
    {
        self.init()
        self.center = center;
        self.radius = radius;
    }
    
    func arcAngle(arcLength:Double) -> Double{
        
        return OMCircle.arcAngle(arcLength, radius: radius)
    }
    
    class func arcAngle(arcLength:Double,radius: Double) -> Double{
        
        return arcLength / radius;
    }
    
    func arcLength(angle:Double) -> Double{
        
        return OMCircle.arcLength(angle,radius: radius)
    }
    
    class func arcLength(angle:Double,radius: Double) -> Double{
        
        return angle * radius;
    }
    
    func arcPoint(angle:Double) -> CGPoint
    {
        //
        // Given a radius length r and an angle in radians and a circle's center (x,y),
        // calculate the coordinates of a point on the circumference
        //
        
        let r = CGFloat(radius)
        let a = CGFloat(angle)
        
        return CGPoint(x: center.x + r * cos(a), y: center.y + r * sin(a))
    }
    
    func contains(point:CGPoint) -> Bool {
        
        //compute the distance between the center of the circle and the point
        
        let dist = Double(center.distanceTo(point))
        
        //if the distance is less than the circle's radius, then the point is inside the circle
        
        return dist <= radius;
    }
    
    
    func encloses(circle:OMCircle) -> Bool
    {
        //compute the distance between the center of the circles
        
        let dist = Double(center.distanceTo(circle.center))
        
        //if the distance plus the circle param's radius is less than this circles radius, we know
        // this circle completely encoloses the circle param
        
        return dist + circle.radius <= radius;
    }
    
    var size:CGSize = CGSizeZero
    {
        didSet
        {
            let x = size.width;
            let y = size.height;
            
            radius = sqrt(Double(x * x + y * y))
        }
    }
    
    func area() -> Double
    {
        return M_PI * radius * radius
    }
}