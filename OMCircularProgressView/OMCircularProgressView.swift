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
//


// Revisar los gradients.
// Revisar la arquitectura. Progreso completo vs progreso por pasos
// Pod
// Documentar
//

#if os(iOS)
    import UIKit
    #elseif os(OSX)
    import AppKit
#endif


//DEBUG

let DEBUG_LAYERS =  true      // very usefull
let DEBUG_GRADIENT = false
let DEBUG_STEPS = false
let NO_GRADIENT = false
let NO_WELL = false
let NO_TEXT = false
let NO_IMAGES = false
let ANIMATE_GRADIENT = true

/// Tag the steps
let DEBUG_SET_STEP_ID = true
var GLOBAL_INDEX:Int = 0


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

public enum OMGradientColors : Int
{
    case Gloss
    case Brightness
    case Clear
    case Next
    case White
    case Black
    init()
    {
        self = Clear
    }
}

/// The type of the gradient.

public enum OMGradientType : Int
{
    // without gradient
    case None
    
    /// A linear gradient.
    case Axial
    
    /// A radial gradient.
    case Radial
    
    /// A radial oval gradient
    case Oval
    
    init() {
        self = None
    }
}

/// The linear gradient direction.
enum OMGradientDirection : Int {
    /// The gradient is vertical.
    case Vertical
    
    /// The gradient is horizontal
    case Horizontal
    
    init() {
        self = Vertical
    }
}

enum OMAlign : Int
{
    case AlignCenter
    case AlignMid
    case AlignBorder
    init() {
        self = AlignMid
    }
}

enum OMAngleAlign: Int
{
    case AngleStart
    case AngleMid
    case AngleEnd
    init() {
        self = AngleMid
    }
}


class OMAngle : NSObject, DebugPrintable, Printable
{
    var start:Double = 0.0                // start of angle in radians
    var end:Double   = 0.0                // end of angle in radians
    
    convenience init(startAngle:Double,endAngle:Double){
        self.init()
        self.start = startAngle
        self.end = endAngle;
    }
    
    // middle of the angle
    func mid() -> Double {
        return start + (length() * 0.5)
    }
    
    // angle length in radians
    func length() -> Double {
        return (end - start)
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


class OMStepData : NSObject, DebugPrintable, Printable
{
    /// Basic
    
    var angle:OMAngle!                              // step angle
    var color:UIColor!                              // step color
    var shapeLayer:CAShapeLayer! = CAShapeLayer()   // progress shape
    
    
    var progress:Double {
        
        set{
            self.shapeLayer.strokeEnd = CGFloat(progress)
        }
        get{
            return Double(self.shapeLayer.strokeEnd)
        }
    }
    
    /// Step gradient 
    
    var gradientType:OMGradientType = .Radial
//    {
//        didSet
//        {
//            if(gradientType == .Radial) {
//                if(gradientLayer?.type != kOMGradientLayerRadial){
//                
//                }
//            }
//        }
//    }
    var gradientClr:OMGradientColors = .Next
    var gradientLayer:CALayer?          // optional gradient layer mask

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
    
    var image : UIImage?                                 // optional image
    var imageLayer:OMProgressImageLayer?                 // optional image layer
    var imageAlign : OMAlign = .AlignBorder
    var imageOrientationToAngle  : Bool = true
    var imageAngleAlign : OMAngleAlign = .AngleStart
    var separatorAngleHalf:Double = 0.0                 // angle of arclength of image hypotenuse in radians
    
    
    //DEBUG
    var index:Int = 0
    
    required convenience init(startAngle:Double,percent:Double,color:UIColor!)
    {
        self.init(startAngle:startAngle,
            endAngle: startAngle + (2.0 * M_PI * percent),
            color:color)
    }
    
    init(startAngle:Double,endAngle:Double,color:UIColor!)
    {
        self.angle = OMAngle(startAngle:startAngle, endAngle:endAngle)
        self.color = color
        
        //DEBUG
        if(NO_GRADIENT == true){
            self.gradientType = .None
        }
        //DEBUG
        if( NO_WELL  == true){
            self.wellColor = nil
        }
        
        //DEBUG
        if(DEBUG_SET_STEP_ID){
            self.index = GLOBAL_INDEX++
        }
    }
    
    //        func animateGradient()
    //        {
    //            //DEBUG
    //            //println("animating \(self.gradientLayer?.colors.count) colors (\(index))")
    //
    //            // Update the colors on the model layer
    //
    //            let fromColors:NSArray? = self.gradientLayer?.colors
    //
    //            let toColors = fromColors?.shift(forward: false)
    //
    //            assert(fromColors?.count == toColors?.count, "Unexpected size of colors")
    //
    //            self.gradientLayer?.colors = toColors as! [AnyObject];
    //
    //            // Create an animation to slowly move the hue gradient left to right.
    //
    //            let animation = CABasicAnimation(keyPath:"colors")
    //
    //            animation.fromValue = fromColors
    //            animation.toValue = toColors
    //            animation.duration = 0.1
    //            animation.removedOnCompletion = true
    //            animation.fillMode = kCAFillModeForwards
    //            animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear)
    //            animation.delegate = self
    //
    //            // Add the animation to our layer
    //
    //            self.gradientLayer?.addAnimation(animation, forKey: "animateGradient")
    //        }
    
    
    //       override func animationDidStart(anim: CAAnimation!){
    //
    //       }
    //
    //       override func animationDidStop(anim: CAAnimation!, finished flag: Bool)
    //       {
    //           self.animateGradient()
    //       }
    
    
    override var debugDescription : String {
        
        let degreeAngle = round(separatorAngleHalf.radiansToDegrees());
        let gradientString:String
        
        if(gradientType == .Radial)
        {
            gradientString  = "gradient(\((gradientLayer as? OMRadialGradientLayer)!.type))"
        }
        else if(gradientType == .Axial)
        {
            gradientString  = "gradient(axial)"
        }else{
            gradientString = ""
        }
        
        let wellString      = (wellColor != nil) ? "+well" : ""
        let imageString     = (image != nil) ? "+image" : ""
        let textString     = (text != nil) ? "+text" : ""
        
        let sepString =  "\(degreeAngle)°"
        
        return "\(angle) sep: \(sepString) prop:(\(gradientString)\(wellString)\(imageString)\(textString))"
    }
    
    override var description: String
    {
        return debugDescription;
    }
}

//
//
//

class OMCircularProgressView: UIView {
    
    /// Private
    
    // Array of OMStepData
    
    private(set) var dataSteps: NSMutableArray = []
    
    private var imageLayer:OMProgressImageLayer?   // center image layer
    private var numberLayer:OMNumberLayer?         // center number layer
    
    // Private vars for animations
    
    private var beginTime: NSTimeInterval = 0;
    private var newBeginTime: NSTimeInterval = 0;
    
    /// Public
    
    // Unused
    
    var progressViewStyle:OMCircularProgressViewStyle = OMCircularProgressViewStyle.SequentialProgress
    
    
    // Animation
    
    var animation : Bool = true;
    var animationDuration : NSTimeInterval = 1.0
    
    /// Component behavior
    
    // The start angle of the all steps.
    // default -90 -> 12 o'clock
    
    var startAngle : Double = -90.degreesToRadians() {
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
    var separatorIsTheImage:Bool = false {
        didSet{
            setNeedsLayout()
        }
    }
    
    var stepSeparator:Bool = true {
        didSet{
            setNeedsLayout()
        }
    }
    
    var roundedHead : Bool = false {
        didSet {
            setNeedsLayout();
        }
    }
    //
    //    CGRect bounds = [self bounds];
    //    float wt = [self wellThickness];
    //    CGRect outer = CGRectInset([self bounds], wt / 2.0, wt / 2.0);
    //    CGRect inner = CGRectInset([self bounds], wt, wt);
    //
    
    //    var wellThickness : CGFloat = 8.0
    //
    //    var radius2 : CGFloat {
    //        get
    //        {
    //            let r  = CGRectInset(bounds, wellThickness / 2.0, wellThickness / 2.0)
    //            return  r.size.min() * 0.5
    //        }
    //    }
    
    
    var innerRadius : CGFloat
    {
        let inset = (borderWidth * 0.5)
        
        let inner = CGRectInset(bounds, inset, inset);
        
        return  (inner.size.min() * 0.5) - (maxImageSize().max() * 0.5)
    }
//
//    var outerRadius : CGFloat
//    {
//        let inset = borderWidth
//            
//        let outer = CGRectInset(bounds, inset, inset);
//            
//        return outer.size.min() * 0.5
//    }
//    
//    var radius : CGFloat {
//        
//        //let imgSize = (maxImageSize().max() * 0.5)
//        
//        //CGRectInset([self bounds], [self wellThickness] / 2.0, [self wellThickness] / 2.0);
//    
//        return (bounds.size.min() * 0.5)  //- imgSize
//    }
    
    
    var radius : CGFloat {
        get {
            return (bounds.size.min() * 0.5) - (maxImageSize().max() * 0.5) ;
        }
    }

    
    required init(coder : NSCoder) {
        super.init(coder: coder)
        
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    
    func commonInit() {
        // DEBUG
        //self.layer.borderWidth = 1.0
        //self.layer.borderColor = UIColor.grayColor().CGColor
    }
    
    //
    
    var borderWidth : CGFloat {
        
        return thicknessRatio * radius
    }
    
    var thicknessRatio : CGFloat = 0.1
    {
        didSet {
            thicknessRatio = min(fabs(thicknessRatio),1.0) // clamp
            setNeedsLayout();
        }
    }
    
    //
    //    override func animationDidStart(anim: CAAnimation!){
    //        //DEBUG
    //        println("--> \(self)\nanimationDidStart:\((anim as! CABasicAnimation).keyPath) : \((anim as! CABasicAnimation).beginTime) ")
    //    }
    //
    //    override func animationDidStop(anim: CAAnimation!, finished flag: Bool)
    //    {
    //        //DEBUG
    //        println("<-- \(self)\nanimationDidStop:\((anim as! CABasicAnimation).keyPath)")
    //    }
    //
    
    
    //
    // Max size of all step images
    //
    // NOTE: The idea is that the images do not over bounds the view
    //
    
    func maxImageSize() -> CGSize
    {
        var maxSize:CGSize = CGSizeZero
        
        for (index, step) in enumerate(self.dataSteps) {
            if let img = (step as! OMStepData).image  {
                maxSize = maxSize.max(img.size)
            }
        }
        
        return maxSize
    }
    
    // Gradient mask
    
//    var gradient:Bool = true
//    {
//        didSet
//        {
//            /// Reconfigure the gradient
//            
//            if(oldValue != self.gradient) {
//                
//                for (index, step) in enumerate(self.dataSteps)
//                {
//                    let curStep = step as! OMStepData
//                    
//                    curStep.gradient = gradient
//                    
//                    if(gradient == false){
//                        self.removeGradient(curStep)
//                    }else{
//                        self.addGradient(curStep)
//                    }
//                }
//            }
//        }
//    }
    
    
    //
    // The gradient type by default is Radial, following the shape of our component
    //
    
//var gradientType:OMGradientType = .Radial
//        {
//        didSet
//        {
//            // Reconfigure the gradient
//            
//            if(oldValue != self.gradientType)
//            {
//                for (index, step) in enumerate(self.dataSteps)
//                {
//                    let s = step as! OMStepData
//                    
//                    if(s.gradient)
//                    {
//                        if(s.gradientLayer?.type == kCAGradientLayerAxial && self.gradientType == .Radial) ||
//                            (s.gradientLayer?.type == kOMGradientLayerRadial && self.gradientType == .Axial)
//                        {
//                            if(self.gradientType == OMGradientType.Axial){
//                                self.setUpAxialGradient(s)
//                            }else{
//                                self.setUpRadialGradient(s)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    //
    // Set Up the default options for the radial gradient
    //
    
    private func setUpRadialGradient(step:OMStepData)
    {
        step.gradientLayer = OMRadialGradientLayer(type:kOMGradientLayerRadial)
        
        (step.gradientLayer as? OMRadialGradientLayer)!.startCenter = bounds.size.center()
        (step.gradientLayer as? OMRadialGradientLayer)!.endCenter   = bounds.size.center()
        
        (step.gradientLayer as? OMRadialGradientLayer)!.startRadius = 0
        (step.gradientLayer as? OMRadialGradientLayer)!.endRadius   = self.radius //- self.lineWidth
    }
    
    
    var gradientDirection:OMGradientDirection = .Vertical
    
    //
    // Set Up the default options for the axial gradient
    //
    // The default startPoint is (0.5, 0.0).
    // The default endPoint is (0.5, 1.0).
    
    private func setUpAxialGradient(step:OMStepData)
    {
        step.gradientLayer = CAGradientLayer()
        
        if(self.gradientDirection == .Vertical) {
            (step.gradientLayer as? CAGradientLayer)!.startPoint = CGPoint(x: 0.5, y: 0.0)
            (step.gradientLayer as? CAGradientLayer)!.endPoint  = CGPoint(x: 0.5, y: 1.0)
        } else if(self.gradientDirection == .Horizontal) {
            (step.gradientLayer as? CAGradientLayer)!.startPoint = CGPoint(x: 0.0, y: 0.5)
            (step.gradientLayer as? CAGradientLayer)!.endPoint  =  CGPoint(x: 1.0, y: 0.5)
        }
    }
    
    // !!!FIXME: if progress does not exist, then the Images are hiden
    
    var progress: Double = 0.0 {
        didSet {
            
            //let rads = self.numberOfRadians()
            
            //assert(rads == 2 * M_PI, "Unexpected consistence of circle radians (2 * π) != \(rads)")
            
            if (progress == OMCompleteProgress) {
                
                progress = Double(dataSteps.count)
            }
            
            //setNeedsLayout()
            
            layoutIfNeeded();
            
            self.updateCompleteProgress()
        }
    }
    
    // MARK: Shadow
    
    var shadowOpacity:Float = 0.85 {
        didSet{
            setNeedsLayout()
        }
    }
    var shadowOffset:CGSize = CGSize(width: 0, height: 3){
        didSet{
            setNeedsLayout()
        }
    }
    var shadowRadius:CGFloat = 1.5 {
        didSet{
            setNeedsLayout()
        }
    }
    
    var shadowColor : UIColor = OMProgressDefaultShadowColor{
        didSet{
            setNeedsLayout()
        }
    }
    
    // MARK: Font and Text (do no need layout)
    
    var percentText:Bool = false {
        didSet{
            self.updateNumericalLayer()
        }
    }
    
    var stepText:Bool = false {
        didSet{
            self.updateNumericalLayer()
        }
    }
    
    var fontName : String = "Helvetica" {
        didSet{
            self.updateNumericalLayer()
        }
    }
    var fontColor : UIColor = UIColor.blackColor(){
        didSet {
            self.updateNumericalLayer()
        }
    }
    
    var fontSize : CGFloat = 12 {
        didSet {
            self.updateNumericalLayer()
        }
    }
    
    var fontBackgroundColor : UIColor = UIColor.clearColor(){
        didSet {
            self.updateNumericalLayer()
        }
    }
    
    var fontStrokeWidth : Float = -3 {
        didSet {
            self.updateNumericalLayer()
        }
    }
    
    var fontStrokeColor : UIColor = UIColor.clearColor(){
        didSet {
            self.updateNumericalLayer()
        }
    }
    
    // MARK: Image center.
    
    
    var image: UIImage? {
        didSet {
            if image != nil {
                imageLayer = OMProgressImageLayer(image: image!)
                //imageLayer?.contents = image!.getGrayScale()?.CGImage
                //imageLayer?.contents = image!.CGImage
                
            }
        }
    }
    
    // MARK:
    
    private func updateCompleteProgress()
    {
        //DEBUG
        //println("--> updateCompleteProgress (progress: \(progress))")
        
        if(progress == 0){
            // Nothig to update
            return
        }
        
        let numberOfSteps = self.dataSteps.count
        
        //DEBUG
        //assert(progress <= Double(numberOfSteps),"Unexpected progress \(progress) max \(numberOfSteps) ")
        
        let claped_progress = min(fabs(progress),Double(numberOfSteps)) //clamp
        
        CATransaction.begin()
        
        let stepsDone   = Int(self.progress);
        let curStep     = self.progress - floor(self.progress);
        
        self.beginTime = CACurrentMediaTime()
        
        for i in 0..<Int(numberOfSteps) {
            
            //DEBUG
            //println("for \(i) of \(numberOfSteps) in  \(progress) :  done:\(stepsDone) current:\(curStep)")
            
            if(i < stepsDone) {
                self.setProgressAtIndex(Int(i), progressAtIndex: 1.0)
            } else {
                self.setProgressAtIndex(Int(i), progressAtIndex: curStep)
                break;
            }
        }
        
        let duration = (self.animationDuration / Double(numberOfSteps)) * progress
        let toValue   = min(fabs(progress / Double(numberOfSteps)),1.0) // clamp
        
        
        // Central image
        
        if let imgLayer = self.imageLayer {
            
            imgLayer.animateProgress( 0,
                toValue: toValue,
                beginTime: self.beginTime,
                duration: duration,
                delegate: self)
        }
        
        // Central number
        
        if let numberLayer = self.numberLayer {
            
            let number:Double
            
            if(self.stepText){
                number = Double(numberOfSteps)
            }else{
                number = toValue
            }
            if ( self.animation ){
                
                numberLayer.animateNumber(  0.0,
                    toValue:number,
                    beginTime:self.beginTime,
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
    
    func getProgressAtIndex(index:Int) -> Double
    {
        assert(index < self.dataSteps.count, "out of bounds.")
        
        if(index >= self.dataSteps.count) {
            return 0
        }
        
        return (self.dataSteps[index] as! OMStepData).progress
    }
    
    //
    //
    //
    
    func animateGradientStartRadius(step:OMStepData,duration:NSTimeInterval, beginTime:NSTimeInterval)
    {
        let animationGradientStartRadius = CABasicAnimation(keyPath: "startRadius")
        
        //            animation.fromValue =  NSValue (CGPoint: CGPoint(x:0,y:0))
        //            animation.toValue   =  NSValue (CGPoint:bounds.size.center())
        
        
        animationGradientStartRadius.fromValue = (radius - borderWidth)
        animationGradientStartRadius.toValue   = radius
        
        animationGradientStartRadius.duration = duration
        
        animationGradientStartRadius.removedOnCompletion = false
        animationGradientStartRadius.additive = true
        animationGradientStartRadius.fillMode = kCAFillModeForwards
        animationGradientStartRadius.delegate = self
        
        // Current animation beginTime
        
        animationGradientStartRadius.beginTime = beginTime
        
        step.gradientLayer?.addAnimation(animationGradientStartRadius, forKey: "startRadius")
    }
    
    //
    //
    //
    
    func animateGradientEndRadius(step:OMStepData, duration:NSTimeInterval, beginTime:NSTimeInterval)
    {
        let animationGradientStartRadius = CABasicAnimation(keyPath: "endRadius")
        
        //            animation.fromValue =  NSValue (CGPoint: CGPoint(x:0,y:0))
        //            animation.toValue   =  NSValue (CGPoint:bounds.size.center())
        
        
        animationGradientStartRadius.fromValue = radius
        animationGradientStartRadius.toValue   = radius - borderWidth
        
        animationGradientStartRadius.duration = duration
        
        animationGradientStartRadius.removedOnCompletion = false
        animationGradientStartRadius.additive = true
        animationGradientStartRadius.fillMode = kCAFillModeForwards
        animationGradientStartRadius.delegate = self
        
        // Current animation beginTime
        
        animationGradientStartRadius.beginTime = beginTime
        
        step.gradientLayer?.addAnimation(animationGradientStartRadius, forKey: "endRadius")
    }
    
    
    //
    // Set progress at index with animation if is needed
    //
    
    func setProgressAtIndex(index:Int, progressAtIndex:Double)
    {
        assert(index < self.dataSteps.count, "out of bounds.")
        
        if(index >= self.dataSteps.count) {
            return
        }
        
        //DEBUG
        //println("--> setProgressAtIndex (index : \(index) progress: \(progress))")
        
        let step = self.dataSteps[index] as! OMStepData
        
        if  (  self.animation  ) {
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            
            animation.fromValue =  0.0
            animation.toValue   =  progressAtIndex
            
            animation.duration = (self.animationDuration / Double(self.dataSteps.count)) * progressAtIndex
            
            animation.removedOnCompletion = false
            animation.additive = true
            animation.fillMode = kCAFillModeForwards
            animation.delegate = self
            
            // Current animation beginTime
            
            if  (newBeginTime != 0)  {
                animation.beginTime = newBeginTime
            }  else  {
                animation.beginTime = self.beginTime
            }
            
            // Calculate the next animation beginTime
            
            newBeginTime = animation.beginTime + animation.duration
            
            // Add animation to the stroke of the shape layer.
            
            step.shapeLayer.addAnimation(animation, forKey: "strokeEnd")
            
            //TEST
            //self.animateGradientStartRadius(step,duration: animation.duration,beginTime:animation.beginTime)
            //self.animateGradientEndRadius(step,duration: animation.duration,beginTime:animation.beginTime)
            
            
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
        assert(self.isAngleInCircleRange(endAngle), "Invalid angle:\(endAngle). range in radians : -(2*PI)/+(2*PI)")
        assert(self.isAngleInCircleRange(startAngle), "Invalid angle:\(startAngle). range in radians : -(2*PI)/+(2*PI)")
        
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
        let percent = min(fabs(percent), 1.0) // clamp
        
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
        
        if(self.dataSteps.count > 0) {
            // The new startAngle is the last endAngle
            startAngle  = (self.dataSteps[self.dataSteps.count - 1] as! OMStepData).angle.end
        }
        return startAngle;
    }
    
    //
    // Remove the gradient mask without destroy it
    //
    
//    private func removeGradient(step:OMStepData) {
//        
//        step.shapeLayer.strokeColor = step.color.CGColor
//        
//        if(step.gradientLayer?.superlayer != nil) {
//            step.gradientLayer?.removeFromSuperlayer()
//        }
//        
//        self.layer.addSublayer(step.shapeLayer)
//        
//        self.layer.setNeedsDisplay();
//    }
//    
//    //
//    // Add the gradient mask
//    //
//    
//    private func addGradient(step:OMStepData) {
//        
//        step.shapeLayer.strokeColor = UIColor.blackColor().CGColor
//        
//        step.gradientLayer?.mask = step.shapeLayer
//        
//        if (step.gradientLayer?.superlayer == nil) {
//            self.layer.addSublayer(step.gradientLayer)
//        }
//        
//        self.layer.setNeedsDisplay();
//    }
    
    //
    // Set Up the gradient layer mask
    //
    
    private func setUpGradientLayer(step:OMStepData) {
        
        /// Setup the step gradient layer mask
        
        if (step.gradientLayer == nil) {
            
            if (DEBUG_GRADIENT == true) {
                if((step.index % 3) == 0){
                    step.gradientType = OMGradientType.Axial
                }else if((step.index % 3) == 1){
                    step.gradientType = OMGradientType.None
                }else{
                    step.gradientType = OMGradientType.Radial
                }
            }
            
            if (step.gradientType == OMGradientType.Axial) {
                  self.setUpAxialGradient(step)
            } else if(step.gradientType == OMGradientType.Radial)  {
                  self.setUpRadialGradient(step)
            } else{
                return
            }
            
            // Change the anchor point of the gradient layer.
            
            // step.gradientLayer?.anchorPoint = CGPointZero;
            
            if ( DEBUG_LAYERS ){
                step.gradientLayer?.name = "step \(self.dataSteps.indexOfObject(step)) gradient"
            }
            
            /// Set up the gradient colors
            
            ///
            /// NOTE : The mask property on CALayer uses the alpha component
            ///            of the mask layer to determine what should be visible and not
            
            
            var hiColor:CGColorRef
            var loColor:CGColorRef
            
            switch(step.gradientClr)
            {
            case .Brightness:
                hiColor = step.color.colorWithBrightnessFactor(1.0).CGColor
                loColor = step.color.colorWithBrightnessFactor(0.4).CGColor
                break;
            case .Clear:
                hiColor = UIColor.clearColor().CGColor
                loColor = step.color.CGColor
                break;
            case .Gloss:
                hiColor = step.color.colorWithAlpha(0.0).CGColor
                loColor = step.color.colorWithAlpha(1.0).CGColor
                
                if(step.gradientType == OMGradientType.Radial){
                    (step.gradientLayer as? OMRadialGradientLayer)!.options = CGGradientDrawingOptions(kCGGradientDrawsAfterEndLocation)
                }
                
                break;
            case .White:
                
                hiColor = step.color.CGColor
                loColor = UIColor.whiteColor().CGColor //step.color.next()!.CGColor
                break
            case .Black:
                
                hiColor = step.color.CGColor
                loColor = UIColor.blackColor().CGColor //step.color.next()!.CGColor
                break;
                
            case .Next:
                
                hiColor = step.color.CGColor
                loColor = step.color.next()!.CGColor //step.color.next()!.CGColor
                break;
            }
            
            if (step.gradientType == .Radial) {
                (step.gradientLayer as? OMRadialGradientLayer)!.colors = [loColor,hiColor]
            } else {
                (step.gradientLayer as? CAGradientLayer)!.colors = [loColor,hiColor]
            }
            
            
            //step.gradientLayer?.locations = [0,1]
            
        }
    
        // Update the mask frame
        
        if(step.gradientLayer?.frame != bounds){
            
            step.gradientLayer?.frame = bounds
            
            // Mark the gradient for update because has a new frame.
            
            step.gradientLayer?.setNeedsDisplay()
        }
        
    }
    
//    override var bounds:CGRect
//    {
//        willSet
//        {
//            super.bounds = bounds
//            
//            for (index, step) in enumerate(self.dataSteps )
//            {
//                let curStep = step as! OMStepData
//                
//                curStep.gradientLayer?.frame = bounds
//            }
//        }
//    }
    
    
    
    //
    // Set up the basic progress layers
    //
    
    private func setUpLayers(step:OMStepData, startAngle:Double, endAngle:Double)
    {
        //DEBUG
        //println("setUpLayers:\(step.index) \(OMAngle(startAngle: startAngle, endAngle: endAngle))")
        
        if ( step.gradientType != .None ) {
            self.setUpGradientLayer(step)
        }
        
        self.setUpProgressLayer(step,startAngle:startAngle,endAngle:endAngle)
        
        self.setUpWellLayer(step)
    }
    
    //
    // Set Up the shape layer
    //
    
    private func setUpProgressLayer(step:OMStepData, startAngle:Double, endAngle:Double)
    {
        let arcAngle : Double
        
        assert( startAngle != endAngle,
            "The start angle and the end angle cannot be the same. angle: \(startAngle.radiansToDegrees())")
        
        if ( DEBUG_LAYERS ){
            step.shapeLayer.name = "step \(self.dataSteps.indexOfObject(step)) shape"
        }
        
        
        /// Calculate the angle of arc length needed for the rounded head in radians
        
        if  (roundedHead)  {
            arcAngle = Double(borderWidth * 0.5) / Double(radius)
        }  else  {
            arcAngle = 0.0
        }
        
//        let r = radius
//        let o = outerRadius
//        let i = innerRadius
//        let b = borderWidth
        
        let bezier = UIBezierPath(  arcCenter:bounds.size.center(),
            radius: innerRadius,
            startAngle:CGFloat(startAngle + arcAngle ),
            endAngle:CGFloat(endAngle - arcAngle ),
            clockwise: true)
        
        step.shapeLayer.path            = bezier.CGPath
        step.shapeLayer.backgroundColor = UIColor.clearColor().CGColor
        step.shapeLayer.fillColor       = nil
        step.shapeLayer.strokeColor     = (  step.gradientType != .None  ) ? UIColor.blackColor().CGColor : step.color.CGColor
        step.shapeLayer.lineWidth       = self.borderWidth
        
        if ( roundedHead ) {
            step.shapeLayer.lineCap = kCALineCapRound
        }
        
        step.shapeLayer.strokeStart = 0.0
        step.shapeLayer.strokeEnd   = 0.0
        
        // shadow
        
        //        step.shapeLayer.shadowOpacity = self.shadowOpacity
        //        step.shapeLayer.shadowOffset = self.shadowOffset
        //        step.shapeLayer.shadowRadius = self.shadowRadius
        
        // DO  NOT WORK
        //        step.imageLayer.shadowOpacity = self.shadowOpacity
        //        step.imageLayer.shadowOffset = self.shadowOffset
        //        step.imageLayer.shadowRadius = self.shadowRadius
        
    
        
        if step.gradientLayer != nil {
            
            // When setting the mask to a new layer, the new layer must have a nil superlayer
            
            step.gradientLayer?.mask = step.shapeLayer
            
            self.layer.addSublayer(step.gradientLayer)
            
        } else {
            
            self.layer.addSublayer(step.shapeLayer)
            
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
                    step.wellLayer?.name = "step \(self.dataSteps.indexOfObject(step)) well"
                }
            }
            
            // This layer uses the shape path
            
            step.wellLayer?.path            = step.shapeLayer.path
            
            step.wellLayer?.backgroundColor = UIColor.clearColor().CGColor
            step.wellLayer?.fillColor       = nil
            step.wellLayer?.strokeColor     = stepWellColor.CGColor
            step.wellLayer?.lineWidth       = self.borderWidth
            
            // Activate shadow only if exist space between steps.
            
            if ( self.stepSeparator ) {
                
                step.wellLayer?.shadowOpacity = self.shadowOpacity
                step.wellLayer?.shadowOffset  = self.shadowOffset
                step.wellLayer?.shadowRadius  = self.shadowRadius
                step.wellLayer?.shadowColor   = self.shadowColor.CGColor
            }
            
            // Same as shape layer
            step.wellLayer?.lineCap = step.shapeLayer.lineCap
            
            // Add the layer behind the other layers
            
            self.layer.insertSublayer(step.wellLayer, atIndex:0)
        }
    }
    
    //
    // Remove all layers from the superlayer.
    //
    
    private func removeAllSublayersFromSuperlayer()
    {
        for (index, step) in enumerate(self.dataSteps )
        {
            let curStep = step as! OMStepData
            
            // Remove the gradient layer mask
            
            curStep.gradientLayer?.removeFromSuperlayer()
            
            curStep.wellLayer?.removeFromSuperlayer()
            
            curStep.imageLayer?.removeFromSuperlayer()
            
            curStep.textLayer?.removeFromSuperlayer()
            
            curStep.shapeLayer.removeFromSuperlayer()
        }
        
        // Remove the center image layer
        
        self.imageLayer?.removeFromSuperlayer()
        
        // Remove the number layer
        
        self.numberLayer?.removeFromSuperlayer()
    }
    
    
    // MARK: Text layer
    
    func updateNumericalLayer()
    {
        if let numberLayer = self.numberLayer
        {
            numberLayer.fontStrokeWidth = self.fontStrokeWidth
            numberLayer.fontStrokeColor = self.fontStrokeColor
            numberLayer.backgroundColor = self.fontBackgroundColor.CGColor;
            numberLayer.formatStyle = self.numberStyle()
            numberLayer.setFont(self.fontName, fontSize:self.fontSize)
            numberLayer.foregroundColor = self.fontColor
            
            // The percent is represented from 0.0 to 1.0
            
            let numberToRepresent = (self.percentText) ? 1 : self.dataSteps.count;
            
            let size = numberLayer.frameSizeLengthFromNumber(numberToRepresent)
            
            numberLayer.frame = self.bounds.size.center().centerRect( size )
        }
    }
    
    func numberStyle() -> CFNumberFormatterStyle
    {
        return ( self.percentText ) ? CFNumberFormatterStyle.PercentStyle : CFNumberFormatterStyle.NoStyle
    }
    
    func setUpNumericalLayer()
    {
        if ( self.numberLayer == nil ) {
            self.numberLayer = OMNumberLayer(number: 0, formatStyle: self.numberStyle(), alignmentMode: "center")
            
            if ( DEBUG_LAYERS )  {
                self.numberLayer?.name = "text layer"
            }
        }
        
        self.updateNumericalLayer()
    }
    
    //
    // Layout the subviews
    //
    
    override func layoutSubviews()
    {
        // DEBUG
        //println("(\(self.layer.name)) --> layoutSubviews(\(frame))")
        
        super.layoutSubviews()
        
        self.updateLayerTree()
    }
    
    //
    // Calculate the point for the image and/or text at the angle.
    //
    
    private func anglePoint(angle:Double, align:OMAlign) -> CGPoint
    {
        // .AlignMid (default)
        
        var newRadius:Double = Double(innerRadius)
        
        if(align == .AlignMid) {
            
        }else if(align == .AlignCenter){
            
            //                println("image center max side : \(self.image?.size.max())")
            //                println("max side of step images : \(self.maxImageSize.max())")
            //                println("max side of number layer : \(self.numberLayer?.frame.size.max())")
            
            //                if(self.image != nil){
            //                    newRadius = Double( self.image!.size.max() )
            //                }else{
            //                    newRadius = Double( maxImageSize.max() )
            //                }
            
            newRadius = Double(radius - self.borderWidth)
            
        }else if(align == .AlignBorder){
            
            newRadius = Double( radius )
            
        }else{
            
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
        for (index, step) in enumerate(self.dataSteps)
        {
            let curStep = step as! OMStepData
            
            if(curStep.imageLayer != nil){
                if ( DEBUG_LAYERS ){
                    curStep.imageLayer!.name = "step \(index) image"
                }
                self.layer.addSublayer(curStep.imageLayer)
            }
        }
    }
    
    private func addStepTextLayers()
    {
        /// Add all steps texts
        
        for (index, step) in enumerate(self.dataSteps)
        {
            let curStep = step as! OMStepData
            
            if(curStep.textLayer != nil){
                if ( DEBUG_LAYERS ){
                    curStep.textLayer!.name = "step \(index) text"
                }
                self.layer.addSublayer(curStep.textLayer)
            }
        }
    }
    
    private func addCenterImage()
    {
        if (self.imageLayer != nil){
            
            imageLayer!.frame = bounds.size.center().centerRect(self.image!.size)
            
            if ( DEBUG_LAYERS ){
                self.imageLayer!.name = "center image"
            }
            
            self.layer.addSublayer(self.imageLayer)
        }
    }
    
    //
    // Create all the necesary layers
    //
    
    private func updateLayerTree()
    {
        /// First, remove all layers
        
        self.removeAllSublayersFromSuperlayer()
        
        /// set Up the center numerical text layer.
        
        if (self.percentText || self.stepText) {
            self.setUpNumericalLayer()
            
        }
        
        //
        // Recalculate the step layers.
        //
        
        /// First create and setup the position of the text and image step layers
        
        let radius_2 = Double(radius * 2.0)  // Avoid to divide by 2 each s0 element calculation
        
        for (index, step) in enumerate(self.dataSteps)
        {
            let curStep = step as! OMStepData
            
            // Do not use separator.
            
            curStep.separatorAngleHalf = 0.0
            
            if ( self.stepSeparator ) {
                
                // The separator is a ratio of step angle length
                
                if ( self.separatorRatio > 0.0 ) {
                    let radiansPerStep = (M_PI * 2) / Double(self.dataSteps.count)
                    curStep.separatorAngleHalf = (self.separatorRatio * radiansPerStep) * 0.5
                } else {
                    
                    // The separator is fixed
                    
                    curStep.separatorAngleHalf = self.separatorFixed
                }
            }
            
            /// Image
            
            if let img = curStep.image {
                
                if ( self.separatorIsTheImage ) {
                    
                    // division by a number mul 2 is the same that div by 2
                    
                    curStep.separatorAngleHalf = Double(img.size.hypot()) / radius_2
                }
                
                // Create the progress image layer
                
                if ( curStep.imageLayer == nil ) {
                    curStep.imageLayer = OMProgressImageLayer(image: img)
                    
                    if ( DEBUG_LAYERS ){
                        curStep.imageLayer?.name = "step \(self.dataSteps.indexOfObject(curStep)) image"
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
                
                curStep.imageLayer?.frame = self.anglePoint(angle, align: curStep.imageAlign).centerRect(img.size)
                

                // Rotate the layer
                
                if(curStep.imageOrientationToAngle){

                    curStep.imageLayer?.angleOrientation = (angle - self.startAngle)
                }
                
                // Sets the layer frame.
                
                
                
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
                    curStep.textLayer?.name = "step \(self.dataSteps.indexOfObject(step)) text"
                }
                
                // Configure the step text layer font
                
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
                
                curStep.textLayer?.frame = self.anglePoint(angle, align: curStep.textAlign).centerRect(sizeOfText!)
                
                if(curStep.textOrientationToAngle){
                    curStep.textLayer?.angleOrientation = (angle - self.startAngle)
                }
            }
        }
        
        ///
        
        // self.assertIfOverflow2PIRadians()
        
        /// Create the layers for each step.
        
        for (index, step) in enumerate(self.dataSteps)
        {
            let curStep = step as! OMStepData
            
            if ( self.stepSeparator ) {
                
                if(index + 1 < self.dataSteps.count ){
                    
                    let nextStep = self.dataSteps[index+1] as! OMStepData
                    
                    //DEBUG
                    //println("angle arc :\(nextStep.separatorAngleHalf + step.separatorAngleHalf)")
                    
                    setUpLayers(curStep,
                        startAngle: curStep.angle.start + curStep.separatorAngleHalf,
                        endAngle: curStep.angle.end - nextStep.separatorAngleHalf)
                }else{
                    let firstStep = self.dataSteps.firstObject as! OMStepData
                    
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
        
        if(NO_IMAGES == false){
            self.addCenterImage()
        }
        
        
        /// Add all steps image
        if(NO_IMAGES == false){
            self.addStepImageLayers()
        }

        
        /// Add all steps texts
        
        if(NO_TEXT == false){
            self.addStepTextLayers()
        }
    
        
        /// Add the text layer.
        
        if(NO_TEXT == false){
            self.layer.addSublayer(self.numberLayer)
        }
        
        
        //if ( DEBUG_LAYERS ){
        //    self.dumpLayers(0,layer:self.layer)
        //}
        
        //self.updateProgress();
        //
        //        self.validLayerTree = true
        //        self.layerTreeSize  = self.bounds.size
        
        
        //DEBUG
        if ( DEBUG_STEPS ){
            self.dumpAllSteps()
        }
    }
    
    
    
    // MARK: Debug functions
    
    private func dumpAllSteps()
    {
        for (index, step) in enumerate(self.dataSteps) {
            println("\(index): \(step as! OMStepData)")
        }
    }
    
    
    private func dumpLayers(level:UInt, layer:CALayer)
    {
        for (index, lay) in enumerate(layer.sublayers) {
            
            let curLayer = lay as! CALayer
            
            println("[\(level)] \(curLayer.name)")
            
            if(curLayer.sublayers != nil){
                dumpLayers(level+1, layer: curLayer);
            }
        }
    }
    
    // MARK: Consistency functions
    
    private func assertIfOverflow2PIRadians()()
    {
        var rads:Double = 0
        
        for var index = 0; index < self.dataSteps.count ; ++index
        {
            let step = self.dataSteps[index] as! OMStepData
            
            if ( self.stepSeparator ) {
                
                if(index + 1 < self.dataSteps.count ) {
                    
                    let nextStep = self.dataSteps[index+1] as! OMStepData
                    
                    rads += OMAngle(startAngle: step.angle.start + step.separatorAngleHalf,
                        endAngle: step.angle.end - nextStep.separatorAngleHalf).length()
                    
                    rads += nextStep.separatorAngleHalf + step.separatorAngleHalf
                }else{
                    let firstStep = self.dataSteps.firstObject as! OMStepData
                    
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
}
