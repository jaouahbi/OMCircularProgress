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
    
//    private class func CFAttributedStringFromString(string:String, formatStyle:CFNumberFormatterStyle) -> CFMutableAttributedString!
//    {
//        let num = CFNumberFormatterCreateNumberFromString(kCFAllocatorDefault,
//            CFNumberFormatterCreate(nil, CFLocaleCopyCurrent(),formatStyle),
//            string as CFStringRef!,
//            nil,
//            0/*kCFNumberFormatterParseIntegersOnly*/)
//        
//        return CFAttributedStringFromNumberWithFormat(num,formatStyle: formatStyle)
//    }
//    
//
//    private class func CFAttributedStringFromNumberWithFormat(number:NSNumber, formatStyle:CFNumberFormatterStyle) -> CFMutableAttributedString!
//    {
//        let textString = CFNumberFormatterCreateStringWithNumber(nil, CFNumberFormatterCreate(nil, CFLocaleCopyCurrent(),formatStyle),number);
//        
//        // Create a mutable attributed string with a max length of 0.
//        // The max length is a hint as to how much internal storage to reserve.
//        // 0 means no hint.
//        
//        let attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
//        
//        // Copy the textString into the newly created attrString
//        
//        CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), textString);
//        
//        
//        return attrString
//    }
    
    
    //
    // Calculate the frame size of the NSNumber to represent.
    //
    // NOTE: the max. percent representation is 1
    //
    
    func frameSizeLengthFromNumber(number:NSNumber) -> CGSize
    {
        return frameSizeLengthFromString(self.toString(number,formatStyle: self.formatStyle))
    }

    func toString(number:CFNumberRef,formatStyle:CFNumberFormatterStyle)  -> String!
    {
       return CFNumberFormatterCreateStringWithNumber(nil,
            CFNumberFormatterCreate(nil, CFLocaleCopyCurrent(),formatStyle),
            number)  as String
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
    
    override func drawInContext(context: CGContext!) {
        
        if let presentationLayer: AnyObject = self.presentationLayer() {
            self.number = presentationLayer.number
        }

        self.string = self.toString(self.number,formatStyle: self.formatStyle)
        
        //DEBUG
        //println("--> drawInContext(\(self.string))")
        
        // the base class do the work
        
        super.drawInContext(context)
    }
}
