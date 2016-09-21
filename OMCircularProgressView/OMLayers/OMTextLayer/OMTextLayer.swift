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
            self.fontStrokeColor = other.fontStrokeColor
            self.fontStrokeWidth = other.fontStrokeWidth
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


extension OMTextLayer
{
    func centreArcPerpendicular(text str: String, context: CGContext, radius r: CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, clockwise: Bool)
    {
        // *******************************************************
        // This draws the String str around an arc of radius r,
        // with the text centred at polar angle theta
        // *******************************************************
        
        let l = str.characters.count
        let attributes = [NSFontAttributeName: font]
        
        let characters: [String] = str.characters.map { String($0) } // An array of single character strings, each character in str
        var arcs: [CGFloat] = [] // This will be the arcs subtended by each character
        var totalArc: CGFloat = 0 // ... and the total arc subtended by the string
        
        // Calculate the arc subtended by each letter and their total
        for i in 0 ..< l {
            arcs += [chordToArc(characters[i].size(attributes: attributes).width, radius: r)]
            totalArc += arcs[i]
        }
        
        // Are we writing clockwise (right way up at 12 o'clock, upside down at 6 o'clock)
        // or anti-clockwise (right way up at 6 o'clock)?
        let direction: CGFloat = clockwise ? -1 : 1
        let slantCorrection = clockwise ? -CGFloat(M_PI_2) : CGFloat(M_PI_2)
        
        // The centre of the first character will then be at
        // thetaI = theta - totalArc / 2 + arcs[0] / 2
        // But we add the last term inside the loop
        
        //
        //In case you don't need the text to be centered, but start from the initial coordinate, change the line
        //var thetaI = theta - direction * totalArc / 2 
        //to var thetaI = theta;
        var thetaI = theta - direction * totalArc / 2
        
        for i in 0 ..< l {
            thetaI += direction * arcs[i] / 2
            // Call centerText with each character in turn.
            // Remember to add +/-90º to the slantAngle otherwise
            // the characters will "stack" round the arc rather than "text flow"
            centre(text: characters[i], context: context, radius: r, angle: thetaI, colour: c, font: font, slantAngle: thetaI + slantCorrection)
            // The centre of the next character will then be at
            // thetaI = thetaI + arcs[i] / 2 + arcs[i + 1] / 2
            // but again we leave the last term to the start of the next loop...
            thetaI += direction * arcs[i] / 2
        }
    }
    
    func chordToArc(_ chord: CGFloat, radius: CGFloat) -> CGFloat {
        // *******************************************************
        // Simple geometry
        // *******************************************************
        return 2 * asin(chord / (2 * radius))
    }
    
    func centre(text str: String, context: CGContext, radius r:CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, slantAngle: CGFloat) {
        // *******************************************************
        // This draws the String str centred at the position
        // specified by the polar coordinates (r, theta)
        // i.e. the x= r * cos(theta) y= r * sin(theta)
        // and rotated by the angle slantAngle
        // *******************************************************
        
        // Set the text attributes
        let attributes = [NSForegroundColorAttributeName: c,
                          NSFontAttributeName: font]
        // Save the context
        context.saveGState()
        // Undo the inversion of the Y-axis (or the text goes backwards!)
        context.scaleBy(x: 1, y: -1)
        // Move the origin to the centre of the text (negating the y-axis manually)
        context.translateBy(x: r * cos(theta), y: -(r * sin(theta)))
        // Rotate the coordinate system
        context.rotate(by: -slantAngle)
        // Calculate the width of the text
        let offset = str.size(attributes: attributes)
        // Move the origin by half the size of the text
        context.translateBy (x: -offset.width / 2, y: -offset.height / 2) // Move the origin to the centre of the text (negating the y-axis manually)
        // Draw the text
        str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        // Restore the context
        context.restoreGState()
    }
    
    // *******************************************************
    // Playground code to test
    // *******************************************************
    /*let size = CGSize(width: 256, height: 256)
    
    UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
    let context = UIGraphicsGetCurrentContext()!
    // *******************************************************************
    // Scale & translate the context to have 0,0
    // at the centre of the screen maths convention
    // Obviously change your origin to suit...
    // *******************************************************************
    context.translateBy (x: size.width / 2, y: size.height / 2)
    context.scaleBy (x: 1, y: -1)
    
    centreArcPerpendicular(text: "Hello round world", context: context, radius: 100, angle: 0, colour: UIColor.red(), font: UIFont.systemFont(ofSize: 16), clockwise: true)
    centreArcPerpendicular(text: "Anticlockwise", context: context, radius: 100, angle: CGFloat(-M_PI_2), colour: UIColor.red(), font: UIFont.systemFont(ofSize: 16), clockwise: false)
    centre(text: "Hello flat world", context: context, radius: 0, angle: 0 , colour: UIColor.yellow(), font: UIFont.systemFont(ofSize: 16), slantAngle: CGFloat(M_PI_4))
    
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()*/
    
}
