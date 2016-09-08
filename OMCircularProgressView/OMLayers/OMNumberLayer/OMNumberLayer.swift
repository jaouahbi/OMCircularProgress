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
// Name of the animatable properties
//

private struct OMNumberLayerProperties {
    static var Number = "number"
}

//
// CALayer object
//

@objc class OMNumberLayer : OMTextLayer
{
    // MARK: properties
    
    var number: NSNumber = 0.0 {
        didSet{
            setNeedsDisplay()
        }
    }
    
    var formatStyle: CFNumberFormatterStyle = CFNumberFormatterStyle.noStyle {
        didSet{
            setNeedsDisplay()
        }
    }
    
    // MARK: constructors
    
    override init(){
        super.init()
    }
    
    convenience init( number : NSNumber ,
                      formatStyle: CFNumberFormatterStyle = CFNumberFormatterStyle.noStyle,
                      alignmentMode:String = "center")
    {
        self.init()
        self.number = number
        self.formatStyle = formatStyle
        
        setAlignmentMode(alignmentMode)
    }
    
    override init(layer: Any) {
        super.init(layer: layer as AnyObject)
        if let other = layer as? OMNumberLayer {
            self.formatStyle =  other.formatStyle
            self.number = other.number
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    /**
     Calculate the frame size of the NSNumber to represent.
     
     :note: the max. percent representation is 1
     
     - parameter number: the number
     
     - returns: return the frame size needed for represent the string
     */
    func frameSizeLengthFromNumber(_ number:NSNumber) -> CGSize {
        return frameSizeLengthFromAttributedString(NSAttributedString(string : number.format(self.formatStyle)))
    }
    
    func animateNumber(_ fromValue:Double,toValue:Double,beginTime:TimeInterval,duration:TimeInterval,delegate:AnyObject?) {
        self.animateKeyPath(OMNumberLayerProperties.Number,
                            fromValue:fromValue as AnyObject?,
                            toValue:toValue as AnyObject?,
                            beginTime:beginTime,
                            duration:duration,
                            delegate:delegate)
    }
    
    // MARK: overrides
    
    override class func needsDisplay(forKey event: String) -> Bool {
        if (event == OMNumberLayerProperties.Number) {
            return true
        }
        return super.needsDisplay(forKey: event)
    }
    
    override func action(forKey event: String) -> CAAction? {
        if (event == OMNumberLayerProperties.Number) {
            return animationActionForKey(event);
        }
        return super.action(forKey: event)
    }
    
    override func draw(in context: CGContext) {
        
        var theNumber:NSNumber? = self.number
        
        let presentation = self.presentation()
        
        if presentation != nil {
            theNumber = presentation!.number
        }
        
        if(theNumber == nil){
            return
        }
        
        let model = self.model() 
        
        model.string = self.number.format(self.formatStyle)
        
        // The base class do the work
        
        super.draw(in: context)
    }
}
