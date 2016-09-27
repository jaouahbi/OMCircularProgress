//
//  BezierPolygon.swift
//
//  Created by Jorge Ouahbi on 12/9/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

// Based on Erica Sadun code
// https://gist.github.com/erica/c54826fd3411d6db053bfdfe1f64ab54

import UIKit

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
            OMLog.printe("Bezier polygon construction requires 3+ sides")
            return BezierPath()
        }
        
        func pointAt(_ theta: CGFloat, inflected: Bool = false, centered: Bool = false) -> CGPoint {
            let inflection = inflected ? percentInflection : 0.0
            let r = centered ? 0.0 : radius * (1.0 + inflection)
            return CGPoint(
                x: r * CGFloat(cos(theta)),
                y: r * CGFloat(sin(theta)))
        }
        
        let π = CGFloat(Double.pi); let 𝜏 = 2.0 * π
        let path = BezierPath()
        let dθ = 𝜏 / CGFloat(sideCount)
        
        path.move(to: pointAt(0.0 + offset))
        switch (percentInflection == 0.0, style) {
        case (true, _):
            for θ in stride(from: 0.0, through: 𝜏, by: dθ) {
                path.addLine(to: pointAt(θ + offset))
            }
        case (false, .curvesingle):
            let cpθ = dθ / 2.0
            for θ in stride(from: 0.0, to: 𝜏, by: dθ) {
                path.addQuadCurve(
                    to: pointAt(θ + dθ + offset),
                    controlPoint: pointAt(θ + cpθ + offset, inflected: true))
            }
        case (false, .flatsingle):
            let cpθ = dθ / 2.0
            for θ in stride(from: 0.0, to: 𝜏, by: dθ) {
                path.addLine(to: pointAt(θ + cpθ + offset, inflected: true))
                path.addLine(to: pointAt(θ + dθ + offset))
            }
        case (false, .curvedouble):
            let (cp1θ, cp2θ) = (dθ / 3.0, 2.0 * dθ / 3.0)
            for θ in stride(from: 0.0, to: 𝜏, by: dθ) {
                path.addCurve(
                    to: pointAt(θ + dθ + offset),
                    controlPoint1: pointAt(θ + cp1θ + offset, inflected: true),
                    controlPoint2: pointAt(θ + cp2θ + offset, inflected: true)
                )
            }
        case (false, .flatdouble):
            let (cp1θ, cp2θ) = (dθ / 3.0, 2.0 * dθ / 3.0)
            for θ in stride(from: 0.0, to: 𝜏, by: dθ) {
                path.addLine(to: pointAt(θ + cp1θ + offset, inflected: true))
                path.addLine(to: pointAt(θ + cp2θ + offset, inflected: true))
                path.addLine(to: pointAt(θ + dθ + offset))
            }
            
        case (false, .flattruple):
            let (cp1θ, cp2θ) = (dθ / 3.0, 2.0 * dθ / 3.0)
            for θ in stride(from: 0.0, to: 𝜏, by: dθ) {
                path.addLine(to: pointAt(θ + cp1θ + offset, inflected: true))
                path.addLine(to: pointAt(θ + dθ / 2.0 + offset, centered: true))
                path.addLine(to: pointAt(θ + cp2θ + offset, inflected: true))
                path.addLine(to: pointAt(θ + dθ + offset))
            }
        case (false, .curvetruple):
            let (cp1θ, cp2θ) = (dθ / 3.0, 2.0 * dθ / 3.0)
            for θ in stride(from: 0.0, to: 𝜏, by: dθ) {
                path.addQuadCurve(
                    to: pointAt(θ + dθ / 2.0 + offset, centered:true),
                    controlPoint: pointAt(θ + cp1θ + offset, inflected: true))
                path.addQuadCurve(
                    to: pointAt(θ + dθ + offset),
                    controlPoint: pointAt(θ + cp2θ + offset, inflected: true))
            }
        }
        
        path.close()
        return path
    }
}
