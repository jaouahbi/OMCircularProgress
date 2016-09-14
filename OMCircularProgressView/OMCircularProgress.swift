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

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif


//TAG_LAYERS
//DEBUG_MASK
//NO_TEXT
//DUMP_STEPS
//DUMP_LAYERS
//NO_IMAGES
//NO_TEXT

//DEBUG

//let DEBUG_LAYERS = false     // very usefull
//let DEBUG_STEPS = false
//let DEBUG_NO_WELL = false
//let DEBUG_NO_TEXT = false
//let DEBUG_NO_IMAGES = false
//let DEBUG_ANIMATIONS = false
//let DEBUG_VERBOSE = false
//let DEBUG_MASK = false
//let DEBUG_ANGLES = false

// Some constants

let kControlInset:CGFloat = 20.0

// MARK: - Constant Definitions

let OMCompleteProgress:Double = Double.infinity
//let OMWellProgressDefaultColor:UIColor = UIColor(white: 0.9, alpha: 1.0)
//DEBUG
let OMWellProgressDefaultColor:UIColor = UIColor.black
let OMProgressDefaultShadowColor:UIColor = UIColor.darkGray
let OMMinSeparatorRadians: Double =  1.0.degreesToRadians()



///LogMode type. Specify what details should be included to the log
public struct ProgressOptions : OptionSet {
    
    public let rawValue: UInt
    public init(rawValue: UInt)  { self.rawValue = rawValue }
    
    //MARK:- Options
    public static let Well     = ProgressOptions(rawValue: 0)
    public static let Text     = ProgressOptions(rawValue: 1 << 0)
    public static let Image    = ProgressOptions(rawValue: 1 << 1)
    public static let Border   = ProgressOptions(rawValue: 1 << 2)
    
    /// AllOptions - Enable all options, [FileName, FuncName, Line]
    //    public static let AllOptions: LogMode = [Date, FileName, FuncName, Line]
    //    public static let FullCodeLocation: LogMode = [FileName, FuncName, Line]
}
// MARK: - Types


/// The styles permitted for the progress bar.
/// NOTE:  You can set and retrieve the current style of progress view through the progressStyle property.

public enum CircularProgressStyle : Int
{
    case directProgress
    case sequentialProgress
    
    init() {
        self = .sequentialProgress
    }
}


/**
 Image and text alignment
 
 - AlignCenter: Align to center
 - AlignMid:    Align to middle
 - AlignBorder: Align to border
 - AlignOuter:  Align to outer
 
 */


enum OMAlign : Int
{
    case center
    case middle
    case border
    case outer
    init() {
        self = .middle
    }
}

////////////////////////////////////////////////////////////////////////////////
//
// The UIControl object
//
////////////////////////////////////////////////////////////////////////////////

@IBDesignable class OMCircularProgress : UIControl {
    
    /// MARK: Contructors
    
    required init?(coder : NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    func commonInit() {
        #if DEBUG_UI
            layer.borderWidth = 1.0
            layer.borderColor = UIColor.greenColor().CGColor
        #endif
        
        //SLog.enableVisualColorLog()
    }
    
    var dataSteps: NSMutableArray   = []         // Array of OMStepData
    
    /// Center
    
    var centerImageLayer:OMProgressImageLayer?   // center image layer
    var centerNumberLayer:OMNumberLayer?         // center number layer
    
    // Animations
    
    internal var beginTime: TimeInterval    = 0;
    internal var newBeginTime: TimeInterval = 0;
    internal let prespective : CGFloat      = -1.0/500.0;
    @IBInspectable var animation : Bool     = true;
    @IBInspectable var animationDuration : TimeInterval = 1.0
    
    
    // Delegate
    weak var delegate:OMCircularProgressProtocol?
    
    
    /// Component behavior
    
    var progressStyle: CircularProgressStyle = .sequentialProgress      // Progress style
    var options      : ProgressOptions       = []                       // Progress options
    
    //
    // The start angle of the all steps.
    // default -90 degrees == 12 o'clock
    //
    
    @IBInspectable var startAngle : Double = -90.degreesToRadians() {
        didSet{
            assert(OMCircleAngle.range(angle: startAngle),
                   "Invalid angle : \(startAngle).The angle range must be in radians : -(2*PI)/+(2*PI)")
            setNeedsLayout()
        }
    }
    
    /// Set the rounded head to each step representation
    
    @IBInspectable var roundedHead : Bool = false {
        didSet {
            setNeedsLayout();
        }
    }
    
    /// Radius
    
    /// Internal Radius
    
    var innerRadius  : CGFloat {
        return self.radius - self.borderWidth;
    }
    
    /// Center Radius
    var midRadius  : CGFloat {
        return self.radius - (self.borderWidth * 0.5);
    }
    
    /// Radius
    var outerRadius  : CGFloat {
        return self.radius;
    }
    
    
    /// Private member for calculate the radius
    
    fileprivate(set) var suggestedRadius : CGFloat = 0.0
    
    /// Radius of the progress view
    
    var radius : CGFloat {
        
        set(newRadius) {
            
            suggestedRadius = newRadius
            self.setNeedsLayout()
        }
        
        get {
            
            if suggestedRadius > 0.0 {
                return suggestedRadius
            }
            
            let simpleRadius = ( bounds.insetBy(dx: kControlInset, dy: kControlInset).size.min() * 0.5)
            
            if numberOfSteps == 0 {
                // All done
                return simpleRadius;
            }
            
            // Reduce the radius
            // return (simpleRadius - self.alignExtraLength(simpleRadius)
            
            return simpleRadius
        }
    }
    
    
    /// Border width (RO)
    
    
    var borderWidth : CGFloat {
        return CGFloat(thicknessRatio * Double(radius))
    }
    
    
    
    var stepBorderRatio : Double = 0.1 {
        didSet {
            stepBorderRatio.clamp(toLowerValue: 0.0,upperValue: 1.0)
            setNeedsLayout();
        }
    }
    
    /// Border radio (default: 10%)
    
    var thicknessRatio : Double = 0.1 {
        didSet {
            thicknessRatio.clamp(toLowerValue: 0.0,upperValue: 1.0)
            setNeedsLayout();
        }
    }
    
    /// Show the well layer
    
    @IBInspectable var showWell : Bool = true {
        didSet{
            setNeedsLayout()
        }
    }
    
    // MARK: Shadow
    
    @IBInspectable var shadowText : Bool = false {
        didSet{
            setNeedsLayout()
        }
    }
    
    /// Sets shadow to the well layer
    
 /*   @IBInspectable var shadowWell : Bool = false {
        didSet{
            setNeedsLayout()
        }
    }*/
    
    //
    @IBInspectable var shadowBorder : Bool = false {
        didSet{
            setNeedsLayout()
        }
    }
    
    /// Shadow Opacity
    @IBInspectable var shadowOpacity:Float = 0.85 {
        didSet{
            setNeedsLayout()
        }
    }
    /// Shadow Offset
    @IBInspectable var shadowOffset:CGSize = CGSize(width: 0, height: 3.0){
        didSet{
            setNeedsLayout()
        }
    }
    /// Shadow Radius
    @IBInspectable var shadowRadius:CGFloat = 1.5 {
        didSet{
            setNeedsLayout()
        }
    }
    /// Shadow Color
    @IBInspectable var shadowColor:UIColor = OMProgressDefaultShadowColor {
        didSet{
            setNeedsLayout()
        }
    }
    
    // MARK: Font and Text (do no need layout)
    
    
    /// The text represent a percent number.
    var percentText:Bool = false {
        didSet{
            updateCenterNumericalLayer()
        }
    }
    
    /// The text represent a arb. text.
    var stepText:Bool = false {
        didSet{
            updateCenterNumericalLayer()
        }
    }
    
    /// The text font name
    @IBInspectable var fontName : String = "Helvetica" {
        didSet{
            updateCenterNumericalLayer()
        }
    }
    
    /// The text font color
    @IBInspectable var fontColor : UIColor = UIColor.black{
        didSet {
            updateCenterNumericalLayer()
        }
    }
    
    /// The text font size.
    @IBInspectable var fontSize : CGFloat = 12 {
        didSet {
            updateCenterNumericalLayer()
        }
    }
    /// The text font backgound color.
    @IBInspectable var fontBackgroundColor : UIColor = UIColor.clear{
        didSet {
            updateCenterNumericalLayer()
        }
    }
    /// The text font width stroke
    @IBInspectable var fontStrokeWidth : Float = -3 {
        didSet {
            updateCenterNumericalLayer()
        }
    }
    /// The text font width stroke color
    @IBInspectable var fontStrokeColor : UIColor = UIColor.clear{
        didSet {
            updateCenterNumericalLayer()
        }
    }
    
    @IBInspectable var textRadius : CGFloat = 0.0 {
        didSet {
            updateCenterNumericalLayer()
        }
    }
    
    // MARK: Images
    
    // @IBInspectable var imageShadow : Bool = true
    
    internal var centerImageScaled:UIImage? = nil
    
    @IBInspectable var centerImage : UIImage? {
        set(newValue) {
            self.centerImageScaled = newValue
            if self.centerImageScaled != nil {
                self.centerImageScaled = scaleCenterImageIfNeeded()
                if let scaledImage = self.centerImageScaled  {
                    if let centerImageLayer = centerImageLayer {
                        centerImageLayer.image = scaledImage
                    } else {
                        centerImageLayer = OMProgressImageLayer(image: scaledImage)
                        #if TAG_LAYERS
                            imageLayer?.name = "progress center image"
                        #endif
                    }
                }
            }
        }
        
        get {
            return self.centerImageScaled
        }
    }
    
    /// The center image of the component.
    
    //    @IBInspectable var image: UIImage? {
    //        didSet {
    //            if let image = image {
    //                if let imageLayer = centerImageLayer {
    //                    imageLayer.contents = image.cgImage
    //                } else {
    //                    centerImageLayer = CALayer()
    //                    centerImageLayer?.contents = image.cgImage
    //                     #if TAG_LAYERS
    //                        centerImageLayer?.name = "center image"
    //                    #endif
    //                }
    //            }
    //        }
    //    }
    
    // !!!FIXME: if progress does not exist, then the Images are hidden
    
    var progress: Double = 0.0 {
        
        didSet {
            
            DEBUG("progress: \(progress)")
            
            //let rads = numberOfRadians()
            //assert(abs(rads - 2 * M_PI) < DBL_EPSILON, "Unexpected consistence of circle radians (2 * π) != \(rads)")
            
            if (progress == OMCompleteProgress) {
                progress = Double(numberOfSteps)
            }
            
            layoutIfNeeded();
            
            updateCompleteProgress()
        }
    }
    
    
    // MARK:
    
    /**
     Update the progress stuff.
     */
    fileprivate func updateCompleteProgress()
    {
        DEBUG("updateCompleteProgress (progress: \(progress))")
        
        if progress == 0 {
            // Nothing to update
            return
        }
        
        assert(progress <= Double(numberOfSteps),"Unexpected progress \(progress) max \(numberOfSteps) ")
        
        var clamped_progress:Double = progress
        
        clamped_progress.clamp(toLowerValue: 0.0,upperValue: Double(numberOfSteps))
        
        let stepsDone   = Int(clamped_progress);
        let curStep     = clamped_progress - floor(clamped_progress);
        
        // Initialize the sequential time control vars.
        
        CATransaction.begin()
        beginTime    = CACurrentMediaTime()
        newBeginTime = 0.0
        
        for index:Int in 0..<numberOfSteps {
            
            VERBOSE("#\(index) of \(numberOfSteps) in \(progress) : done:\(stepsDone) current:\(curStep)")
            
            setStepProgress(index, stepProgress: (index < stepsDone) ?  1.0 : curStep)
        }
        
        let duration        = (animationDuration / Double(numberOfSteps)) * clamped_progress
        var toValue:Double  = (progress / Double(numberOfSteps))
        
        toValue.clamp(toLowerValue: 0.0,upperValue: 1.0)
        
        ///  center image
        weak var delegate = self
        
        if let centerImageLayer = centerImageLayer  {
            if animation  {
                // Remove all animations
                centerImageLayer.removeAllAnimations()
                centerImageLayer.animateProgress( 0,
                                                  toValue: toValue,
                                                  beginTime: beginTime,
                                                  duration: duration,
                                                  delegate: delegate)
            }
        }
        
        ///  center number
        
        if let numberLayer = centerNumberLayer {
            let number:Double = (stepText) ? Double(numberOfSteps) : toValue
            if animation  {
                // Remove all animations
                numberLayer.removeAllAnimations()
                numberLayer.animateNumber(  0.0,
                                            toValue:number,
                                            beginTime:beginTime,
                                            duration:duration,
                                            delegate:delegate)
            } else {
                numberLayer.number = toValue as NSNumber
            }
        }
        
        CATransaction.commit()
        
        DEBUG("updateCompleteProgress (progress: \(clamped_progress))")
    }
    
    
    /**
     Get the progress of the step by index
     
     - parameter index:           step index
     - returns:               step progress
     */
    
    func getStepProgress(_ index:Int) -> Double
    {
        assert(index <= numberOfSteps, "out of bounds. \(index) max: \(numberOfSteps)")
        
        if(index >= numberOfSteps) {
            return 0
        }
        
        return self[index]!.progress
    }
    
    
    /**
     Set step progress at index with animation if is needed
     
     - parameter index:           step index
     - parameter progressAtIndex: step progress
     */
    func setStepProgress(_ index:Int, stepProgress:Double) {
        
        assert(index <= numberOfSteps, "out of bounds. \(index) max: \(numberOfSteps)")
        
        if (index >= numberOfSteps) {
            return
        }
        
        DEBUG("setStepProgress (index : \(index) progress: \(stepProgress))")
        
        if let step = self[index] {
            
            if animation {
                stepAnimation(step, progress:stepProgress)
            } else {
                // Remove the default animation from strokeEnd
                
                step.shapeLayer.actions = ["strokeEnd" : NSNull()]
                
                if let shapeLayerBorder = step.shapeLayerBorder {
                    shapeLayerBorder.actions = step.shapeLayer.actions
                }
                // Simply assign the new step value
                
                step.progress = stepProgress
            }
        }
    }
    
    /**
     * Get the total number of radians
     *
     * returns: number of radians
     */
    
    func numberOfRadians() -> Double {
        return dataSteps.reduce(0){
            $0 + ($1 as! OMStepData).angle.length()
        }
    }
    
    func percentDone() -> Double {
        let radians =  numberOfRadians()
        if radians > 0 {
            return radians / (M_PI * 2.0)
        }
        return 0;
    }
    
    /**
     * Get the last angle used. If do not found any. Uses startAngle.
     *
     * returns: return the start angle
     */
    func getStartAngle() -> Double {
        var startAngle = self.startAngle;
        if (dataSteps.count > 0) {
            // The new startAngle is the last endAngle
            startAngle  = (dataSteps.lastObject  as! OMStepData).angle.end
        }
        return startAngle;
    }
    
    /**
     Set up the basic progress layers.
     - Progress (shape) layer
     - Well layer
     - Mask layer
     - parameter step:       step data
     - parameter startAngle: start angle of the  step
     - parameter endAngle:   end angle of the step
     */
    fileprivate func setUpLayers(_ step:OMStepData, startAngle:Double, endAngle:Double) {
        
        DEBUG("setUpLayers:\(stepIndex(step)) \(OMAngle(startAngle: startAngle, endAngle: endAngle))")
        
        // SetUp the mask layer
        
        if let maskLayer = step.maskLayer {
            // Update the mask frame
            if maskLayer.frame != bounds {
                maskLayer.frame = bounds
                // Mark the layer for update because has a new frame.
                maskLayer.setNeedsDisplay()
            }
        }
        
        setUpProgressLayer(step,startAngle:startAngle,endAngle:endAngle)
        
        // The user wants a well
        
        if showWell {
            assert(step.wellColor != nil)
            setUpWellLayer(step)
        } else {
            step.wellLayer?.removeFromSuperlayer()
        }
    }
    
    /**
     Check if all the steps can have the head rounded
     
     - returns: return true if all the step can be the head rounded.
     */
    
    fileprivate func canRoundTheHeads() -> Bool {
        for (_, step) in dataSteps.enumerated() {
            let step = step as! OMStepData
            /// Calculate the angle of arc length needed for the rounded head in radians
            let arcAngle = Double(borderWidth * 0.5) / Double(radius)
            let angleRoundedHead =  OMAngle(startAngle: step.angle.start + arcAngle,
                                            endAngle: step.angle.end   - arcAngle)
            if( !angleRoundedHead.valid() ) {
                return false;
            }
        }
        return true
    }
    
    /**
     * Add the border layer.
     *
     * parameter step: step data
     */
    
    func addBorderLayer(_ step:OMStepData) {
        
        let layerBorder:CAShapeLayer
        
        DEBUG("addBorderLayer()")
        
        if step.shapeLayerBorder == nil {
            layerBorder = CAShapeLayer()
        } else {
            layerBorder = step.shapeLayerBorder!
        }
        
        assert((step.shapeLayer.path != nil), "CAShapeLayer with a nil CGPath");
        
        layerBorder.path        = step.shapeLayer.path
        layerBorder.fillColor   = nil
        layerBorder.strokeColor = step.borderColor.cgColor
        
        if  shadowBorder {
            layerBorder.shadowOpacity = shadowOpacity
            layerBorder.shadowOffset  = shadowOffset
            layerBorder.shadowRadius  = shadowRadius
            layerBorder.shadowColor   = shadowColor.cgColor
            //             layerBorder.shadowPath    = step.shapeLayer.path
        } else {
            layerBorder.shadowOpacity = 0
        }
        
        
        #if TAG_LAYERS
            layerBorder.name = "step \(stepIndex(step)) shape border"
        #endif
        
        layerBorder.strokeStart = 0.0
        layerBorder.strokeEnd   = 0.0
        layerBorder.lineWidth   = borderWidth
        
        
        layerBorder.lineCap     = step.shapeLayer.lineCap
        step.shapeLayerBorder   = layerBorder               // save the border layer
        
        step.shapeLayer.lineWidth = (borderWidth * CGFloat(1.0 - step.borderRatio))
    }
    
    
    /**
     * Set Up the progress (shape) layer
     *
     * parameter step:       step data
     * parameter startAngle: start angle of the  step
     * parameter endAngle:   end angle of the step
     */
    
    fileprivate func setUpProgressLayer(_ step:OMStepData, startAngle:Double, endAngle:Double) {
        
        DEBUG("setUpProgressLayer(startAngle:\(startAngle) endAngle:\(endAngle))")
        assert(startAngle < endAngle, "Unexpected start/end angle. \(startAngle)/\(endAngle)");
        // This assert can be caused when separator Ratio is 1.0
        assert(startAngle != endAngle,
               "The start angle and the end angle cannot be the same. angle: \(startAngle.radiansToDegrees())")
        #if TAG_LAYERS
            step.shapeLayer.name = "step \(stepIndex(step)) shape"
        #endif
        // rounded
        let canRoundedHead = canRoundTheHeads()
        // arc
        var roundedHeadArcAngle : Double = 0
        if  roundedHead {
            if canRoundedHead {
                roundedHeadArcAngle = Double(borderWidth * 0.5) / Double(radius)
            }
        }
        // angle
        let theAngle = OMAngle(startAngle: startAngle + roundedHeadArcAngle,
                               endAngle: endAngle   - roundedHeadArcAngle)
        
        VERBOSE("STEP[\(stepIndex(step))] angle:\(theAngle) Rounded head arclen : \(round(roundedHeadArcAngle.radiansToDegrees()))°")
        
        let shapeLayer = step.shapeLayer
        
        let bezier = UIBezierPath( arcCenter:bounds.size.center(),
                                   radius:midRadius,
                                   startAngle:CGFloat(theAngle.start),
                                   endAngle:CGFloat(theAngle.end),
                                   clockwise: true)
        
        shapeLayer.path            = bezier.cgPath
        shapeLayer.backgroundColor = UIColor.clear.cgColor
        shapeLayer.fillColor       = nil
        shapeLayer.strokeColor     = ( step.maskLayer != nil ) ? UIColor.black.cgColor : step.color.cgColor
        shapeLayer.lineCap         = (roundedHead && canRoundedHead) ?  kCALineCapRound : kCALineCapButt;
        shapeLayer.strokeStart     = 0.0
        shapeLayer.strokeEnd       = 0.0
        
        // DEBUG
        step.borderRatio = stepBorderRatio
        if step.borderRatio > 0 {
            addBorderLayer(step);
        } else {
            shapeLayer.lineWidth  = borderWidth
        }
        // MASK CODE
        if step.maskLayer != nil {
            // When setting the mask to a new layer, the new layer must have a nil superlayer
            step.maskLayer?.mask = shapeLayer
            layer.addSublayer(step.maskLayer!)
            #if DEBUG_MASK
                layer.addSublayer(shapeLayer)
            #endif
        } else if let borderLayer = step.shapeLayerBorder {
            borderLayer.addSublayer(shapeLayer)
            layer.addSublayer(step.shapeLayerBorder!)
        } else {
            layer.addSublayer(shapeLayer)
        }
    }
    
    
    /**
     * Set Up the well layer of the progress layer.
     *
     * parameter step: step data
     */
    
    fileprivate func setUpWellLayer(_ step:OMStepData) {
        DEBUG("setUpWellLayer()")
        
        #if !DEBUG_NO_WELL
        if let stepWellColor = step.wellColor {
            if  step.wellLayer == nil {
                // Create the well layer
                step.wellLayer = CAShapeLayer()
                #if TAG_LAYERS
                    step.wellLayer?.name = "step \(stepIndex(step)) well"
                #endif
            }
            
            // This layer uses the shape path
            step.wellLayer?.path            = step.shapeLayer.path
            step.wellLayer?.backgroundColor = UIColor.clear.cgColor
            step.wellLayer?.fillColor       = nil
            step.wellLayer?.strokeColor     = stepWellColor.cgColor
            step.wellLayer?.lineWidth       = borderWidth
            
            // Activate shadow only if exist space between steps.
            /*step.wellLayer?.shadowOpacity   = 0
            
            if  shadowWell {
                
                step.wellLayer?.shadowOpacity = shadowOpacity
                step.wellLayer?.shadowOffset  = shadowOffset
                step.wellLayer?.shadowRadius  = shadowRadius
                step.wellLayer?.shadowColor   = shadowColor.cgColor
            }*/
           
            // Same as shape layer
            step.wellLayer?.lineCap = step.shapeLayer.lineCap
            
            // Add the layer behind the other layers
            layer.insertSublayer(step.wellLayer!, at:0)
        }
        #endif
    }
    
    /**
     *   Layout the subviews
     */
    override func layoutSubviews() {
        DEBUG("layoutSubviews()")
        super.layoutSubviews()
        updateLayerTree()
    }
    
    /**
     Calculate the point for the image and/or text at the angle.
     
     - parameter angle: element angle
     - parameter align: desired element align
     - parameter size:  optional element size
     
     - returns: return a element final CGPoint
     */
    
    fileprivate func anglePoint(_ angle:Double, align:OMAlign, size:CGSize = CGSize.zero) -> CGPoint {
        DEBUG("anglePoint(\(angle) \(align) \(size))")
        // .middle (default)
        let newRadius:Double
        switch(align){
        case .middle:
            newRadius = Double(midRadius)
            break
        case .center:
            newRadius = Double( innerRadius )
            break
        case .border:
            newRadius = Double( outerRadius )
            break
        case .outer:
            newRadius = Double( outerRadius + (size.height * 0.5) )
            break
        }
        
        // Given a radius length r and an angle in radians and a circle's center (x,y),
        // calculate the coordinates of a point on the circumference
        
        let theta = CGFloat( angle )
        
        // Cartesian angle to polar.
        
        return CGPoint(x: bounds.size.center().x + CGFloat(newRadius) * cos(theta), y: bounds.size.center().y + CGFloat(newRadius) * sin(theta))
        
    }
    
    /**
     Add the created step image layers to the root layer.
     */
    
    fileprivate func addStepImageLayers() {
        DEBUG("addStepImageLayers()")
        for (index, step) in dataSteps.enumerated() {
            let curStep = step as! OMStepData
            
            if let imageLayer = curStep.imageLayer {
                #if TAG_LAYERS
                    imageLayer.name = "step \(index) image"
                #endif
                //imageLayer.setPlainShadow()
                layer.addSublayer(imageLayer)
            }
        }
    }
    /**
     Add the created step image layers to the root layer.
     */
    fileprivate func addStepTextLayers() {
        DEBUG("addStepTextLayers()")
        for (index, step) in dataSteps.enumerated() {
            let curStep = step as! OMStepData
            
            if let textLayer = curStep.textLayer {
                #if TAG_LAYERS
                    textLayer.name = "step \(index) text"
                #endif
                
                //textLayer.setCurvedShadow()
                layer.addSublayer(textLayer)
            }
        }
    }
    /**
     Add the center image layer
     */
    fileprivate func addCenterImageLayer() {
        DEBUG("addCenterImageLayer()")
        if let centerImageLayer = centerImageLayer, let progressImage = centerImage {
            centerImageLayer.frame = bounds.size.center().centerRect(progressImage.size)
            #if TAG_LAYERS
                centerImageLayer.name = "center image"
            #endif
            //imgLayer.setShadow()
            layer.addSublayer(centerImageLayer)
        }
    }
    
    //    func scaleStepImageIfNeeded(_ step:OMStepData) {
    //        DEBUG("scaleStepImageIfNeeded()")
    //        if let image = step.image {
    //            let curSide = image.size.max()
    //            let arcLength = step.angle.arcLength(Double(radius))
    //            // aproxx side from arc lenght.
    //            let newSide:CGFloat = CGFloat(arcLength / 3.0)
    //
    //            print("arc lenght: \(arcLength) with radius \(radius) and angle \(step.angle.start) for \(curSide) = new side: \(newSide)")
    ////            if  angleLength - Double(curSide) < 1.0 {
    ////                return
    ////            }
    //
    //            //assert(maxSide > 0.0, "overflow side.")
    //            if newSide > 0.0 && newSide < curSide {
    //                // TODO: the minimun size of the image must be limited
    //                let sizeOfRect    = CGSize( width:  newSide , height: newSide)
    //                //let diagonal      = sqrt((sizeOfRect.width * sizeOfRect.width) + (sizeOfRect.height * sizeOfRect.height))
    //                step.imageScaled  = image.scaledToFitToSize(sizeOfRect)
    //            } else {
    //                step.imageScaled = nil;
    //            }
    //        }
    //    }
    
    //
    //    func calcChord( radius : Double, angle : Double )
    //    {
    //    let rad = angle;
    //    let r2=radius*radius;
    //    let area = ( r2/2.0 * (rad-sin( rad ) ) );
    //    let chord = 2.0*radius*sin(rad/2);
    //    let arclen = rad*radius;
    //    let perimeter = ( area + chord );
    //    let height = radius*(1.0-cos(rad/2.0))
    //    };
    
    
    /**
     * Scale the step image if needed
     *
     * parameter step: Step Object
     */
    
    
    func scaleStepImageIfNeeded(_ step:OMStepData) {
        DEBUG("scaleStepImageIfNeeded() : \(step.image?.size)")
        if let image = step.image {
            let maxSide = image.size.max()
            var arcChord:CGFloat = round(CGFloat(step.angle.arcChord(radius: Double(outerRadius))))
            if (step.imageAlign == .border) {
                arcChord /= 3.0
                if(arcChord > 0.0 && (arcChord < maxSide)){
                    let newSize = CGSize(width:  arcChord,height: arcChord)
                    VERBOSE("Scaling the center image \(image.size) to \(newSize)")
                    // TODO: the minimun size of the image must be limited
                    step.imageScaled  = image.scaledToFitToSize(newSize)
                }
            } else if (arcChord > 0.0 && (arcChord < maxSide)) {
                let newSize = CGSize(width:  arcChord,height: arcChord)
                VERBOSE("Scaling the center image \(image.size) to \(newSize)")
                step.imageScaled  = image.scaledToFitToSize(newSize)
            } else {
                step.imageScaled = nil;
            }
        }
    }
    
    /**
     * Scale the center image if needed
     *
     * parameter step: Step Object
     */
    
    func scaleCenterImageIfNeeded() -> UIImage? {
        
        DEBUG("scaleCenterImageIfNeeded() : \(centerImage?.size)")
        if let image = centerImage {
            let curSize = image.size.max()
            let maxSide:CGFloat = CGFloat((1.0 - self.thicknessRatio) * Double(self.radius) * 2.0);
            //assert(maxSide > 0.0, "overflow side.")
            if maxSide > 0.0 && maxSide < curSize {
                let newSize = CGSize(width:  maxSide,height: maxSide)
                VERBOSE("Scaling the center image \(image.size) to \(newSize)")
                //the minimun size of the image must be limited
                return  image.scaledToFitToSize(newSize)
            }
        }
        return centerImage
    }
    
    /**
     * SetUp the text layer geometry
     *
     * parameter step: Step Object
     */
    
    
    fileprivate func setUpStepImageLayerGeometry(step:OMStepData) {
        DEBUG("setUpStepImageLayerGeometric()")
        let sizeOfImage = step.imageLayer?.image?.size
        // Reset the angle orientation before sets the new frame
        step.imageLayer?.setTransformRotationZ(0)
        let angle = step.angle.align(step.imageAngleAlign)
        let anglePoint = self.anglePoint(angle,
                                         align: step.imageAlign,
                                         size: sizeOfImage!)
        let frame = anglePoint.centerRect(sizeOfImage!)
        VERBOSE("Frame \(frame) from the aligned step angle \(angle) and the image size \(sizeOfImage)")
        step.imageLayer?.frame = frame
        // Rotate the layer
        if (step.imageOrientationToAngle) {
            let rotationZ = (angle - startAngle)
            VERBOSE("Image will be oriented to angle: \(rotationZ)")
            step.imageLayer?.setTransformRotationZ(rotationZ)
        }
    }
    
    /**
     * SetUp the image layer
     *
     * parameter step: Step Object
     */
    
    
    fileprivate func setUpStepImageLayer(_ step:OMStepData) {
        DEBUG("setUpImageLayer()")
        var newLayer = false
        /// Image
        // Scale the image if is necesary
        scaleStepImageIfNeeded(step)
        // Select the correct image
        if let imageScaled = step.imageScaled ?? step.image {
            // Create the progress image layer
            if step.imageLayer == nil {
                newLayer = true
                step.imageLayer = OMProgressImageLayer(image: imageScaled)
                #if TAG_LAYERS
                    curStep.imageLayer?.name = "step \(stepIndex(curStep)) image"
                #endif
            } else {
                // Update the image
                step.imageLayer?.image = imageScaled
            }
            setUpStepImageLayerGeometry(step: step)
            
            if newLayer {
               // step.textLayer?.setCurvedShadow()
            }
            
            // Mark the layer for repaint
            step.imageLayer?.setNeedsDisplay()
        }
    }
    
    
    /**
     * SetUp the textLayer
     *
     * parameter step: Step Object
     */
    
    fileprivate func setUpTextLayer(_ step:OMStepData) {
        DEBUG("setUpTextLayer()")
        var newLayer = true
        // Update the text layer. If it don't exist, create it.
        if let curTextLayer = step.textLayer {
            newLayer = false
            curTextLayer.string = step.text
            #if TAG_LAYERS
                curTextLayer.name = "step \(stepIndex(step)) text"
            #endif
        } else {
            step.textLayer = OMTextLayer(string: step.text!)
            
        }
        
        if !step.fontName.isEmpty {
            var notCreateFont:Bool = false
            if step.textLayer?.font != nil {
                notCreateFont = (step.textLayer?.font?.fontName  == step.fontName &&
                    step.textLayer?.font?.pointSize == step.fontSize)
            }
            if !notCreateFont {
                DEBUG("Setting new font (\(step.fontName)) size: \( step.fontSize)")
                DEBUG("Old font (\(step.textLayer?.font?.fontName)) size: \( step.textLayer?.font?.pointSize)")
                step.textLayer?.font = UIFont(name: step.fontName, size: step.fontSize)
            }
        }
        
        step.textLayer?.foregroundColor = step.fontColor
        step.textLayer?.fontStrokeColor = step.fontStrokeColor
        step.textLayer?.backgroundColor = step.fontBackgroundColor.cgColor
        step.textLayer?.fontStrokeWidth = step.fontStrokeWidth
        
        setUpStepTextLayerGeometry(step)
        
        if newLayer {
            //step.textLayer?.setCurvedShadow()
        }
    }
    
    /**
     * Setup the text layer geometry
     *
     * parameter step: Step Object
     */
    
    fileprivate func setUpStepTextLayerGeometry(_ step:OMStepData) {
        DEBUG("setUpStepTextLayerGeometric()")
        if let textLayer = step.textLayer {
            textLayer.setTransformRotationZ(0.0)
            let sizeOfText = textLayer.frameSize();
            let angle:Double = step.angle.align(step.textAngleAlign)
            DEBUG("Angle \(round(angle.radiansToDegrees())) Aling:\(step.textAngleAlign)")
            let positionInAngle = anglePoint(angle, align: step.textAlign, size: sizeOfText)
            DEBUG("Position in angle \(positionInAngle) Align:\(step.textAlign)")
            textLayer.frame = positionInAngle.centerRect(sizeOfText)
            if step.textOrientationToAngle {
                textLayer.setTransformRotationZ( angle - startAngle)
            }
        }
    }
    
    /**
     * Remove all layers from the superlayer.
     */
    func removeSublayers() {
        DEBUG("removeSublayers()")
        for (_, layer) in self.layer.sublayers!.enumerated() {
            layer.removeAllAnimations()
            layer.removeFromSuperlayer()
        }
    }
    
    
    /**
     *   Create or update all the necesary layers
     */
    internal func updateLayerTree() {
        DEBUG("updateLayerTree()")
        /// Recalculate the layer tree
        if percentText || stepText {
            // set up the central numerical text layer.
            setUpCenterNumericalTextLayer()
        }
        // Create and setup the position of the text and image step layers
        for (_, step) in dataSteps.enumerated() {
            let curStep  = step as! OMStepData
            let hasImage = (curStep.image != nil)   // Image Layer
            let hasText  = (curStep.text  != nil)   // Text Layer
            if hasImage {
                setUpStepImageLayer(curStep)
            }
            if  hasText {
                setUpTextLayer(curStep)
            }
        }
        
        /// Create the layers for each step.
        
        for (_, step) in dataSteps.enumerated() {
            let curStep = step as! OMStepData
            setUpLayers(curStep,
                        startAngle:curStep.angle.start,
                        endAngle: curStep.angle.end)
        }
        
        
        // Add the center image
        #if !NO_IMAGES
            addCenterImageLayer()
        #endif
        // Add all steps image
        #if !NO_IMAGES
            addStepImageLayers()
        #endif
        // Add all steps texts
        #if !NO_TEXT
            addStepTextLayers()
            /// Add the text layer.
            if let numberLayer = centerNumberLayer {
                layer.addSublayer(numberLayer)
            }
        #endif
        
        #if DEBUG
            #if DUMP_LAYERS
                dumpLayers(0,layer:self.layer)
            #endif
            #if DUMP_STEPS
                dumpAllSteps()
            #endif
        #endif
        
        
        //self.layer.transformSublayers(angle:75, prespective: prespective)
    }
    
    
}
