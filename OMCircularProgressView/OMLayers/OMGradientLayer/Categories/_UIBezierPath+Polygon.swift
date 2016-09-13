
#if os(OSX)
    import Cocoa
    public typealias BezierPath = NSBezierPath
#else
    import UIKit
    public typealias BezierPath = UIBezierPath
#endif

#if os(OSX)
    // UIKit Compatibility
    extension NSBezierPath {
        func addLine(to point: CGPoint) {
            self.line(to: point)
        }
        
        func addCurve(to point: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
            self.curve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
        
        func addQuadCurve(to point: CGPoint, controlPoint: CGPoint) {
            self.curve(to: point, controlPoint1: controlPoint, controlPoint2: controlPoint)
        }
    }
#endif

public struct Bezier {
    public enum PolygonStyle { case flatsingle, flatdouble, curvesingle, curvedouble, flattruple, curvetruple }
    static func polygon(
        sides sideCount: Int = 5,
        radius: CGFloat = 50.0,
        startAngle offset: CGFloat =  0.0,
        style: PolygonStyle = .curvesingle,
        percentInflection: CGFloat = 0.0) -> BezierPath
    {
        guard sideCount >= 3 else {
            print("Bezier polygon construction requires 3+ sides")
            return BezierPath()
        }
        
        func pointAt(_ theta: CGFloat, inflected: Bool = false, centered: Bool = false) -> CGPoint {
            let inflection = inflected ? percentInflection : 0.0
            let r = centered ? 0.0 : radius * (1.0 + inflection)
            return CGPoint(
                x: r * CGFloat(cos(theta)),
                y: r * CGFloat(sin(theta)))
        }
        
        let path = BezierPath()
        let dθ = Double(CGFloat(𝜏) / CGFloat(sideCount))
        
        path.move(to: pointAt(0.0 + offset))
        switch (percentInflection == 0.0, style) {
        case (true, _):
            for θ in stride(from: 0.0, through: 𝜏, by: dθ) {
                path.addLine(to: pointAt(CGFloat(θ) + offset))
            }
        case (false, .curvesingle):
            let cpθ = dθ / 2.0
            for θ in stride(from: 0.0, to: 𝜏, by: dθ) {
                path.addQuadCurve(
                    to: pointAt(CGFloat(θ) + CGFloat(dθ) + offset),
                    controlPoint: pointAt(CGFloat(θ) + CGFloat(cpθ) + offset, inflected: true))
            }
        case (false, .flatsingle):
            let cpθ = dθ / 2.0
            for θ in stride(from: 0.0, to: 𝜏, by: dθ) {
                path.addLine(to: pointAt(CGFloat(θ) + CGFloat(cpθ) + offset, inflected: true))
                path.addLine(to: pointAt(CGFloat(θ) + CGFloat(dθ) + offset))
            }
        case (false, .curvedouble):
            let (cp1θ, cp2θ) = (dθ / 3.0, 2.0 * dθ / 3.0)
            for θ in stride(from: 0.0, to: 𝜏, by: dθ) {
                path.addCurve(
                    to: pointAt(CGFloat(θ) + CGFloat(dθ) + offset),
                    controlPoint1: pointAt(CGFloat(θ) + CGFloat(cp1θ) + offset, inflected: true),
                    controlPoint2: pointAt(CGFloat(θ) + CGFloat(cp2θ) + offset, inflected: true)
                )
            }
        case (false, .flatdouble):
            let (cp1θ, cp2θ) = (dθ / 3.0, 2.0 * dθ / 3.0)
            for θ in stride(from: 0.0, to: 𝜏, by: dθ) {
                path.addLine(to: pointAt(CGFloat(θ) + CGFloat(cp1θ) + offset, inflected: true))
                path.addLine(to: pointAt(CGFloat(θ) + CGFloat(cp2θ) + offset, inflected: true))
                path.addLine(to: pointAt(CGFloat(θ) + CGFloat(dθ) + offset))
            }
            
        case (false, .flattruple):
            let (cp1θ, cp2θ) = (dθ / 3.0, 2.0 * dθ / 3.0)
            for θ in stride(from: 0.0, to: 𝜏, by: dθ) {
                path.addLine(to: pointAt(CGFloat(θ) + CGFloat(cp1θ) + offset, inflected: true))
                path.addLine(to: pointAt(CGFloat(θ) + CGFloat(dθ) / 2.0 + offset, centered: true))
                path.addLine(to: pointAt(CGFloat(θ) + CGFloat(cp2θ) + offset, inflected: true))
                path.addLine(to: pointAt(CGFloat(θ) + CGFloat(dθ) + offset))
            }
        case (false, .curvetruple):
            let (cp1θ, cp2θ) = (dθ / 3.0, 2.0 * dθ / 3.0)
            for θ in stride(from: 0.0, to: 𝜏, by: dθ) {
                path.addQuadCurve(
                    to: pointAt(CGFloat(θ) + CGFloat(dθ) / 2.0 + offset, centered:true),
                    controlPoint: pointAt(CGFloat(θ) + CGFloat(cp1θ) + offset, inflected: true))
                path.addQuadCurve(
                    to: pointAt(CGFloat(θ) + CGFloat(dθ) + offset),
                    controlPoint: pointAt(CGFloat(θ) + CGFloat(cp2θ) + offset, inflected: true))
            }
        }
        
        path.close()
        return path
    }
}
