//
//  UIBezierPath+Points.m
//
//  Created by Jorge Ouahbi on 28/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

#import "UIBezierPath+Points.h"

@implementation UIBezierPath(Points)
#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]

// Get points from Bezier Curve
void _getPointsFromBezier(void *info, const CGPathElement *element)
{
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    
    // Retrieve the path element type and its points
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    // Add the points if they're available (per type)
    if (type != kCGPathElementCloseSubpath)
    {
        [bezierPoints addObject:VALUE(0)];
        if ((type != kCGPathElementAddLineToPoint) &&
            (type != kCGPathElementMoveToPoint))
            [bezierPoints addObject:VALUE(1)];
    }
    if (type == kCGPathElementAddCurveToPoint)
        [bezierPoints addObject:VALUE(2)];
}

-(NSArray *)points
{
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(self.CGPath, (__bridge void *)points, _getPointsFromBezier);
  //  NSLog(@"%@ %ld",points, [points count]);
    return points;
}


@end
