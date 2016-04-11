import Darwin

class OMCircle
{
    static var TWO_PI:Double = 2.0 * M_PI
    let radius: Double = 0.0
    var perimeter: Double {
        return OMCircle.TWO_PI * radius
    }
    
    var area: Double {
        return M_PI * radius * radius
    }
    
    func arcLength(theta: OMAngle) -> Double {
        return perimeter * theta.length() / M_PI
    }
}