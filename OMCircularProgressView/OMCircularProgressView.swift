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
//  OMCircularProgressView.swift
//
//  Created by Jorge Ouahbi on 19/1/15.
//
//
//  0.1 (29-3-2015)
//      Dynamic calculation of the maximun size of the images.
//      Image and text orientation to angle option
//      Change center numerical text layer to CFNumberFormatterStyle.NoStyle style by default
//
//      (31-03-2015)
//      Renamed component
//      Remove the use of UIView.center because some times got bad values.
//      Added angle align to step text and image

//  0.1.1 (14-04-2015)
//      Individual gradient for each progress step. For example:
//      now its posible to set the step one to axial gradient and the step two to radial gradient, and so...
//      Font settings added for each progress step.
//      The layers are created only one time. The next layer layouts only are reconfigured if needed

//  0.1.2 (10-05-2015)
//      Remove the gradients.
//      Added the layerMask.
//      Added the setter for the radius.


#if os(iOS)
    import UIKit
    #elseif os(OSX)
    import AppKit
#endif


//DEBUG

let DEBUG_LAYERS =  false      // very usefull
let DEBUG_GRADIENT = false
let DEBUG_STEPS = false
let NO_GRADIENT = false
let NO_WELL = false
let NO_TEXT = false
let NO_IMAGES = false
let ANIMATE_GRADIENT = false
let DEBUG_ANIMATIONS = false

/// Tag the steps
let DEBUG_SET_STEP_ID = true
var GLOBAL_INDEX:Int = 0


// MARK: - Extensions


/**
*  GPoint Extension
*
*/

extension CGPoint
{
    public func center(size:CGSize) -> CGPoint {
        return CGPoint(x:self.x - size.width  * 0.5, y:self.y - size.height * 0.5);
    }
    
    public func centerRect(size:CGSize) -> CGRect{
        return CGRect(origin: self.center(size), size:size)
    }
}

/**
*  CGSize Extension
*
*/

extension CGSize
{
    func min() -> CGFloat {
        return Swift.min(height,width);
    }
    
    func max() -> CGFloat {
        return Swift.max(height,width);
    }
    
    func max(other : CGSize) -> CGSize {
        return self.max() >= other.max()  ? self : other;
    }
    
    func hypot() -> CGFloat {
        return CoreGraphics.hypot(height,width)
    }
    
    func center() -> CGPoint {
        return CGPoint(x:width * 0.5,y:height * 0.5)
    }
}


/**
*  Double Extension for conversion from/to degrees/radians
*
*/

public extension Double {
    
    func degreesToRadians () -> Double {
        return self * 0.01745329252
    }
    func radiansToDegrees () -> Double {
        return self * 57.29577951
    }
    
    func clamp0(max:Double) -> Double {
       return min(fabs(self),max)
    }
}


/**
*  UIColor Extension that generate next UIColor
*
*/

extension UIColor : GeneratorType
{
    var alpha : CGFloat {
        return CGColorGetAlpha(self.CGColor)
    }
    
    var hue: CGFloat {
        
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        
        if ( getHue(&hue, saturation:&saturation, brightness:&brightness, alpha:&alpha)) {
            return hue
        }
        
        return 1.0;
    }
    
    
    var saturation: CGFloat {
        
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        
        if ( getHue(&hue, saturation:&saturation, brightness:&brightness, alpha:&alpha)) {
            return saturation
        }
        
        return 1.0;
    }
    
    var brightness: CGFloat {
        
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        
        if ( getHue(&hue, saturation:&saturation, brightness:&brightness, alpha:&alpha)) {
            return brightness
        }
        
        return 1.0;
    }
    
    // Required to adopt `GeneratorType`
    
    typealias Element = UIColor
    
    // Required to adopt `GeneratorType`
    
    public func next() -> UIColor?
    {
        let increment = 360.0 / 7
        
        let hue = (Double(self.hue) * 360.0)
        
        // make it circular
        
        let degrees =  (hue + increment) % 360.0
        
        return UIColor(hue: CGFloat(1.0 * degrees / 360.0),
            saturation: saturation,
            brightness: brightness,
            alpha: alpha)
    }
}




let OMCompleteProgress:Double = Double.infinity
let OMWellProgressDefaultColor:UIColor = UIColor(white: 0.9, alpha: 1.0)
let OMProgressDefaultShadowColor:UIColor = UIColor.darkGrayColor()


// MARK: - Types


/// The styles permitted for the progress bar.
/// NOTE:  You can set and retrieve the current style of progress view through the progressViewStyle property.

public enum OMCircularProgressViewStyle : Int
{
    case DirectProgress
    case SequentialProgress
    
    init()
    {
        self = SequentialProgress
    }
}

/**
*  Elements alignment
*
*/

enum OMAlign : Int
{
    case AlignCenter
    case AlignMid
    case AlignBorder
    case AlignOuter
    init() {
        self = AlignMid
    }
}

/**
* Angles alignment
*
*/

enum OMAngleAlign: Int
{
    case AngleStart
    case AngleMid
    case AngleEnd
    init() {
        self = AngleMid
    }
}


/**
*  Object that encapsulate the angles
*
*/


class OMAngle : NSObject, DebugPrintable, Printable
{
    var start:Double = 0.0                // start of angle in radians
    var end:Double   = 0.0                // end of angle in radians
    
    convenience init(startAngle:Double,endAngle:Double){
        self.init()
        start = startAngle
        end = endAngle;
    }
    
    // middle of the angle
    func mid() -> Double {
        return start + (length() * 0.5)
    }
    
    // angle length in radians
    func length() -> Double {
        return end - start
    }
    
    override var debugDescription : String {
        let sizeOfAngle = round(length().radiansToDegrees())
        let degreeS     = round(start.radiansToDegrees());
        let degreeE     = round(end.radiansToDegrees());
        return "[\(degreeS)° - \(degreeE)°] : \(sizeOfAngle)°"
    }
    
    override var description: String {
        return debugDescription;
    }
}

/**
*  Object that represent each step element data.
*
*/

class OMStepData : NSObject, DebugPrintable, Printable
{
    /// Basic
    
    var angle:OMAngle!                              // step angle
    var color:UIColor!                              // step color
    var shapeLayer:CAShapeLayer! = CAShapeLayer()   // progress shape
    
    
    var progress:Double {
        
        set{
            shapeLayer.strokeEnd = CGFloat(progress)
        }
        get{
            return Double(shapeLayer.strokeEnd)
        }
    }
    
    var maskLayer:CALayer?          // optional layer mask

    /// Well layer.
    
    var wellLayer:CAShapeLayer?                 //
    var wellColor:UIColor?  = OMWellProgressDefaultColor
    
    
    /// Text
    
    var text:String?                                // optional step text
    var textLayer:OMTextLayer?                      // layer for the text
    var textAlign:OMAlign = .AlignMid               // text align
    var textOrientationToAngle  : Bool = true       // is text oriented to the step angle
    var textAngleAlign : OMAngleAlign = .AngleMid
    
    /// Font
    
    var fontName : String = "Helvetica";
    var fontColor : UIColor = UIColor.blackColor()
    var fontSize : CGFloat = 9
    var fontBackgroundColor : UIColor = UIColor.clearColor()
    var fontStrokeWidth : Float = 0
    var fontStrokeColor : UIColor = UIColor.clearColor()
    
    //
    // Step image
    //
    
    var imageShadow : Bool = true
    var image : UIImage?                                 // optional image
    private var imageScaled:UIImage?
    var imageLayer:OMProgressImageLayer?                 // optional image layer
    var imageAlign : OMAlign = .AlignBorder
    var imageOrientationToAngle  : Bool = true
    var imageAngleAlign : OMAngleAlign = .AngleStart
    var separatorAngleHalf:Double = 0.0                 // angle of arclength of image hypotenuse in radians
    
    
    //DEBUG
    var index:Int = 0
    
    required convenience init(startAngle:Double,percent:Double,color:UIColor!){
        self.init(startAngle:startAngle,
            endAngle: startAngle + (2.0 * M_PI * percent),
            color:color)
    }
    
    init(startAngle:Double,endAngle:Double,color:UIColor!){
        angle = OMAngle(startAngle:startAngle, endAngle:endAngle)
        self.color = color
        
        //DEBUG
        if( NO_WELL  == true){
            wellColor = nil
        }
        
        //DEBUG
        if(DEBUG_SET_STEP_ID){
            index = GLOBAL_INDEX++
        }
    }
    
    override var debugDescription : String {
        
        let degreeAngle = round(separatorAngleHalf.radiansToDegrees());
        let gradientString:String = ( self.maskLayer != nil) ? "mask" :""
        
        let wellString      = (wellColor != nil) ? "+well" : ""
        let imageString     = (image != nil) ? "+image" : ""
        let textString     = (text != nil) ? "+text" : ""
        
        let sepString =  "\(degreeAngle)°"
        
        return "\(angle) sep: \(sepString) prop:(\(gradientString)\(wellString)\(imageString)\(textString))"
    }
    
    override var description: String {
        return debugDescription;
    }
}



//
//
// The UIView object
//
//

class OMCircularProgressView: UIView, DebugPrintable, Printable {
    
    /// Private
    
    private var dataSteps: NSMutableArray = []     // Array of OMStepData
    private var imageLayer:OMProgressImageLayer?   // center image layer
    private var numberLayer:OMNumberLayer?         // center number layer
    
    // Private vars for animations
    
    private var beginTime: NSTimeInterval    = 0;
    private var newBeginTime: NSTimeInterval = 0;
    
    /// Public
    
    // Animation
    
    var animation : Bool = true;
    var animationDuration : NSTimeInterval = 1.0
    
    /// Component behavior
    
    var progressViewStyle:OMCircularProgressViewStyle = .SequentialProgress
    
    var numberOfSteps : UInt {
        return UInt(dataSteps.count);
    }
    
    // The start angle of the all steps.
    // default -90 degrees == 12 o'clock
    
    var startAngle : Double = -90.degreesToRadians() {
        didSet{
            setNeedsLayout()
        }
    }
    
    var stepSeparator:Bool = true {
        didSet{
            setNeedsLayout()
        }
    }
    
    var separatorRatio: Double = 0 {
        didSet{
            setNeedsLayout()
        }
    }
    
    var separatorFixed: Double = 1.0.degreesToRadians() {
        didSet{
            setNeedsLayout()
        }
    }

    var roundedHead : Bool = false {
        didSet {
            setNeedsLayout();
        }
    }

    /// Radius
    
    var innerRadius  : CGFloat {
        return self.radius - self.borderWidth;
    }
    
    var midRadius  : CGFloat {
        return self.radius - (self.borderWidth * 0.5);
    }
    
    var outerRadius  : CGFloat {
        return self.radius;
    }
    
    func maxAngleLength() -> Double{
        var maxAngle:Double = 0
        
        for (index, step) in enumerate(dataSteps) {
            maxAngle = max((step as! OMStepData).angle.length(),maxAngle)
        }
        
        return maxAngle
    }
    
    
    func maxImageSize() -> CGSize {
        
        var maxSize:CGSize = CGSizeZero
        
        for (index, step) in enumerate(dataSteps) {
            if let img = (step as! OMStepData).image{
                maxSize = img.size.max(maxSize)
            }
        }
        
        return maxSize
    }
    
    func maxTextSize() -> CGSize {
        
        var maxSize:CGSize = CGSizeZero
        
        for (index, step) in enumerate(dataSteps) {
            if let txt = (step as! OMStepData).textLayer{
                maxSize = txt.bounds.size.max(maxSize)
            }
        }
        
        return maxSize
    }
    
    private(set) var internalRadius : CGFloat = 0.0
    
    var radius : CGFloat {
        
        set(newRadius) {
            
            internalRadius = newRadius
        }
        
        get {
            
            var alignExtraLength:CGFloat = 0.0
            var simpleRadius = internalRadius > 0.0 ? internalRadius : (bounds.size.min() * 0.5)
            
            var outerImageAlign:Int  = 0
            var borderImageAlign:Int = 0
            var outerTextAlign:Int  = 0
            var borderTextAlign:Int = 0
            
            // Max angle
            
            var maxAngle:Double = self.maxAngleLength()
            
            // Need the position of the images for calculate the radius without overflow the bounds
            
            for (index, step) in enumerate(dataSteps) {
                
                let curStep = (step as! OMStepData)
                
                // Image
                outerImageAlign  += (curStep.imageAlign == .AlignOuter) ? 1 : 0
                borderImageAlign += (curStep.imageAlign == .AlignBorder) ? 1 : 0
                
                // Text
                outerTextAlign  += (curStep.textAlign == .AlignOuter) ? 1 : 0
                borderTextAlign += (curStep.textAlign == .AlignBorder) ? 1 : 0
            }
        

            let maxSide = CGFloat(maxAngle) * simpleRadius
            
            if ( maxSide < self.maxImageSize().max() ) {
                if ( outerImageAlign > 0) {
                    alignExtraLength  = maxSide
                } else if ( borderImageAlign > 0) {
                    alignExtraLength = maxSide * 0.5
                }else{
                    
                    // nothing
                }
            }
            
            
            let maxSideText = maxTextSize()
            
            if ( outerTextAlign > 0) {
                alignExtraLength = max( alignExtraLength, maxSideText.max())
            } else if ( borderTextAlign > 0) {
                alignExtraLength =  max(maxSideText.max() * CGFloat(0.5), alignExtraLength)
            }else{
                    
                // nothing
            }
            //DEBUG
            //println("\(self.layer.name) radius : \(simpleRadius) max image side:\(maxSide) max text size \(maxSideText) extra radius length \( alignExtraLength)")
            
            return (simpleRadius - alignExtraLength)
        }
    }

    
    //
    
    var borderWidth : CGFloat {
        return thicknessRatio * radius
    }
    
    var thicknessRatio : CGFloat = 0.1 {
        didSet {
            thicknessRatio = min(fabs(thicknessRatio),1.0) // clamp
            setNeedsLayout();
        }
    }

    /// MARK: CAAnimation delegate
    
    override func animationDidStart(anim: CAAnimation!){
        if(DEBUG_ANIMATIONS){
            println("--> \(self)\nanimationDidStart:\((anim as! CABasicAnimation).keyPath) : \((anim as! CABasicAnimation).beginTime) ")
        }
    }

    override func animationDidStop(anim: CAAnimation!, finished flag: Bool){
        if(DEBUG_ANIMATIONS){
            println("<-- \(self)\nanimationDidStop:\((anim as! CABasicAnimation).keyPath)")
        }
    }


    // MARK: Shadow
    
    var shadowOpacity:Float = 0.85 {
        didSet{
            setNeedsLayout()
        }
    }
    var shadowOffset:CGSize = CGSize(width: 0, height: 3.0){
        didSet{
            setNeedsLayout()
        }
    }
    var shadowRadius:CGFloat = 1.5 {
        didSet{
            setNeedsLayout()
        }
    }
    
    var shadowColor:UIColor = OMProgressDefaultShadowColor{
        didSet{
            setNeedsLayout()
        }
    }
    
    // MARK: Font and Text (do no need layout)
    
    var percentText:Bool = false {
        didSet{
            updateNumericalLayer()
        }
    }
    
    var stepText:Bool = false {
        didSet{
            updateNumericalLayer()
        }
    }
    
    var fontName : String = "Helvetica" {
        didSet{
            updateNumericalLayer()
        }
    }
    var fontColor : UIColor = UIColor.blackColor(){
        didSet {
            updateNumericalLayer()
        }
    }
    
    var fontSize : CGFloat = 12 {
        didSet {
            updateNumericalLayer()
        }
    }
    
    var fontBackgroundColor : UIColor = UIColor.clearColor(){
        didSet {
            updateNumericalLayer()
        }
    }
    
    var fontStrokeWidth : Float = -3 {
        didSet {
            updateNumericalLayer()
        }
    }
    
    var fontStrokeColor : UIColor = UIColor.clearColor(){
        didSet {
            updateNumericalLayer()
        }
    }

    // MARK: Images
    
    var imageShadow : Bool = true

    
    var image: UIImage? {
        didSet {
            if image != nil {
                if(imageLayer != nil){
                    imageLayer?.image = image
                }else{

                    imageLayer = OMProgressImageLayer(image: image!)
                    
                    if ( DEBUG_LAYERS ){
                        imageLayer?.name = "center image"
                    }
                }
            }
        }
    }

    // !!!FIXME: if progress does not exist, then the Images are hiden
    
    var progress: Double = 0.0 {
        
        didSet {
            
            //println("progress: \(progress)")
            
            //let rads = numberOfRadians()
            
            //assert(rads == 2 * M_PI, "Unexpected consistence of circle radians (2 * π) != \(rads)")
            
            if (progress == OMCompleteProgress) {
                
                progress = Double(numberOfSteps)
            }
            
            //updateLayerTree()
            
            layoutIfNeeded();
            
            updateCompleteProgress()
        }
    }
    
    
    /// MARK: Contructors
    
    required init(coder : NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    
    func commonInit() {
        // DBG
        //layer.borderWidth = 1.0
        //layer.borderColor = UIColor.grayColor().CGColor
    }
    
    // MARK:
    
    private func updateCompleteProgress()
    {
        //DEBUG
        //
        
        //println("--> updateCompleteProgress (progress: \(progress))")
        
        if(progress == 0){
            // Nothig to update
            return
        }
        
        //DEBUG
        //assert(progress <= Double(numberOfSteps),"Unexpected progress \(progress) max \(numberOfSteps) ")
        
        let clamped_progress = progress.clamp0(Double(numberOfSteps))
        
        CATransaction.begin()
        
        let stepsDone   = UInt(clamped_progress);
        let curStep     = clamped_progress - floor(clamped_progress);
        
        beginTime = CACurrentMediaTime()
        
        for i:UInt in 0..<numberOfSteps {
            
            //DEBUG
            //println("for \(i) of \(numberOfSteps) in  \(progress) :  done:\(stepsDone) current:\(curStep)")
            
            if(i < stepsDone) {
                setProgressAtIndex(i, progressAtIndex: 1.0)
            } else {
                setProgressAtIndex(i, progressAtIndex: curStep)
            }
        }
        
        let duration = (animationDuration / Double(numberOfSteps)) * progress
        let toValue   = (progress / Double(numberOfSteps)).clamp0(1.0)
        
        /// Center
        //  image
        
        if let imgLayer = imageLayer {
            
            imgLayer.animateProgress( 0,
                toValue: toValue,
                beginTime: beginTime,
                duration: duration,
                delegate: self)
        }
        
        ///  number
        
        if let numberLayer = numberLayer {
            
            let number:Double
            
            if(stepText){
                number = Double(numberOfSteps)
            }else{
                number = toValue
            }
            
            if ( animation ){
                
                numberLayer.animateNumber(  0.0,
                    toValue:number,
                    beginTime:beginTime,
                    duration:duration,
                    delegate:self)
            }
            else
            {
                numberLayer.number = toValue as NSNumber
            }
        }
        
        CATransaction.commit()
        
        //DEBUG
        //println("<-- updateProgress (progress: \(progress))")
    }
    
    /// Progress of the step
    
    func getProgressAtIndex(index:UInt) -> Double
    {
        assert(index < numberOfSteps, "out of bounds.")
        
        if(index >= numberOfSteps) {
            return 0
        }
        
        return (dataSteps[Int(index)] as! OMStepData).progress
    }
    
    //
    // Set progress at index with animation if is needed
    //
    
    func setProgressAtIndex(index:UInt, progressAtIndex:Double) {
        
        assert(index < numberOfSteps, "out of bounds.")
        
        if (index >= numberOfSteps) {
            return
        }
        
        //DEBUG
        //println("--> setProgressAtIndex (index : \(index) progress: \(progressAtIndex))")
        
        let step = dataSteps[Int(index)] as! OMStepData
        
        if (animation) {
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            
            animation.fromValue =  0.0
            animation.toValue   =  progressAtIndex
            
            animation.duration = (animationDuration / Double(dataSteps.count)) * progressAtIndex
            
            animation.removedOnCompletion = false
            animation.additive = true
            animation.fillMode = kCAFillModeForwards
            animation.delegate = self
            
            if (progressViewStyle == .SequentialProgress) {
                
                // Current animation beginTime
            
                if  (newBeginTime != 0)  {
                    animation.beginTime = newBeginTime
                }  else  {
                    animation.beginTime = beginTime
                }
                
                // Calculate the next animation beginTime
                
                newBeginTime = animation.beginTime + animation.duration
            }
            
            // Add animation to the stroke of the shape layer.
            
            step.shapeLayer.addAnimation(animation, forKey: "strokeEnd")
            
            //animateGradientColors(step,duration: animation.duration,beginTime:animation.beginTime)
                
            //TEST
            //animateGradientStartRadius(step,duration: animation.duration,beginTime:animation.beginTime)
            //animateGradientEndRadius(step,duration: animation.duration,beginTime:animation.beginTime)
            
            if let imgLayer = step.imageLayer {
                
                // Add animation to the image
                
                imgLayer.animateProgress(0.0,
                    toValue:  progressAtIndex,
                    beginTime: animation.beginTime,
                    duration: animation.duration ,
                    delegate: self)
            }
        }
        else
        {
            // Remove the default animation from strokeEnd
            
            step.shapeLayer.actions = ["strokeEnd" as NSString : NSNull()]
            step.shapeLayer.strokeEnd = CGFloat(progressAtIndex)
        }
    }
    
    
    func newStep(startAngle:Double, endAngle:Double, color:UIColor!) -> OMStepData
    {
        assert(isAngleInCircleRange(endAngle), "Invalid angle:\(endAngle). range in radians : -(2*PI)/+(2*PI)")
        assert(isAngleInCircleRange(startAngle), "Invalid angle:\(startAngle). range in radians : -(2*PI)/+(2*PI)")
        
        let step = OMStepData(startAngle:startAngle,endAngle:endAngle,color:color)
        
        // Save the step
        
        dataSteps.addObject(step)
        
        // Return it for user modification.
        
        return step;
    }
    
    
    func newStep(angle:Double, color:UIColor!) -> OMStepData {
        
        let startAngle = getStartAngle()
        
        return newStep(  startAngle, endAngle:startAngle + angle, color:color );
    }
    
    
    func  newStepWithPercent(startAngle:Double, percent:Double, color:UIColor!) -> OMStepData
    {
        let percent = percent.clamp0(1.0)
        
        let step = OMStepData(startAngle:startAngle,percent:percent,color:color)
        
        return step
    }
    
    func newStepWithPercent(percent:Double, color:UIColor!) -> OMStepData {
        
        return newStepWithPercent(getStartAngle(),percent: percent, color: color);
    }
    
    //
    // Get the last angle used. If do not found any. Uses startAngle.
    //
    
    private func getStartAngle() -> Double {
        
        var startAngle = self.startAngle;
        
        if(dataSteps.count > 0) {
            // The new startAngle is the last endAngle
            startAngle  = (dataSteps[dataSteps.count - 1] as! OMStepData).angle.end
        }
        return startAngle;
    }
    
    //
    // Set up the basic progress layers
    //
    
    private func setUpLayers(step:OMStepData, startAngle:Double, endAngle:Double)
    {
        //DEBUG
        //println("setUpLayers:\(step.index) \(OMAngle(startAngle: startAngle, endAngle: endAngle))")
        
        if (( step.maskLayer ) != nil) {
            
            // Update the mask frame
            
            if(step.maskLayer?.frame != bounds){
                
                step.maskLayer?.frame = bounds
                
                // Mark the layer for update because has a new frame.
                
                step.maskLayer?.setNeedsDisplay()
            }
        }
        
        setUpProgressLayer(step,startAngle:startAngle,endAngle:endAngle)
        
        setUpWellLayer(step)
    }
    
    //
    // Set Up the shape layer
    //
    
    private func setUpProgressLayer(step:OMStepData, startAngle:Double, endAngle:Double)
    {
        let arcAngle : Double
        
        // can be caused by separatorRatio = 1.0
        
        assert( startAngle != endAngle,
            "The start angle and the end angle cannot be the same. angle: \(startAngle.radiansToDegrees())")
        
        if (DEBUG_LAYERS) {
            step.shapeLayer.name = "step \(dataSteps.indexOfObject(step)) shape"
        }
        
        /// Calculate the angle of arc length needed for the rounded head in radians
        
        if (roundedHead) {
            arcAngle = Double(borderWidth * 0.5) / Double(radius)
        } else {
            arcAngle = 0.0
        }
        
        let bezier = UIBezierPath(  arcCenter:bounds.size.center(),
            radius: midRadius,
            startAngle:CGFloat(startAngle + arcAngle ),
            endAngle:CGFloat(endAngle - arcAngle ),
            clockwise: true)
        
        step.shapeLayer.path            = bezier.CGPath
        step.shapeLayer.backgroundColor = UIColor.clearColor().CGColor
        step.shapeLayer.fillColor       = nil
        //step.shapeLayer.strokeColor     = (  step.gradientType != .None  ) ? UIColor.blackColor().CGColor : step.color.CGColor
        
        step.shapeLayer.strokeColor     = (  step.maskLayer != nil ) ? UIColor.blackColor().CGColor : step.color.CGColor
        
        step.shapeLayer.lineWidth       = borderWidth
        
        if ( roundedHead ) {
            step.shapeLayer.lineCap = kCALineCapRound
        }
        
        step.shapeLayer.strokeStart = 0.0
        step.shapeLayer.strokeEnd   = 0.0
        
        if step.maskLayer != nil {
            
            // When setting the mask to a new layer, the new layer must have a nil superlayer
            
            step.maskLayer?.mask = step.shapeLayer
            
            layer.addSublayer(step.maskLayer)
            
        } else {
            
            layer.addSublayer(step.shapeLayer)
        }
    }
    
    //
    //
    //
    
    private func setUpWellLayer(step:OMStepData)
    {
        if let stepWellColor = step.wellColor {
            
            if(step.wellLayer == nil){
                
                // Create the well layer
                
                step.wellLayer = CAShapeLayer()
                
                if ( DEBUG_LAYERS ) {
                    step.wellLayer?.name = "step \(dataSteps.indexOfObject(step)) well"
                }
            }
            
            // This layer uses the shape path
            
            step.wellLayer?.path            = step.shapeLayer.path
            
            step.wellLayer?.backgroundColor = UIColor.clearColor().CGColor
            step.wellLayer?.fillColor       = nil
            step.wellLayer?.strokeColor     = stepWellColor.CGColor
            step.wellLayer?.lineWidth       = borderWidth
            
            // Activate shadow only if exist space between steps.
            
            //if ( stepSeparator ) {
                
                step.wellLayer?.shadowOpacity = shadowOpacity
                step.wellLayer?.shadowOffset  = shadowOffset
                step.wellLayer?.shadowRadius  = shadowRadius
                step.wellLayer?.shadowColor   = shadowColor.CGColor
                step.wellLayer?.shadowPath    = ( stepSeparator ) ?  nil : step.shapeLayer.path
            //}
            
            // Same as shape layer
            step.wellLayer?.lineCap = step.shapeLayer.lineCap
            
            // Add the layer behind the other layers
            
            layer.insertSublayer(step.wellLayer, atIndex:0)
        }
    }
    
    //
    // Remove all layers from the superlayer.
    //
    
    private func removeAllSublayersFromSuperlayer()
    {
        for (index, step) in enumerate(dataSteps )
        {
            let curStep = step as! OMStepData
            
            // Remove the gradient layer mask
            
            curStep.maskLayer?.removeFromSuperlayer()
            
            curStep.wellLayer?.removeFromSuperlayer()
            
            curStep.imageLayer?.removeFromSuperlayer()
            
            curStep.textLayer?.removeFromSuperlayer()
            
            curStep.shapeLayer.removeFromSuperlayer()
        }
        
        // Remove the center image layer
        
        imageLayer?.removeFromSuperlayer()
        
        // Remove the number layer
        
        numberLayer?.removeFromSuperlayer()
    }
    
    
    // MARK: Text layer
    
    func updateNumericalLayer()
    {
        if let numberLayer = numberLayer
        {
            numberLayer.fontStrokeWidth = fontStrokeWidth
            numberLayer.fontStrokeColor = fontStrokeColor
            numberLayer.backgroundColor = fontBackgroundColor.CGColor;
            numberLayer.formatStyle = numberStyle()
            numberLayer.setFont(fontName, fontSize:fontSize)
            numberLayer.foregroundColor = fontColor
            
            // The percent is represented from 0.0 to 1.0
            
            let numberToRepresent = ( percentText ) ? 1 : dataSteps.count;
            
            let size = numberLayer.frameSizeLengthFromNumber(numberToRepresent)
            
            numberLayer.frame = bounds.size.center().centerRect( size )
        
            // Shadow for center text
            
            numberLayer.shadowOpacity = shadowOpacity
            numberLayer.shadowOffset  = shadowOffset
            numberLayer.shadowRadius  = shadowRadius
            numberLayer.shadowColor   = shadowColor.CGColor
        }
    }
    
    func numberStyle() -> CFNumberFormatterStyle
    {
        return ( percentText ) ? CFNumberFormatterStyle.PercentStyle : CFNumberFormatterStyle.NoStyle
    }
    
    func setUpNumericalLayer()
    {
        if ( numberLayer == nil ) {
            numberLayer = OMNumberLayer(number: 0, formatStyle: numberStyle(), alignmentMode: "center")
            
            if ( DEBUG_LAYERS )  {
                numberLayer?.name = "text layer"
            }
        }
        
        updateNumericalLayer()
    }
    
    //
    // Layout the subviews
    //
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        updateLayerTree()
    }
    
    //
    // Calculate the point for the image and/or text at the angle.
    //
    
    private func anglePoint(angle:Double, align:OMAlign, size:CGSize = CGSizeZero) -> CGPoint
    {
        // .AlignMid (default)
        
        var newRadius:Double = Double(midRadius)
        
        if(align == .AlignMid) {
            
        } else if(align == .AlignCenter) {

            newRadius = Double( innerRadius )
            
        } else if(align == .AlignBorder) {
            
            newRadius = Double( outerRadius )
        
        } else if(align == .AlignOuter) {
            
            newRadius = Double( outerRadius + (size.height * 0.5) )
            
        } else {
            
            assertionFailure("Unexpected align \(align)")
        }
        
        //
        // Given a radius length r and an angle in radians and a circle's center (x,y),
        // calculate the coordinates of a point on the circumference
        //
        
        let theta = CGFloat( angle )
        
        return CGPoint(x: bounds.size.center().x + CGFloat(newRadius)  * cos(theta), y: bounds.size.center().y + CGFloat(newRadius) * sin(theta))
        
    }
    
    
    private func addStepImageLayers()
    {
        for (index, step) in enumerate(dataSteps)
        {
            let curStep = step as! OMStepData
            
            if(curStep.imageLayer != nil){
                if ( DEBUG_LAYERS ){
                    curStep.imageLayer!.name = "step \(index) image"
                }
                layer.addSublayer(curStep.imageLayer)
            }
        }
    }
    
    private func addStepTextLayers()
    {
        /// Add all steps texts
        
        for (index, step) in enumerate(dataSteps)
        {
            let curStep = step as! OMStepData
            
            if(curStep.textLayer != nil){
                if ( DEBUG_LAYERS ){
                    curStep.textLayer!.name = "step \(index) text"
                }
                layer.addSublayer(curStep.textLayer)
            }
        }
    }
    
    private func addCenterImage()
    {
        if (imageLayer != nil){
            
            imageLayer!.frame = bounds.size.center().centerRect(image!.size)
            
            if ( DEBUG_LAYERS ){
                imageLayer!.name = "center image"
            }
            
            layer.addSublayer(imageLayer)
        }
    }
    
    //
    // Create all the necesary layers
    //
    
    private func updateLayerTree()
    {
        /// First, remove all layers
        
        removeAllSublayersFromSuperlayer()
        
        /// set Up the center numerical text layer.
        
        if (percentText || stepText) {
            setUpNumericalLayer()
            
        }
        
        //
        // Recalculate the step layers.
        //
        
        /// First create and setup the position of the text and image step layers
        
        let radius_2 = Double(radius * 2.0)  // Avoid to divide by 2 each s0 element calculation
        
        for (index, step) in enumerate(dataSteps)
        {
            let curStep = step as! OMStepData
            
            // Do not use separator.
            
            curStep.separatorAngleHalf = 0.0
            
            if ( stepSeparator ) {
                
                // The separator is a ratio of step angle length
                
                if ( separatorRatio > 0.0 ) {
                    let radiansPerStep = (M_PI * 2) / Double(dataSteps.count)
                    curStep.separatorAngleHalf = (separatorRatio * radiansPerStep) * 0.5
                } else {
                    
                    // The separator is fixed
                    
                    curStep.separatorAngleHalf = separatorFixed
                }
            }
            
            
            /// Image
            
            // Sacale the image if is necesary
            
            if let img = curStep.image {
                
                let curSize = img.size.max()
                
                let angleLength = curStep.angle.length()
                
                var maxSide:CGFloat = CGFloat(angleLength * Double(outerRadius))
                
                assert(maxSide > 0.0, "overflow side.")
                
                if ( maxSide < curSize ) {
                    curStep.imageScaled  = img.scaledToFitToSize(CGSize(width: Int(maxSide),height: Int(maxSide)))
                } else {
                    curStep.imageScaled = nil;
                }
            }
            
            // Select the correct image
   
            if let img = curStep.imageScaled ?? curStep.image {
                
                // If separatorRatio has a valid value. Use it.
                
                if ( stepSeparator && ( separatorRatio == 0.0 ) ) {
                    
                    let halfLength = curStep.angle.length() * 0.5
                    
                    // division by a number mul 2 is the same that div by 2
                    
                    let halfAngle  = Double(img.size.hypot()) / radius_2
                    
                    // avoid overflow the angle by the separator
                    
                    if ( halfAngle < halfLength ){
                        
                        curStep.separatorAngleHalf = halfAngle
                    }
                }
                
                // Create the progress image layer
                
                if ( curStep.imageLayer == nil ) {
                    curStep.imageLayer = OMProgressImageLayer(image: img)
                    
                    if ( DEBUG_LAYERS ){
                        curStep.imageLayer?.name = "step \(dataSteps.indexOfObject(curStep)) image"
                    }
                    
                } else {
                    curStep.imageLayer?.image = img
                }
                
                var angle:Double = curStep.angle.start
                
                switch(curStep.imageAngleAlign)
                {
                    case .AngleMid:
                        angle = curStep.angle.mid()
                        break;
                    case .AngleStart:
                        angle = curStep.angle.start
                        break;
                    case .AngleEnd:
                        angle = curStep.angle.end
                        break;
                    default:
                        assertionFailure("Unexpected angle align \(curStep.textAngleAlign)")
                }
                
                if(curStep.imageOrientationToAngle){
                    // Reset the angle prientation before sets a new frame
                    curStep.imageLayer?.angleOrientation = 0
                }
                
                curStep.imageLayer?.frame = anglePoint(angle, align: curStep.imageAlign, size: img.size).centerRect(img.size)
                

                // Rotate the layer
                
                if(curStep.imageOrientationToAngle){

                    curStep.imageLayer?.angleOrientation = (angle - startAngle)
                }
                
                // Mark the layer for repaint
                
                curStep.imageLayer?.setNeedsDisplay()
            }
            
            /// Text
            
            if let stepText = curStep.text {
                
                if(curStep.textLayer == nil){
                    curStep.textLayer = OMTextLayer(string: stepText)
                }else{
                    curStep.textLayer?.string = stepText
                }
                
                if ( DEBUG_LAYERS ){
                    curStep.textLayer?.name = "step \(dataSteps.indexOfObject(step)) text"
                }
                
                /// Configure the step text layer font
                
                curStep.textLayer?.setFont( curStep.fontName,fontSize:  curStep.fontSize)
                
                curStep.textLayer?.foregroundColor = curStep.fontColor
                curStep.textLayer?.fontStrokeColor = curStep.fontStrokeColor
                curStep.textLayer?.backgroundColor = curStep.fontBackgroundColor.CGColor
                curStep.textLayer?.fontStrokeWidth = curStep.fontStrokeWidth
                
                let sizeOfText = curStep.textLayer?.frameSizeLengthFromString(stepText)
                
                var angle:Double = curStep.angle.mid()
                
                switch(curStep.textAngleAlign)
                {
                    case .AngleMid:
                        angle = curStep.angle.mid()
                        break;
                    case .AngleStart:
                        angle = curStep.angle.start
                        break;
                    case .AngleEnd:
                        angle = curStep.angle.end
                        break;
                    default:
                        assertionFailure("Unexpected angle align \(curStep.textAngleAlign)")
                }
                
                if(curStep.textOrientationToAngle ){
                    // Reset the angle prientation before sets a new frame
                    curStep.textLayer?.angleOrientation = 0
                }
                
                curStep.textLayer?.frame = anglePoint(angle, align: curStep.textAlign, size: sizeOfText!).centerRect(sizeOfText!)
                
                if(curStep.textOrientationToAngle){
                    curStep.textLayer?.angleOrientation = (angle - startAngle)
                }
                
               // curStep.textLayer?.radius = self.outerRadius
            }
        }
        
        ///
        
        // assertIfOverflow2PIRadians()
        
        /// Create the layers for each step.
        
        for (index, step) in enumerate(dataSteps)
        {
            let curStep = step as! OMStepData
            
            if ( stepSeparator ) {
                
                if(index + 1 < dataSteps.count ){
                    
                    let nextStep = dataSteps[index+1] as! OMStepData
                    
                    //DEBUG
                    //println("angle arc :\(nextStep.separatorAngleHalf + step.separatorAngleHalf)")
                    
                    setUpLayers(curStep,
                        startAngle: curStep.angle.start + curStep.separatorAngleHalf,
                        endAngle: curStep.angle.end - nextStep.separatorAngleHalf)
                }else{
                    let firstStep = dataSteps.firstObject as! OMStepData
                    
                    //DEBUG
                    //println("** angle arc :\(firstStep.separatorAngleHalf + step.separatorAngleHalf)")
                    
                    setUpLayers(curStep,
                        startAngle:curStep.angle.start + curStep.separatorAngleHalf,
                        endAngle:curStep.angle.end - firstStep.separatorAngleHalf)
                }
            } else {
                setUpLayers(curStep,
                    startAngle:curStep.angle.start,
                    endAngle: curStep.angle.end)
            }
        }
        
        /// Add the center image
        
        if (NO_IMAGES == false) {
            addCenterImage()
        }
        
        
        /// Add all steps image
        if (NO_IMAGES == false) {
            addStepImageLayers()
        }

        
        /// Add all steps texts
        
        if (NO_TEXT == false) {
            addStepTextLayers()
            
            /// Add the text layer.
            layer.addSublayer(numberLayer)
        }
    
        if ( DEBUG_LAYERS ){
            dumpLayers(0,layer:self.layer)
        }
        
        
        //DEBUG
        if ( DEBUG_STEPS ){
            dumpAllSteps()
        }
    }
    
    
    
    // MARK: Debug functions
    
    private func dumpAllSteps()
    {
        for (index, step) in enumerate(dataSteps) {
            println("\(index): \(step as! OMStepData)")
        }
    }
    
    
    private func dumpLayers(level:UInt, layer:CALayer)
    {
        if(layer.sublayers != nil)
        {
            for (index, lay) in enumerate(layer.sublayers) {
            
                let curLayer = lay as! CALayer
            
                println("[\(level)] \(curLayer.name)")
            
                if(curLayer.sublayers != nil){
                    dumpLayers(level+1, layer: curLayer);
                }
            }
        }
    }
    
    // MARK: Consistency functions
    
    private func assertIfOverflow2PIRadians()()
    {
        var rads:Double = 0
        
        for var index = 0; index < dataSteps.count ; ++index
        {
            let step = dataSteps[index] as! OMStepData
            
            if ( stepSeparator ) {
                
                if(index + 1 < dataSteps.count ) {
                    
                    let nextStep = dataSteps[index+1] as! OMStepData
                    
                    rads += OMAngle(startAngle: step.angle.start + step.separatorAngleHalf,
                        endAngle: step.angle.end - nextStep.separatorAngleHalf).length()
                    
                    rads += nextStep.separatorAngleHalf + step.separatorAngleHalf
                }else{
                    let firstStep = dataSteps.firstObject as! OMStepData
                    
                    rads += OMAngle(startAngle:step.angle.start + step.separatorAngleHalf,
                        endAngle:step.angle.end - firstStep.separatorAngleHalf).length()
                    
                    rads += firstStep.separatorAngleHalf + step.separatorAngleHalf
                }
            } else {
                rads += OMAngle(startAngle:step.angle.start, endAngle: step.angle.end).length()
            }
        }
        
        assert(rads <= M_PI * 2.0, "out of radians")
    }
    
    
    private func isAngleInCircleRange(angle:Double) -> Bool{
        return (angle > (M_PI * 2) || angle < -(M_PI * 2)) == false
    }
    
    private func numberOfRadians() -> Double
    {
        var rads = 0.0
        for var index = 0; index < dataSteps.count ; ++index{
            rads +=  (dataSteps[index] as! OMStepData).angle.length()
        }
        
        return rads
    }
    
    override var debugDescription: String
    {
        var str : String = "Radius : \(radius) \(innerRadius) \(outerRadius) \(midRadius) Border : \(borderWidth)"
            
        return str;
    }
    
    override var description: String
    {
        return debugDescription;
    }
}
