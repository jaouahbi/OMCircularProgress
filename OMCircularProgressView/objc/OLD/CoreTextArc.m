//
//  CoreTextArc.m
//
//  Created by Jorge Ouahbi on 22/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AssertMacros.h>
#import <Test-Swift.h>

#import "CoreTextArc.h"

//#define ARCVIEW_DEFAULT_FONT_NAME	@"Didot"
//#define ARCVIEW_DEFAULT_FONT_SIZE	64.0
//#define ARCVIEW_DEFAULT_RADIUS		150.0


typedef struct GlyphArcInfo {
    CGFloat			width;
    CGFloat			angle;	// in radians
} GlyphArcInfo;


static BOOL showsGlyphBounds = false;
static BOOL showsLineMetrics = false;
static BOOL showsArcLine     = true;

//FIXME:
//static BOOL dimsSubstitutedGlyphs = false;


static void PrepareGlyphArcInfo(CTLineRef line, CFIndex glyphCount, GlyphArcInfo *glyphArcInfo,OMAngle* angle)
{
    NSArray *runArray = (__bridge NSArray *)CTLineGetGlyphRuns(line);
    
    // Examine each run in the line, updating glyphOffset to track how far along the run is in terms of glyphCount.
    CFIndex glyphOffset = 0;
    for (id run in runArray) {
        CFIndex runGlyphCount = CTRunGetGlyphCount((__bridge CTRunRef)run);
        
        // Ask for the width of each glyph in turn.
        CFIndex runGlyphIndex = 0;
        for (; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
            glyphArcInfo[runGlyphIndex + glyphOffset].width = CTRunGetTypographicBounds((__bridge CTRunRef)run, CFRangeMake(runGlyphIndex, 1), NULL, NULL, NULL);
        }
        
        glyphOffset += runGlyphCount;
    }
    
    double lineLength = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
    
    CGFloat prevHalfWidth = glyphArcInfo[0].width / 2.0;
    
    glyphArcInfo[0].angle =  (prevHalfWidth / lineLength) * angle.length;
    
    double arcLength = glyphArcInfo[0].angle;
    
    // Divide the arc into slices such that each one covers the distance from one glyph's center to the next.
    CFIndex lineGlyphIndex = 1;
    for (; lineGlyphIndex < glyphCount; lineGlyphIndex++) {
        CGFloat halfWidth = glyphArcInfo[lineGlyphIndex].width / 2.0;
        CGFloat prevCenterToCenter = prevHalfWidth + halfWidth;
        
        glyphArcInfo[lineGlyphIndex].angle = (prevCenterToCenter / lineLength) * angle.length;
        
        arcLength += glyphArcInfo[lineGlyphIndex].angle;
        
        NSLog(@"#%ld angle %f (%f) [%f]",
              lineGlyphIndex,
              glyphArcInfo[lineGlyphIndex].angle * 57.29577951,
              arcLength * 57.29577951,
              angle.length * 57.29577951);
        
        prevHalfWidth = halfWidth;
    }
}



//
//- (id)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//        _font = [NSFont fontWithName:ARCVIEW_DEFAULT_FONT_NAME size:ARCVIEW_DEFAULT_FONT_SIZE];
//        _string = @"Curvaceous Type";
//        _radius = ARCVIEW_DEFAULT_RADIUS;
//        _showsGlyphBounds = NO;
//        _showsLineMetrics = NO;
//        _dimsSubstitutedGlyphs = NO;
//    }
//    return self;
//}

@implementation CoreTextArc

+(void) drawTextInArc:(CGRect) rect radius:(CGFloat) radius angle:(OMAngle*) angle string:(NSString*) string font:(UIFont*) font  color:(UIColor*) color
{
    // Don't draw if we don't have a font or string
    if (font == NULL || string == NULL){
        return;
    }
    
    // Initialize the text matrix to a known value
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    if(color == NULL) {
        color = [UIColor whiteColor];
    }
    
    // Draw a white background
    [color set];
    UIRectFill(rect);
    
    // Create our attributes.
    NSDictionary *attributes = @{NSFontAttributeName: font, NSLigatureAttributeName: @0};
    assert(attributes != nil);
    
    // Create the attributed string.
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:attributes];

    [CoreTextArc drawAttributedStringInArc:context rect:rect radius:radius angle:angle attrString:attrString];
}


+(void) drawAttributedStringInArc:(CGContextRef) context rect:(CGRect)rect radius:(CGFloat) radius angle:(OMAngle*)angle  attrString: (NSAttributedString*) attrString
{
    
    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attrString);
    assert(line != NULL);
    
    CFIndex glyphCount = CTLineGetGlyphCount(line);
    if (glyphCount == 0) {
        CFRelease(line);
        return;
    }
    
    GlyphArcInfo *	glyphArcInfo = (GlyphArcInfo*)calloc(glyphCount, sizeof(GlyphArcInfo));
    PrepareGlyphArcInfo(line, glyphCount, glyphArcInfo, angle);
    
    // Move the origin from the lower left of the view nearer to its center.
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMidX(rect), CGRectGetMidY(rect) - radius / 2.0);
    
    // Stroke the arc in red for verification.
    if (showsArcLine) {
        
        CGContextBeginPath(context);
        
        NSLog(@"*** from %f to %f",
              (angle.start * 57.29577951),
              (angle.end   * 57.29577951));
        
        CGMutablePathRef path = CGPathCreateMutable();
        //CGPathAddRelativeArc(path, NULL, center.x, center.y, innerRadius, startAngle, angle);
        CGPathAddRelativeArc(path, NULL, 0, 0, radius, angle.start, angle.length);
        //CGPathCloseSubpath(path);
        CGContextAddPath(context, path);
        
        //CGContextAddArc(context, 0.0, 0.0, radius,  angle.start , angle.end , 1);
        
        CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
        CGContextStrokePath(context);
    }
   
    // Rotate the context 90 degrees counterclockwise.
    CGContextRotateCTM(context, M_PI_2);
    
    /*
     Now for the actual drawing. The angle offset for each glyph relative to the previous glyph has already been calculated; with that information in hand, draw those glyphs overstruck and centered over one another, making sure to rotate the context after each glyph so the glyphs are spread along a semicircular path.
     */
    CGPoint textPosition = CGPointMake(0.0, radius);
    CGContextSetTextPosition(context, textPosition.x, textPosition.y);
    
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    CFIndex runCount = CFArrayGetCount(runArray);
    
    CFIndex glyphOffset = 0;
    CFIndex runIndex = 0;
    for (; runIndex < runCount; runIndex++) {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CFIndex runGlyphCount = CTRunGetGlyphCount(run);
        Boolean	drawSubstitutedGlyphsManually = false;
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        /*
         Determine if we need to draw substituted glyphs manually. Do so if the runFont is not the same as the overall font.
         */
//        if (dimsSubstitutedGlyphs && ![font isEqual:(__bridge UIFont *)runFont]) {
//            drawSubstitutedGlyphsManually = true;
//        }
        
        CFIndex runGlyphIndex = 0;
        for (; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
            CFRange glyphRange = CFRangeMake(runGlyphIndex, 1);
            
            CGFloat angleRotation = -(glyphArcInfo[runGlyphIndex + glyphOffset].angle);
            
            NSLog(@"glyph#%ld angleRotation : %f", runGlyphIndex, angleRotation * 57.29577951);
            
            CGContextRotateCTM(context, angleRotation);
            
            // Center this glyph by moving left by half its width.
            CGFloat glyphWidth = glyphArcInfo[runGlyphIndex + glyphOffset].width;
            CGFloat halfGlyphWidth = glyphWidth / 2.0;
            CGPoint positionForThisGlyph = CGPointMake(textPosition.x - halfGlyphWidth, textPosition.y);
            
            // Glyphs are positioned relative to the text position for the line, so offset text position leftwards by this glyph's width in preparation for the next glyph.
            
            textPosition.x -= glyphWidth;
            
            CGAffineTransform textMatrix = CTRunGetTextMatrix(run);
            textMatrix.tx = positionForThisGlyph.x;
            textMatrix.ty = positionForThisGlyph.y;
            CGContextSetTextMatrix(context, textMatrix);
            
            if (!drawSubstitutedGlyphsManually) {
                CTRunDraw(run, context, glyphRange);
            }
            else {
                /*
                 We need to draw the glyphs manually in this case because we are effectively applying a graphics operation by setting the context fill color. Normally we would use kCTForegroundColorAttributeName, but this does not apply as we don't know the ranges for the colors in advance, and we wanted demonstrate how to manually draw.
                 */
                CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
                CGGlyph glyph;
                CGPoint position;
                
                CTRunGetGlyphs(run, glyphRange, &glyph);
                CTRunGetPositions(run, glyphRange, &position);
                
                CGContextSetFont(context, cgFont);
                CGContextSetFontSize(context, CTFontGetSize(runFont));
                CGContextSetRGBFillColor(context, 0.25, 0.25, 0.25, 0.5);
                CGContextShowGlyphsAtPositions(context, &glyph, &position, 1);
                
                CFRelease(cgFont);
            }
            
            // Draw the glyph bounds
            if (showsGlyphBounds) {
                CGRect glyphBounds = CTRunGetImageBounds(run, context, glyphRange);
                
                CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);
                CGContextStrokeRect(context, glyphBounds);
            }
            // Draw the bounding boxes defined by the line metrics
            if (showsLineMetrics) {
                
                CGRect lineMetrics;
                CGFloat ascent, descent;
                
                CTRunGetTypographicBounds(run, glyphRange, &ascent, &descent, NULL);
                
                // The glyph is centered around the y-axis
                
                lineMetrics.origin.x    = -halfGlyphWidth;
                lineMetrics.origin.y    = positionForThisGlyph.y - descent;
                lineMetrics.size.width  = glyphWidth;
                lineMetrics.size.height = ascent + descent;
                
                CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
                CGContextStrokeRect(context, lineMetrics);
            }
        }
        
        glyphOffset += runGlyphCount;
    }
    
    CGContextRestoreGState(context);
    
    free(glyphArcInfo);
    CFRelease(line);
}

@end

