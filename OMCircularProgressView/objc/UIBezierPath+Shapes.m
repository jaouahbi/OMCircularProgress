//
//  UIBezierPath.m
//
//  Created by Jorge Ouahbi on 28/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

#import "UIBezierPath+Shapes.h"

@implementation UIBezierPath(Shapes)

//- (id) initWithAttributedString: (NSAttributedString *) aString
//{
//    if (!(self = [super initWithFrame:CGRectZero])) return self;
//    
//    self.backgroundColor = [UIColor clearColor];
//    _string = aString;
//    renderer = [StringRendering rendererForView:self string:aString];
//    return self;
//}

//- (UIBezierPath *) circlePath:(CGRect) rect inset:(CGFloat) inset angle:(double) angle
//{
//    float cX = CGRectGetMidX(rect);
//    float cY = CGRectGetMidY(rect);
//    
//    float radius = (MIN(rect.size.width, rect.size.height) / 2.0f) - inset;
//    
//    float dTheta = 2 * M_PI / 60.0f;
//    
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path moveToPoint:CGPointMake(cX + radius, cY)];
//    
//    for (float theta = dTheta; theta < (angle - dTheta); theta += dTheta)
//    {
//        float dx = radius * cos(theta);
//        float dy = radius * sin(theta);
//        [path addLineToPoint:CGPointMake(cX + dx, cY + dy)];
//    }
//    
//    return path;
//}

- (UIBezierPath *) circlePath:(CGPoint) center radius:(CGFloat) radius startAngle:(double) startAngle angle:(double) angle
{
    double cX = center.x;
    double cY = center.y;

    double dTheta =  2 * M_PI / 60.0f;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    double endAngle = (angle + startAngle);/// /(angle - dTheta + startAngle);
    
    NSLog(@"*** startAngle %f endAngle %f angle %f (%f)",
          startAngle* 57.29577951,endAngle* 57.29577951,angle* 57.29577951,(endAngle-startAngle)* 57.29577951);
    
    for (double theta = startAngle; theta < endAngle; theta += dTheta) {
        
        double dx = radius * cos(theta);
        double dy = radius * sin(theta);
        
        CGPoint pt = CGPointMake(cX + dx, cY + dy);
        
        if (theta == startAngle) {
            [path moveToPoint:pt];
        } else {
            [path addLineToPoint:pt];
        }
    }
    
    return path;
}

//- (UIBezierPath *) spiralPath:(CGFloat) radius center:(CGPoint) center
//{
//    float cX = CGRectGetMidX(self.bounds);
//    float cY = CGRectGetMidY(self.bounds);
//    
//    float dRadius = 1.0f;
//    
//    float dTheta = 2 * M_PI / 60.0f;
//    
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path moveToPoint:CGPointMake(cX + radius, cY)];
//    
//    for (float theta = dTheta; theta < 8 * M_PI; theta += dTheta)
//    {
//        radius += dRadius;
//        float dx = radius * cos(theta);
//        float dy = radius * sin(theta);
//        [path addLineToPoint:CGPointMake(cX + dx, cY + dy)];
//    }
//    
//    return path;
//}


@end
