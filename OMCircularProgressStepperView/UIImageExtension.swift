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
//  CreatedZZZZ by Jorge Ouahbi on 28/3/15.
//
//  0.1 Added alpha parameter to blendImage func (29-03-2015)
//      Added grayScaleWithAlphaImage()
//

import UIKit

extension UIImage
{
    convenience init!(named:String, newSize:CGSize)
    {
        let newImage = UIImage(named: named)?.resizedImage(newSize, interpolationQuality: kCGInterpolationDefault )
        
        self.init(CGImage:newImage!.CGImage,scale:newImage!.scale,orientation: newImage!.imageOrientation)
    }
    
    func rotatedImage(rads:CGFloat) -> UIImage
    {
        // Create the bitmap context
        UIGraphicsBeginImageContextWithOptions(self.size,false,scale);
        
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, size.width/2, size.height/2);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, rads);
        
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
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
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
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        
        self.drawAtPoint(CGPointZero)
        other.drawAtPoint(CGPointZero, blendMode:kCGBlendModeNormal, alpha:alpha)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage
    }
    
    func maskImage(path:UIBezierPath) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        
        path.addClip()
        self.drawAtPoint(CGPointZero)
        
        
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return maskedImage;
    }
    
    // Returns an affine transform that takes into account the image orientation when drawing a scaled image
    func transformForOrientation(newSize:CGSize) -> CGAffineTransform
    {
        var transform:CGAffineTransform = CGAffineTransformIdentity;
        
        switch (self.imageOrientation) {
        case .Up, .UpMirrored:
            break;
            
        case .Down, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI));
            break;
            
        case .Left, .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2));
            break;
            
        case .Right,.RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2));
            break;
        }
        
        switch (self.imageOrientation) {
        case .UpMirrored, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case .LeftMirrored , .RightMirrored:
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case .Down, .Up ,.Right, .Left:
            break;
        }
        
        return transform;
    }
    
    // Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
    // The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
    // If the new size is not integral, it will be rounded up
    func resizedImage( newSize:CGSize, transform:CGAffineTransform, transpose:Bool,
        interpolationQuality:CGInterpolationQuality)-> UIImage!
    {
        let newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
        let transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
        let imageRef = self.CGImage;
        
        // Build a context that's the same dimensions as the new size
        let bitmap = CGBitmapContextCreate(nil,
            UInt(newRect.size.width),
            UInt(newRect.size.height),
            CGImageGetBitsPerComponent(imageRef),
            0,
            CGImageGetColorSpace(imageRef),
            CGImageGetBitmapInfo(imageRef));
        
        // Rotate and/or flip the image if required by its orientation
        CGContextConcatCTM(bitmap, transform);
        
        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(bitmap, interpolationQuality);
        
        // Draw into the context; this scales the image
        CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
        
        // Get the resized image from the context and a UIImage
        let newImageRef = CGBitmapContextCreateImage(bitmap);
        
        return UIImage(CGImage:newImageRef)!
    }
    
    
    func resizedImage(newSize:CGSize,interpolationQuality:CGInterpolationQuality ) -> UIImage!
    {
        var drawTransposed:Bool;
        
        switch (self.imageOrientation) {
        case .Left, .LeftMirrored ,.Right, .RightMirrored:
            drawTransposed = true;
        default:
            drawTransposed = false;
        }
        
        return self.resizedImage(newSize,
            transform:self.transformForOrientation(newSize),
            transpose:drawTransposed,
            interpolationQuality:interpolationQuality);
    }
    
}
