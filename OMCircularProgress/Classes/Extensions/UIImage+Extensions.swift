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
//  UIImage+Extensions.swift
//
//  Created by Jorge Ouahbi on 28/3/15.
//
//  0.1  Added alpha parameter to blendImage func (29-03-2015)
//  0.11 Added addOutterShadow func (22-04-2015)
//  0.12 Remplazed the CoreGraphics resize code by UIKit resize code  (28-04-2015)
//  0.13 Merged with other projects UIImage extensions (24-09-2016)
//
//

import UIKit


extension UIImage
{
    func cornerRadius(_ radius:CGFloat) -> UIImage
    {
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0);
        
        //clip image
        UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height),cornerRadius:radius).addClip()
        
        //draw image
        self.draw(at: CGPoint.zero);
        
        //capture resultant image
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    
    func resize( _ newSize:CGSize ) -> UIImage {
        return resizedImage(newSize, interpolationQuality: CGInterpolationQuality.default )
    }
    
    func rotatedImage(_ radians:CGFloat) -> UIImage
    {
        // Create the bitmap context
        UIGraphicsBeginImageContextWithOptions(self.size,false,0.0);
        
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap?.translateBy(x: size.width * 0.5, y: size.height * 0.5);
        
        //   // Rotate the image context
        bitmap?.rotate(by: radians);
        
        // Now, draw the rotated/scaled image into the context
        bitmap?.scaleBy(x: 1.0, y: -1.0);
        bitmap?.draw(self.cgImage!, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height));
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage!;
        
    }
    
    
    // Returns an affine transform that takes into account the image orientation when drawing a scaled image
    func transformForOrientation(_ newSize:CGSize) -> CGAffineTransform
    {
        var transform:CGAffineTransform = CGAffineTransform.identity;
        
        switch (self.imageOrientation) {
        case .up, .upMirrored:
            break;
            
        case .down, .downMirrored:
            transform = transform.translatedBy(x: newSize.width, y: newSize.height);
            transform = transform.rotated(by: .pi);
            break;
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: newSize.width, y: 0);
            transform = transform.rotated(by: .pi / 2.0);
            break;
            
        case .right,.rightMirrored:
            transform = transform.translatedBy(x: 0, y: newSize.height);
            transform = transform.rotated(by: CGFloat(-.pi / 2.0));
            break;
        @unknown default:
            fatalError()
        }
        
        switch (self.imageOrientation) {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: newSize.width, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
            break;
            
        case .leftMirrored , .rightMirrored:
            transform = transform.translatedBy(x: newSize.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
            break;
            
        case .down, .up ,.right, .left:
            break;
        @unknown default:
            fatalError()
        }
        
        return transform;
    }
    
    // Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
    // The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
    // If the new size is not integral, it will be rounded up
    func resizedImage( _ newSize:CGSize, transform:CGAffineTransform, transpose:Bool,
                       interpolationQuality:CGInterpolationQuality)-> UIImage!
    {
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral;
        let transposedRect = CGRect(x: 0, y: 0, width: newRect.size.height, height: newRect.size.width);
        let imageRef = self.cgImage;
        
        // Build a context that's the same dimensions as the new size
        let bitmap = CGContext(data: nil,
                               width: Int(newRect.size.width),
                               height: Int(newRect.size.height),
                               bitsPerComponent: (imageRef?.bitsPerComponent)!,
                               bytesPerRow: 0,
                               space: (imageRef?.colorSpace!)!,
                               bitmapInfo: (imageRef?.bitmapInfo.rawValue)!);
        
        // Rotate and/or flip the image if required by its orientation
        bitmap?.concatenate(transform);
        
        // Set the quality level to use when rescaling
        bitmap!.interpolationQuality = interpolationQuality;
        
        // Draw into the context; this scales the image
        bitmap?.draw(imageRef!, in: transpose ? transposedRect : newRect);
        
        // Get the resized image from the context and a UIImage
        let newImageRef = bitmap?.makeImage();
        
        return UIImage(cgImage:newImageRef!)
    }
    
    
    func resizedImage(_ newSize:CGSize,interpolationQuality:CGInterpolationQuality ) -> UIImage! {
        var drawTransposed:Bool;
        
        switch (self.imageOrientation) {
        case .left, .leftMirrored ,.right, .rightMirrored:
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


extension UIImage
{
    func scaledToSize(_ newSize:CGSize,rect:CGRect) -> UIImage
    {
        //  avoid redundant drawing
        
        if (self.size == newSize) {
            return self;
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        
        //Draw image in provided rect
        
        self.draw(in: rect);
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        //Pop this context
        UIGraphicsEndImageContext();
        
        return newImage!;
    }
    
    func cropToRect(_ rect:CGRect) -> UIImage
    {
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        
        //draw
        self.draw(at: CGPoint(x: -rect.origin.x, y: -rect.origin.y))
        
        //capture resultant image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        //return image
        return image!
    }
    
    
    func scaledToFitToSize(_ newSize:CGSize) -> UIImage
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
        let scaledSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor);
        
        //Scale the image
        return self.scaledToSize(scaledSize,rect:CGRect(x: 0.0, y: 0.0, width: scaledSize.width, height: scaledSize.height));
    }
    
    func  scaledToFillToSize(_ newSize:CGSize) -> UIImage
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
        let scaledSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor);
        
        //Create origin point so that the center of the image falls into the drawing context rect (the origin will have negative component).
        var imageDrawOrigin:CGPoint = CGPoint.zero
        
        widthScale > heightScale ?  (imageDrawOrigin.y = (newSize.height - scaledSize.height) * 0.5) :
            (imageDrawOrigin.x = (newSize.width - scaledSize.width) * 0.5);
        
        
        //Create rect where the image will draw
        let imageDrawRect = CGRect(x: imageDrawOrigin.x, y: imageDrawOrigin.y, width: scaledSize.width, height: scaledSize.height);
        
        //The imageDrawRect is larger than the newSize rect, where the imageDraw origin is located defines what part of
        //the image will fall into the newSize rect.
        return self.scaledToSize(newSize,rect:imageDrawRect);
    }
    
}


//
// Transform and blend extension
//

extension UIImage
{
    
    /// Transform the image in grayscale.
    ///
    /// - returns: UIImage
    
    func grayScaleWithAlphaImage() -> UIImage?
    {
        let imageRect = CGRect(self.size)
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        let context = UIGraphicsGetCurrentContext();
        
        // Draw a white background
        // context?.setFillColor(gray:1.0, alpha: 1.0);

        context?.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0);
        context?.fill(imageRect);
        
        // Draw the luminosity on top of the white background to get grayscale
        self.draw(in: imageRect,blendMode:CGBlendMode.luminosity,alpha:1.0);
        
        // Apply the source image's alpha
        self.draw(in: imageRect,blendMode:CGBlendMode.destinationIn,alpha:1.0);
        
        let grayscaleImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        return grayscaleImage
    }
    
    /// Blend current UIImage with other
    ///
    /// - parameter other:  other image
    /// - parameter alpha: blend alpha (default:1.0)
    ///
    /// - returns: UIImage?
    
    func blendImage(_ other:UIImage, alpha:CGFloat = 1.0) -> UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        
        self.draw(at: CGPoint.zero)
        other.draw(at: CGPoint.zero, blendMode:CGBlendMode.normal, alpha:alpha)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage
    }
    
    /// Blend current UIImage with other (alpha:1.0)
    ///
    /// - parameter other: other image
    ///
    /// - returns: UIImage?
    
    func blendImage(_ other:UIImage) -> UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        
        self.draw(at: CGPoint.zero)
        other.draw(at: CGPoint.zero)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage
    }
    
    /// Mask current UIImage with path
    ///
    /// - parameter other: path
    ///
    /// - returns: UIImage?
    
    func maskImage(_ path:UIBezierPath) -> UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        path.addClip()
        self.draw(at: CGPoint.zero)
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return maskedImage
    }
}

// reflection extension

extension UIImage {

    class func gradientMask() -> CGImage
    {
        // create gradient mask
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 256), true, 0.0);
        
        let gradientContext = UIGraphicsGetCurrentContext();
        let colors:[CGFloat] = [0.0, 1.0, 1.0, 1.0];
        let colorSpace = CGColorSpaceCreateDeviceGray();
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: colors, locations: nil, count: 2);
        let gradientStartPoint = CGPoint(x: 0, y: 0);
        let gradientEndPoint = CGPoint(x: 0, y: 256);
        
        gradientContext?.drawLinearGradient(gradient!,
                                            start: gradientStartPoint,
                                            end: gradientEndPoint,
                                            options: CGGradientDrawingOptions.drawsAfterEndLocation);
        
        let sharedMask = gradientContext?.makeImage();
        
        UIGraphicsEndImageContext();
        
        return sharedMask!;
    }
    
    func reflectedImageWithScale(_ scale:CGFloat) -> UIImage
    {
        //get reflection dimensions
        let height = ceil(self.size.height * scale);
        let size = CGSize(width: self.size.width, height: height);
        let bounds = CGRect(size);
        
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        let context = UIGraphicsGetCurrentContext();
        
        //clip to gradient
        context?.clip(to: bounds, mask: UIImage.gradientMask());
        
        //draw reflected image
        context?.scaleBy(x: 1.0, y: -1.0);
        context?.translateBy(x: 0.0, y: -self.size.height)
        self.draw(in: bounds)
        
        //capture resultant image
        let reflection = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //return reflection image
        return reflection!;
    }
    
    func imageWithReflectionWithScale(_ scale:CGFloat,gap:CGFloat,alpha:CGFloat = 1.0) -> UIImage
    {
        //get reflected image
        let reflection = self.reflectedImageWithScale(scale);
        let reflectionOffset = reflection.size.height + gap;
        
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.size.width, height: self.size.height + reflectionOffset * 2.0), false, 0.0);
        
        //draw reflection
        reflection.draw(at: CGPoint(x: 0.0, y: reflectionOffset + self.size.height + gap),blendMode:CGBlendMode.normal,alpha:alpha);
        
        //draw image
        self.draw(at: CGPoint(x: 0.0, y: reflectionOffset));
        
        //capture resultant image
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //return image
        return image!;
    }
}


//
// Shadow extension
//

extension UIImage {
    
    func addShadowColor(_ offset:CGSize, color:UIColor = UIColor.darkGray, blur:CGFloat = 6.0) -> UIImage
    {
        //get size
        let border = CGSize(width: abs(offset.width) + blur, height: abs(offset.height) + blur);
        
        let size = CGSize(width: self.size.width + border.width * 2.0,
                          height: self.size.height + border.height * 2.0);
        
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        let context = UIGraphicsGetCurrentContext();
        
        //set up shadow
        context?.setShadow(offset: offset, blur: blur, color: color.cgColor);
        
        //draw with shadow
        self.draw(at: CGPoint(x: border.width, y: border.height))
        
        //capture resultant image
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //return image
        return image!
    }
    
    func addOutterShadowColor(_ color:UIColor = UIColor.darkGray,blurSize: CGFloat = 6.0) -> UIImage? {
        
        let offset = CGSize(width: blurSize*0.5,height: -blurSize*0.5)
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue
        
        let shadowContext : CGContext = CGContext( data: nil,
                                                   width: Int(self.size.width * scale + blurSize),
                                                   height: Int(self.size.height * scale + blurSize),
                                                   bitsPerComponent: self.cgImage!.bitsPerComponent,
                                                   bytesPerRow: 0,
                                                   space: self.cgImage!.colorSpace!,
                                                   bitmapInfo: bitmapInfo)!
        
        shadowContext.setShadow(offset: offset,
                                blur: blurSize*0.5,
                                color: color.cgColor)
        
        shadowContext.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width * scale , height: self.size.height * scale))
        
        return UIImage(cgImage: shadowContext.makeImage()!, scale:scale, orientation: imageOrientation)
    }
    
    func addInnerShadow() {
        //TODO:
    }
    
}
