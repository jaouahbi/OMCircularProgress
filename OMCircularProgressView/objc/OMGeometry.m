#import "OMGeometry.h"

static const CGFloat PointClosenessThreshold = 1e-10;
static const CGFloat TangentClosenessThreshold = 1e-12;
static const CGFloat BoundsClosenessThreshold = 1e-9;


double DegreesToRadians(double degrees)
{
    return degrees * 0.01745329252;
}

double RadiansToDegrees(double radians)
{
    return radians * 57.29577951;
}

CGFloat DistanceBetweenPoints(POINT point1, POINT point2)
{
    CGFloat xDelta = point2.x - point1.x;
    CGFloat yDelta = point2.y - point1.y;
    return sqrt(xDelta * xDelta + yDelta * yDelta);
}

CGFloat DistancePointToLine(POINT point, POINT lineStartPoint, POINT lineEndPoint)
{
    CGFloat lineLength = DistanceBetweenPoints(lineStartPoint, lineEndPoint);
    if ( lineLength == 0 )
        return 0;
    CGFloat u = ((point.x - lineStartPoint.x) * (lineEndPoint.x - lineStartPoint.x) + (point.y - lineStartPoint.y) * (lineEndPoint.y - lineStartPoint.y)) / (lineLength * lineLength);
    POINT intersectionPoint = MakePoint(lineStartPoint.x + u * (lineEndPoint.x - lineStartPoint.x), lineStartPoint.y + u * (lineEndPoint.y - lineStartPoint.y));
    return DistanceBetweenPoints(point, intersectionPoint);
}

POINT AddPoint(POINT point1, POINT point2) {
    return MakePoint(point1.x + point2.x, point1.y + point2.y);
}

POINT UnitScalePoint(POINT point, CGFloat scale) {
    POINT result = point;
    CGFloat length = PointLength(point);
    if ( length != 0.0 ) {
        result.x *= scale/length;
        result.y *= scale/length;
    }
    return result;
}

POINT ScalePoint(POINT point, CGFloat scale) {
    return MakePoint(point.x * scale, point.y * scale);
}

CGFloat DotMultiplyPoint(POINT point1, POINT point2) {
    return point1.x * point2.x + point1.y * point2.y;
}

POINT SubtractPoint(POINT point1, POINT point2)
{
    return MakePoint(point1.x - point2.x, point1.y - point2.y);
}

CGFloat PointLength(POINT point)
{
    return sqrt((point.x * point.x) + (point.y * point.y));
}

CGFloat PointSquaredLength(POINT point)
{
    return (point.x * point.x) + (point.y * point.y);
}

POINT NormalizePoint(POINT point)
{
    POINT result = point;
    CGFloat length = PointLength(point);
    if ( length != 0.0 ) {
        result.x /= length;
        result.y /= length;
    }
    return result;
}

POINT NegatePoint(POINT point)
{
    return MakePoint(-point.x, -point.y);
}

POINT RoundPoint(POINT point)
{
    POINT result = { round(point.x), round(point.y) };
    return result;
}

POINT LineNormal(POINT lineStart, POINT lineEnd)
{
    return NormalizePoint(MakePoint(-(lineEnd.y - lineStart.y), lineEnd.x - lineStart.x));
}

POINT LineMidpoint(POINT lineStart, POINT lineEnd)
{
    CGFloat distance = DistanceBetweenPoints(lineStart, lineEnd);
    POINT tangent = NormalizePoint(SubtractPoint(lineEnd, lineStart));
    return AddPoint(lineStart, UnitScalePoint(tangent, distance / 2.0));
}

POINT RectGetTopLeft(RECT rect)
{
    return MakePoint(MinX(rect), MinY(rect));
}

POINT RectGetTopRight(RECT rect)
{
    return MakePoint(MaxX(rect), MinY(rect));
}

POINT RectGetBottomLeft(RECT rect)
{
    return MakePoint(MinX(rect), MaxY(rect));
}

POINT RectGetBottomRight(RECT rect)
{
    return MakePoint(MaxX(rect), MaxY(rect));
}

void ExpandBoundsByPoint(POINT *topLeft, POINT *bottomRight, POINT point)
{
    if ( point.x < topLeft->x )
        topLeft->x = point.x;
    if ( point.x > bottomRight->x )
        bottomRight->x = point.x;
    if ( point.y < topLeft->y )
        topLeft->y = point.y;
    if ( point.y > bottomRight->y )
        bottomRight->y = point.y;
}

RECT UnionRect(RECT rect1, RECT rect2)
{
    POINT topLeft = RectGetTopLeft(rect1);
    POINT bottomRight = RectGetBottomRight(rect1);
    ExpandBoundsByPoint(&topLeft, &bottomRight, RectGetTopLeft(rect2));
    ExpandBoundsByPoint(&topLeft, &bottomRight, RectGetTopRight(rect2));
    ExpandBoundsByPoint(&topLeft, &bottomRight, RectGetBottomRight(rect2));
    ExpandBoundsByPoint(&topLeft, &bottomRight, RectGetBottomLeft(rect2));    
    return MakeRect(topLeft.x, topLeft.y, bottomRight.x - topLeft.x, bottomRight.y - topLeft.y);
}

BOOL ArePointsClose(POINT point1, POINT point2)
{
    return ArePointsCloseWithOptions(point1, point2, PointClosenessThreshold);
}

BOOL ArePointsCloseWithOptions(POINT point1, POINT point2, CGFloat threshold)
{
    return AreValuesCloseWithOptions(point1.x, point2.x, threshold) &&
            AreValuesCloseWithOptions(point1.y, point2.y, threshold);
}

BOOL AreValuesClose(CGFloat value1, CGFloat value2)
{
    return AreValuesCloseWithOptions(value1, value2, PointClosenessThreshold);
}

BOOL AreValuesCloseWithOptions(CGFloat value1, CGFloat value2, CGFloat threshold)
{
    CGFloat delta = value1 - value2;    
    return (delta <= threshold) && (delta >= -threshold);
}

//////////////////////////////////////////////////////////////////////////
// Helper methods for angles
//

static const CGFloat TWOPI = 2.0 * M_PI;

// Normalize the angle between 0 and 2pi

CGFloat NormalizeAngle(CGFloat value)
{
    while ( value < 0.0 )
        value += TWOPI;
    while ( value >= TWOPI )
        value -= TWOPI;
    return value;
}

// Compute the polar angle from the cartesian point

CGFloat PolarAngle(POINT point)
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
    return NormalizeAngle(value);
}


AngleRange AngleRangeMake(CGFloat minimum, CGFloat maximum)
{
    AngleRange range = { minimum, maximum };
    return range;
}

static BOOL IsValueGreaterThanWithOptions(CGFloat value, CGFloat minimum, CGFloat threshold)
{
    if ( AreValuesCloseWithOptions(value, minimum, threshold) )
        return NO;
    return value > minimum;
}

BOOL IsValueGreaterThan(CGFloat value, CGFloat minimum)
{
    return IsValueGreaterThanWithOptions(value, minimum, TangentClosenessThreshold);
}

BOOL IsValueLessThan(CGFloat value, CGFloat maximum)
{
    if ( AreValuesCloseWithOptions(value, maximum, TangentClosenessThreshold) )
        return NO;
    return value < maximum;
}

BOOL IsValueGreaterThanEqual(CGFloat value, CGFloat minimum)
{
    if ( AreValuesCloseWithOptions(value, minimum, TangentClosenessThreshold) )
        return YES;
    return value >= minimum;
}

static BOOL IsValueLessThanEqualWithOptions(CGFloat value, CGFloat maximum, CGFloat threshold)
{
    if ( AreValuesCloseWithOptions(value, maximum, threshold) )
        return YES;
    return value <= maximum;
}

BOOL IsValueLessThanEqual(CGFloat value, CGFloat maximum)
{
    return IsValueLessThanEqualWithOptions(value, maximum, TangentClosenessThreshold);
}

BOOL AngleRangeContainsAngle(AngleRange range, CGFloat angle)
{
    if ( range.minimum <= range.maximum )
        return IsValueGreaterThan(angle, range.minimum) && IsValueLessThan(angle, range.maximum);
    
    // The range wraps around 0. See if the angle falls in the first half
    if ( IsValueGreaterThan(angle, range.minimum) && angle <= TWOPI )
        return YES;
    
    return angle >= 0.0 && IsValueLessThan(angle, range.maximum);
}


//////////////////////////////////////////////////////////////////////////////////
// Parameter ranges
//
Range RangeMake(CGFloat minimum, CGFloat maximum)
{
    Range range = { minimum, maximum };
    return range;
}

BOOL RangeHasConverged(Range range, NSUInteger places)
{
    CGFloat factor = pow(10.0, places);
    NSInteger minimum = (NSInteger)(range.minimum * factor);
    NSInteger maxiumum = (NSInteger)(range.maximum * factor);
    return minimum == maxiumum;
}

CGFloat RangeGetSize(Range range)
{
    return range.maximum - range.minimum;
}

CGFloat RangeAverage(Range range)
{
    return (range.minimum + range.maximum) / 2.0;
}

CGFloat RangeScaleNormalizedValue(Range range, CGFloat value)
{
    return (range.maximum - range.minimum) * value + range.minimum;
}

Range RangeUnion(Range range1, Range range2)
{
    Range range = { MIN(range1.minimum, range2.minimum), MAX(range1.maximum, range2.maximum) };
    return range;
}

BOOL AreTangentsAmbigious(POINT edge1Tangents[2], POINT edge2Tangents[2])
{
    POINT normalEdge1[2] = { NormalizePoint(edge1Tangents[0]), NormalizePoint(edge1Tangents[1]) };
    POINT normalEdge2[2] = { NormalizePoint(edge2Tangents[0]), NormalizePoint(edge2Tangents[1]) };
    
    return ArePointsCloseWithOptions(normalEdge1[0], normalEdge2[0], TangentClosenessThreshold) || ArePointsCloseWithOptions(normalEdge1[0], normalEdge2[1], TangentClosenessThreshold) || ArePointsCloseWithOptions(normalEdge1[1], normalEdge2[0], TangentClosenessThreshold) || ArePointsCloseWithOptions(normalEdge1[1], normalEdge2[1], TangentClosenessThreshold);
}

BOOL TangentsCross(POINT edge1Tangents[2], POINT edge2Tangents[2])
{    
    // Calculate angles for the tangents
    CGFloat edge1Angles[] = { PolarAngle(edge1Tangents[0]), PolarAngle(edge1Tangents[1]) };
    CGFloat edge2Angles[] = { PolarAngle(edge2Tangents[0]), PolarAngle(edge2Tangents[1]) };
    
    // Count how many times edge2 angles appear between the self angles
    AngleRange range1 = AngleRangeMake(edge1Angles[0], edge1Angles[1]);
    NSUInteger rangeCount1 = 0;
    if ( AngleRangeContainsAngle(range1, edge2Angles[0]) )
        rangeCount1++;
    if ( AngleRangeContainsAngle(range1, edge2Angles[1]) )
        rangeCount1++;
    
    // Count how many times self angles appear between the edge2 angles
    AngleRange range2 = AngleRangeMake(edge1Angles[1], edge1Angles[0]);
    NSUInteger rangeCount2 = 0;
    if ( AngleRangeContainsAngle(range2, edge2Angles[0]) )
        rangeCount2++;
    if ( AngleRangeContainsAngle(range2, edge2Angles[1]) )
        rangeCount2++;
    
    // If each pair of angles split the other two, then the edges cross.
    
    return rangeCount1 == 1 && rangeCount2 == 1;
}

BOOL LineBoundsMightOverlap(RECT bounds1, RECT bounds2)
{
    CGFloat left = MAX(MinX(bounds1), MinX(bounds2));
    CGFloat right = MIN(MaxX(bounds1), MaxX(bounds2));
    if ( IsValueGreaterThanWithOptions(left, right, BoundsClosenessThreshold) )
        return NO; // no horizontal overlap
    CGFloat top = MAX(MinY(bounds1), MinY(bounds2));
    CGFloat bottom = MIN(MaxY(bounds1), MaxY(bounds2));
    return IsValueLessThanEqualWithOptions(top, bottom, BoundsClosenessThreshold);
}
