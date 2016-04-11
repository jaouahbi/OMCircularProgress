
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#define IPHONE

#ifdef IPHONE

    #define POINT       CGPoint
    #define RECT        CGRect

    #define MakeRect    CGRectMake
    #define ZeroRect    CGRectZero
    #define EqualRects  CGRectEqualToRect

    #define MinX        CGRectGetMinX
    #define MidX        CGRectGetMidX
    #define MaxX        CGRectGetMaxX
    #define MinY        CGRectGetMinY
    #define MidY        CGRectGetMidY
    #define MaxY        CGRectGetMaxY
    #define Width       CGRectGetWidth
    #define Height      CGRectGetHeight
    #define UnionRect   CGRectUnion

    #define IsEmptyRect CGRectIsEmpty
    #define ZeroPoint   CGPointZero
    #define MakePoint   CGPointMake
    #define MakeSize    CGSizeMake

    #define PointInRect(x,y) CGRectContainsPoint(y,x)
    #define EqualPoints CGPointEqualToPoint

#else

    #define POINT       NSPoint
    #define RECT        NSRect

    #define MakeRect    NSMakeRect
    #define MakeSize    NSMakeSize
    #define MakePoint   NSMakePoint

    #define UnionRect   NSUnionRect

    #define ZeroPoint   NSZeroPoint
    #define ZeroRect    NSZeroRect
    #define MinX        NSMinX
    #define MidX        NSMidX
    #define MaxX        NSMaxX
    #define MinY        NSMinY
    #define MidY        NSMidY
    #define MaxY        NSMaxY
    #define Width       NSWidth
    #define Height      NSHeight

    #define EqualRects  NSEqualRects
    #define IsEmptyRect NSIsEmptyRect

#endif


CGFloat DistanceBetweenPoints(POINT point1, POINT point2);
CGFloat DistancePointToLine(POINT point, POINT lineStartPoint, POINT lineEndPoint);
POINT LineNormal(POINT lineStart, POINT lineEnd);
POINT LineMidpoint(POINT lineStart, POINT lineEnd);

POINT AddPoint(POINT point1, POINT point2);
POINT ScalePoint(POINT point, CGFloat scale);
POINT UnitScalePoint(POINT point, CGFloat scale);
POINT SubtractPoint(POINT point1, POINT point2);
CGFloat DotMultiplyPoint(POINT point1, POINT point2);
CGFloat PointLength(POINT point);
CGFloat PointSquaredLength(POINT point);
POINT NormalizePoint(POINT point);
POINT NegatePoint(POINT point);
POINT RoundPoint(POINT point);

POINT RectGetTopLeft(RECT rect);
POINT RectGetTopRight(RECT rect);
POINT RectGetBottomLeft(RECT rect);
POINT RectGetBottomRight(RECT rect);

void ExpandBoundsByPoint(POINT *topLeft, POINT *bottomRight, POINT point);
RECT UnionRect(RECT rect1, RECT rect2);

BOOL ArePointsClose(POINT point1, POINT point2);
BOOL ArePointsCloseWithOptions(POINT point1, POINT point2, CGFloat threshold);
BOOL AreValuesClose(CGFloat value1, CGFloat value2);
BOOL AreValuesCloseWithOptions(CGFloat value1, CGFloat value2, CGFloat threshold);
BOOL IsValueGreaterThan(CGFloat value, CGFloat minimum);
BOOL IsValueLessThan(CGFloat value, CGFloat maximum);
BOOL IsValueGreaterThanEqual(CGFloat value, CGFloat minimum);
BOOL IsValueLessThanEqual(CGFloat value, CGFloat maximum);

extern BOOL LineBoundsMightOverlap(RECT bounds1, RECT bounds2);

//
// Parameter ranges
//

// Range is a range of parameter (t)

typedef struct Range {
    CGFloat minimum;
    CGFloat maximum;
} Range;

extern Range RangeMake(CGFloat minimum, CGFloat maximum);
extern BOOL RangeHasConverged(Range range, NSUInteger places);
extern CGFloat RangeGetSize(Range range);
extern CGFloat RangeAverage(Range range);
extern CGFloat RangeScaleNormalizedValue(Range range, CGFloat value);
extern Range RangeUnion(Range range1, Range range2);

//
// Angle Range structure provides a simple way to store angle ranges
//  and determine if a specific angle falls within. 
//

typedef Range AngleRange;

//typedef struct AngleRange {
//    CGFloat minimum;
//    CGFloat maximum;
//} AngleRange;


AngleRange AngleRangeMake(CGFloat minimum, CGFloat maximum);
BOOL AngleRangeContainsAngle(AngleRange range, CGFloat angle);

CGFloat NormalizeAngle(CGFloat value);
CGFloat PolarAngle(POINT point);

extern double DegreesToRadians(double degrees);
extern double RadiansToDegrees(double radians);

extern BOOL TangentsCross(POINT edge1Tangents[2], POINT edge2Tangents[2]);
extern BOOL AreTangentsAmbigious(POINT edge1Tangents[2], POINT edge2Tangents[2]);
