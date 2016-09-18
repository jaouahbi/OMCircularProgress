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

let kCompleteProgress:Double = Double.infinity



////////////////////////////////////////////////////////////////////////////////
//
// The OMCircularProgress delegate Protocol
//
////////////////////////////////////////////////////////////////////////////////

@objc protocol OMCircularProgressProtocol
{
    /**
     
     Notificate the layer hit
     
     - parameter ctl:      The object caller
     - parameter layer:    The layer hitted
     - parameter location: The CGPoint where the layer was hitted
     */
    @objc optional func layerHit(_ ctl:UIControl, layer:CALayer, location:CGPoint)
}


// MARK: - Constant Definitions

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
    
    /// Transforma layer create prespective.
    
    //internal var prespectiveAngle: Double  = 0
    //internal let prespective     : CGFloat = -1.0/1000.0;
    //internal var transformLayer  : CATransformLayer?
    
    internal var containerLayer  : CALayer = CALayer()
    
    /// Center
    
    internal var centerImageLayer:OMProgressImageLayer?   // center image layer
    internal var centerNumberLayer:OMNumberLayer?         // center number layer
    
    // Animations
    
    internal var beginTime: Double    = 0;
    internal var newBeginTime: Double = 0;
    @IBInspectable var animation : Bool     = true;
    @IBInspectable var animationDuration : TimeInterval = 1.0
    
    
    // Delegate
    weak var delegate:OMCircularProgressProtocol?
    
    
    /// Component behavior
    
    var progressStyle: CircularProgressStyle = .sequentialProgress      // Progress style
    var options      : ProgressOptions       = []                       // Progress options
    
    /// The start angle of the all steps. (default: -90 degrees == 12 o'clock)
    
    @IBInspectable var startAngle : Double = -90.degreesToRadians() {
        didSet{
            assert(OMCircleAngle.range(angle: startAngle),
                   "Invalid angle : \(startAngle).The angle range must be in radians : -(2*PI)/+(2*PI)")
            setNeedsLayout()
        }
    }
    
    /// Set the rounded head to each step representation  (default: false)
    
    @IBInspectable var roundedHead : Bool = false {
        didSet {
            setNeedsLayout();
        }
    }
    
    
    /// Show the well layer (default: false)
    
    @IBInspectable var showWell : Bool = false {
        didSet{
            setNeedsLayout()
        }
    }
    
    // MARK: Shadow
    
    //@IBInspectable var shadowText : Bool = true {
    //    didSet{
    //        setNeedsLayout()
    //    }
    // }
    
    /// Sets shadow to the well layer
    
    /*   @IBInspectable var shadowWell : Bool = false {
     didSet{
     setNeedsLayout()
     }
     }*/
    
    /*
     //
     @IBInspectable var shadowBorder : Bool = false {
     didSet{
     setNeedsLayout()
     }
     }
     
     /// Shadow Opacity
     @IBInspectable var shadowOpacity : Float = 0.85 {
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
     */
    
    /*
     
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
     
     */
    
    
    /*
    internal var textLayer:OMNumberLayer? = nil                // layer for the text
    lazy var text : OMTextLayer! = {
        if self.textLayer  == nil {
            // create the numerical text layer with the text centered
            let alignmentMode = "center"
            self.textLayer =  OMNumberLayer(number: 0, formatStyle: numberStyle(), alignmentMode: alignmentMode)
            #if true
                 self.textLayer?.name = "text layer"
            #endif
        }
        return self.textLayer!
    }()*/
    
    func centerText() -> OMNumberLayer {
        
        if centerNumberLayer == nil {
            // create the numerical text layer with the text centered
            let alignmentMode = "center"
            centerNumberLayer = OMNumberLayer(number: 0, formatStyle: numberStyle(), alignmentMode: alignmentMode)
            #if true
                centerNumberLayer?.name = "text layer"
            #endif
        }
        
        return centerNumberLayer!
    }
    
    
    
    /**
     * Update the center numerical layer
     */
    
    
    func updateCenterTextLayerGeometry() {
        
        let numberLayer = centerText()
        
        // The percent is represented from 0.0 to 1.0
        
        let numberToRepresent = NSNumber(value:Int32(( percentText ) ? 1 : dataSteps.count));
        
        let size = numberLayer.frameSizeLengthFromNumber(numberToRepresent)
        
        numberLayer.frame = bounds.size.center().centerRect(size)
        
    }
    
    /**
     * Format style for the númerical layer
     *
     * returns: return the number style (CFNumberFormatterStyle)
     */
    
    func numberStyle() -> CFNumberFormatterStyle {
        return  percentText  ? .percentStyle : .decimalStyle
    }
    
    // MARK: Images
    
    // @IBInspectable var imageShadow : Bool = true
    /*
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
     #if true
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
     */
    
    internal var imageLayer : OMProgressImageLayer? = nil    // optional image layer
    lazy var image : OMProgressImageLayer! = {
        if self.imageLayer  == nil {
            self.imageLayer = OMProgressImageLayer()
        }
        return self.imageLayer!
    }()
    
    // MARK: Font and Text (do no need layout)
    
    
    /// The text represent a percent number.
    var percentText:Bool = false {
        didSet{
            updateCenterTextLayerGeometry()
        }
    }
    
    /// The text represent a arb. text.
    var stepText:Bool = false {
        didSet{
            updateCenterTextLayerGeometry()
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
    
    /// Border width
    
    var borderWidth : CGFloat {
        return CGFloat(thicknessRatio * Double(radius))
    }
    
    
    
    /// Border radio (default: 10%)
    
    var thicknessRatio : Double = 0.1 {
        didSet {
            thicknessRatio.clamp(toLowerValue: 0.0,upperValue: 1.0)
            setNeedsLayout();
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
    //                     #if true
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
            
            if (progress == kCompleteProgress) {
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
        
        DEBUG("setUpLayers:\(stepIndex(step)) \(OMAngle(start: startAngle, end: endAngle))")
        
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
            setUpWellLayer(step)
        } else {
            step.wellLayer?.removeFromSuperlayer()
        }
    }
    
    
    /**
     * Set Up the progress (shape) layer
     *
     * parameter step:       step data
     * parameter start: start angle of the  step
     * parameter end:   end angle of the step
     */
    
    fileprivate func setUpProgressLayer(_ step:OMStepData, startAngle:Double, endAngle:Double) {
        DEBUG("setUpProgressLayer(startAngle:\(startAngle) endAngle:\(endAngle))")
        // This assert can be caused when separator Ratio is 1.0
        assert(startAngle != endAngle,
               "The start angle and the end angle cannot be the same. angle: \(startAngle.radiansToDegrees())")
        assert(startAngle < endAngle, "Unexpected start/end angle. \(startAngle)/\(endAngle)");
        
        #if true
            step.shapeLayer.name = "step \(stepIndex(step)) shape"
        #endif
        
        // TODO: the head can be rounded?
        
        let canRoundedHead = true
        let roundedHeadArcAngleStart:Double = 0
        let roundedHeadArcAngleEnd:Double   = 0
        // angle
        let theAngle = OMAngle(start: startAngle + roundedHeadArcAngleStart,
                               end  : endAngle   - roundedHeadArcAngleEnd)
        
        
        VERBOSE("STEP[\(stepIndex(step))] angle:\(theAngle) Rounded head angle arc len : \(round(roundedHeadArcAngleStart.radiansToDegrees()))°")
        
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
        
        if step.borderRatio > 0 {
            INFO("Adding the border layer.")
            assert((step.shapeLayer.path != nil), "CAShapeLayer with a nil CGPath");
            
            step.border.path        = step.shapeLayer.path
            step.border.fillColor   = nil
            if(step.border.strokeColor == nil) {
                step.border.strokeColor = UIColor.black.cgColor //step.borderColor.cgColor
            }
            
            #if true
                step.border.name = "step \(stepIndex(step)) shape border"
            #endif
            
            step.border.strokeStart = 0.0
            step.border.strokeEnd   = 0.0
            step.border.lineWidth   = borderWidth
            
            step.border.lineCap     = step.shapeLayer.lineCap
            
            
            step.shapeLayer.lineWidth = (borderWidth * CGFloat(1.0 - step.borderRatio))
        } else {
            shapeLayer.lineWidth  = borderWidth
        }
        
        
        if let mask = step.maskLayer,let border = step.shapeLayerBorder {
            border.addSublayer(shapeLayer)
            containerLayer.addSublayer(border)
            mask.mask = step.shapeLayer
            containerLayer.addSublayer(mask)
        } else if let mask = step.maskLayer {
            mask.mask = shapeLayer
            containerLayer.addSublayer(mask)
            #if DEBUG_MASK
                containerLayer.addSublayer(shapeLayer)
            #endif
        } else if let border = step.shapeLayerBorder {
            border.addSublayer(shapeLayer)
            containerLayer.addSublayer(step.shapeLayerBorder!)
        } else {
            containerLayer.addSublayer(shapeLayer)
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
            
            /*if let stepWellColor = step.wellColor {
             if  step.wellLayer == nil {
             // Create the well layer
             step.wellLayer = CAShapeLayer()
             #if true
             step.wellLayer?.name = "step \(stepIndex(step)) well"
             #endif
             }*/
            
            // This layer uses the shape path
            step.well.path            = step.shapeLayer.path
            step.well.backgroundColor = UIColor.clear.cgColor
            step.well.fillColor       = nil
            
            if (step.well.strokeColor == nil) {
                step.well.strokeColor     = UIColor(white:0.9, alpha:0.8).cgColor
            }
            step.well.lineWidth       = borderWidth
            
            // Activate shadow only if exist space between steps.
            /*step.wellLayer?.shadowOpacity   = 0
             
             if  shadowWell {
             
             step.wellLayer?.shadowOpacity = shadowOpacity
             step.wellLayer?.shadowOffset  = shadowOffset
             step.wellLayer?.shadowRadius  = shadowRadius
             step.wellLayer?.shadowColor   = shadowColor.cgColor
             }*/
            
            // Same as shape layer
            step.well.lineCap = step.shapeLayer.lineCap
            
            // Add the layer behind the other layers
            containerLayer.insertSublayer(step.well, at:0)
            //}
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
     * Calculate the center rect for the image and/or text at the angle.
     *
     * parameter angle: element angle
     * parameter align: desired element align  default: .middle
     * parameter size:  optional element size  default: CGSize.zero
     *
     * returns: return a element final CGPoint
     */
    
    fileprivate func angleRect(_ angle:Double, align:OMAlign, size:CGSize = CGSize.zero) -> CGRect {
        DEBUG("anglePointCentered(\(angle) \(align) \(size))")
        return anglePoint(angle,align: align,size: size).centerRect(size)
        
    }
    fileprivate func anglePoint(_ angle:Double, align:OMAlign, size:CGSize = CGSize.zero) -> CGPoint {
        DEBUG("anglePoint(\(angle) \(align) \(size))")
        //
        let newRadius:Double
        switch(align){
        case .middle:
            newRadius = Double(midRadius)
            break
        case .center:
            newRadius = Double(innerRadius)
            break
        case .border:
            newRadius = Double(outerRadius)
            break
        case .outer:
            newRadius = Double(outerRadius + (size.height * 0.5))
            break
        }
        
        
        // Given a radius length r and an angle in radians and a circle's center (x,y),
        // calculate the coordinates of a point on the circumference
        
        let theta = CGFloat( angle )
        
        // Cartesian angle to polar.
        
        return CGPoint(x: bounds.size.center().x + CGFloat(newRadius) * cos(theta), y: bounds.size.center().y + CGFloat(newRadius) * sin(theta))
        
    }
    
    /**
     * Add the created step image layers to the root layer.
     */
    
    fileprivate func addStepImageLayers() {
        #if !NO_IMAGES
            DEBUG("addStepImageLayers()")
            for (index, step) in dataSteps.enumerated() {
                let curStep = step as! OMStepData
                
                if let imageLayer = curStep.imageLayer {
                    #if true
                        imageLayer.name = "step \(index) image"
                    #endif
                    //imageLayer.setPlainShadow()
                    containerLayer.addSublayer(imageLayer)
                }
            }
        #endif
    }
    /**
     * Add the created step image layers to the root layer.
     */
    fileprivate func addStepTextLayers() {
        DEBUG("addStepTextLayers()")
        for (index, step) in dataSteps.enumerated() {
            if (step as! OMStepData).text.string != nil {
                #if true
                    (step as! OMStepData).text.name = "step \(index) text"
                #endif
                containerLayer.addSublayer((step as! OMStepData).text)
            }
        }
    }
    /**
     * Add the center image layer to the root layer.
     */
    fileprivate func addCenterImageLayer() {
        #if !NO_IMAGES
            DEBUG("addCenterImageLayer()")
            
            if let img  = image.image {
                image.frame = bounds.size.center().centerRect(img.size)
                #if true
                    image.name = "center image"
                #endif
                //imgLayer.setShadow()
                
                containerLayer.addSublayer(image)
            }
        #endif
    }
    
    /**
     * Scale the step image if needed
     *
     * parameter step: Step Object
     */
    
    /*
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
     }*/
    
    /**
     * Scale the center image if needed
     *
     * parameter step: Step Object
     */
    
    func scaleCenterImageIfNeeded() -> UIImage? {
        
        DEBUG("scaleCenterImageIfNeeded() : \(image.image?.size)")
        if let img = image.image {
            let curSize = img.size.max()
            let maxSide:CGFloat = CGFloat((1.0 - self.thicknessRatio) * Double(self.radius) * 2.0);
            
            //assert(maxSide > 0.0, "overflow side.")
            if maxSide > 0.0 && maxSide < curSize {
                let newSize = CGSize(width:  maxSide,height: maxSide)
                VERBOSE("Scaling the center image \(img.size) to \(newSize)")
                //the minimun size of the image must be limited
                return  img.scaledToFitToSize(newSize)
            }
            /*
             let r = CGFloat(self.thicknessRatio) * self.radius
             if img.size.max() * 0.5 >  r {
             return  img.scaledToFitToSize(CGSize(width:  r,height: r))
             }
             */
        }
        return image.image
    }
    
    
    
    
    /**
     * SetUp the textLayer
     *
     * parameter step: Step Object
     */
    /*
     fileprivate func setUpTextLayer(_ step:OMStepData) {
     DEBUG("setUpTextLayer()")
     var newLayer = true
     /*
     // Update the text layer. If it don't exist, create it.
     if let curTextLayer = step.textLayer {
     newLayer = false
     curTextLayer.string = step.text
     #if true
     curTextLayer.name = "step \(stepIndex(step)) text"
     #endif
     } else {
     step.textLayer = OMTextLayer(string: step.text!)
     
     }*/
     
     /*
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
     }*/
     
     /* step.textLayer?.foregroundColor = step.fontColor
     step.textLayer?.fontStrokeColor = step.fontStrokeColor
     step.textLayer?.backgroundColor = step.fontBackgroundColor.cgColor
     step.textLayer?.fontStrokeWidth = step.fontStrokeWidth
     */
     
     setUpStepTextLayerGeometry(step)
     
     if newLayer {
     //step.textLayer?.setCurvedShadow()
     }
     }
     */
    
    
    /**
     * SetUp the text layer geometry
     *
     * parameter step: Step Object
     */
    
    
    fileprivate func setUpStepImageLayerGeometry(step:OMStepData) {
        DEBUG("setUpStepImageLayerGeometric()")
        let sizeOf = step.imageLayer?.image?.size
        // Reset the angle orientation before sets the new frame
        step.imageLayer?.setTransformRotationZ(0)
        let angle = step.angle.align(step.imageAngleAlign)
        DEBUG("Angle \(round(angle.radiansToDegrees())) image aling:\(step.imageAngleAlign)")
        let anglePoint = self.anglePoint(angle, align: step.imageAlign, size: sizeOf!)
        let positionInAngle = anglePoint.centerRect(sizeOf!)
        VERBOSE("Frame \(positionInAngle) from the aligned step angle \(angle) and the image size \(sizeOf)")
        step.imageLayer?.frame = positionInAngle
        // Rotate the layer
        if (step.imageOrientationToAngle) {
            let rotationZ = (angle - startAngle)
            VERBOSE("Image will be oriented to angle: \(rotationZ)")
            step.imageLayer?.setTransformRotationZ(rotationZ)
        }
    }
    
    /**
     * Setup the text layer geometry
     *
     * parameter step: Step Object
     */
    
    fileprivate func setUpStepTextLayerGeometry(_ step:OMStepData) {
        DEBUG("setUpStepTextLayerGeometric()")
        if step.text.string != nil {
            // Reset the angle orientation before sets the new frame
            step.text.setTransformRotationZ(0.0)
            let sizeOf = step.text.frameSize();
            let angle:Double = step.angle.align(step.textAngleAlign)
            DEBUG("Angle \(round(angle.radiansToDegrees())) text aling:\(step.textAngleAlign)")
            let anglePoint = self.anglePoint(angle, align: step.textAlign, size: sizeOf)
            DEBUG("Position in angle \(anglePoint) Align:\(step.textAlign)")
            let positionInAngle = anglePoint.centerRect(sizeOf)
            VERBOSE("Frame \(positionInAngle) from the aligned step angle \(angle) and the text size \(sizeOf)")
            step.text.frame = positionInAngle
            if step.textOrientationToAngle {
                let rotationZ = (angle - startAngle)
                VERBOSE("Image will be oriented to angle: \(rotationZ)")
                step.text.setTransformRotationZ( rotationZ )
            }
        }
    }
    
    /**
     * Remove all layers from the superlayer.
     */
    func removeSublayers() {
        DEBUG("removeSublayers()")
        if let s = containerLayer.sublayers {
            for (_, layer) in s.enumerated() {
                layer.removeAllAnimations()
                layer.removeFromSuperlayer()
            }
        }
        containerLayer.removeAllAnimations()
        containerLayer.removeFromSuperlayer()
    }
    
    func addImages() {
        
        // Add all steps image
        addStepImageLayers()
        
        // Add the center image
        addCenterImageLayer()

    }
    
    /**
     *   Create or update all the necesary layers
     */
    internal func updateLayerTree() {
        
        DEBUG("updateLayerTree()")
        
        layer.addSublayer(containerLayer)
        
        /*if let transformLayer = transformLayer {
         //Initialize the TransformLayer
         transformLayer.frame = self.bounds;
         }*/
        
        /// Recalculate the layer tree
        if percentText || stepText {
            // set up the central numerical text layer.
            updateCenterTextLayerGeometry()
        }
        // Create and setup the position of the text and image step layers
        for (_, step) in dataSteps.enumerated() {
            let curStep  = step as! OMStepData
            // Image Layer
            if curStep.image.image != nil {
                
                #if true
                    curStep.image.name = "step \(stepIndex(curStep)) image"
                #endif
                
                setUpStepImageLayerGeometry(step: curStep)
            }
            // Text Layer
            if  curStep.text  != nil {
                setUpStepTextLayerGeometry(curStep)
            }
        }
        
        /// Create the layers for each step.
        for (_, step) in dataSteps.enumerated() {
            let curStep = step as! OMStepData
            setUpLayers(curStep,
                        startAngle:curStep.angle.start,
                        endAngle: curStep.angle.end)
        }
        
        addImages()
        
        // Add all steps texts
        #if !NO_TEXT
            addStepTextLayers()
            /// Add the text layer.
            if let numberLayer = centerNumberLayer {
                containerLayer.addSublayer(numberLayer)
            }
        #endif
        
        //#if DEBUG
            //#if DUMP_LAYERS
            //    dumpLayers(0, layer:self.layer)
            //#endif
            #if DUMP_STEPS
                dumpAllSteps()
            #endif
        //#endif
        
        
        /*if let transformLayer = transformLayer {
         //Initialize the TransformLayer
         transformLayer.transformSublayers(angle:prespectiveAngle, prespective: prespective)
         }*/
        
        print(self.debugDescription)
    }
    
    
}


extension OMCircularProgress
{
    /**
     * Get the number of steps
     */
    public var numberOfSteps : Int {
        return self.dataSteps.count;
    }
    
    /**
     * Step to index in the steps array
     */
    internal func stepIndex(_ step:OMStepData) -> Int {
        return self.dataSteps.index(of: step)
    }
    
    /**
     *  Get/Set the step data, subscripted by index from the list of steps
     */
    
    subscript(stepIndex: Int) -> OMStepData? {
        get {
            assert(stepIndex < numberOfSteps, "out of bounds. \(stepIndex) max: \(numberOfSteps)")
            if stepIndex < numberOfSteps {
                return dataSteps[stepIndex] as? OMStepData
            }
            return nil
        }
        
        set(newStep) {
            assert(stepIndex < numberOfSteps, "out of bounds. \(stepIndex) max: \(numberOfSteps)")
            if stepIndex < numberOfSteps {
                dataSteps[Int(stepIndex)] = newStep!
            }
        }
    }
    
    /**
     * Create a new progress step.
     *
     * Each progress step is represented by the object OMStepData
     *
     * parameter start: step start angle
     * parameter end:   step end angle
     * parameter color:      step color
     *
     * returns: return a OMStepData object.
     */
    
    func addStep(_ start:Double, end:Double, color:UIColor!) -> OMStepData? {
        let angle = OMCircleAngle(start:start,end:end)
        let valid = angle.valid()
        assert(valid,"Invalid angle:\(angle). range in radians : -(2*PI)/+(2*PI)")
        if(!valid) {
            WARNING("Invalid angle :\(angle)")
            return nil;
        }
        // Create the step
        let step = OMStepData(angle: angle, color:color)
        
        VERBOSE("Adding new step with the angle: \(step.angle)")
        
        if isOverflow(lenght: angle.length()) {
            return nil
        }
        // Save the step
        dataSteps.add(step)
        return step
    }
    
    /**
     * Remove all steps.
     */
    
    func removeAllSteps() {
        self.dataSteps.removeAllObjects()
        removeSublayers()
        layoutSubviews()
    }
    
    /**
     * Check steps overflow
     */
    
    internal func isOverflow(lenght:Double) -> Bool {
        let numberOfRad = numberOfRadians() + lenght
        let diference   = numberOfRad - 𝜏
        if diference > Double(FLT_EPSILON) {
            WARNING("Out of radians: can't create the step. overflow by \(𝜏 - numberOfRad) radians")
            return true
        }
        return false
    }
    /**
     * Create a new step progress.
     *
     * parameter angle:   step end angle
     * parameter color:      step color
     *
     * returns: return a OMStepData object.
     */
    
    func addStep(_ angle:Double, color:UIColor!) -> OMStepData? {
        let startAngle = getStartAngle()
        return addStep( startAngle, end:startAngle + angle, color:color );
    }
    
    /**
     * Create a new step progress.
     *
     * parameter startAngle: step start angle
     * parameter percent:    step end angle expresed as percent of complete circle.
     * parameter color:      step color
     *
     * returns: return a OMStepData object.
     */
    
    func addStepWithPercent(_ start:Double, percent:Double, color:UIColor!) -> OMStepData? {
        assert(OMCircleAngle.range(angle: start),
               "Invalid angle:\(startAngle). range in radians : -(2*PI)/+(2*PI)")
        
        // clap the percent.
        let step = OMStepData(start:start,
                              percent:clamp(percent, lower: 0.0,upper: 1.0),
                              color:color)
        
        VERBOSE("Adding new step with the angle: \(step.angle)")
        if isOverflow(lenght:  step.angle.length()) {
            return nil
        }
        
        dataSteps.add(step)
        return step
    }
    
    /**
     * Create a new step progress.
     *
     * parameter percent:   step angle expresed as percent of complete circle.
     * parameter color:     step color
     *
     * returns: return a OMStepData object.
     */
    
    func addStepWithPercent(_ percent:Double, color:UIColor!) -> OMStepData? {
        return addStepWithPercent(getStartAngle(), percent: percent, color: color);
    }
}
extension OMCircularProgress
{
    // MARK: Debug functions
    
    /**
     * Debug print all steps
     */
    func dumpAllSteps() {
        for (index, step) in dataSteps.enumerated() {
            VERBOSE("\(index): \(step as! OMStepData)")
        }
    }
    
    /**
     * Debug print all layers
     *
     * parameter level: recursion level
     * parameter layer: layer to debug print
     */
    
    func dumpLayers(_ level:UInt, layer:CALayer) {
        if (layer.sublayers != nil) {
            for (_, curLayer) in layer.sublayers!.enumerated() {
                let name = curLayer.name ?? String(describing: curLayer)
                print("[\(level):\(name)]")
                if(curLayer.sublayers != nil){
                    dumpLayers(level+1, layer: curLayer)
                }
            }
        }
    }
    
    // MARK: Consistency functions
    
    /// debug description
    override var description : String {
        var str : String = super.description
        str += "Radius : \(radius) Inner Radius: \(innerRadius) Outer Radius: \(outerRadius) Mid Radius: \(midRadius) Border : \(borderWidth) "
        str += " Steps:[ "
        for (index, step) in dataSteps.enumerated() {
            str += "\(index): \((step as! OMStepData)) "
        }
        str += "]"
        
        return str;
    }
    
}

extension OMCircularProgress : CAAnimationDelegate
{
    /// MARK: CAAnimation delegate
    
    func animationDidStart(_ anim: CAAnimation) {
        VERBOSE("START:\((anim as! CABasicAnimation).keyPath) : \((anim as! CABasicAnimation).beginTime) ")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            VERBOSE("END:\((anim as! CABasicAnimation).keyPath)")
        }
    }
    
    //
    // Animate the shapeLayer and the image for the step
    //
    
    func stepAnimation(_ step:OMStepData, progress:Double) {
        
        assert(progress >= 0);
        
        weak var delegate = self
        
        // Remove all animations
        step.shapeLayer.removeAllAnimations()
        
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        strokeAnimation.fromValue =  0.0
        strokeAnimation.toValue   =  progress
        
        strokeAnimation.duration = (animationDuration / Double(numberOfSteps)) * progress
        
        strokeAnimation.isRemovedOnCompletion = false
        strokeAnimation.isAdditive = true
        strokeAnimation.fillMode = kCAFillModeForwards
        strokeAnimation.delegate = self
        
        if (progressStyle == .sequentialProgress) {
            
            // Current animation beginTime
            
            if  (newBeginTime != 0)  {
                strokeAnimation.beginTime = newBeginTime
            }  else  {
                strokeAnimation.beginTime = beginTime
            }
            
            // Calculate the next animation beginTime
            newBeginTime = strokeAnimation.beginTime + strokeAnimation.duration
        }
        
        //
        // Add animation to the stroke of the shape layer.
        //
        
        step.shapeLayer.add(strokeAnimation, forKey: "strokeEnd")
        
        if let shapeLayerBorder = step.shapeLayerBorder {
            shapeLayerBorder.add(strokeAnimation, forKey: "strokeEnd")
        }
        
        if let imgLayer = step.imageLayer {
            // Remove all animations
            imgLayer.removeAllAnimations()
            // Add animation to the image
            imgLayer.animateProgress(0.0,
                                     toValue:  progress,
                                     beginTime: strokeAnimation.beginTime,
                                     duration: strokeAnimation.duration ,
                                     delegate: delegate)
        }
    }
}
extension OMCircularProgress
{
    /**
     Get the correct layer for the location
     
     - parameter location: point location in the view
     - returns: return the layer that contains the point
     */
    
    func layerForLocation( _ location:CGPoint ) -> CALayer?
    {
        // hitTest Returns the farthest descendant of the layer (Copy of layer)
        
        if let player = self.layer.presentation()
        {
            let hitPresentationLayer = player.hitTest(location)
            
            if let hitplayer = hitPresentationLayer {
                
                // Real layer
                
                return hitplayer.model()
            }
            
            VERBOSE("Unable to locate the layer that contains the location \(location)")
        }
        
        return nil;
    }
    
    // MARK: UIResponder
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            var location:CGPoint = touch.location(in: self);
            
            location = self.convert(location, to:nil)
            
            if let la = self.layerForLocation(location) {
                
                if((self.delegate) != nil && (self.delegate!.layerHit) != nil) {
                    self.delegate!.layerHit!(self, layer: la, location: location)
                }
            }
        }
        
        super.touchesBegan(touches , with:event)
    }
}

