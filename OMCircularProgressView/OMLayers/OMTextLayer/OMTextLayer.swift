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

public enum OMVerticalAlignment {
    case Top
    case Middle
    case Bottom
}


@objc class OMTextLayer : OMLayer
{
    // MARK: properties
    
    private(set) var fontRef:CTFontRef = CTFontCreateWithName("Helvetica" as CFStringRef, 12.0, nil);
    
    var underlineColor : UIColor?
    {
        didSet{
            setNeedsDisplay()
        }
    }
    
    var underlineStyle : CTUnderlineStyle = .None
    {
        didSet{
            setNeedsDisplay()
        }
    }
    
    //
    //  see 1: default ligatures, 0: no ligatures, 2: all ligatures
    //

    var verticalAlignment : OMVerticalAlignment = .Middle
    {
        didSet{
            setNeedsDisplay()
        }
    }
    
    //
    //  default 1: default ligatures, 0: no ligatures, 2: all ligatures
    //
    
    var fontLigature:NSNumber   = NSNumber(int: 1)
    {
        didSet{
            setNeedsDisplay()
        }
    }

    var fontStrokeColor:UIColor = UIColor.lightGrayColor()
    {
        didSet{
            setNeedsDisplay()
        }
    }

    var fontStrokeWidth:Float   = -3
        {
        didSet{
            setNeedsDisplay()
        }
    }
    
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
    
    var lineBreakMode:CTLineBreakMode = .ByCharWrapping {
        didSet{
            setNeedsDisplay()
        }
    }
    
    var alignment: CTTextAlignment = CTTextAlignment.Center {
        didSet{
            setNeedsDisplay()
        }
    }
    
    var font: UIFont? = nil {
        didSet{
            if let font = font {
                setFont(font, matrix: nil)
            }
            setNeedsDisplay()
        }
    }
    
    
    // MARK: constructors
    
    override init() {
        super.init()
        
    }
    
    convenience init(string : String, alignmentMode:String = "center") {
        self.init()
        setAlignmentMode(alignmentMode)
        self.string = string
    }
    
    
    convenience init(string : String, font:UIFont ,alignmentMode:String = "center") {
        self.init()
        setAlignmentMode(alignmentMode)
        self.string = string
        setFont(font, matrix: nil)
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
        if let other = layer as? OMTextLayer {
            self.string = other.string
            self.fontRef = other.fontRef
            self.foregroundColor = other.foregroundColor
            self.lineBreakMode = other.lineBreakMode
            self.alignment = other.alignment
            self.underlineColor = other.underlineColor
            self.underlineStyle = other.underlineStyle
            self.verticalAlignment = other.verticalAlignment
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    // MARK: private helpers
    
    //
    // Add attributes to the String
    //
    
    func stringWithAttributes(string : String) -> CFAttributedStringRef {
        
        return attributedStringWithAttributes(NSAttributedString(string : string))
    }
    
    //
    // Add the attributes to the CFAttributedString
    //
    
    func attributedStringWithAttributes(attrString : CFAttributedStringRef) -> CFAttributedStringRef {
        
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
        

        // TODO: add more CTParagraphStyleSetting
        // CTParagraph
        
        let setting = [CTParagraphStyleSetting(spec: .Alignment, valueSize: sizeofValue(alignment), value: &alignment),
                       CTParagraphStyleSetting(spec: .LineBreakMode, valueSize: sizeofValue(lineBreakMode), value: &lineBreakMode)]
      
        CFAttributedStringSetAttribute(newString,
                                       range,
                                       kCTParagraphStyleAttributeName,
                                       CTParagraphStyleCreate(setting, setting.count))
        
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
        
        CFAttributedStringSetAttribute(newString,
                                       range,
                                       kCTUnderlineStyleAttributeName,
                                       NSNumber(int:underlineStyle.rawValue));
        
        if let underlineColor = underlineColor {
            CFAttributedStringSetAttribute(newString,
                                           range,
                                           kCTUnderlineColorAttributeName,
                                           underlineColor.CGColor);
        }

        // TODO: Add more attributes
        
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
    
    func setAlignmentMode(alignmentMode : String)
    {
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
    }

    private func setFont(fontName:String!, fontSize:CGFloat, matrix: UnsafePointer<CGAffineTransform> = nil) {
        
        assert(fontSize > 0,"Invalid font size (fontSize ≤ 0)")
        assert(fontName.isEmpty == false ,"Invalid font name (empty)")
        
        if(fontSize > 0 && fontName != nil) {
            fontRef = CTFontCreateWithName(fontName as CFStringRef, fontSize, matrix)
        }
    }
    

    private func setFont(font:UIFont, matrix: UnsafePointer<CGAffineTransform> = nil) {
        setFont(font.fontName, fontSize: font.pointSize, matrix: matrix)
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
            
            if ( self.verticalAlignment == .Top) {
                CGPathAddRect(path, nil, bounds); // Draw normally (top)
            } else if (self.verticalAlignment == .Middle) {
                let boundingBox = CTFontGetBoundingBox(fontRef);
                
                //Get the position on the y axis (middle)
                var midHeight = bounds.size.height * 0.5;
                midHeight -= boundingBox.size.height  * 0.5;
                
                CGPathAddRect(path, nil, CGRectMake(0, midHeight, bounds.size.width, boundingBox.size.height));
            } else if (self.verticalAlignment == .Bottom) {
                let boundingBox = CTFontGetBoundingBox(fontRef);
                
                CGPathAddRect(path, nil, CGRectMake(0, 0, bounds.size.width, boundingBox.size.height));
            } else {
                assertionFailure();
                CGPathAddRect(path, nil, bounds); // Draw normally (top)
            }
        
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
