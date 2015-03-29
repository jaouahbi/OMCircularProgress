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
//  Created by Jorge Ouahbi on 27/2/15.
//
//  Description:
//  Simple derived OMTextLayer class that support animation of a number.
//


#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

import CoreText
import CoreFoundation


/*

NSRange decimalPart = [text rangeOfString:@"%"];

if ((decimalPart.location != NSNotFound) ) 
{
    UIFont *decimalFont = [label.font fontWithSize:label.font.pointSize / 1.6];

    [title addAttribute:NSFontAttributeName value:decimalFont range:decimalPart];

    [title addAttribute:(id)kCTSuperscriptAttributeName value:@"1" range:decimalPart];

}

*/

private struct OMNumberLayerProperties {
    static var Number = "number"
}

class OMNumberLayer : OMTextLayer
{
    // MARK: properties
    
    var number: NSNumber = 0.0 {
        didSet{
            setNeedsDisplay()
        }
    }
    
    var formatStyle: CFNumberFormatterStyle = CFNumberFormatterStyle.NoStyle {
        didSet{
            setNeedsDisplay()
        }
    }
    
    // MARK: constructors
    
    override init(){
        super.init()
    }
    
    convenience init( number : NSNumber ,
        formatStyle: CFNumberFormatterStyle = CFNumberFormatterStyle.NoStyle,
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
        super.init(coder:aDecoder)
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
        let fmt = CFNumberFormatterCreate(nil, CFLocaleCopyCurrent(),formatStyle)
        
        return CFNumberFormatterCreateStringWithNumber(nil,fmt,number)  as String
    }
    
    func animateNumber(fromValue:Double,toValue:Double,beginTime:NSTimeInterval,duration:NSTimeInterval, delegate:AnyObject?)
    {        
        self.animateKeyPath(OMNumberLayerProperties.Number,
            fromValue:fromValue,
            toValue:toValue,
            beginTime:beginTime,
            duration:duration,
            delegate:delegate)
    }
    
    // MARK: overrides
    
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

        self.string = self.toString(self.number, formatStyle: self.formatStyle)
        
        //DEBUG
        //println("--> drawInContext(\(self.string))")
        
        // the base class do the work
        
        super.drawInContext(context)
    }
}
