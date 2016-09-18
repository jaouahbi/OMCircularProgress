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
//  CALayer derived class that uses CoreText for draw a text.
//
//  Versión 0.1  (29-3-2015)
//      Creation.
//  Versión 0.11 (29-3-2015)
//      Replaced paragraphStyle by a array of CTParagraphStyleSetting.
//  Versión 0.11 (15-5-2015)
//      Added font ligature
//  Versión 0.12 (1-9-2016)
//      Added font underline
//  Versión 0.12 (6-9-2016)
//      Updated to swift 3.0


#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

import CoreGraphics
import CoreText
import CoreFoundation

public enum OMVerticalAlignment {
    case top
    case middle
    case bottom
}

@objc class OMTextLayer : CALayer
{
    // MARK: properties
    
    fileprivate(set) var fontRef:CTFont = CTFontCreateWithName("Helvetica" as CFString, 12.0, nil);
    
    var underlineColor : UIColor?
    {
        didSet{
            setNeedsDisplay()
        }
    }
    
    var underlineStyle : CTUnderlineStyle = CTUnderlineStyle()
    {
        didSet{
            setNeedsDisplay()
        }
    }
    
    //
    //  see 1: default ligatures, 0: no ligatures, 2: all ligatures
    //

    var verticalAlignment : OMVerticalAlignment = .middle
    {
        didSet{
            setNeedsDisplay()
        }
    }
    
    //
    //  default 1: default ligatures, 0: no ligatures, 2: all ligatures
    //
    
    var fontLigature:NSNumber   = NSNumber(value: 1 as Int32)
    {
        didSet{
            setNeedsDisplay()
        }
    }

    var fontStrokeColor:UIColor = UIColor.lightGray
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
    
    var foregroundColor:UIColor = UIColor.black {
        didSet{
            setNeedsDisplay()
        }
    }
    
    var fontBackgroundColor:UIColor = UIColor.clear {
        didSet{
            setNeedsDisplay()
        }
    }
    
    var lineBreakMode:CTLineBreakMode = .byCharWrapping {
        didSet{
            setNeedsDisplay()
        }
    }
    
    var alignment: CTTextAlignment = CTTextAlignment.center {
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
        
        self.contentsScale = UIScreen.main.scale
        self.needsDisplayOnBoundsChange = true;
        
        // https://github.com/danielamitay/iOS-App-Performance-Cheatsheet/blob/master/QuartzCore.md
        
        //self.shouldRasterize = true
        self.drawsAsynchronously = true
        self.allowsGroupOpacity  = false
        
        
        
    //   self.borderWidth = 2    ;
   //     self.borderColor = UIColor.red.cgColor
        
        
//        self.shouldRasterize = true
//        self.rasterizationScale = UIScreen.main.scale
        
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
    
    override init(layer: Any) {
        super.init(layer: layer)
        if let other = layer as? OMTextLayer {
            self.string = other.string
            self.fontRef = other.fontRef
            self.foregroundColor = other.foregroundColor
            self.fontBackgroundColor = other.fontBackgroundColor
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
    
    func stringWithAttributes(_ string : String) -> CFAttributedString {
        
        return attributedStringWithAttributes(NSAttributedString(string : string))
    }
    
    //
    // Add the attributes to the CFAttributedString
    //
    
    func attributedStringWithAttributes(_ attrString : CFAttributedString) -> CFAttributedString {
        
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
                                       foregroundColor.cgColor);
        
        if #available(iOS 10.0, *) {
            CFAttributedStringSetAttribute(newString,
                                           range,
                                           kCTBackgroundColorAttributeName,
                                           fontBackgroundColor.cgColor)
        } else {
            // Fallback on earlier versions
        };
        
    
        CFAttributedStringSetAttribute(newString,range,kCTFontAttributeName,fontRef)
        

        // TODO: add more CTParagraphStyleSetting
        // CTParagraph
        
        let setting = [CTParagraphStyleSetting(spec: .alignment, valueSize: MemoryLayout.size(ofValue: alignment), value: &alignment),
                       CTParagraphStyleSetting(spec: .lineBreakMode, valueSize: MemoryLayout.size(ofValue: lineBreakMode), value: &lineBreakMode)]
      
        CFAttributedStringSetAttribute(newString,
                                       range,
                                       kCTParagraphStyleAttributeName,
                                       CTParagraphStyleCreate(setting, setting.count))
        
        CFAttributedStringSetAttribute(newString,
                                       range,
                                       kCTStrokeWidthAttributeName,
                                       NSNumber(value: fontStrokeWidth as Float))
        
        CFAttributedStringSetAttribute(newString,
                                       range,
                                       kCTStrokeColorAttributeName,
                                       fontStrokeColor.cgColor)
        
        CFAttributedStringSetAttribute(newString,
                                       range,
                                       kCTLigatureAttributeName,
                                       fontLigature)
        
        CFAttributedStringSetAttribute(newString,
                                       range,
                                       kCTUnderlineStyleAttributeName,
                                       NSNumber(value: underlineStyle.rawValue as Int32));
        
        if let underlineColor = underlineColor {
            CFAttributedStringSetAttribute(newString,
                                           range,
                                           kCTUnderlineColorAttributeName,
                                           underlineColor.cgColor);
        }

        // TODO: Add more attributes
        
        return newString!
    }
    
    
    //
    // Calculate the frame size of a String
    //
    
    func frameSize() -> CGSize {
        
        return frameSizeLengthFromAttributedString(NSAttributedString(string : self.string!))
    }
    
    func frameSizeLengthFromAttributedString(_ attrString : NSAttributedString) -> CGSize {
        
        let attrStringWithAttributes = attributedStringWithAttributes(attrString)
        
        let stringLength = CFAttributedStringGetLength(attrStringWithAttributes)
        
        // Create the framesetter with the attributed string.
        
        let framesetter = CTFramesetterCreateWithAttributedString(attrStringWithAttributes);
        
        let targetSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        
        let frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0, stringLength), nil, targetSize, nil)
        
        return frameSize;
    }
    
    func setAlignmentMode(_ alignmentMode : String)
    {
        switch (alignmentMode)
        {
        case "center":
            alignment = CTTextAlignment.center
        case "left":
            alignment = CTTextAlignment.left
        case "right":
            alignment = CTTextAlignment.right
        case "justified":
            alignment = CTTextAlignment.justified
        case "natural":
            alignment = CTTextAlignment.natural
        default:
            alignment = CTTextAlignment.left
        }
    }

    fileprivate func setFont(_ fontName:String!, fontSize:CGFloat, matrix: UnsafePointer<CGAffineTransform>? = nil) {
        
        assert(fontSize > 0,"Invalid font size (fontSize ≤ 0)")
        assert(fontName.isEmpty == false ,"Invalid font name (empty)")
        
        if(fontSize > 0 && fontName != nil) {
            fontRef = CTFontCreateWithName(fontName as CFString, fontSize, matrix)
        }
    }
    

    fileprivate func setFont(_ font:UIFont, matrix: UnsafePointer<CGAffineTransform>? = nil) {
        setFont(font.fontName, fontSize: font.pointSize, matrix: matrix)
    }
    
    // MARK: overrides
    
    override func draw(in context: CGContext) {
        
        if let string = self.string {
            
            context.saveGState();
            
            // Set the text matrix.
            context.textMatrix = CGAffineTransform.identity;
            
            // Core Text Coordinate System and Core Graphics are OSX style
            #if os(iOS)
                context.translateBy(x: 0, y: self.bounds.size.height);
                context.scaleBy(x: 1.0, y: -1.0);
            #endif
            
            // Add the atributtes to the String
            let attrStringWithAttributes = stringWithAttributes(string)
            
            // Create a path which bounds the area where you will be drawing text.
            // The path need not be rectangular.
            var rect:CGRect = bounds
            let path = CGMutablePath();
           
            /*// Calculate the rect
            if (self.verticalAlignment == .middle) {
                // Draw normally (top)
            } else if (self.verticalAlignment == .top) {
                let boundingBox = CTFontGetBoundingBox(fontRef);
                //Get the position on the y axis (middle)
                var midHeight = bounds.size.height * 0.5;
                midHeight -= boundingBox.size.height  * 0.5;
                rect  = CGRect(x:0, y:midHeight, width:bounds.size.width, height:boundingBox.size.height)
            } else if (self.verticalAlignment == .bottom) {
                let boundingBox = CTFontGetBoundingBox(fontRef);
                rect  = CGRect(x:0, y:bounds.size.height-boundingBox.size.height, width:bounds.size.width, height:boundingBox.size.height)
            } else {
                assertionFailure();
                // Draw normally (top)
            }*/

            // add the rect for the frame
            path.addRect(rect);
            
            // Create the framesetter with the attributed string.
            let framesetter = CTFramesetterCreateWithAttributedString(attrStringWithAttributes);
            
            // Create a frame.
            let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil);
            
            // Draw the specified frame in the given context.
            CTFrameDraw(frame, context);

//            context.flush()
            
            context.restoreGState()
    
        }
        
        
        super.draw(in: context)
        
        /*
        let imgRef = context.makeImage();
        
        let img = UIImage(cgImage:imgRef!);
        
        print("\(img)");
        */
        
    }
}
