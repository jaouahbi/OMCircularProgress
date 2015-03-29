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
//  OMCircularProgressStepperView.swift
//
//  Created by Jorge Ouahbi on 19/1/15.
//
//  version 0.1 (29-3-2015)

//  Dynamic calculation of the maximun image size.
//  Image and text orientation to angle option
//


#if os(iOS)
    import UIKit
    #elseif os(OSX)
    import AppKit
#endif


//DEBUG
let NO_GRADIENT = false
let DEBUG_LAYERS =  false
let NO_WELL = false
let NO_ANIMATE_GRADIENT = true
let DEBUG_SET_STEP_ID = false
var GLOBAL_INDEX:Int = 0


let OMCompleteProgress:Double = Double.infinity
let OMWellProgressDefaultColor:UIColor = UIColor(white: 0.9, alpha: 1.0)



//class LayerAnimation
//{
//    func flipLayerX(layer:CALayer, duration:CFTimeInterval,delay:CFTimeInterval)
//    {
////        rotate = 0
////        scaleX = 1
////        scaleY = 1
//        
//        var perspective = CATransform3DIdentity
//        perspective.m34 = -1.0 / layer.frame.size.width/2
//        
//        let animation = CABasicAnimation(keyPath: "transform")
//        
//        let trans = CATransform3DConcat(perspective, CATransform3DMakeRotation(CGFloat(M_PI), 0, 1, 0))
//        
//        animation.fromValue = NSValue(CATransform3D:CATransform3DMakeRotation(0, 0, 0, 0))
//        animation.toValue = NSValue(CATransform3D:trans)
//        animation.duration = duration
//        animation.beginTime = CACurrentMediaTime() + delay
//        animation.timingFunction = getTimingFunction(curve)
//    }
//    
//    func flipLayerY(layer:CALayer, duration:CFTimeInterval, delay:CFTimeInterval)
//    {
//        var perspective = CATransform3DIdentity
//        perspective.m34 = -1.0 / layer.frame.size.width/2
//        
//        let animation = CABasicAnimation(keyPath: "transform")
//        let trans     = CATransform3DConcat(perspective,CATransform3DMakeRotation(CGFloat(M_PI), 1, 0, 0))
//        
//        animation.fromValue = NSValue(CATransform3D:CATransform3DMakeRotation(0, 0, 0, 0))
//        animation.toValue = NSValue(CATransform3D:trans)
//        animation.duration = duration
//        animation.beginTime = CACurrentMediaTime() + delay
//        animation.timingFunction = getTimingFunction(curve)
//    }
//}

// MARK: - Types



/// The styles permitted for the progress bar.
/// NOTE:  You can set and retrieve the current style of progress view through the progressViewStyle property.

public enum OMCircularProgressViewStyle : Int
{
    case Default
    case Stepper
    
    init()
    {
        self = Default
    }
}


/// The type of the gradient.

public enum OMGradientType : Int
{
    /// A linear gradient.
    case Linear
    
    /// A radial gradient.
    case Radial
    
    init() {
        self = Linear
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
        return "[\(degreeS)° to \(degreeE)°]:\(sizeOfAngle)°"
    }
    
    override var description: String {
        return debugDescription;
    }
}


class OMStepData : NSObject, DebugPrintable, Printable
{
    /// Basic
    
    var angle: OMAngle!                          // step angle
    var color:UIColor!
    var shapeLayer:CAShapeLayer! = CAShapeLayer()
    
    /// Gradient
    
    var gradient:Bool = true
    var gradientLayer:OMGradientLayer?          // optional gradient layer mask
    
    //
    // Well layer.
    //
    
    var wellLayer:CAShapeLayer?                 //
    var wellColor:UIColor?  = OMWellProgressDefaultColor
    

    /// Text
    
    var text:String?                 // optional step text
    var textLayer:OMTextLayer?
    var textAlign:OMAlign = .AlignMid
    var textOrientationToAngle  : Bool = true
    
    //
    // Step image
    //
    
    var imageLayer:OMProgressImageLayer?                 // optional image layer
    var image : UIImage?                                 // optional image
    var imageAlign : OMAlign = .AlignBorder
    var imageOrientationToAngle  : Bool = true
    
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
            self.gradient = false;
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
    
    //    func animateGradient()
    //    {
    //        //DEBUG
    //        //println("animating \(self.gradientLayer?.colors.count) colors (\(index))")
    //
    //        // Update the colors on the model layer
    //
    //        let fromColors = self.gradientLayer?.colors
    //
    //        let toColors = self.shiftColors(fromColors!)
    //
    //        assert(fromColors?.count == toColors.count, "Unexpected size of colors")
    //
    //        self.gradientLayer?.colors = toColors as! [AnyObject];
    //
    //        // Create an animation to slowly move the hue gradient left to right.
    //
    //        let animation = CABasicAnimation(keyPath:"colors")
    //
    //        animation.fromValue = fromColors
    //        animation.toValue = toColors
    //        animation.duration = 0.01
    //        animation.removedOnCompletion = true
    //        animation.fillMode = kCAFillModeForwards
    //        animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear)
    //        animation.delegate = self
    //
    //        // Add the animation to our layer
    //
    //        self.gradientLayer?.addAnimation(animation, forKey: "animateGradient")
    //    }
    
    
    //    override func animationDidStart(anim: CAAnimation!){
    //
    //    }
    //
    //    override func animationDidStop(anim: CAAnimation!, finished flag: Bool)
    //    {
    //        //self.animateGradient()
    //    }
    
    
    override var debugDescription : String {

        let degreeAngle = round(separatorAngleHalf.radiansToDegrees());
        let gradientString  = gradient ? "gradient(\(gradientLayer!.type))" : ""
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

class OMCircularProgressStepperView: UIView {
    
    private(set) var dataSteps: NSMutableArray = []
    private var imageLayer:OMProgressImageLayer?           // center image layer
    private var numberLayer:OMNumberLayer?         // center number layer
    private var validLayerTree: Bool  = false
    private var layerTreeSize: CGSize = CGSizeZero
    private var beginTime: NSTimeInterval = 0;
    private var newBeginTime: NSTimeInterval = 0;
    
    // Unused
    
    var progressViewStyle:OMCircularProgressViewStyle = OMCircularProgressViewStyle.Stepper
    
    
    // Animation
    var animation : Bool = true;
    var animationDuration : NSTimeInterval = 1.0

    
    // Component Behavior
    
    
    var startAngle : Double = -90.degreesToRadians() {
        didSet{
            setNeedsLayout()
        }
    }
    
    var separatorRatio: Double = 0
    {
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
//            if( roundedHead ){
//                roundedHead = ( self.thicknessRatio < self.roundedHeadThicknessThreshold );
//            }
            setNeedsLayout();
        }
    }
    
    var radius : CGFloat {
        get {
            return (bounds.size.min() * 0.5) - (maxImageSize().max() * 0.5) ;
        }
    }
    
    var lineWidth : CGFloat {
        get {
            return thicknessRatio * radius
        }
    }
    
    var thicknessRatio : CGFloat = 0.1
    {
        didSet {
            thicknessRatio = min(fabs(thicknessRatio),1.0)
            
            //checkGradient();
            
            setNeedsLayout();
        }
    }
    
    
    override func animationDidStart(anim: CAAnimation!){
        //DEBUG
        //println("--> animationDidStart:\((anim as! CABasicAnimation).keyPath) : \((anim as! CABasicAnimation).beginTime) ")
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool)
    {
        //DEBUG
        //println("<-- animationDidStop:\((anim as! CABasicAnimation).keyPath)")
    }
    

    // Gradient mask
    
    var gradient:Bool = true
    {
        didSet
        {
            /// Reconfigure the gradient
            
            if(oldValue != self.gradient) {
                for var index = 0; index < dataSteps.count ; ++index {
                    let step = (dataSteps[index] as! OMStepData)
                    step.gradient = gradient
                    
                    if(gradient == false){
                        self.removeGradient(step)
                    }else{
                        self.addGradient(step)
                    }
                }
            }
        }
    }
    
    func maxImageSize() -> CGSize
    {
        var maxSize:CGSize = CGSizeZero
        
        for var i = 0; i < self.dataSteps.count ; ++i
        {
            let step = self.dataSteps[i] as! OMStepData
            if let img = step.image{
                maxSize = maxSize.max(img.size)
            }
        }
        return maxSize
    }
    
//    private func checkGradient()
//    {
//        if(self.thicknessRatio <= self.gradientRadialThicknessThreshold && self.gradientType == .Radial){
//            println("Unsupported behavior for a radial gradient.")
//        }
//    }
    
    var gradientDirection:OMGradientDirection = .Vertical
    var gradientType:OMGradientType = .Linear
    {
        didSet
        {
            // Reconfigure the gradient
            
            if(oldValue != self.gradientType)
            {
                //checkGradient()
                var createLayers:Int = 0
                
                for var index = 0; index < dataSteps.count ; ++index
                {
                    let step = dataSteps[index] as! OMStepData
                    
                    if(step.gradient)
                    {
                        if(step.gradientLayer?.isKindOfClass(CAGradientLayer) == true &&
                            self.gradientType == OMGradientType.Radial) ||
                            (step.gradientLayer?.isKindOfClass(OMGradientLayer) == true &&
                                self.gradientType == OMGradientType.Linear)
                        {
                            if(self.gradientType == OMGradientType.Linear){
                                self.setUpLinearGradient(step)
                            }else{
                                self.setUpRadialGradient(step)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func setUpLinearGradientDirection()
    {
        if(self.gradientDirection == .Vertical)
        {
            self.gradientStartPoint = CGPoint(x: 0.5, y:0.0);
            self.gradientEndPoint = CGPoint(x: 0.5, y:1.0);
            
        }
        else if(self.gradientDirection == .Horizontal)
        {
            self.gradientStartPoint = CGPoint(x: 0.0, y:0.5);
            self.gradientEndPoint =  CGPoint(x: 1.0, y:0.5);
        }
    }
    
    private (set) var gradientStartPoint: CGPoint = CGPointZero
    private (set) var gradientEndPoint: CGPoint  = CGPointZero
    private func setUpRadialGradient(step:OMStepData)
    {
        step.gradientLayer?.type = kOMGradientLayerRadial
        
//        step.gradientLayer?.startCenter = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5)
//        step.gradientLayer?.endCenter = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5)
        
        step.gradientLayer?.startCenter = self.center
        step.gradientLayer?.endCenter   = self.center
        
        step.gradientLayer?.startRadius = self.radius - self.lineWidth
        step.gradientLayer?.endRadius   = self.radius
    }
    
    private func setUpLinearGradient(step:OMStepData)
    {
        step.gradientLayer?.type = kCAGradientLayerAxial
        
        self.setUpLinearGradientDirection()
        
        step.gradientLayer?.startPoint = self.gradientStartPoint;
        step.gradientLayer?.endPoint   = self.gradientEndPoint;
    }
    
    
    // Force layout even the view has the same size
    // USEME
    private func invalidateTreeLayerAndLayout() {
        self.validLayerTree = false
        setNeedsLayout()
    }
    
    
    var progress: Double = 0.0 {
        didSet
        {
            let rads = self.numberOfRadians()
            
            assert(rads == 2 * M_PI, "Unexpected consistence of circle radians (2 * π) != \(rads)")
            
            if (progress == OMCompleteProgress) {
                
                progress = Double(dataSteps.count)
            }
            setNeedsLayout()
            //self.updateProgress()
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
    
    // MARK: Consistency functions
    
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
    
    
    // MARK:
    
    private func updateProgress()
    {
        //DEBUG
        //println("--> updateProgress (progress: \(progress))")
        
        if(progress == 0){
            // Nothig to update
            return
        }
        
        let numberOfSteps = self.dataSteps.count
        
        //DEBUG
        //assert(progress <= Double(numberOfSteps),"Unexpected progress \(progress) max \(numberOfSteps) ")
        
        let claped_progress = min(fabs(progress),Double(numberOfSteps))
        
        CATransaction.begin()
        
        let stepsDone   = Int(self.progress);
        let curStep = self.progress - floor(self.progress);
        
        self.beginTime = CACurrentMediaTime()
        
        for var i = 0; i < Int(numberOfSteps) ; ++i
        {
            //DEBUG
            //println("for \(i) of \(numberOfSteps) in  \(progress) :  done:\(stepsDone) current:\(curStep)")
            
            if(i < stepsDone) {
                self.setProgressAtIndex(Int(i), progress:1.0)
            } else {
                self.setProgressAtIndex(Int(i), progress: curStep)
                break;
            }
        }
        
        let duration = (self.animationDuration / Double(numberOfSteps)) * progress
        let toValue   = min(fabs(progress / Double(numberOfSteps)),1.0)
        
        if let imgLayer = self.imageLayer {
            
            imgLayer.animateProgress( 0,
                toValue: toValue,
                beginTime: self.beginTime,
                duration: duration,
                delegate: self)
        }
        
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
        println("<-- updateProgress (progress: \(progress))")
    }

    func getProgressAtIndex(index:Int) -> Double
    {
        assert(index < self.dataSteps.count, "out of bounds.")
        
        if(index >= self.dataSteps.count) {
            return 0
        }
        
        let step = self.dataSteps[index] as! OMStepData
        
        return Double(step.shapeLayer.strokeEnd)
    }
    
    func setProgressAtIndex(index:Int, progress:Double)
    {
        assert(index < self.dataSteps.count, "out of bounds.")
        
        //DEBUG
        //println("begin setProgressAtIndex (index : \(index) progress: \(progress))")
        
        let step = self.dataSteps[index] as! OMStepData
        
        
        //            if(NO_ANIMATE_GRADIENT == false){
        //                step.animateGradient()
        //            }
        
        if(self.animation)
        {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            
            animation.fromValue =  0.0
            animation.toValue   =  progress
            
            animation.duration = (self.animationDuration / Double(self.dataSteps.count)) * progress
            
            animation.removedOnCompletion = false
            animation.additive = true
            animation.fillMode = kCAFillModeForwards
            animation.delegate = self
            
            if (newBeginTime != 0) {
                animation.beginTime = newBeginTime
            }else{
                animation.beginTime = self.beginTime
            }
            
            newBeginTime = animation.beginTime + animation.duration
            
            step.shapeLayer.addAnimation(animation, forKey: "strokeEnd")
            
            if let imgLayer = step.imageLayer {
                
                imgLayer.animateKeyPath("progress",
                    fromValue: animation.fromValue.doubleValue,
                    toValue:  animation.toValue.doubleValue,
                    beginTime: animation.beginTime,
                    duration: animation.duration ,
                    delegate: self)
            }
        }
        else
        {
            // remove the default animation from strokeEnd
            
            step.shapeLayer.actions = ["strokeEnd" as NSString : NSNull()]
            step.shapeLayer.strokeEnd = CGFloat(progress)
        }
    }
    
    
    func newStep(startAngle:Double, endAngle:Double, color:UIColor!) -> OMStepData
    {
        assert(self.isAngleInCircleRange(endAngle), "Invalid angle:\(endAngle). range in radians : -(2*PI)/+(2*PI)")
        assert(self.isAngleInCircleRange(startAngle), "Invalid angle:\(startAngle). range in radians : -(2*PI)/+(2*PI)")
        
        let step = OMStepData(startAngle:startAngle,endAngle:endAngle,color:color)
        
        // Save the step
        
        dataSteps.addObject(step)
        
        return step;
    }
    
    
    func newStep(angle:Double, color:UIColor!) -> OMStepData {
        
        let startAngle = getStartAngle()
        
        return newStep(  startAngle,
                            endAngle:startAngle + angle,
                            color:color );
    }
    
    
    func  newStepWithPercent(startAngle:Double, percent:Double, color:UIColor!) -> OMStepData
    {
        let percent = min(fabs(percent), 1.0)
        
        let step = OMStepData(startAngle:startAngle,percent:percent,color:color)
        
        return step
    }
    
    func newStepWithPercent(percent:Double, color:UIColor!) -> OMStepData {
        
        return newStepWithPercent(getStartAngle(),percent: percent, color: color);
    }
    
    
    private func getStartAngle() -> Double
    {
        var startAngle = self.startAngle;
        
        if(self.dataSteps.count > 0){
            // the new startAngle is the last endAngle
            startAngle  = (self.dataSteps[self.dataSteps.count - 1] as! OMStepData).angle.end
        }
        return startAngle;
    }
    
    private func removeGradient(step:OMStepData)
    {
        step.shapeLayer.strokeColor = step.color.CGColor
        
        step.gradientLayer?.removeFromSuperlayer()
        
        self.layer.addSublayer(step.shapeLayer)
    }
    
    private func addGradient(step:OMStepData)
    {
        step.shapeLayer.strokeColor = UIColor.blackColor().CGColor
        
        step.gradientLayer?.mask = step.shapeLayer
        
        self.layer.addSublayer(step.gradientLayer)
    }
    
    private func setUpGradientLayer(step:OMStepData)
    {
        // Setup the step gradient layer mask
        
        step.gradientLayer = OMGradientLayer()
        
        if(self.gradientType == OMGradientType.Linear){
            setUpLinearGradient(step)
        }else{
            setUpRadialGradient(step)
        }
        
        if ( DEBUG_LAYERS ){
            step.gradientLayer?.name = "step \(self.dataSteps.indexOfObject(step)) gradient"
        }
        
        step.gradientLayer?.frame = frame
        
        let arrayOfColors: [AnyObject] = step.color.colorsFromColor() as! [AnyObject]
        
        step.gradientLayer?.colors = arrayOfColors
        
        step.gradientLayer?.setNeedsDisplay()
    }
    
    private func setUpLayers(step:OMStepData, startAngle:Double, endAngle:Double)
    {
        //DEBUG
        //println("setUpLayers:\(step) from angle \(startAngle.radiansToDegrees()) to angle \(endAngle.radiansToDegrees())")
        
        if (step.gradient) {
            self.setUpGradientLayer(step)
        }
        
        self.setUpProgressLayer(step,startAngle:startAngle,endAngle:endAngle)
        
        self.setUpWellLayer(step)
        
        //self.setUpTextLayer(step)
    }
    
    
//    private func setUpTextLayer(step:OMStepData)
//    {
//        step.textLayer = CATextLayer()
//        step.textLayer!.string = step.text
//    }

    private func setUpProgressLayer(step:OMStepData, startAngle:Double, endAngle:Double)
    {
        let arcAngle :Double
        
        assert(startAngle != endAngle, "The start angle and the end angle cannot be the same. angle: \(startAngle.radiansToDegrees())")
        
        if ( DEBUG_LAYERS ){
            step.shapeLayer.name = "step \(self.dataSteps.indexOfObject(step)) shape"
        }
        
        // Calculate the angle of arc length needed for the rounded head in radians
        
        if (roundedHead) {
            
            arcAngle = Double(lineWidth * 0.5) / Double(radius)
        }
        else
        {
            arcAngle = 0.0
        }
        
        let newRadius = CGFloat(radius - (self.lineWidth * 0.5))
        
        let bezier = UIBezierPath(  arcCenter:center,
            radius: newRadius,
            startAngle:CGFloat(startAngle + arcAngle ),
            endAngle:CGFloat(endAngle - arcAngle ),
            clockwise: true)
        
        
        step.shapeLayer.path = bezier.CGPath
        step.shapeLayer.backgroundColor = UIColor.clearColor().CGColor
        step.shapeLayer.fillColor = nil
        step.shapeLayer.strokeColor = (step.gradient) ? UIColor.blackColor().CGColor : step.color.CGColor
        step.shapeLayer.lineWidth = self.lineWidth
        
        if (roundedHead) {
            step.shapeLayer.lineCap = kCALineCapRound
        }
        
        step.shapeLayer.strokeStart = 0.0
        step.shapeLayer.strokeEnd = 0.0
        
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
            
            if self.layer.sublayers != nil {
                self.layer.insertSublayer(step.gradientLayer, above:self.imageLayer)
            }else{
                self.layer.addSublayer(step.gradientLayer)
            }
        }else{
            self.layer.addSublayer(step.shapeLayer)
        }
    }
    
    //
    //
    //
    
    private func setUpWellLayer(step:OMStepData)
    {
        if let stepWellColor = step.wellColor {
            
            step.wellLayer = CAShapeLayer()
            
            if ( DEBUG_LAYERS ){
                step.wellLayer?.name = "step \(self.dataSteps.indexOfObject(step)) well"
            }
            
            step.wellLayer?.path = step.shapeLayer.path
            
            step.wellLayer?.backgroundColor = UIColor.clearColor().CGColor
            step.wellLayer?.fillColor   = nil
            step.wellLayer?.strokeColor = stepWellColor.CGColor
            step.wellLayer?.lineWidth = self.lineWidth
            
            // Activate shadow only if exist space between steps.
            
            if(self.stepSeparator)
            {
                step.wellLayer?.shadowOpacity = self.shadowOpacity
                step.wellLayer?.shadowOffset = self.shadowOffset
                step.wellLayer?.shadowRadius = self.shadowRadius
            }
            
            if(roundedHead){
                step.wellLayer?.lineCap = "round"
            }
            
            if(self.layer.sublayers != nil){
                self.layer.insertSublayer(step.wellLayer, atIndex:0)
            }else{
                self.layer.addSublayer(step.wellLayer)
            }
        }
    }
    
    private func removeAllSublayersFromSuperlayer()
    {
        for var i = 0; i < self.dataSteps.count ; ++i
        {
            let step = (self.dataSteps[i] as! OMStepData)
            
            // Remove the gradient layer mask
            
            step.gradientLayer?.removeFromSuperlayer()
            
            step.wellLayer?.removeFromSuperlayer()
            
            step.imageLayer?.removeFromSuperlayer()
            
            step.textLayer?.removeFromSuperlayer()
            
            step.shapeLayer.removeFromSuperlayer()
        }

        // center image layer
        self.imageLayer?.removeFromSuperlayer()
        // number layer
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
            
            let numberToRepresent = (self.percentText) ? 1 : self.dataSteps.count;
            
            let size = numberLayer.frameSizeLengthFromNumber(numberToRepresent)
            
            numberLayer.frame = CGRectMake(self.center.x - size.width * 0.5,
                self.center.y - size.height * 0.5,
                size.width,
                size.height)
        }
    }
    
    func numberStyle() -> CFNumberFormatterStyle
    {
        return (self.percentText) ? CFNumberFormatterStyle.PercentStyle : CFNumberFormatterStyle.DecimalStyle
    }
    
    func setUpNumericalLayer()
    {
        self.numberLayer = OMNumberLayer(number: 0, formatStyle: self.numberStyle(), alignmentMode: "center")
        
        if ( DEBUG_LAYERS ){
            self.numberLayer?.name = "text layer"
        }
        
        self.updateNumericalLayer()
    }
    
    
    override func layoutSubviews()
    {
        //DEBUG
        //println("--> layoutSubviews()")
        
        super.layoutSubviews()
        
        if(self.validLayerTree == false || self.layerTreeSize != self.bounds.size){
            
            self.newLayerTree()
        }
        else
        {
            println("Skipping layoutSubviews()")
        }
        
        //DEBUG
        //println("<-- layoutSubviews()")
    }

    //
    // Calculate the point for the image and/or text at the angle.
    //
    
    private func anglePoint(angle:Double, align:OMAlign) -> CGPoint
    {
        // .AlignMid (default)
        
        var newRadius:Double = Double(radius - (self.lineWidth * 0.5))
        
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
            
            newRadius = Double(radius - self.lineWidth)
            
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
        
        return CGPoint(x: center.x + CGFloat(newRadius)  * cos(theta), y: center.y + CGFloat(newRadius) * sin(theta))
        
    }


    private func addStepImageLayers()
    {
        for var index = 0; index < self.dataSteps.count ; ++index{
            let step = self.dataSteps[index] as! OMStepData
            if(step.imageLayer != nil){
                if ( DEBUG_LAYERS ){
                    step.imageLayer!.name = "step \(index) image"
                }
                self.layer.addSublayer(step.imageLayer)
            }
        }
    }
    
    private func addStepTextLayers()
    {
        /// Add all steps texts
        
        for var index = 0; index < self.dataSteps.count ; ++index{
            let step = self.dataSteps[index] as! OMStepData
            if(step.textLayer != nil){
                if ( DEBUG_LAYERS ){
                    step.textLayer!.name = "step \(index) text"
                }
                self.layer.addSublayer(step.textLayer)
            }
        }
    }
    
    private func addCenterImage()
    {
        if (self.imageLayer != nil){
            imageLayer!.frame = CGRect(origin:
                CGPoint(x:center.x -  self.image!.size.width * 0.5,
                    y:center.y -  self.image!.size.height * 0.5),
                size: self.image!.size)
            
            if ( DEBUG_LAYERS ){
                self.imageLayer!.name = "center image"
            }
            
            self.layer.addSublayer(self.imageLayer)
        }
    }
    //
    // Create all the necesary layers
    //
    
    private func newLayerTree()
    {
        /// First, clear all layers
        
        self.removeAllSublayersFromSuperlayer()
        
        /// set Up the center numerical text layer.
        
        if (self.percentText || self.stepText) {
            self.setUpNumericalLayer()
            
        }
        
        /// Recalculate the progress layers.
        
        let radius_2 = Double(radius * 2.0)  // Avoid to divide by 2 each s0 element calculation
        
        for var index = 0; index < self.dataSteps.count ; ++index
        {
            let step = self.dataSteps[index] as! OMStepData
            
            // Do not use separator.
            
            step.separatorAngleHalf = 0.0
            
            if (self.stepSeparator == true) {
                
                // The separator is a ratio of step angle length
                
                if(self.separatorRatio > 0.0){
                    step.separatorAngleHalf = (self.separatorRatio * ((M_PI * 2) / Double(self.dataSteps.count))) * 0.5
                }else{
                    
                    // The separator is fixed
                    step.separatorAngleHalf = self.separatorFixed
                }
            }

            /// Image
            
            if let img = step.image {
                
                if (self.separatorIsTheImage) {
                    // division by a number mul 2 is the same that div by 2
                    step.separatorAngleHalf = Double(img.size.hypot()) / radius_2
                }

                // Create the progress image layer
                
                step.imageLayer = OMProgressImageLayer(image: img)
            
                // Sets the layer frame.
                
                let imgPoint = self.anglePoint(step.angle.start, align: step.imageAlign)
                
                let origin = CGPoint(x:imgPoint.x - img.size.width  * 0.5, y:imgPoint.y - img.size.height * 0.5)
                
                step.imageLayer?.frame = CGRect(origin: origin, size:img.size)
                
                // Rotate the layer
                
                if(step.imageOrientationToAngle){
                    step.imageLayer?.angleOrientation = (step.angle.start - self.startAngle)
                    //step.imageLayer?.angleOrientation = -(step.angle.start - self.startAngle)
                }
            }
            
            /// Text
            
            if let stepText = step.text {
                
                step.textLayer = OMTextLayer(string: stepText)
                
                if ( DEBUG_LAYERS ){
                    step.textLayer?.name = "step \(self.dataSteps.indexOfObject(step)) text"
                }
                
                // TODO: make configurable
                
                step.textLayer?.setFont("Helvetica",fontSize: 14)
                
                step.textLayer?.foregroundColor = UIColor.whiteColor()
                step.textLayer?.fontStrokeColor = UIColor.blackColor()
                
                let sizeOfText = step.textLayer?.frameSizeLengthFromString(stepText)
                
                let textPoint = self.anglePoint(step.angle.mid(), align: step.textAlign)

                let origin = CGPoint(x:textPoint.x - sizeOfText!.width * 0.5, y:textPoint.y - sizeOfText!.height * 0.5)
                
                step.textLayer?.frame = CGRect(origin: origin, size:sizeOfText!)
                
                if(step.textOrientationToAngle){
                    step.textLayer?.angleOrientation = (step.angle.start - self.startAngle)
                }
            }
        }
        
        ///
    
        // self.assertOutofRadians()
        
        /// Create the layers for each step.
        
        for var index = 0; index < self.dataSteps.count ; ++index
        {
            let step = self.dataSteps[index] as! OMStepData
            
            //if(step.imageOnTop == false && self.stepSeparator == true){
            
            if(self.stepSeparator == true){
                
                if(index + 1 < self.dataSteps.count ){
                    
                    let nextStep = self.dataSteps[index+1] as! OMStepData
                    
                    //DEBUG
                    //println("angle arc :\(nextStep.separatorAngleHalf + step.separatorAngleHalf)")
                    
                    setUpLayers(step,
                        startAngle: step.angle.start + step.separatorAngleHalf,
                        endAngle: step.angle.end - nextStep.separatorAngleHalf)
                }else{
                    let firstStep = self.dataSteps.firstObject as! OMStepData
                    
                    //DEBUG
                    //println("** angle arc :\(firstStep.separatorAngleHalf + step.separatorAngleHalf)")
                    
                    setUpLayers(step,
                        startAngle:step.angle.start + step.separatorAngleHalf,
                        endAngle:step.angle.end - firstStep.separatorAngleHalf)
                }
            } else {
                setUpLayers(step,
                    startAngle:step.angle.start,
                    endAngle: step.angle.end)
            }
        }
        
        /// Add the center image
       
        self.addCenterImage()
        
        
        /// Add all steps image
   
        self.addStepImageLayers()
        
        
        /// Add all steps texts
        
        self.addStepTextLayers()
        
        
        /// Add the text layer.
        
        self.layer.addSublayer(self.numberLayer)
        
        
        if ( DEBUG_LAYERS ){
            self.dumpLayers(0,layer:self.layer)
        }
        
        self.updateProgress();
        
        self.validLayerTree = true
        self.layerTreeSize  = self.bounds.size
        
        
        //DEBUG
        self.dumpAllSteps()
    }
    
    
    // MARK: Debug
    
    private func dumpAllSteps()
    {
        for var index = 0; index < self.dataSteps.count ; ++index
        {
            let step = self.dataSteps[index] as! OMStepData
            println("\(index): \(step)")
        }
    }
    

    private func dumpLayers(level:UInt ,layer:CALayer)
    {
        for var index = 0; index < layer.sublayers?.count ; ++index{
            
            let l = layer.sublayers[index] as! CALayer
            
            println("[\(level)] \(l.name)")
            
            if(l.sublayers != nil){
                dumpLayers(level+1, layer: l);
            }
        }
    }
    
    
    private func assertOutofRadians()
    {
        var rads:Double = 0
        
        for var index = 0; index < self.dataSteps.count ; ++index
        {
            let step = self.dataSteps[index] as! OMStepData
            
            //if(step.imageOnTop == false && self.stepSeparator == true){
            
            if(self.stepSeparator == true){
                
                if(index + 1 < self.dataSteps.count ){
                    
                    let nextStep = self.dataSteps[index+1] as! OMStepData
                    
                    //DEBUG
                    //println("angle arc :\(nextStep.separatorAngleHalf + step.separatorAngleHalf)")
                    
                    rads += OMAngle(startAngle: step.angle.start + step.separatorAngleHalf,
                        endAngle: step.angle.end - nextStep.separatorAngleHalf).length()
                    
                    rads += nextStep.separatorAngleHalf + step.separatorAngleHalf
                }else{
                    let firstStep = self.dataSteps.firstObject as! OMStepData
                    
                    //DEBUG
                    //println("** angle arc :\(firstStep.separatorAngleHalf + step.separatorAngleHalf)")
                    
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
    
}
