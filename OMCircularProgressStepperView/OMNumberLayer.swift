//
//  OMNumberLayer.swift
//  ExampleSwift
//
//  Created by Jorge Ouahbi on 27/2/15.
//  Copyright (c) 2015 Jorge Ouahbi. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import AppKit
#endif

import CoreText
import CoreFoundation

class OMNumberLayer : CALayer
{
    private(set) var paragraphStyle:CTParagraphStyle?
    private(set) var fontRef:CTFontRef = CTFontCreateWithName("Helvetica" as CFStringRef, 12.0, nil);

    var number: NSNumber = 0.0 {
        didSet{
            setNeedsDisplay()
        }
    }
    var formatStyle: CFNumberFormatterStyle = CFNumberFormatterStyle.DecimalStyle
    {
        didSet{
            setNeedsDisplay()
        }
    }
    
    var foregroundColor:UIColor = UIColor.blackColor() {
        didSet{
            setNeedsDisplay()
        }
    }

    private class func CFAttributedStringFromNumberWithFormat(number:NSNumber, formatStyle:CFNumberFormatterStyle) -> CFMutableAttributedString!
    {
        let textString = CFNumberFormatterCreateStringWithNumber(nil, CFNumberFormatterCreate(nil, CFLocaleCopyCurrent(),formatStyle),number);
        
        // Create a mutable attributed string with a max length of 0.
        // The max length is a hint as to how much internal storage to reserve.
        // 0 means no hint.
        
        let attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        
        // Copy the textString into the newly created attrString
        
        CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), textString);
        
        
        return attrString
    }
    
    
    func applyAttributes(attrString : CFMutableAttributedStringRef) -> CFAttributedStringRef
    {
        // Create a color that will be added as an attribute to the attrString.
        //        let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        //
        //        let red = CGColorCreate(rgbColorSpace, [1.0, 0.0, 0.0, 1.0]);
        //
        //        // Set the color of the first 12 chars to red.
        //        CFAttributedStringSetAttribute(attrString, CFRangeMake(0, 2),
        //            kCTForegroundColorAttributeName, red);
        
        let stringLength = CFAttributedStringGetLength(attrString)
        
        CFAttributedStringSetAttribute(attrString,
            CFRangeMake(0, stringLength),
            kCTForegroundColorAttributeName,
            self.foregroundColor.CGColor);
        
        CFAttributedStringSetAttribute(attrString,
            CFRangeMake(0, stringLength),
            kCTFontAttributeName,
            self.fontRef)
        
        CFAttributedStringSetAttribute(attrString,
            CFRangeMake(0, stringLength),
            kCTParagraphStyleAttributeName,
            self.paragraphStyle)
        
        //        CFAttributedStringSetAttribute(attrString,
        //            CFRangeMake(0, stringLength),
        //            kCTStrokeWidthAttributeName,
        //            NSNumber(float: -3))
        //
        //        CFAttributedStringSetAttribute(attrString,
        //            CFRangeMake(0, stringLength),
        //            kCTStrokeColorAttributeName,
        //            UIColor.lightGrayColor().CGColor)

        
        return attrString
    }
    
    func frameSizeLength(number:NSNumber) -> CGSize
    {
        let attrString = OMNumberLayer.CFAttributedStringFromNumberWithFormat(number, formatStyle: self.formatStyle)
        
        let attrStringWithAttributes = self.applyAttributes(attrString)
        
        let stringLength = CFAttributedStringGetLength(attrStringWithAttributes)
        
        // Create the framesetter with the attributed string.
        
        let framesetter = CTFramesetterCreateWithAttributedString(attrStringWithAttributes);
        
        let targetSize = CGSizeMake(CGFloat.max, CGFloat.max)
        
        return CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0, stringLength), nil, targetSize, nil)
        
    }
    func setAlignmentMode(alignmentMode:String)
    {
        var alignment: CTTextAlignment = OMNumberLayer.CTTextAlignmentFromString(alignmentMode)
        let alignmentSetting = [CTParagraphStyleSetting(spec: .Alignment, valueSize: UInt(sizeofValue(alignment)), value: &alignment)]
        self.paragraphStyle = CTParagraphStyleCreate(alignmentSetting, UInt(alignmentSetting.count))
    }
    
    override init()
    {
        super.init()
    }
    
    convenience init( number : NSNumber ,
        formatStyle: CFNumberFormatterStyle  = CFNumberFormatterStyle.DecimalStyle,
        alignmentMode:String = "center")
    {
        self.init()
        self.contentsScale = UIScreen.mainScreen().scale
        self.number = number
        self.formatStyle = formatStyle
        
        setAlignmentMode(alignmentMode)
    }    

    override init!(layer: AnyObject!) {
        super.init(layer: layer)
        if (layer.isKindOfClass(OMNumberLayer)) {
            if let other = layer as? OMNumberLayer {
                self.formatStyle = layer.formatStyle
                self.number = layer.number
                self.fontRef = layer.fontRef
                self.foregroundColor = layer.foregroundColor
                self.paragraphStyle = layer.paragraphStyle
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private class func CTTextAlignmentFromString(alignmentMode:String) -> CTTextAlignment
    {
        var alignment: CTTextAlignment
        
        switch (alignmentMode)
        {
        case "center":
            alignment = CTTextAlignment.TextAlignmentCenter
        case "left":
            alignment = CTTextAlignment.TextAlignmentLeft
        case "right":
            alignment = CTTextAlignment.TextAlignmentRight
        case "justified":
            alignment = CTTextAlignment.TextAlignmentJustified
        case "natural":
            alignment = CTTextAlignment.TextAlignmentNatural
        default:
            alignment = CTTextAlignment.TextAlignmentLeft
        }
        
        return alignment
    }
    func setFont(fontName:String!, fontSize:CGFloat) {
        assert(fontSize > 0,"Invalid font size (0)")
        assert(fontName.isEmpty == false ,"Invalid font name (empty)")
        
        self.fontRef = CTFontCreateWithName(fontName as CFStringRef, fontSize, nil);
    }
    
    func animateNumber(fromValue:Double,toValue:Double,duration:NSTimeInterval, delegate:AnyObject?)
    {
        let keyPath = "number"

        let animation = CABasicAnimation(keyPath:keyPath);
        var currentValue: AnyObject? = self.presentationLayer()?.valueForKey(keyPath)
        
        if (currentValue == nil) {
            currentValue = fromValue
        }
        
        animation.fromValue = currentValue
        animation.toValue = toValue
        animation.delegate = delegate
        animation.duration = duration
        animation.beginTime = CACurrentMediaTime()
        animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionDefault)
        animation.setValue(self,forKey:"numberAnimation")
        self.addAnimation(animation, forKey:keyPath)
        self.setValue(toValue,forKey:keyPath)
    }
    
    override class func needsDisplayForKey(event: String!) -> Bool
    {
        if(event == "number"){
            return true
        }
        return CALayer.needsDisplayForKey(event)
    }
    
    
    override func actionForKey(event: String!) -> CAAction!
    {
        if(event == "number"){
            let animation = CABasicAnimation(keyPath: event)
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.fromValue = self.presentationLayer().number
            return animation
        }
        return super.actionForKey(event)
    }
    
    override func drawInContext(context: CGContext!) {
        //super.drawInContext(context);
        
        CGContextSaveGState(context);
        
        // draw things like circles and lines,
        // everything displays correctly ...
        
        // now drawing the text
        //UIGraphicsPushContext(context);
        
        // Set the text matrix.
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        
        // Create a path which bounds the area where you will be drawing text.
        // The path need not be rectangular.
        
        // Core Text Coordinate System is OSX style
        
#if os(iOS)
        CGContextTranslateCTM(context, 0, self.bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
#endif

        let path = CGPathCreateMutable();
        
        // Initialize a rectangular path.
        
        CGPathAddRect(path, nil, self.bounds);
        
        var theNumber: NSNumber = self.number
        
        if let player: AnyObject = self.presentationLayer() {
            theNumber = player.number
        }
        
        let attrString = OMNumberLayer.CFAttributedStringFromNumberWithFormat(theNumber, formatStyle: formatStyle)
        
        let attrStringWithAttributes = self.applyAttributes(attrString)
        
        // Create the framesetter with the attributed string.
        
        let framesetter = CTFramesetterCreateWithAttributedString(attrString);
        
        // Create a frame.
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil);
        
        // Draw the specified frame in the given context.
        CTFrameDraw(frame, context);
        
        //UIGraphicsPopContext();
        CGContextRestoreGState(context);
    }
    
    //DEBUG
    override func display() {
        super.display()
        if(self.bounds.size.height == 0 || self.bounds.size.width == 0) {
            println("empty layer.")
        }
    }
}
