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
//  Based on : https://developer.apple.com/library/mac/samplecode/CoreTextArcCocoa/
//
//  AND
//
//  StringRendering.h
//
//  Created by Erica Sadun on 7/29/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface NSAttributedString(UIBezierPath)

//@property (assign) CGFloat inset;
//@property (strong) CALayer *layer;
//@property (strong) NSAttributedString *string;



//+ (id) rendererForLayer: (CALayer *) layer string: (NSAttributedString *) aString;

//- (void) prepareContextForCoreText: (CGContextRef) context ;
//- (void) drawInContext: (CGContextRef) context rect:(CGRect) theRect;

- (void) drawOnPoints:(CGContextRef )context points: (NSArray *) points;
//- (void) drawInPath:(CGContextRef )context path: (CGMutablePathRef) path;
- (void) drawOnBezierPath:(CGContextRef )context path: (UIBezierPath *) path;
@end
