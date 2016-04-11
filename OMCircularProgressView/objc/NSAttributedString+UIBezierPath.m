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

#import "NSAttributedString+UIBezierPath.h"
#import "UIBezierPath+Points.h"

static const CGFloat TWO_PI = 2.0 * M_PI;

static BOOL showsGlyphBounds = false;
static BOOL showsLineMetrics = false;

@implementation NSAttributedString(UIBezierPath)

//+ (id) rendererForLayer: (CALayer *) layer string: (NSAttributedString *) aString
//{
//    OMStringRendering *renderer = [[self alloc] init];
//    renderer.layer  = layer;
//    renderer.string = aString;
////    renderer.showsGlyphBounds = true;
////    renderer.showsLineMetrics = true;
//    return renderer;
//}

// Prepare a flipped context
//- (void) prepareContextForCoreText: (CGContextRef) context ;
//{
//	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//	CGContextTranslateCTM(context, 0, _layer.bounds.size.height);
//	CGContextScaleCTM(context, 1.0, -1.0); // flip the context
//}

// Adjust the drawing rectangle to compensate for the flipped context
//- (CGRect) adjustedRect: (CGRect) rect
//{
//    CGRect newRect = rect;
//    CGFloat newYOrigin = _layer.bounds.size.height - (rect.size.height + rect.origin.y);
//    newRect.origin.y = newYOrigin;
//    return newRect;
//}

// Add text to rectangle
//- (void) drawInContext: (CGContextRef) context rect:(CGRect) theRect
//{
//    CGRect insetRect = CGRectInset(theRect, _inset, _inset);
//	CGRect rect = [self adjustedRect: insetRect];
//	CGMutablePathRef path = CGPathCreateMutable();
//	CGPathAddRect(path, NULL, rect);
//    
//	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_string);
//    CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, _string.length), path, NULL);
//	
//	CTFrameDraw(theFrame, context);
//	
//	CFRelease(framesetter);
//	CFRelease(theFrame);
//	CFRelease(path);
//}

// Draw in path

//- (void) drawInPath:(CGContextRef )context path: (CGMutablePathRef) path
//{
//	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_string);
//	CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, _string.length), path, NULL);
//	
//	CTFrameDraw(theFrame, context);
//	
//	CFRelease(framesetter);
//	CFRelease(theFrame);
//	CFRelease(path);	
//
//}



// Normalize the angle between 0 and 2pi
CGFloat normalizeAngle(CGFloat value)
{
    while ( value < 0.0 )
        value += TWO_PI;
    while ( value >= TWO_PI )
        value -= TWO_PI;
    return value;
}

// Compute the polar angle from the cartesian point
CGFloat polarFromCartesianAngle(CGPoint point)
{
    CGFloat value = 0.0;
    if ( point.x > 0.0 )
        value = atan(point.y / point.x);
    else if ( point.x < 0.0 ) {
        if ( point.y >= 0.0 )
            value = atan(point.y / point.x) + M_PI;
        else
            value = atan(point.y / point.x) - M_PI;
    } else {
        if ( point.y > 0.0 )
            value =  M_PI_2;
        else if ( point.y < 0.0 )
            value =  -M_PI_2;
        else
            value = 0.0;
    }
    return normalizeAngle(value);
}


// Return distance between two points
float distance (CGPoint p1, CGPoint p2)
{
	float dx = p2.x - p1.x;
	float dy = p2.y - p1.y;
	
	return sqrt(dx*dx + dy*dy);
}



- (void) drawOnPoints:(CGContextRef )context points: (NSArray *) points
{
	NSInteger pointCount = points.count;
	if (pointCount < 2) return;

    CGRect bounds = CGContextGetClipBoundingBox(context);
    
    // calculate the length of the point path
    
	float totalPointLength = 0.0f;
    for (int i = 1; i < pointCount; i++) {
		totalPointLength += distance([points [i] CGPointValue], [points [i-1] CGPointValue]);
    }
	
	// Create the typographic line
	CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)self);
	if (!line) return;
	double lineLength = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
	
	// Retrieve the runs
	CFArrayRef runArray = CTLineGetGlyphRuns(line);
	
	// Count the items
	int glyphCount = 0; //  Number of glyphs encountered
	float runningWidth; //  running width tally
	int glyphNum = 0;   //  Current glyph
	for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++) 
	{
		CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
		for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++) 
		{
			runningWidth += CTRunGetTypographicBounds(run, CFRangeMake(runGlyphIndex, 1), NULL, NULL, NULL);
			if (!glyphNum && (runningWidth > totalPointLength))
				glyphNum = glyphCount;
			glyphCount++;
		}
	}
    
    // Use total length to calculate the percent of path consumed at each point
	NSMutableArray *pointPercentArray = [NSMutableArray array];
	[pointPercentArray addObject:@(0.0f)];
	float distanceTravelled = 0.0f;
	for (int i = 1; i < pointCount; i++)
	{
		distanceTravelled += distance([points [i] CGPointValue], [points[i-1] CGPointValue]);
		[pointPercentArray addObject:@((distanceTravelled / totalPointLength))];
	}
	
	// Add a final item just to stop with. Probably not needed. 
	[pointPercentArray addObject:[NSNumber numberWithFloat:2.0f]];
    
//    NSLog(@"pointCount=%ld totalPointLength=%f pointPercentArray:%@ distanceTravelled:%f glyphCount:%d lineLength:%f",
//          pointCount,
//          totalPointLength,
//          pointPercentArray,
//          distanceTravelled,
//          glyphCount,
//          lineLength);
    
    // PREPARE FOR DRAWING
    
    NSRange subrange = {0, glyphNum};
    NSAttributedString * const newString = [self attributedSubstringFromRange:subrange];
    
	// Re-establish line and run array
	if (glyphNum)
	{
		CFRelease(line);
        
		line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)newString);
		if (!line) {NSLog(@"Error re-creating line"); return;}
		
		lineLength = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
		runArray = CTLineGetGlyphRuns(line);
	}
 
	// Keep a running tab of how far the glyphs have travelled to
	// be able to calculate the percent along the point path
	float glyphDistance = 0.0f;
		
    CGContextSaveGState(context);
    
    // Set the initial positions
    CGPoint textPosition = CGPointZero;
	CGContextSetTextPosition(context, textPosition.x, textPosition.y);
    
    //NSLog(@"runArray=%ld",CFArrayGetCount(runArray));
    
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++) 
	{
		// Retrieve the run
		CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
		
        // Retrieve font and color
		CFDictionaryRef attributes = CTRunGetAttributes(run);
		CTFontRef runFont = CFDictionaryGetValue(attributes, kCTFontAttributeName);
		CGColorRef fontColor = (CGColorRef) CFDictionaryGetValue(attributes, kCTForegroundColorAttributeName);
		//CFShow(attributes);
        
        if (fontColor) {
            CGContextSetFillColorWithColor(context, fontColor);
            CGContextSetStrokeColorWithColor(context, fontColor);
        }
        
		//if (fontColor) [[UIColor colorWithCGColor:fontColor] set];
		
        CFIndex glyCount = CTRunGetGlyphCount(run);
        
        //NSLog(@"Glyph count (%ld) for run %ld", glyCount,runIndex);
        
        //
		// Iterate through each glyph in the run
        //
        
		for (CFIndex runGlyphIndex = 0; runGlyphIndex < glyCount; runGlyphIndex++)
		{
			// Calculate the percent travel
            
            CFRange glyphRange = CFRangeMake(runGlyphIndex, 1);
            
			float glyphWidth = CTRunGetTypographicBounds(run, glyphRange, NULL, NULL, NULL);
			float percentConsumed = glyphDistance / lineLength;
            
			// Find a corresponding pair of points in the path
			CFIndex index = 1;
			while ((index < pointPercentArray.count) && 
				   (percentConsumed > [pointPercentArray [index] floatValue]))
				index++;
			
			// Don't try to draw if we're out of data. This should not happen.
            if (index > (points.count - 1)) {
                continue;
            }
			
			// Calculate the intermediate distance between the two points
			CGPoint point1 = [points [index - 1] CGPointValue];
			CGPoint point2 = [points [index] CGPointValue];
            
			float percent1 = [pointPercentArray [index - 1] floatValue];
			float percent2 = [pointPercentArray [index] floatValue];
            
            float percentOffset = 0.0;
            if(percentConsumed != 0) {
                percentOffset = (percentConsumed - percent1) / (percent2 - percent1);
            }
            
			float dx = point2.x - point1.x;
			float dy = point2.y - point1.y;
			
			CGPoint targetPoint = CGPointMake(point1.x + (percentOffset * dx), (point1.y + percentOffset * dy));
			targetPoint.y = bounds.size.height - targetPoint.y;
            
			// Set the x and y offset
			CGContextTranslateCTM(context, targetPoint.x, targetPoint.y);
			CGPoint positionForThisGlyph = CGPointMake(textPosition.x, textPosition.y);
			
            //FIXME
            
			// Rotate
            //float angle = 0;
//            
//            if( dx != 0 ){
//                angle = -atan(dy / dx);
//            }else{
//                NSLog(@"Error dx = 0");
//            }
            
            CGFloat angleRotation = -1 * polarFromCartesianAngle(CGPointMake(dx, dy));
            
			//if (dx < 0) angle += M_PI; // going left, update the angle
            
			CGContextRotateCTM(context, angleRotation);
            
			
			// Apply text matrix transform
			textPosition.x -= glyphWidth;
			CGAffineTransform textMatrix = CTRunGetTextMatrix(run);
			textMatrix.tx = positionForThisGlyph.x;
			textMatrix.ty = positionForThisGlyph.y;
			CGContextSetTextMatrix(context, textMatrix);
			
            /// Draw the glyph bounds
            if (showsGlyphBounds) {
                
                CGRect glyphBounds = CTRunGetImageBounds(run, context, glyphRange);
                CGContextSetLineWidth(context, 0.2);
                CGContextSetRGBStrokeColor(context, 1.0, 0.0, 1.0, 1.0);
                CGContextStrokeRect(context, glyphBounds);
            }
            
             // Draw the bounding boxes defined by the line metrics
            if (showsLineMetrics) {
            
                CGRect lineMetrics;
                CGFloat ascent, descent;
            
                double width = CTRunGetTypographicBounds(run, glyphRange, &ascent, &descent, NULL);
            
                // The glyph is centered around the y-axis
            
                lineMetrics.origin.x    = -(width / 2.0);
                lineMetrics.origin.y    = positionForThisGlyph.y - descent;
                lineMetrics.size.width  = glyphWidth;
                lineMetrics.size.height = ascent + descent;
            
                CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
                CGContextStrokeRect(context, lineMetrics);
            }
            
			// Draw the glyph
			CGGlyph glyph;
			CGPoint position;
			CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
			CTRunGetGlyphs(run, glyphRange, &glyph);
			CTRunGetPositions(run, glyphRange, &position);
			CGContextSetFont(context, cgFont);
			CGContextSetFontSize(context, CTFontGetSize(runFont));
			CGContextShowGlyphsAtPositions(context, &glyph, &position, 1);
			
			CFRelease(cgFont);
			
			// Reset context transforms
			CGContextRotateCTM(context, -angleRotation);
			CGContextTranslateCTM(context, -targetPoint.x, -targetPoint.y);
			
			glyphDistance += glyphWidth;

		}
	}
	
	CFRelease(line);
	CGContextRestoreGState(context);
}

- (void) drawOnBezierPath: (CGContextRef) context path:(UIBezierPath *) path {
    
    if (path == nil || context == nil) {
        NSLog(@"Unexpected nil argument. (context:%@,path:%@)",context,path);
        return;
    }
    
    [self drawOnPoints:context points:[path points]];
}

@end
