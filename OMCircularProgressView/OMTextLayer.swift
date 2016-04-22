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
//  OMTextLayer.swift
//
//  Created by Jorge Ouahbi on 23/3/15.
//
//  Description:
//  Simple derived CALayer class that uses CoreText for draw a text.
//
//  Versión 0.1  (29-3-2015)
//      Creation.
//  Versión 0.11 (29-3-2015)
//      Replaced paragraphStyle by a array of CTParagraphStyleSetting.
//  Versión 0.11 (15-5-2015)
//      Added font ligature


#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

import CoreText
import CoreFoundation


@objc class OMTextLayer : OMLayer
{
    // MARK: properties
    
    // private(set) var paragraphStyle:CTParagraphStyle?
    
    private(set) var fontRef:CTFontRef = CTFontCreateWithName("Helvetica" as CFStringRef, 12.0, nil);
    
    //
    // containing integer, default 1: default ligatures, 0: no ligatures, 2: all ligatures
    //
    
    var fontLigature:NSNumber = NSNumber(int: 1)
    var fontStrokeColor:UIColor = UIColor.lightGrayColor()
    var fontStrokeWidth:Float   = -3
    
    var paragraphStyleSettings:[CTParagraphStyleSetting] = [CTParagraphStyleSetting]()
    
    var string : String? = nil {
        didSet{
            setNeedsDisplay()
        }
    }
    
    var foregroundColor:UIColor = UIColor.blackColor() {
        didSet{
            setNeedsDisplay()
        }
    }
    
    // MARK: constructors
    
    override init() {
        super.init()
    }
    
    convenience init(string : String, alignmentMode:String = "center") {
        
        self.init()
        self.string = string
        setAlignmentMode(alignmentMode)
        setLineBreakMode(.ByCharWrapping)
    }
    
    override init(layer: AnyObject) {
        
        super.init(layer: layer)
        if let other = layer as? OMTextLayer {
            
            self.string = other.string
            self.fontRef = other.fontRef
            self.foregroundColor = other.foregroundColor
            self.paragraphStyleSettings = other.paragraphStyleSettings
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder:aDecoder)
    }
    
    func stringWithAttributes(string : String) -> CFAttributedStringRef {
        
        return attributedStringWithAttributes(NSAttributedString(string : string))
    }
    
    func attributedStringWithAttributes(attrString : CFAttributedStringRef) -> CFAttributedStringRef{
        
        let stringLength = CFAttributedStringGetLength(attrString)
        
        let range = CFRangeMake(0, stringLength)
        
        //
        // Create a mutable attributed string with a max length of 0.
        // The max length is a hint as to how much internal storage to reserve. 
        // 0 means no hint.
        //
        
        let newString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        
        // Copy the textString into the newly created attrString
        
        CFAttributedStringReplaceString (newString, CFRangeMake(0,0), CFAttributedStringGetString(attrString));

        CFAttributedStringSetAttribute(newString,
            range,
            kCTForegroundColorAttributeName,
            foregroundColor.CGColor);
        
        CFAttributedStringSetAttribute(newString,range,kCTFontAttributeName,fontRef)
        
       // paragraphStyle  = CTParagraphStyleCreate(paragraphStyleSettings, paragraphStyleSettings.count)
        
        CFAttributedStringSetAttribute(newString,
            range,
            kCTParagraphStyleAttributeName,
            CTParagraphStyleCreate(paragraphStyleSettings, paragraphStyleSettings.count))
        
        CFAttributedStringSetAttribute(newString,
                   range,
                   kCTStrokeWidthAttributeName,
                   NSNumber(float: fontStrokeWidth))
        
        CFAttributedStringSetAttribute(newString,
                  range,
                   kCTStrokeColorAttributeName,
                   fontStrokeColor.CGColor)
        
        CFAttributedStringSetAttribute(newString,
            range,
            kCTLigatureAttributeName,
            fontLigature)
        
        //TODO:
        //kCTUnderlineStyleAttributeName
        //kCTUnderlineColorAttributeName
        //kCTSuperscriptAttributeName
        
        return newString
    }

    
    //
    // Calculate the frame size of a String
    //
    
    func frameSize() -> CGSize {
        
        return frameSizeLengthFromAttributedString(NSAttributedString(string : self.string!))
    }
    
    func frameSizeLengthFromAttributedString(attrString : NSAttributedString) -> CGSize {
        
        let attrStringWithAttributes = attributedStringWithAttributes(attrString)
        
        let stringLength = CFAttributedStringGetLength(attrStringWithAttributes)
        
        // Create the framesetter with the attributed string.
        
        let framesetter = CTFramesetterCreateWithAttributedString(attrStringWithAttributes);
        
        let targetSize = CGSizeMake(CGFloat.max, CGFloat.max)
        
        let frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0, stringLength), nil, targetSize, nil)
        
        return frameSize;
    }
    
    func setLineBreakMode(lineBreakModeInput : CTLineBreakMode)
    {
        var lineBreakMode = lineBreakModeInput
        
        let lineBreakSetting = CTParagraphStyleSetting(spec: .LineBreakMode, valueSize: sizeofValue(lineBreakMode), value:
            &lineBreakMode)
        
        paragraphStyleSettings.insert(lineBreakSetting,atIndex: 1);
    }
    
    func setAlignmentMode(alignmentMode : String)
    {
        var alignment: CTTextAlignment
        
        switch (alignmentMode)
        {
            case "center":
                alignment = CTTextAlignment.Center
            case "left":
                alignment = CTTextAlignment.Left
            case "right":
                alignment = CTTextAlignment.Right
            case "justified":
                alignment = CTTextAlignment.Justified
            case "natural":
                alignment = CTTextAlignment.Natural
            default:
                alignment = CTTextAlignment.Left
        }
        
        let alignmentSetting = CTParagraphStyleSetting(spec: .Alignment, valueSize: sizeofValue(alignment), value: &alignment)
        
        paragraphStyleSettings.insert(alignmentSetting,atIndex: 0)
    }

    
    func setFont(fontName:String!, fontSize:CGFloat, matrix: UnsafePointer<CGAffineTransform> = nil) {
        
        assert(fontSize > 0,"Invalid font size (fontSize ≤ 0)")
        assert(fontName.isEmpty == false ,"Invalid font name (empty)")
        
        if(fontSize > 0 && fontName != nil){
        
            fontRef = CTFontCreateWithName(fontName as CFStringRef, fontSize, matrix)
        }
    }
    
    // MARK: overrides
    
    override func drawInContext(context: CGContext) {
        
        super.drawInContext(context)
    
        if let string = self.string {
            
            CGContextSaveGState(context);
            
            // Set the text matrix.
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            
            // Core Text Coordinate System and Core Graphics are OSX style
            
            self.flipContextIfNeed(context)
            
            // Add the atributtes to the String
            
            let attrStringWithAttributes = stringWithAttributes(string)
            
            // Create a path which bounds the area where you will be drawing text.
            // The path need not be rectangular.
            
            let path = CGPathCreateMutable();
            
            CGPathAddRect(path, nil, bounds);
            
            // Create the framesetter with the attributed string.
            
            let framesetter = CTFramesetterCreateWithAttributedString(attrStringWithAttributes);
            
            // Create a frame.
            
            let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil);
            
            // Draw the specified frame in the given context.
            
            CTFrameDraw(frame, context);
            
            
            CGContextRestoreGState(context);
        }
    }
}
