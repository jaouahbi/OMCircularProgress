////
////    Copyright 2015 - Jorge Ouahbi
////
////   Licensed under the Apache License, Version 2.0 (the "License");
////   you may not use this file except in compliance with the License.
////   You may obtain a copy of the License at
////
////       http://www.apache.org/licenses/LICENSE-2.0
////
////   Unless required by applicable law or agreed to in writing, software
////   distributed under the License is distributed on an "AS IS" BASIS,
////   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
////   See the License for the specific language governing permissions and
////   limitations under the License.
////
//
//
////
////  UIImage.swift
////
////  Created by Jorge Ouahbi on 28/3/15.
////
////  0.1  Added alpha parameter to blendImage func (29-03-2015)
////  0.11 Added addOutterShadow func (22-04-2015)
////
////
//
//import UIKit
//
//
//extension UIImage {
//
//    func numberOfPixels() -> CGSize
//    {
//        return CGSize(width:size.width * scale, height: size.height * scale)
//    }
//}
//
//extension UIImage {
//    
//    func addOutterShadow(blurSize: CGFloat = 6.0) -> UIImage? {
//        
//        let bitmapInfo : CGBitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
//        
//        let shadowContext : CGContextRef = CGBitmapContextCreate( nil,
//            Int(numberOfPixels().width + blurSize),
//            Int(numberOfPixels().height + blurSize),
//            CGImageGetBitsPerComponent(self.CGImage),
//            0,
//            CGImageGetColorSpace(self.CGImage),
//            bitmapInfo)
//        
//        let color = UIColor.darkGrayColor().CGColor
//        
//        CGContextSetShadowWithColor(shadowContext,
//            CGSize(width: blurSize*0.5,height: -blurSize*0.5),
//            blurSize*0.5,
//            color)
//        
//        CGContextDrawImage(shadowContext, CGRect(x: 0, y: blurSize, width: numberOfPixels().width, height: numberOfPixels().height), self.CGImage)
//        
//        return UIImage(CGImage: CGBitmapContextCreateImage(shadowContext), scale:scale, orientation: imageOrientation)
//    }
//}
//
//
//extension UIImage
//{
//
//    
//    func resize( newSize:CGSize ) -> UIImage
//    {
//        return resizedImage(newSize, interpolationQuality: kCGInterpolationHigh )
//    }
//    
//    func rotatedImage(rads:CGFloat) -> UIImage
//    {
//        // Create the bitmap context
//        UIGraphicsBeginImageContextWithOptions(self.size,false,scale);
//        
//        let bitmap = UIGraphicsGetCurrentContext()
//        
//        // Move the origin to the middle of the image so we will rotate and scale around the center.
//        CGContextTranslateCTM(bitmap, size.width/2, size.height/2);
//        
//        // Rotate the image context
//        CGContextRotateCTM(bitmap, rads);
//        
//        // Now, draw the rotated/scaled image into the context
//        CGContextScaleCTM(bitmap, 1.0, -1.0);
//        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), self.CGImage);
//        
//        let newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        return newImage;
//        
//    }
//    
//    /*
//    
//    
//    122
//    down vote
//    accepted
//    If you have a greyscale image and want white become the tinting color, kCGBlendModeMultiply is the way to go. With this method, you cannot have highlights lighter than your tinting color.
//    
//    On the contrary, if you have either a non-greyscale image, OR you have highlights and shadows that should be preserved, the blend mode kCGBlendModeColor is the way to go. White will stay white and black will stay black as the lightness of the image is preserved. This mode is just made for tinting - it is the same as Photoshop's Color layer blend mode (disclaimer: slightly differing results may happen).
//    
//    Note that tinting alpha-pixels does not work correctly neither in iOS nor in Photoshop - half-transparent black pixels would not stay black. I updated the answer below to work around that issue, it took quite a long time to find out.
//    
//    You can also use one of the blend modes kCGBlendModeSourceIn/DestinationIn instead of CGContextClipToMask.
//    
//    If you want to create a UIImage, each of the following code sections can be surrounded by the following code:
//    
//    UIGraphicsBeginImageContextWithOptions (myIconImage.size, NO, [[UIScreen mainScreen] scale]); // for correct resolution on retina, thanks @MobileVet
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextTranslateCTM(context, 0, myIconImage.size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
//    
//    CGRect rect = CGRectMake(0, 0, myIconImage.size.width, myIconImage.size.height);
//    
//    // image drawing code here
//    
//    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    So here's the code for tinting a transparent image with kCGBlendModeColor:
//    
//    // draw black background to preserve color of transparent pixels
//    CGContextSetBlendMode(context, kCGBlendModeNormal);
//    [[UIColor blackColor] setFill];
//    CGContextFillRect(context, rect);
//    
//    // draw original image
//    CGContextSetBlendMode(context, kCGBlendModeNormal);
//    CGContextDrawImage(context, rect, myIconImage.CGImage);
//    
//    // tint image (loosing alpha) - the luminosity of the original image is preserved
//    CGContextSetBlendMode(context, kCGBlendModeColor);
//    [tintColor setFill];
//    CGContextFillRect(context, rect);
//    
//    // mask by alpha values of original image
//    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
//    CGContextDrawImage(context, rect, myIconImage.CGImage);
//    If your image has no half-transparent pixels, you could also do it the other way around with kCGBlendModeLuminosity:
//    
//    // draw tint color
//    CGContextSetBlendMode(context, kCGBlendModeNormal);
//    [tintColor setFill];
//    CGContextFillRect(context, rect);
//    
//    // replace luminosity of background (ignoring alpha)
//    CGContextSetBlendMode(context, kCGBlendModeLuminosity);
//    CGContextDrawImage(context, rect, myIconImage.CGImage);
//    
//    // mask by alpha values of original image
//    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
//    CGContextDrawImage(context, rect, myIconImage.CGImage);
//    If you don't care for luminosity, as you just have got an image with an alpha channel that should be tinted with a color, you can do it in a more efficient way:
//    
//    // draw tint color
//    CGContextSetBlendMode(context, kCGBlendModeNormal);
//    [tintColor setFill];
//    CGContextFillRect(context, rect);
//    
//    // mask by alpha values of original image
//    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
//    CGContextDrawImage(context, rect, myIconImage.CGImage);
//    or the other way around:
//    
//    // draw alpha-mask
//    CGContextSetBlendMode(context, kCGBlendModeNormal);
//    CGContextDrawImage(context, rect, myIconImage.CGImage);
//    
//    // draw tint color, preserving alpha values of original image
//    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
//    [tintColor setFill];
//    CGContextFillRect(context, rect);
//
//    
//    */
//    // Transform the image in grayscale.
//    func grayScaleWithAlphaImage() -> UIImage
//    {
//        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
//        let imageRect = CGRect(origin: CGPointZero, size: self.size);
//        
//        let ctx = UIGraphicsGetCurrentContext();
//        
////        CGContextTranslateCTM(ctx, 0, self.size.height);
////        CGContextScaleCTM(ctx, 1.0, -1.0);
//        
//            CGContextBeginTransparencyLayerWithRect ( ctx, imageRect, nil )
//        
//            // Draw a white background
//            CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
//            CGContextFillRect(ctx, imageRect);
//        
//            // Draw the luminosity on top of the white background to get grayscale
//            //self.drawInRect(imageRect,blendMode:kCGBlendModeLuminosity,alpha:1.0);
//        
//            // replace luminosity of background (ignoring alpha)
//            CGContextSetBlendMode(ctx, kCGBlendModeLuminosity);
//            CGContextSetAlpha(ctx, 1.0);
//            CGContextDrawImage(ctx, imageRect, self.CGImage);
//
//        
//            // Apply the source image's alpha
//            //        self.drawInRect(imageRect,blendMode:kCGBlendModeDestinationIn,alpha:1.0);
//        
//            // mask by alpha values of original image
//            CGContextSetBlendMode(ctx, kCGBlendModeDestinationIn);
//            CGContextSetAlpha(ctx, 1.0);
//            CGContextDrawImage(ctx, imageRect, self.CGImage);
//        
//        CGContextEndTransparencyLayer(ctx)
//        
//        let grayscaleImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        return grayscaleImage
//    }
//    
//    func blendImage(other:UIImage, alpha:CGFloat = 1.0) -> UIImage
//    {
//        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
//        
//        let ctx = UIGraphicsGetCurrentContext();
////        
////        CGContextTranslateCTM(ctx, 0, self.size.height);
////        CGContextScaleCTM(ctx, 1.0, -1.0);
//      
//        let imageRect = CGRect(origin: CGPointZero, size: self.size);
//        
//        //self.drawAtPoint(CGPointZero)
//        
//        CGContextBeginTransparencyLayerWithRect ( ctx, imageRect, nil )
//        
//            CGContextSetBlendMode(ctx, kCGBlendModeNormal)
//            CGContextSetAlpha(ctx, alpha)
//            CGContextDrawImage(ctx, imageRect, self.CGImage)
//        
//
//            CGContextSetBlendMode(ctx, kCGBlendModeNormal)
//            CGContextSetAlpha(ctx, alpha);
//            CGContextDrawImage(ctx, imageRect, other.CGImage)
//        
//        
//        CGContextEndTransparencyLayer(ctx)
//        
//        //other.drawAtPoint(CGPointZero, blendMode:kCGBlendModeNormal, alpha:alpha)
//        
//        let newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        return newImage
//    }
//    
//    func maskImage(path:UIBezierPath) -> UIImage
//    {
//        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
//        let ctx = UIGraphicsGetCurrentContext();
//        
////        CGContextAddPath(ctx, path.CGPath)
////        
////        if (path.usesEvenOddFillRule) {
////            CGContextEOClip(ctx);
////        } else {
////            CGContextClip(ctx)
////        }
//
//        path.addClip()
//        self.drawAtPoint(CGPointZero)
//        
//        //let imageRect = CGRect(origin: CGPointZero, size: self.size);
//        //CGContextDrawImage(ctx, imageRect, self.CGImage)
//        
//        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return maskedImage;
//    }
//    
//    // Returns an affine transform that takes into account the image orientation when drawing a scaled image
//    func transformForOrientation(newSize:CGSize) -> CGAffineTransform
//    {
//        var transform:CGAffineTransform = CGAffineTransformIdentity;
//        
//        switch (self.imageOrientation) {
//        case .Up, .UpMirrored:
//            break;
//            
//        case .Down, .DownMirrored:
//            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
//            transform = CGAffineTransformRotate(transform, CGFloat(M_PI));
//            break;
//            
//        case .Left, .LeftMirrored:
//            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
//            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2));
//            break;
//            
//        case .Right,.RightMirrored:
//            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
//            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2));
//            break;
//        }
//        
//        switch (self.imageOrientation) {
//        case .UpMirrored, .DownMirrored:
//            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
//            transform = CGAffineTransformScale(transform, -1, 1);
//            break;
//            
//        case .LeftMirrored , .RightMirrored:
//            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
//            transform = CGAffineTransformScale(transform, -1, 1);
//            break;
//            
//        case .Down, .Up ,.Right, .Left:
//            break;
//        }
//        
//        return transform;
//    }
//    
//    // Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
//    // The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
//    // If the new size is not integral, it will be rounded up
//    func resizedImage( newSize:CGSize, transform:CGAffineTransform, transpose:Bool,
//        interpolationQuality:CGInterpolationQuality)-> UIImage!
//    {
//        let newRect = CGRectIntegral(CGRect(origin: CGPointZero, size: newSize))
//        let transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
//        let imageRef = self.CGImage;
//        
//        // Build a context that's the same dimensions as the new size
//        let bitmap = CGBitmapContextCreate(nil,
//            Int(newRect.size.width),
//            Int(newRect.size.height),
//            CGImageGetBitsPerComponent(imageRef),
//            0,
//            CGImageGetColorSpace(imageRef),
//            CGImageGetBitmapInfo(imageRef));
//        
////        UIGraphicsBeginImageContextWithOptions(newRect.size,false,scale);
////        
////        let bitmap = UIGraphicsGetCurrentContext()
//        
//        // Rotate and/or flip the image if required by its orientation
//        CGContextConcatCTM(bitmap, transform);
//        
//        // Set the quality level to use when rescaling
//        CGContextSetInterpolationQuality(bitmap, interpolationQuality);
//        
//        // Draw into the context; this scales the image
//        CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
//        
//        
//        //let newImage = UIGraphicsGetImageFromCurrentImageContext();
//        //UIGraphicsEndImageContext();
//        //return newImage;
//        
//        // Get the resized image from the context and a UIImage
//        let newImageRef = CGBitmapContextCreateImage(bitmap);
//        
//        return UIImage(CGImage:newImageRef,scale:scale,orientation:imageOrientation)!
//    }
//    
//    
//    func resizedImage(newSize:CGSize,interpolationQuality:CGInterpolationQuality ) -> UIImage!
//    {
//        var drawTransposed:Bool;
//        
//        switch (self.imageOrientation) {
//        case .Left, .LeftMirrored ,.Right, .RightMirrored:
//            drawTransposed = true;
//        default:
//            drawTransposed = false;
//        }
//        
//        return self.resizedImage(newSize,
//            transform:self.transformForOrientation(newSize),
//            transpose:drawTransposed,
//            interpolationQuality:interpolationQuality);
//    }
//    
//}

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
//  UIImage.swift
//
//  Created by Jorge Ouahbi on 28/3/15.
//
//  0.1  Added alpha parameter to blendImage func (29-03-2015)
//  0.11 Added addOutterShadow func (22-04-2015)
//  0.12 Remplazed the CoreGraphics resize code by UIKit resize code  (28-04-2015)
//

import UIKit


extension UIImage
{
    func scaledToSize(newSize:CGSize,rect:CGRect) -> UIImage
    {
        //  avoid redundant drawing
        
        if (CGSizeEqualToSize(self.size, newSize)){
            return self;
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        
        //Draw image in provided rect
        
        self.drawInRect(rect);
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        //Pop this context
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    
    func cropToRect(rect:CGRect) -> UIImage
    {
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    
        //draw
        self.drawAtPoint(CGPointMake(-rect.origin.x, -rect.origin.y))
    
        //capture resultant image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
    
        //return image
        return image
    }
    
    
    func scaledToFitToSize(newSize:CGSize) -> UIImage
    {
        //Only scale images down
        if (size.width < newSize.width && size.height < newSize.height) {
            return self
        }
        
        //Determine the scale factors
        let widthScale = newSize.width/size.width;
        let heightScale = newSize.height/size.height;
        
        var scaleFactor:CGFloat;
        
        //The smaller scale factor will scale more (0 < scaleFactor < 1) leaving the other dimension inside the newSize rect
        widthScale < heightScale ? (scaleFactor = widthScale) : (scaleFactor = heightScale);
        let scaledSize = CGSizeMake(size.width * scaleFactor, size.height * scaleFactor);
        
        //Scale the image
        return self.scaledToSize(scaledSize,rect:CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height));
    }
    
    func  scaledToFillToSize(newSize:CGSize) -> UIImage
    {
        //Only scale images down
        if (size.width < newSize.width && size.height < newSize.height) {
            return self
        }
        
        //Determine the scale factors
        let widthScale = newSize.width/size.width;
        let heightScale = newSize.height/size.height;
        
        var scaleFactor:CGFloat;
        
        //The larger scale factor will scale less (0 < scaleFactor < 1) leaving the other dimension hanging outside the newSize rect
        widthScale > heightScale ? (scaleFactor = widthScale) : (scaleFactor = heightScale);
        let scaledSize = CGSizeMake(size.width * scaleFactor, size.height * scaleFactor);
        
        //Create origin point so that the center of the image falls into the drawing context rect (the origin will have negative component).
        var imageDrawOrigin:CGPoint = CGPointZero
        
        widthScale > heightScale ?  (imageDrawOrigin.y = (newSize.height - scaledSize.height) * 0.5) :
            (imageDrawOrigin.x = (newSize.width - scaledSize.width) * 0.5);
        
        
        //Create rect where the image will draw
        let imageDrawRect = CGRectMake(imageDrawOrigin.x, imageDrawOrigin.y, scaledSize.width, scaledSize.height);
        
        //The imageDrawRect is larger than the newSize rect, where the imageDraw origin is located defines what part of
        //the image will fall into the newSize rect.
        return self.scaledToSize(newSize,rect:imageDrawRect);
    }
    
}


extension UIImage
{
    class func gradientMask() -> CGImageRef
    {
        //create gradient mask
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 256), true, 0.0);
        
        let gradientContext = UIGraphicsGetCurrentContext();
        var colors:[CGFloat] = [0.0, 1.0, 1.0, 1.0];
        let colorSpace = CGColorSpaceCreateDeviceGray();
        let gradient = CGGradientCreateWithColorComponents(colorSpace, colors, nil, 2);
        let gradientStartPoint = CGPointMake(0, 0);
        let gradientEndPoint = CGPointMake(0, 256);
        
        CGContextDrawLinearGradient(gradientContext, gradient,
            gradientStartPoint,
            gradientEndPoint,
            CGGradientDrawingOptions(kCGGradientDrawsAfterEndLocation));
        
        let sharedMask = CGBitmapContextCreateImage(gradientContext);
        
        UIGraphicsEndImageContext();
        
        return sharedMask;
    }
    
    func reflectedImageWithScale(scale:CGFloat) -> UIImage
    {
        //get reflection dimensions
        let height = ceil(self.size.height * scale);
        let size = CGSizeMake(self.size.width, height);
        let bounds = CGRectMake(0.0, 0.0, size.width, size.height);
        
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        let context = UIGraphicsGetCurrentContext();
        
        //clip to gradient
        CGContextClipToMask(context, bounds, UIImage.gradientMask());
        
        //draw reflected image
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextTranslateCTM(context, 0.0, -self.size.height)
        self.drawInRect(CGRectMake(0.0, 0.0, self.size.width, self.size.height))
        
        //capture resultant image
        let reflection = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //return reflection image
        return reflection;
    }
    
    func imageWithReflectionWithScale(scale:CGFloat,gap:CGFloat,alpha:CGFloat) -> UIImage
    {
        //get reflected image
        let reflection = self.reflectedImageWithScale(scale);
        let reflectionOffset = reflection.size.height + gap;
        
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width, self.size.height + reflectionOffset * 2.0), false, 0.0);
        
        //draw reflection
        reflection.drawAtPoint(CGPointMake(0.0, reflectionOffset + self.size.height + gap),blendMode:kCGBlendModeNormal,alpha:alpha);
        
        //draw image
        self.drawAtPoint(CGPointMake(0.0, reflectionOffset));
        
        //capture resultant image
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //return image
        return image;
    }
}

extension UIImage {
    
    func addInnerShadow() {
        //TODO:
    }
    
    
    func addShadowColor(offset:CGSize, color:UIColor = UIColor.darkGrayColor(), blur:CGFloat = 6.0) -> UIImage
    {
        //get size
        let border = CGSizeMake(fabs(offset.width) + blur, fabs(offset.height) + blur);
        
        let size = CGSizeMake(self.size.width + border.width * 2.0,
                              self.size.height + border.height * 2.0);
        
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        let context = UIGraphicsGetCurrentContext();
        
        //set up shadow
        CGContextSetShadowWithColor(context, offset, blur, color.CGColor);
        
        //draw with shadow
        self.drawAtPoint(CGPoint(x: border.width, y: border.height))
        
        //capture resultant image
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //return image
        return image
    }
    
    func addOutterShadowColor(color:UIColor = UIColor.darkGrayColor(),blurSize: CGFloat = 6.0) -> UIImage? {

        let offset = CGSize(width: blurSize*0.5,height: -blurSize*0.5)
        
        let shadowContext : CGContextRef = CGBitmapContextCreate( nil,
            Int(self.size.width * scale + blurSize),
            Int(self.size.height * scale + blurSize),
            CGImageGetBitsPerComponent(self.CGImage),
            0,
            CGImageGetColorSpace(self.CGImage),
            CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue))
        
        CGContextSetShadowWithColor(shadowContext,
            offset,
            blurSize*0.5,
            color.CGColor)
        
        CGContextDrawImage(shadowContext,
            CGRect(x: 0, y: 0, width: self.size.width * scale , height: self.size.height * scale), self.CGImage)
        
        return UIImage(CGImage: CGBitmapContextCreateImage(shadowContext), scale:scale, orientation: imageOrientation)
    }
}


extension UIImage
{
    
    func rotatedImage(radians:CGFloat) -> UIImage
    {
        // Create the bitmap context
        UIGraphicsBeginImageContextWithOptions(self.size,false,0.0);
        
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, size.width/2, size.height/2);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, radians);
        
        // Now, draw the rotated/scaled image into the context
        CGContextScaleCTM(bitmap, 1.0, -1.0);
        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), self.CGImage);
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
        
    }
    
    // Transform the image in grayscale.
    
    func grayScaleWithAlphaImage() -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0);
        let imageRect = CGRectMake(0.0, 0.0, self.size.width, self.size.height);
        
        let ctx = UIGraphicsGetCurrentContext();
        
        // Draw a white background
        CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
        CGContextFillRect(ctx, imageRect);
        
        // Draw the luminosity on top of the white background to get grayscale
        self.drawInRect(imageRect,blendMode:kCGBlendModeLuminosity,alpha:1.0);
        
        // Apply the source image's alpha
        self.drawInRect(imageRect,blendMode:kCGBlendModeDestinationIn,alpha:1.0);
        
        let grayscaleImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return grayscaleImage
    }
    
    func blendImage(other:UIImage, alpha:CGFloat = 1.0) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0);
        
        self.drawAtPoint(CGPointZero)
        other.drawAtPoint(CGPointZero, blendMode:kCGBlendModeNormal, alpha:alpha)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage
    }
    
    func maskImage(path:UIBezierPath) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        
        path.addClip()
        self.drawAtPoint(CGPointZero)
        
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return maskedImage;
    }
    
    func cornerRadius(radius:CGFloat) -> UIImage
    {
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0);
        
        //clip image
        UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height),cornerRadius:radius).addClip()
        
        //draw image
        self.drawAtPoint(CGPointZero);
        
        //capture resultant image
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        
        return image
    }
}
