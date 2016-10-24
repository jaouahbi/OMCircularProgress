
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
//  OMGlossGradient.swift
//
//  Created by Jorge Ouahbi on 20/4/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//


import Foundation
import UIKit



// from http://www.cocoawithlove.com/2008/09/drawing-gloss-gradients-in-coregraphics.html

/*
 This type of gradient is common on buttons or other graphical adornments on webpages. The "aqua" aesthetic of Mac OS X also uses this type of gradient in numerous places.
 
 The gradient is actually composed of a number of components, all intended to simulate a translucent glass or plastic lens-shaped object that is lit from above.
 
 The light gray "lens" shape is the glass or plastic translucent object being modelled.
 
 The top half, as seen by the viewer, is dominated by the arc labelled "B" which is light from the light-source reflected directly to the viewer.
 
 The bottom half, as seen by the viewer, contains the effects of two arcs: C and A. Arc C is a "caustic" highlight, where the light from the light source is focussed to a higher intensity by the lens shape of the translucent material. Arc A is darker because the recessed nature of the translucent material casts a shadow over this area.
 
 The final point to note is that the lens shape is not flat at the back, so these light and dark components attenuate in a non-linear fashion.
 
 Creating the effect in code
 
 We need four different color values:
 
 The top of the gloss highlight (whitest due to incident angle of reflection)
 The bottom of the gloss highlight (white-ish but not as white as top)
 The background color - darkest visible part of shadow (will be provided as input to the function)
 The caustic color (brighter than background and incorporating a subtle hue change)
 Once we have these values, we can simply create a gradient out of them.
 
 The gloss highlight color
 
 The two gloss highlight colors will just be a blend of white and the background color. Picking relative intensities of these two colors is not very hard. I chose a 0.6 fraction of white for my top gloss color and a 0.2 for the bottom of the gloss (although these fractions will be reduced by the scaling below).
 
 When using a range of background colors, I found that dark colors needed a smaller fraction of white than light colors to appear similarly glossy, so I had to scale the effect based on background brightness.
 
 I chose the following function to produce a scaling coefficient for my gloss brightness, based on brightness of the background color:
 
 The input components are 3 floats (RGB). The coefficients with which I multiply them are the NTSC color-to-luminance conversion coefficients. It's an acceptable "perceptual brightness" conversion for color and far easier than RGB to LUV. I then raise this value to a fractional power — value chosen experimentally as it seemed to give about the right final value across the range of brightnesses.
 
 The caustic highlight color
 
 The caustic color is a harder problem. We need to achieve a hue and brightness shift of the background color towards yellow, while retaining the background's saturation.
 
 Again, as with gloss, there was a non-linearity to account for: colors further in hue from yellow required proportionally less hue shift to maintain the appearance of the same hue-shift effect. I chose to scale the hue shift by a cosine such that the hue shift seemed perceptually appropriate.
 
 In addition, grays (having no real hue) need special handling. Reds needed special handling to account for the fact that hue wraps around at red. Purples didn't really look good hued towards yellow, so I decided to make them hue towards magenta
 So this function is really just an HSV conversion of the inputComponents and the yellowColor, and the blending of the two.
 
 Composing into a single gradient
 
 Now to assemble the colors into a gradient. We'll need to implement an interpolation function that will return the correct color for a given progress point in the gradient.
 
 With the aforementioned "background color", "caustic color", "top gloss white fraction" and "bottom gloss white fraction" passed into this function as the "color", "caustic", "initialWhite" and "finalWhite" parameters of the GlossParameters struct, the function looks like this:
 
 As you can see, the function is split into two halves: the first half handles the gloss and the second half handles the caustic. An exponential is used to create an attenuating effect on the gradient.
 
 Draw the gradient
 
 The draw function is pretty straightforward. Most of it is configuring the GlossParameters struct with the coefficient and offsets of the exponential, invoking the functions to generate the required colors and performing the mechanics of drawing a gradient using CGShadingCreateAxial and CGContextDrawShading
 
 Conclusion
 
 There are lots of parameters in these functions that can be tweaked to personal preference. You can enhance the hue change, the gradient slopes and the gloss intensity very simply.
 
 I'm fairly happy with the gloss and its brightness. I think that's worked well.
 
 The hue shift for the caustic works well but the brightness of the caustic seems a little inconsistent. This could be tweaked a little.
 
 Purples on the boundary with blue or red can look a little strange. Maybe there's a way to smooth this, I don't know. I haven't really thought about it.
 
 This approach doesn't work well with bright colors provided as the input color, since the input color is used as the darkest color in the gradient. This is not a problem as much as it is a consideration when choosing the input color.
 */




//func glossShadingCallback(_ infoPointer:UnsafeMutableRawPointer?,
//                     inData: UnsafePointer<CGFloat>,
//                     outData: UnsafeMutablePointer<CGFloat>) -> Swift.Void {
//
//    let rawPointer = UnsafeMutableRawPointer(infoPointer)
//
//    var info = rawPointer?.load(as: GlossParameters.self)
//
//    info?.shadingFunction(inData, outData)
//}
//



//As you can see, the function is split into two halves: the first half handles the gloss and the second half handles the caustic. An exponential is used to create an attenuating effect on the gradient.
//
//Draw the gradient
//
//The draw function is pretty straightforward. Most of it is configuring the GlossParameters struct with the coefficient and offsets of the exponential, invoking the functions to generate the required colors and performing the mechanics of drawing a gradient using CGShadingCreateAxial and CGContextDrawShading.


//func DrawGlossGradient(context:CGContext, color:UIColor, inRect:CGRect)
//{
//    let params:OMGlossParameters = OMGlossParameters(color:color);
//
//
//    static const float input_value_range [2] = {0, 1};
//    static const float output_value_ranges[8] = {0, 1, 0, 1, 0, 1, 0, 1};
//    CGFunctionCallbacks callbacks = {0, glossInterpolation, NULL};
//
//    CGFunctionRef gradientFunction = CGFunctionCreate(
//        (void *)&amp;params,
//        1, // number of input values to the callback
//        input_value_range,
//        4, // number of components (r, g, b, a)
//        output_value_ranges,
//        &amp;callbacks);
//
//    CGPoint startPoint = CGPointMake(NSMinX(inRect), NSMaxY(inRect));
//    CGPoint endPoint = CGPointMake(NSMinX(inRect), NSMinY(inRect));
//
//    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
//    CGShadingRef shading = CGShadingCreateAxial(colorspace, startPoint,
//                                                endPoint, gradientFunction, FALSE, FALSE);
//
//    CGContextSaveGState(context);
//    CGContextClipToRect(context, NSRectToCGRect(inRect));
//    CGContextDrawShading(context, shading);
//    CGContextRestoreGState(context);
//
//    CGShadingRelease(shading);
//    CGColorSpaceRelease(colorspace);
//    CGFunctionRelease(gradientFunction);
//}

/*
 The gradient is actually composed of a number of components, all intended to simulate a translucent glass or plastic lens-shaped object that is lit from above.
 */

public struct OMGlossGradient
{
    let  EXP_COEFFICIENT:CGFloat = 1.2;
    let  REFLECTION_MAX:CGFloat = 0.60;
    let  REFLECTION_MIN:CGFloat = 0.20;
    
    var glossColor:UIColor
    var caustic:UIColor
    var expCoefficient:CGFloat = 0
    var expScale:CGFloat = 0
    var expOffset:CGFloat = 0
    var initialWhite:CGFloat = 0
    var finalWhite:CGFloat = 0
    
    init(glossColor : UIColor) {
        
        self.expCoefficient = EXP_COEFFICIENT;
        self.expOffset      = CGFloat(expf(-(Float)(self.expCoefficient)));
        self.expScale       = 1.0 / (1.0 - self.expOffset);
        
        self.glossColor = glossColor
        if (glossColor.numberOfComponents == 3) {
            self.glossColor = glossColor.withAlphaComponent(1.0);
        }
        
        let glossScale = OMGlossGradient.perceptualGlossFractionForColor(color: self.glossColor);
        
        self.initialWhite = glossScale * REFLECTION_MAX;
        self.finalWhite   = glossScale * REFLECTION_MIN;
        
        self.caustic      = OMGlossGradient.perceptualCausticColorForColor(color: self.glossColor);
        
    }
    
    // So this function is really just an HSV conversion of the inputComponents and the yellowColor, and the blending of the two.
    
    static func perceptualCausticColorForColor(color:UIColor) -> UIColor
    {
        let CAUSTIC_FRACTION = CGFloat(0.60)
        let COSINE_ANGLE_SCALE = Double(1.4)
        let MIN_RED_THRESHOLD = CGFloat(0.95)
        let MAX_BLUE_THRESHOLD = CGFloat(0.7)
        let GRAYSCALE_CAUSTIC_SATURATION = CGFloat(0.2)
        
        var hue        = color.hsbaComponents[0]
        var saturation = color.hsbaComponents[1]
        let brightness = color.hsbaComponents[2]
        let alpha      = color.hsbaComponents[3];
        
        var targetHue         = UIColor.yellow.hsbaComponents[0]
        var targetSaturation  = UIColor.yellow.hsbaComponents[1]
        var targetBrightness  = UIColor.yellow.hsbaComponents[2]
        
        if (saturation < 1e-3) {
            hue = targetHue;
            saturation = GRAYSCALE_CAUSTIC_SATURATION;
        }
        
        if (hue > MIN_RED_THRESHOLD) {
            hue -= 1.0;
            
        } else if (hue > MAX_BLUE_THRESHOLD) {
            targetHue         = UIColor.magenta.hsbaComponents[0]
            targetSaturation  = UIColor.magenta.hsbaComponents[1]
            targetBrightness  = UIColor.magenta.hsbaComponents[2]
        }
        
        let scaledCaustic = CGFloat(Double(CAUSTIC_FRACTION) * 0.5 * (1.0 + cos(COSINE_ANGLE_SCALE * Double.pi * Double((hue - targetHue)))))
        
        return UIColor(hue:hue * (1.0 - scaledCaustic) + targetHue * scaledCaustic,
                       saturation:saturation * (1.0 - scaledCaustic) + targetSaturation * scaledCaustic,
                       brightness:brightness * (1.0 - scaledCaustic) + targetBrightness * scaledCaustic,
                       alpha:alpha);
    }
    
    
    static func  perceptualGlossFractionForColor(color:UIColor) -> CGFloat {
        let REFLECTION_SCALE_NUMBER = CGFloat(0.2)
        let NTSC_RED_FRACTION = CGFloat(0.299)
        let NTSC_GREEN_FRACTION = CGFloat(0.587)
        let NTSC_BLUE_FRACTION = CGFloat(0.114)
        let glossScale = NTSC_RED_FRACTION * color.components![0] +
            NTSC_GREEN_FRACTION * color.components![1] +
            NTSC_BLUE_FRACTION  * color.components![2];
        return pow(glossScale, REFLECTION_SCALE_NUMBER)
    }
    
    
    // All colors in the gradient are calculated from the single color parameter.
    
    public static func glosserp(_ start:UIColor, end:UIColor, t:CGFloat) -> UIColor {
        
        OMLog.printd("(OMGlossGradient) start color: \(start.shortDescription) end color: \(end.shortDescription) alpha: \(t)")
        
        var alpha = t
        let color = UIColor.lerp(start, end: end, t: t)
        let info  = OMGlossGradient(glossColor: color)
        
        if (alpha < 0.5) {
            
            alpha = alpha * 2.0;
            
            alpha = 1.0 - info.expScale * CGFloat((expf(Float(alpha * -info.expCoefficient)) - Float(info.expOffset)))
            
            let currentWhite = alpha * (info.finalWhite - info.initialWhite) + info.initialWhite;
            
            let curWhite =  (1.0 - currentWhite)
            
            return UIColor(red:(info.glossColor.components![0]) * curWhite + currentWhite,
                           green:(info.glossColor.components![1]) * curWhite + currentWhite,
                           blue:(info.glossColor.components![2]) * curWhite + currentWhite,
                           alpha:(info.glossColor.components![3]) * curWhite + currentWhite);
        }
        else
        {
            alpha = (alpha - 0.5) * 2.0;
            
            alpha = info.expScale *  CGFloat((expf(Float((1.0 - alpha) * -info.expCoefficient)) - Float(info.expOffset)))
            
            let curProgress =  (1.0 - alpha)
            
            return UIColor(red:(info.glossColor.components![0]) * curProgress + info.caustic.components![0] * alpha,
                           green:(info.glossColor.components![1]) * curProgress + info.caustic.components![1] * alpha,
                           blue:(info.glossColor.components![2]) * curProgress + info.caustic.components![2] * alpha,
                           alpha:(info.glossColor.components![3]) * curProgress + info.caustic.components![3] * alpha)
        }
    }
}


