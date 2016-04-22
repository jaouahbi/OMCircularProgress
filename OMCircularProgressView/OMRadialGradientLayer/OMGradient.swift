import Foundation
import CoreGraphics

@objc public class OMGradient : NSObject
{
    private(set) var gradient  : CGGradientRef?
    
    var locations : [CGFloat]? {
        didSet {
            gradient = nil
        }
    }
    var colors: [CGColor] = [] {
        didSet {
            gradient = nil
        }
    }
    
    func setColors(colors:[CGColor], withLocations:[CGFloat]?) {
        self.colors     = colors
        self.locations  = withLocations
    }
    
    func getGradient() -> CGGradientRef? {
        
        var colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()!
        var numberOfComponents:Int   = 4 // RGBA
        var components:Array<CGFloat>?
        let numberOfLocations:Int
        
        if (colors.count > 0) {
            if let gradientCached = self.gradient {
                // if nothing has been changed, return the cached gradient
                return gradientCached
            }
            
            if locations != nil {
                numberOfLocations = min(locations!.count, colors.count)
            } else {
                // If a nil array is given, the stops are assumed to spread uniformly across the [0,1] range
                numberOfLocations = colors.count
            }
            
            if (numberOfLocations > 0) {
                
                // Analize one color
                let colorRef       = colors.first
                numberOfComponents = Int(CGColorGetNumberOfComponents(colorRef))
                colorSpace         = CGColorGetColorSpace(colorRef)!
                
                if (numberOfComponents > 0) {
                    components = [CGFloat](count: numberOfLocations * numberOfComponents, repeatedValue: 0.0)
                    for locationIndex in 0 ..< numberOfLocations {
                        let color = colors[locationIndex]
                        // sanity check
                        assert(numberOfComponents == Int(CGColorGetNumberOfComponents(color)))
                        assert(CGColorSpaceGetModel(CGColorGetColorSpace(color)) == CGColorSpaceGetModel(colorSpace));
                        
                        let colorComponents = CGColorGetComponents(color);
                        
                        for componentIndex in 0 ..< numberOfComponents {
                            components?[numberOfComponents * locationIndex + componentIndex] = colorComponents[componentIndex]
                        }
                    }
                    
                    // If locations is NULL, the first color in colors is assigned to location 0, the last color incolors is assigned
                    // to location 1, and intervening colors are assigned locations that are at equal intervals in between.
                    
                    if (locations != nil) {
                        gradient = CGGradientCreateWithColorComponents(colorSpace,
                                                                            UnsafePointer<CGFloat>(components!),
                                                                            UnsafePointer<CGFloat>(locations!),
                                                                            numberOfLocations);
                    } else {
                        gradient = CGGradientCreateWithColorComponents(colorSpace,
                                                                            UnsafePointer<CGFloat>(components!),
                                                                            nil,
                                                                            numberOfLocations);
                    }
                    return gradient;
                }
            }
        }
        return nil
    }
}

