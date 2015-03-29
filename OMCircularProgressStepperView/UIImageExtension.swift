//
//  UIImage.swift
//
//  Created by Jorge Ouahbi on 28/3/15.
//  Copyright (c) 2015 Jorge Ouahbi. All rights reserved.
//
//  0.1 Added alpha parameter to blendImage func (29-03-2015)

import UIKit

extension UIImage
{
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

    
    func blendImage(other:UIImage, alpha:CGFloat = 1.0) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        
        self.drawAtPoint(CGPointZero)
        other.drawAtPoint(CGPointZero, blendMode:kCGBlendModeNormal, alpha:alpha)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage
    }
    
    func grayScaleImage() -> UIImage {
        let imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
        let colorSpace = CGColorSpaceCreateDeviceGray();
        
        let width = UInt(self.size.width)
        let height = UInt(self.size.height)
        let context = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, .allZeros);
        CGContextDrawImage(context, imageRect, self.CGImage!);
        
        let imageRef = CGBitmapContextCreateImage(context);
        
        return UIImage(CGImage: imageRef)!
    }
    
   // func maskImage(path:UIBezierPath, trans: UnsafePointer<CGAffineTransform> = nil ) -> UIImage
     func maskImage(path:UIBezierPath ) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
    
        
//        if(trans != nil) {
//            let context = UIGraphicsGetCurrentContext();
//            CGContextConcatCTM(context,trans.memory)
//        }
        
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
