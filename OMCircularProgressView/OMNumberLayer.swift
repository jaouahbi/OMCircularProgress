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
//  Version: 0.0.1 : (7-5-2015) 
//  Added the NSNumber extension.
//


#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

import CoreText
import CoreFoundation


//
//  NSNumber extension.
//

extension NSNumber {
    func format(formatStyle:CFNumberFormatterStyle) -> String! {
        let fmt = CFNumberFormatterCreate(nil, CFLocaleCopyCurrent(),formatStyle)
        return CFNumberFormatterCreateStringWithNumber(nil,fmt,self)  as String
    }
}

//
// Name of the animatable properties
//

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
    
    //
    // Calculate the frame size of the NSNumber to represent.
    //
    // NOTE: the max. percent representation is 1
    //
    
    func frameSizeLengthFromNumber(number:NSNumber) -> CGSize {
        return frameSizeLengthFromString(number.format(self.formatStyle))
    }

    
    func animateNumber(fromValue:Double,toValue:Double,beginTime:NSTimeInterval,duration:NSTimeInterval,delegate:AnyObject?)
    {        
        self.animateKeyPath(OMNumberLayerProperties.Number,
            fromValue:fromValue,
            toValue:toValue,
            beginTime:beginTime,
            duration:duration,
            delegate:delegate)
    }
    
    // MARK: overrides
    
    override class func needsDisplayForKey(event: String!) -> Bool {
        if (event == OMNumberLayerProperties.Number) {
            return true
        }
        return super.needsDisplayForKey(event)
    }
    
    override func actionForKey(event: String!) -> CAAction! {
        if (event == OMNumberLayerProperties.Number) {
            return animationActionForKey(event);
        }
        return super.actionForKey(event)
    }
    
    override func drawInContext(context: CGContext!) {
        
        super.drawInContext(context)
        
        if let presentationLayer: AnyObject = self.presentationLayer() {
            self.number = presentationLayer.number
        }

        self.string = self.number.format(self.formatStyle)
        
        // The base class do the work
        
        super.drawInContext(context)
    }
}
