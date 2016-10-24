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
//  Versión 0.13 (22-9-2016)
//      Added code so that the text can follow an angle with a certain radius (Based on ArcTextView example by Apple)
//  Versión 0.14 (25-9-2016)
//      Added text to path helper function


#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

import CoreGraphics
import CoreText
import CoreFoundation

@objc class OMTextLayer : CALayer
{
    // MARK: properties
    
    fileprivate(set) var fontRef:CTFont = CTFontCreateWithName("Helvetica" as CFString, 12.0, nil);
    
    var angleLength : Double? {
        didSet {
            setNeedsDisplay()
        }
    }
    var radiusRatio : CGFloat = 0.0 {
        didSet {
            radiusRatio = clamp(radiusRatio, lower: 0, upper: 1.0)
            setNeedsDisplay()
        }
    }
    
    var underlineColor : UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var underlineStyle : CTUnderlineStyle = CTUnderlineStyle() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    //
    //  default 1: default ligatures, 0: no ligatures, 2: all ligatures
    //
    
    var fontLigature:NSNumber   = NSNumber(value: 1 as Int32) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var fontStrokeColor:UIColor = UIColor.lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var fontStrokeWidth:Float   = -3 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var string : String? = nil {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var foregroundColor:UIColor = UIColor.black {
        didSet {
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
        //self.rasterizationScale = UIScreen.main.scale
        self.drawsAsynchronously = true
        self.allowsGroupOpacity  = false
        
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
            
            let rect:CGRect = bounds
            
            if (radiusRatio == 0 && angleLength == nil) {
                
                // Create a path which bounds the area where you will be drawing text.
                // The path need not be rectangular.
                
                let path = CGMutablePath();
                
                // add the rect for the frame
                path.addRect(rect);
                
                // Add the atributtes to the String
                let attrStringWithAttributes = stringWithAttributes(string)
                
                // Create the framesetter with the attributed string.
                let framesetter = CTFramesetterCreateWithAttributedString(attrStringWithAttributes);
                
                // Create a frame.
                let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil);
                
                // Draw the specified frame in the given context.
                CTFrameDraw(frame, context);
                
                //  context.flush()
                
            } else {
                drawWithArc(context: context, rect:rect)
            }
            
            context.restoreGState()
            
        }
        
        super.draw(in: context)
    }
}

struct GlyphArcInfo {
    var width:CGFloat;
    var angle:CGFloat;  // in radians
};


extension OMTextLayer
{
    func createLine() -> CTLine?
    {
        if let string = string {
            return CTLineCreateWithAttributedString(self.stringWithAttributes(string))
        }
        return nil;
    }
    
    func getRunFont(_ run:CTRun) -> CTFont
    {
        let dict = CTRunGetAttributes(run) as NSDictionary
        let runFont: CTFont = dict.object(forKey: String(kCTFontAttributeName)) as! CTFont
        return runFont;
    }
    
    func createPathFromStringWithAttributes() -> UIBezierPath? {
        
        OMLog.printd("\(self.name ?? ""): createPathFromStringWithAttributes()")
        
        if let line = createLine() {
            
            let letters = CGMutablePath()
            
            let runArray = CTLineGetGlyphRuns(line) as NSArray
            
            let run: CTRun = runArray[0] as! CTRun
            
            let runFont: CTFont = getRunFont(run)
            
            let glyphCount = CTRunGetGlyphCount(run)
            
            for runGlyphIndex in 0 ..< glyphCount {
                
                let thisGlyphRange = CFRangeMake(runGlyphIndex, 1)
                var glyph = CGGlyph()
                var position = CGPoint.zero
                
                CTRunGetGlyphs(run, thisGlyphRange, &glyph)
                CTRunGetPositions(run, thisGlyphRange, &position)
                
                var affine = CGAffineTransform.identity
                let letter = CTFontCreatePathForGlyph(runFont, glyph, &affine)
                if let letter = letter {
                    let lettersAffine = CGAffineTransform(translationX: position.x, y: position.y)
                    letters.addPath(letter,transform:lettersAffine);
                }
            }
            
            let path = UIBezierPath()
            path.move(to: CGPoint.zero)
            path.append(UIBezierPath(cgPath: letters))
            return path
        }
        return nil;
    }
}

extension OMTextLayer {
    
    func prepareGlyphArcInfo(line:CTLine, glyphCount:CFIndex, angle:Double) -> [GlyphArcInfo] {
        assert(glyphCount > 0);
        
        let runArray = CTLineGetGlyphRuns(line) as Array
        
        var glyphArcInfo : [GlyphArcInfo] = []
        glyphArcInfo.reserveCapacity(glyphCount)
        
        // Examine each run in the line, updating glyphOffset to track how far along the run is in terms of glyphCount.
        var glyphOffset:CFIndex = 0;
        for run in runArray {
            let runGlyphCount = CTRunGetGlyphCount(run as! CTRun);
            
            // Ask for the width of each glyph in turn.
            for runGlyphIndex in 0 ..< runGlyphCount {
                let i = runGlyphIndex + glyphOffset
                let runGlyphRange       = CFRangeMake(runGlyphIndex, 1)
                let runTypographicWidth = CGFloat(CTRunGetTypographicBounds(run as! CTRun, runGlyphRange, nil, nil, nil))
                let newGlyphArcInfo     = GlyphArcInfo(width:runTypographicWidth,angle:0)
                
                glyphArcInfo.insert(newGlyphArcInfo, at:i)
            }
            
            glyphOffset += runGlyphCount;
        }
        
        let lineLength = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
        
        var info = glyphArcInfo.first!
        var prevHalfWidth:CGFloat = info.width / 2.0;
        
        info.angle = (prevHalfWidth / lineLength) * CGFloat(angleLength!)
        
        var angleArc = info.angle
        
        // Divide the arc into slices such that each one covers the distance from one glyph's center to the next.
        
        for lineGlyphIndex:CFIndex in 1 ..< glyphCount {
            
            let halfWidth = glyphArcInfo[lineGlyphIndex].width / 2.0;
            
            let prevCenterToCenter:CGFloat = prevHalfWidth + halfWidth;
            
            let glyphAngle = (prevCenterToCenter / lineLength) * CGFloat(angleLength!)
            
            angleArc += glyphAngle
            
            //OMLog.printd("\(self.name ?? ""): #\(lineGlyphIndex) angle : \(OMAngle.format(Double(glyphAngle))) arc length :\(OMAngle.format(Double(angleArc)))")
            
            glyphArcInfo[lineGlyphIndex].angle = glyphAngle
            
            prevHalfWidth = halfWidth
        }
        
        return  glyphArcInfo;
    }
    
    
    func drawWithArc(context:CGContext, rect:CGRect) {
        OMLog.printd("\(self.name ?? ""): drawWithArc(\(rect))")
        
        if let string = string, let angle = self.angleLength {
            
            let attributeString = self.stringWithAttributes(string)
            let line  = CTLineCreateWithAttributedString(attributeString)
            let glyphCount:CFIndex = CTLineGetGlyphCount(line);
            if glyphCount == 0 {
                OMLog.printw("\(self.name ?? ""): 0 glyphs \(attributeString))")
                return;
            }
            
            let glyphArcInfo = prepareGlyphArcInfo(line: line,glyphCount: glyphCount,angle: angle)
            if glyphArcInfo.count > 0 {
                
                // Move the origin from the lower left of the view nearer to its center.
                context.saveGState();
                context.translateBy(x: rect.midX, y: rect.midY)
                
                // Rotate the context 90 degrees counterclockwise.
                context.rotate(by: CGFloat(M_PI_2));
                
                // Now for the actual drawing. The angle offset for each glyph relative to the previous glyph has already been
                // calculated; with that information in hand, draw those glyphs overstruck and centered over one another, making sure
                // to rotate the context after each glyph so the glyphs are spread along a semicircular path.
                var textPosition = CGPoint(x:0.0,y: self.radiusRatio * minRadius(rect.size));
                
                context.textPosition = textPosition
                
                let runArray = CTLineGetGlyphRuns(line);
                let runCount = CFArrayGetCount(runArray);
                
                var glyphOffset:CFIndex = 0;
                
                for runIndex:CFIndex in 0 ..< runCount {
                    let run = (runArray as NSArray)[runIndex]
                    let runGlyphCount:CFIndex = CTRunGetGlyphCount(run as! CTRun);
                    
                    for runGlyphIndex:CFIndex in 0 ..< runGlyphCount {
                        
                        let glyphRange:CFRange = CFRangeMake(runGlyphIndex, 1);
                        
                        let angleRotation:CGFloat = -(glyphArcInfo[runGlyphIndex + glyphOffset].angle);
                        
                        //OMLog.printd("\(self.name ?? ""): run glyph#\(runGlyphIndex) angle rotation : \(OMAngle.format(Double(angleRotation)))");
                        
                        context.rotate(by: angleRotation);
                        
                        // Center this glyph by moving left by half its width.
                        
                        let glyphWidth:CGFloat = glyphArcInfo[runGlyphIndex + glyphOffset].width;
                        let halfGlyphWidth:CGFloat = glyphWidth / 2.0;
                        let positionForThisGlyph:CGPoint = CGPoint(x:textPosition.x - halfGlyphWidth, y:textPosition.y);
                        
                        // Glyphs are positioned relative to the text position for the line,
                        // so offset text position leftwards by this glyph's width in preparation for the next glyph.
                        
                        textPosition.x -= glyphWidth;
                        
                        var textMatrix = CTRunGetTextMatrix(run as! CTRun)
                        
                        textMatrix.tx = positionForThisGlyph.x;
                        textMatrix.ty = positionForThisGlyph.y;
                        
                        context.textMatrix = textMatrix;
                        
                        CTRunDraw(run as! CTRun, context, glyphRange);
                    }
                    glyphOffset += runGlyphCount;
                }
                context.restoreGState();
            }
        }
    }
}

