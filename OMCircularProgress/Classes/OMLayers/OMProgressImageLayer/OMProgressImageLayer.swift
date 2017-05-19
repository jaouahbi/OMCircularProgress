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
//  OMProgressImageLayer.swift
//
//  Created by Jorge Ouahbi on 26/3/15.
//
//  0.1 (29-03-2015)
//      Added radial progress, grayscale mode and direction,
//      showing/hiding and update shadow copy layer options.
//      Now render the image in context
//      Update the layer when beginRadians is changed if the type is Circular
//      Sets OMProgressType.OMCircular as default type
//      Fixed the alpha channel for the grayscaled image
//      Added prepareForDrawInContext()

#if os(iOS)
    import UIKit
    #elseif os(OSX)
    import AppKit
#endif

public enum OMProgressType : Int
{
    case horizontal
    case vertical
    case circular
    case radial
}

//
// Name of the animatable properties
//

private struct OMProgressImageLayerProperties {
    static var Progress = "progress"
}

class OMProgressImageLayer : CALayer
{
    // progress showing image or hiding
    
    var showing:Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // progress direction
    
    var clockwise:Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    var image:UIImage?  = nil {
        didSet {
            setNeedsDisplay()
        }
    }
    var progress: Double  = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // -90 degrees
    var beginRadians: Double = -.pi / 2.0 {
        didSet {
            if(self.type == .circular) {
                setNeedsDisplay()
            }
        }
    }
    
    var type:OMProgressType  = .circular {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var grayScale:Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func animateProgress(_ fromValue:Double,toValue:Double,beginTime:TimeInterval,duration:TimeInterval, delegate:AnyObject?) {
        self.animateKeyPath(OMProgressImageLayerProperties.Progress,
            fromValue:fromValue as AnyObject?,
            toValue:toValue as AnyObject?,
            beginTime:beginTime,
            duration:duration,
            delegate:delegate)
    }
    
    override init(){
        super.init()
        self.contentsScale = UIScreen.main.scale
        self.needsDisplayOnBoundsChange = true;
        
        // https://github.com/danielamitay/iOS-App-Performance-Cheatsheet/blob/master/QuartzCore.md
        
        self.shouldRasterize = true
        self.rasterizationScale = UIScreen.main.scale
        self.drawsAsynchronously = true
        self.allowsGroupOpacity  = true
        //self.contentsGravity = "resizeAspect"
    }
    
    convenience init(image:UIImage){
        self.init()
        self.image = image
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        if let other = layer as? OMProgressImageLayer {
            self.progress        = other.progress
            self.image           = other.image
            self.type            = other.type
            self.beginRadians    = other.beginRadians
            self.grayScale       = other.grayScale
            self.showing         = other.showing
            self.clockwise       = other.clockwise
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override class func needsDisplay(forKey event: String) -> Bool {
        if(event == OMProgressImageLayerProperties.Progress){
            return true
        }
        return super.needsDisplay(forKey: event)
    }
    
    override func action(forKey event: String) -> CAAction? {
        if(event == OMProgressImageLayerProperties.Progress){
            return animationActionForKey(event);
        }
        return super.action(forKey: event)
    }
    
    fileprivate func imageForDrawInContext() -> UIImage? {
        var newImage:UIImage? = nil
        var newProgress:Double = self.progress
        
        if let presentationLayer: AnyObject = self.presentation(){
            newProgress = presentationLayer.progress
        }
        
        if newProgress > 0 {
            switch(self.type) {
            case .radial:
                
                let radius = image!.size.max() * CGFloat(newProgress)
                
                let center = image!.size.center()
                
                let path = UIBezierPath(arcCenter: center,
                    radius: radius ,
                    startAngle: 0,
                    endAngle: CGFloat.pi * 2.0,
                    clockwise: true)
                
                path.addLine(to: center)
                path.close()
                
                newImage = self.image!.maskImage(path)
                break
                
                
            case .circular:
                
                let radius = image!.size.max()
                let center = image!.size.center()
                let startAngle:Double = beginRadians
                
                let endAngle:Double
                if !self.clockwise {
                    endAngle  =  Double(Double.pi * 2.0 * (1.0 - newProgress) + beginRadians)
                } else {
                    endAngle  =  Double(Double.pi * 2.0 * newProgress + beginRadians)
                }
                
                let path = UIBezierPath(arcCenter: center,
                    radius: radius ,
                    startAngle: CGFloat(startAngle),
                    endAngle: CGFloat(endAngle),
                    clockwise: self.showing)
                
                path.addLine(to: center)
                path.close()
                newImage = self.image!.maskImage(path)
                break;
            case .vertical:
                let newHeight = Double(self.bounds.size.height) * newProgress
                let path = UIBezierPath(rect: CGRect(CGSize(width:self.bounds.size.width,height:CGFloat(newHeight))))
                newImage = self.image!.maskImage(path)
                break;
            case .horizontal:
                let newWidth = Double(self.bounds.size.width) * newProgress
                let path = UIBezierPath(rect:CGRect(CGSize(width: CGFloat(newWidth),height:self.bounds.size.height)))
                newImage = self.image!.maskImage(path)
                break;
            }
        } else {
            newImage = self.image?.grayScaleWithAlphaImage()
        }
        
        return newImage
    }
    
    // MARK: overrides
    
    override func draw(in context: CGContext) {
        
        super.draw(in: context)

        // Image setup
        let newImage = self.imageForDrawInContext()
        
        // Core Text Coordinate System and Core Graphics are OSX style
        #if os(iOS)
            context.translateBy(x: 0, y: self.bounds.size.height);
            context.scaleBy(x: 1.0, y: -1.0);
        #endif
        
        if let newImage = newImage {
            let rect = CGRect(CGSize(width: newImage.size.width, height: newImage.size.height))
            if  grayScale {
                // original image grayscaled + original image blend
                if let image = self.image {
                   if let grayImage = image.grayScaleWithAlphaImage() {
                        if let imageBlended = grayImage.blendImage(newImage) {
                            context.draw(imageBlended.cgImage!, in: rect)
                        }
                    }
                }
            } else {
                context.draw(newImage.cgImage!, in: rect)
            }
        }
    }
}
