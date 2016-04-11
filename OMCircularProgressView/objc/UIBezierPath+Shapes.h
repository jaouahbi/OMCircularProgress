//
//  UIBezierPath.h
//
//  Created by Jorge Ouahbi on 28/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIBezierPath(Shapes)


- (UIBezierPath *) circlePath:(CGPoint) center radius:(CGFloat) radius startAngle:(double) startAngle angle:(double) angle;
//- (UIBezierPath *) circlePath:(CGRect) rect inset:(CGFloat) inset angle:(double) angle;
//- (UIBezierPath *) spiralPath:(CGFloat) radius center:(CGPoint) center;

@end
