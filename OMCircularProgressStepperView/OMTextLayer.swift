//
//  OMTextLayer.swift
//  ExampleSwift
//
//  Created by Jorge Ouahbi on 23/3/15.
//  Copyright (c) 2015 Jorge Ouahbi. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

import CoreText
import CoreFoundation

class OMTextLayer : CALayer
{
    private(set) var paragraphStyle:CTParagraphStyle?
    private(set) var fontRef:CTFontRef = CTFontCreateWithName("Helvetica" as CFStringRef, 12.0, nil);

    var fontStrokeColor:UIColor = UIColor.lightGrayColor()
    var fontStrokeWidth:Float   = -3
    
    var string : String? = nil {
        didSet{
            setNeedsDisplay()
        }
    }
    
//    override var frame:CGRect
//    {
//        didSet {
//            
//            if(self.bounds.isEmpty){
//                
//                let sizeOfLayer:CGSize
//                
//                if(self.string != nil){
//                    sizeOfLayer = self.frameSizeLengthFromString(self.string!)
//                }else{
//                    sizeOfLayer = CGSizeZero
//                }
//                
//                 super.frame = CGRect(origin: self.frame.origin, size: sizeOfLayer )
//            }
//        }
//    }
    
    var foregroundColor:UIColor = UIColor.blackColor() {
        didSet{
            setNeedsDisplay()
        }
    }
    
    func stringWithAttributes(string : String) -> CFAttributedStringRef
    {
        return self.attributedStringWithAttributes(NSAttributedString(string : string))
    }
    
    func attributedStringWithAttributes(attrString : CFAttributedStringRef) -> CFAttributedStringRef
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
        
        
        let range = CFRangeMake(0, stringLength)
        
        // Create a mutable attributed string with a max length of 0.
        // The max length is a hint as to how much internal storage to reserve.
        // 0 means no hint.
        
        let newString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        
        // Copy the textString into the newly created attrString
        
        CFAttributedStringReplaceString (newString, CFRangeMake(0,0), CFAttributedStringGetString(attrString));

        CFAttributedStringSetAttribute(newString,
            range,
            kCTForegroundColorAttributeName,
            self.foregroundColor.CGColor);
        
        CFAttributedStringSetAttribute(newString,
            range,
            kCTFontAttributeName,
            self.fontRef)
        
        CFAttributedStringSetAttribute(newString,
            range,
            kCTParagraphStyleAttributeName,
            self.paragraphStyle)
        
        CFAttributedStringSetAttribute(newString,
                   range,
                   kCTStrokeWidthAttributeName,
                   NSNumber(float: self.fontStrokeWidth))
        
        CFAttributedStringSetAttribute(newString,
                  range,
                   kCTStrokeColorAttributeName,
                   self.fontStrokeColor.CGColor)

        //TODO:
        //kCTUnderlineStyleAttributeName
        //kCTUnderlineColorAttributeName
        
        return newString
    }
    
    //
    // Calculate the frame size of a String
    //
    
    func frameSizeLengthFromString(string : String) -> CGSize
    {
        return frameSizeLengthFromAttributedString(NSAttributedString(string : string))
    }
    
    func frameSizeLengthFromAttributedString(attrString : NSAttributedString) -> CGSize
    {
        let attrStringWithAttributes = self.attributedStringWithAttributes(attrString)
        
        let stringLength = CFAttributedStringGetLength(attrStringWithAttributes)
        
        // Create the framesetter with the attributed string.
        
        let framesetter = CTFramesetterCreateWithAttributedString(attrStringWithAttributes);
        
        let targetSize = CGSizeMake(CGFloat.max, CGFloat.max)
        
        return CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0, stringLength), nil, targetSize, nil)
    }
    
    func setAlignmentMode(alignmentMode : String)
    {
        var alignment: CTTextAlignment = OMTextLayer.CTTextAlignmentFromString(alignmentMode)
        let alignmentSetting = [CTParagraphStyleSetting(spec: .Alignment, valueSize: UInt(sizeofValue(alignment)), value: &alignment)]
        self.paragraphStyle = CTParagraphStyleCreate(alignmentSetting, UInt(alignmentSetting.count))
    }
    
    override init()
    {
        super.init()
        self.contentsScale = UIScreen.mainScreen().scale
        self.needsDisplayOnBoundsChange = true;
    }
    
    convenience init(string : String, alignmentMode:String = "center")
    {
        self.init()

        self.string = string
        
        setAlignmentMode(alignmentMode)
    }    

    override init!(layer: AnyObject!) {
        super.init(layer: layer)
        if let other = layer as? OMTextLayer {
            self.string = other.string
            self.fontRef = other.fontRef
            self.foregroundColor = other.foregroundColor
            self.paragraphStyle = other.paragraphStyle
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
    
    func setFont(fontName:String!, fontSize:CGFloat, matrix: UnsafePointer<CGAffineTransform> = nil) {
        
        assert(fontSize > 0,"Invalid font size (0)")
        assert(fontName.isEmpty == false ,"Invalid font name (empty)")
        
        if(fontSize > 0 && fontName != nil){
        
            self.fontRef = CTFontCreateWithName(fontName as CFStringRef, fontSize, matrix)
        }
    }
    
    override func drawInContext(context: CGContext!) {
        
        //DEBUG
        //println("--> drawInContext(\(self.string))")
        
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
        
        // Add the atributtes to the String
        
        let attrStringWithAttributes = self.stringWithAttributes(self.string!)
        
        // Create the framesetter with the attributed string.
        
        let framesetter = CTFramesetterCreateWithAttributedString(attrStringWithAttributes);
        
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
        if(self.bounds.isEmpty) {
            println("WARNING: empty layer.")
        }
    }
}
