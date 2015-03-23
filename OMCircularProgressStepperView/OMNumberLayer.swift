//
//  OMNumberLayer.swift
//  ExampleSwift
//
//  Created by Jorge Ouahbi on 27/2/15.
//  Copyright (c) 2015 Jorge Ouahbi. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

import CoreText
import CoreFoundation


private struct OMNumberLayerProperties {
    static var Number = "number"
}

class OMNumberLayer : OMTextLayer
{
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
    
    private class func CFAttributedStringFromString(string:String, formatStyle:CFNumberFormatterStyle) -> CFMutableAttributedString!
    {
        let num = CFNumberFormatterCreateNumberFromString(kCFAllocatorDefault,
            CFNumberFormatterCreate(nil, CFLocaleCopyCurrent(),formatStyle),
            string as CFStringRef!,
            nil,
            0/*kCFNumberFormatterParseIntegersOnly*/)
        
        return CFAttributedStringFromNumberWithFormat(num,formatStyle: formatStyle)
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
    
    
    //
    // Calculate the frame size of the NSNumber to represent.
    //
    // NOTE: the max. percent representation is 1
    //
    
    func frameSizeLengthFromNumber(number:NSNumber) -> CGSize
    {
        let attrString = OMNumberLayer.CFAttributedStringFromNumberWithFormat(number, formatStyle: self.formatStyle)
        
        return frameSizeLengthFromAttributedString(attrString)
    }

    override init()
    {
        super.init()
    }
    
    convenience init( number : NSNumber ,
        formatStyle: CFNumberFormatterStyle = CFNumberFormatterStyle.DecimalStyle,
        alignmentMode:String = "center")
    {
        self.init()
        self.number = number
        self.formatStyle = formatStyle
        
        setAlignmentMode(alignmentMode)
    }    

    override init!(layer: AnyObject!) {
        super.init(layer: layer)
        if let other = layer as? OMNumberLayer {
            self.formatStyle =  other.formatStyle
            self.number = other.number
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func animateNumber(fromValue:Double,toValue:Double,beginTime:NSTimeInterval,duration:NSTimeInterval, delegate:AnyObject?)
    {
        let keyPath = OMNumberLayerProperties.Number

        let animation = CABasicAnimation(keyPath:keyPath);
        var currentValue: AnyObject? = self.presentationLayer()?.valueForKey(keyPath)
        
        if (currentValue == nil) {
            currentValue = fromValue
        }
        
        animation.fromValue = currentValue
        animation.toValue = toValue
        animation.delegate = delegate
        animation.duration = duration
        animation.beginTime = beginTime 
        animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionDefault)
        animation.setValue(self,forKey:"numberAnimation")
        self.addAnimation(animation, forKey:keyPath)
        self.setValue(toValue,forKey:keyPath)
    }
    
    override class func needsDisplayForKey(event: String!) -> Bool
    {
        if(event == OMNumberLayerProperties.Number){
            return true
        }
        return super.needsDisplayForKey(event)
    }
    
    override func actionForKey(event: String!) -> CAAction!
    {
        if(event == OMNumberLayerProperties.Number){
            let animation = CABasicAnimation(keyPath: event)
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.fromValue = self.presentationLayer().valueForKey(event);
            return animation
        }
        return super.actionForKey(event)
    }
    
    func numberToString() -> String!
    {
        return CFAttributedStringGetString(OMNumberLayer.CFAttributedStringFromNumberWithFormat(self.number, formatStyle: formatStyle)) as? String
    }
    override func drawInContext(context: CGContext!) {
        
        if let presentationLayer: AnyObject = self.presentationLayer() {
            self.number = presentationLayer.number
        }

        self.string = self.numberToString()
        
        //DEBUG
        println("--> drawInContext(\(self.string))")
        
        super.drawInContext(context)
        
//        CGContextSaveGState(context);
//        
//        // draw things like circles and lines,
//        // everything displays correctly ...
//        
//        // now drawing the text
//        //UIGraphicsPushContext(context);
//        
//        // Set the text matrix.
//        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//        
//        // Create a path which bounds the area where you will be drawing text.
//        // The path need not be rectangular.
//        
//        // Core Text Coordinate System is OSX style
//        
//#if os(iOS)
//        CGContextTranslateCTM(context, 0, self.bounds.size.height);
//        CGContextScaleCTM(context, 1.0, -1.0);
//#endif
//
//        let path = CGPathCreateMutable();
//        
//        // Initialize a rectangular path.
//        
//        CGPathAddRect(path, nil, self.bounds);
//        
//        var theNumber: NSNumber = self.number
//        
//        if let player: AnyObject = self.presentationLayer() {
//            theNumber = player.number
//        }
//        
//        let attrString = OMNumberLayer.CFAttributedStringFromNumberWithFormat(theNumber, formatStyle: formatStyle)
//        
//        let attrStringWithAttributes = self.attributedStringWithAttributes(attrString)
//        
//        // Create the framesetter with the attributed string.
//        
//        let framesetter = CTFramesetterCreateWithAttributedString(attrString);
//        
//        // Create a frame.
//        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil);
//        
//        // Draw the specified frame in the given context.
//        CTFrameDraw(frame, context);
//        
//        //UIGraphicsPopContext();
//        CGContextRestoreGState(context);
    }
}
