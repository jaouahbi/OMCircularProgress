
#import <UIKit/UIKit.h>

@class OMAngle;

@interface CoreTextArc : NSObject

+(void) drawAttributedStringInArc:(CGContextRef) context rect:(CGRect)rect radius:(CGFloat) radius angle:(OMAngle*)angle  attrString: (NSAttributedString*) attrString;

+(void) drawTextInArc:(CGRect) rect radius:(CGFloat) radius angle:(OMAngle*) angle string:(NSString*) string font:(UIFont*) font  color:(UIColor*) color;

@end
