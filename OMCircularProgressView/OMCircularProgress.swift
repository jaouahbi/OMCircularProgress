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

// Some constants

let kControlInset:CGFloat = 20.0

let kCompleteProgress:Double = Double.infinity

let kDefaultStartAngle:Double = -90.degreesToRadians()

let kDefaultBorderColor:CGColor       = UIColor.black.cgColor

// Image Shadow
let kDefaultElementShadowOffset:CGSize  = CGSize(width:0.0,height: 10.0)
let kDefaultElementShadowRadius:CGFloat = 3
let kDefaultElementShadowColor:CGColor  = UIColor.black.cgColor


// Border Shadow
let kDefaultBorderShadowOffset:CGSize  = CGSize(width:0.0,height: 2.5)
let kDefaultBorderShadowRadius:CGFloat = 2
let kDefaultBorderShadowColor:CGColor  = UIColor(white:0.3,alpha:1.0).cgColor

//
// The OMCircularProgress delegate Protocol
//

@objc protocol OMCircularProgressProtocol
{
    /**
     *
     * Notificate the layer hit
     *
     * parameter ctl:      The object caller
     * parameter layer:    The layer hitted
     * parameter location: The CGPoint where the layer was hitted
     *
     */
    
    @objc optional func layerHit(_ ctl:UIControl, layer:CALayer, location:CGPoint)
}


// MARK: - Constant Definitions

///LogMode type. Specify what details should be included to the log
public struct CPCOptions : OptionSet {
    
    public let rawValue: UInt
    public init(rawValue: UInt)  { self.rawValue = rawValue }
    
    //MARK:- Options
    public static let well          = CPCOptions(rawValue: 1 << 0)
    public static let roundedHead   = CPCOptions(rawValue: 1 << 1)
    //public static let image         = CPCOptions(rawValue: 1 << 2)
    //public static let border        = CPCOptions(rawValue: 1 << 4)
    
    /// AllOptions - Enable all options, [FileName, FuncName, Line]
    //    public static let AllOptions: LogMode = [Date, FileName, FuncName, Line]
    //    public static let FullCodeLocation: LogMode = [FileName, FuncName, Line]
}
// MARK: - Types


/// The styles permitted for the progress bar.
/// NOTE:  You can set and retrieve the current style of progress view through the progressStyle property.

public enum CPCStyle : Int
{
    case direct
    case sequential
    
    init() {
        self = .sequential
    }
}


/**
 Image and text radius alignment
 
 - center: Align to center
 - middle:    Align to middle
 - border: Align to border
 - outer:  Align to outer
 
 */


enum CPCRadiusAlignment : Int
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
    
    required init?(style : CPCStyle) {
        super.init(frame:CGRect.zero)
        self.progressStyle = style
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        
    }
    
    // Array of CPStepData
    
    var dataSteps: NSMutableArray   = []
    
    //internal var containerLayer  : CATransformLayer? = nil
    internal var containerLayer  : CALayer? = nil
    
    /// Animations
    
    @IBInspectable var enableAnimations : Bool     = true;
    @IBInspectable var animationDuration : TimeInterval = 1.0
    
    // Animation control
    
    internal var beginTime: Double    = 0;
    internal var newBeginTime: Double = 0;
    
    
    // Delegate
    
    weak var delegate:OMCircularProgressProtocol?
    
    /// Component behavior
    
    var progressStyle: CPCStyle = .sequential      // Progress style
    var options      : CPCOptions       = []                       // Progress options
    
    /// The start angle of the all steps. (default: -90 degrees == 12 o'clock)
    
    @IBInspectable var startAngle : Double = kDefaultStartAngle {
        didSet {
            assert(CPCAngle.inRange(angle: startAngle),
                   "Invalid angle : \(startAngle).The angle range must be in radians : -(2*PI)/+(2*PI)")
            setNeedsLayout()
        }
    }
    
    /// Set the rounded head to each step representation  (default: false)
    
    //@IBInspectable var roundedHead : Bool = false {
    //    didSet {
    //        setNeedsLayout();
    //    }
    //}
    
    /// Show the well layer (default: false)
    
    //    @IBInspectable var showWell : Bool = false {
    //        didSet{
    //            setNeedsLayout()
    //        }
    //    }
    
    internal var numberLayer:OMNumberLayer? = nil                // layer for the text
    lazy var number : OMNumberLayer! = {
        if self.numberLayer  == nil {
            // create the numerical text layer with the text centered
            self.numberLayer =  OMNumberLayer()
            self.numberLayer?.name = "number layer"
        }
        return self.numberLayer!
    }()
    
    
    /**
     * Update the center numerical layer
     */
    
    func updateNumberLayerGeometry() {
        
        let numberLayer = number!
        
        // The percent is represented from 0.0 to 1.0
        
        let numberToRepresent = NSNumber(value:Int32(1));
        
        let size = numberLayer.frameSizeLengthFromNumber(numberToRepresent)
        
        numberLayer.frame = bounds.size.center().centerRect(size)
        
    }
    
    // MARK: Images
    
    internal var imageLayer : OMProgressImageLayer? = nil    // optional image layer
    lazy var image : OMProgressImageLayer! = {
        if self.imageLayer  == nil {
            self.imageLayer = OMProgressImageLayer()
        }
        return self.imageLayer!
    }()
    
    // MARK: Font and Text (do no need layout)
    
    // text
    
    /// The text represent a percent number.
    var percentText:Bool = false {
        didSet{
            number.formatStyle = percentText ? .percentStyle : .noStyle
            updateNumberLayerGeometry()
        }
    }
    
    /// Radius
    
    // Internal Radius
    
    var innerRadius  : CGFloat {
        return self.radius - self.borderWidth;
    }
    
    // Center Radius
    var midRadius  : CGFloat {
        return self.radius - (self.borderWidth * 0.5);
    }
    
    // Radius
    var outerRadius  : CGFloat {
        return self.radius;
    }
    
    // Private member for calculate the radius
    
    fileprivate(set) var suggestedRadius : CGFloat = 0.0
    
    // Radius of the progress view
    
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
            
            return simpleRadius
        }
    }
    
    // Border
    
    // Border width
    
    internal var borderWidth : CGFloat {
        return CGFloat(thicknessRatio * Double(radius))
    }
    
    // Border radio (default: 10%)
    
    public var thicknessRatio : Double = 0.1 {
        didSet {
            thicknessRatio.clamp(toLowerValue: 0.0,upperValue: 1.0)
            setNeedsLayout();
        }
    }
    
    // !!!FIXME: if progress does not exist, then the Images are hidden
    
    public var progress: Double = 0.0 {
        
        didSet(newValue) {
            
            print("DEBUG(\(layer.name ?? "")): progress: \(progress)")
            
            //let rads = numberOfRadians()
            //assert(abs(rads - 2 * M_PI) < DBL_EPSILON, "Unexpected angle consistence of circle radians (2 * π) != \(rads)")
            
            if (progress == kCompleteProgress) {
                progress = Double(numberOfSteps)
            }
            
            layoutIfNeeded();
            
            updateCompleteProgress()
        }
    }
    
    
    // MARK:
    
    /**
     * Update the progress stuff.
     */
    fileprivate func updateCompleteProgress()
    {
        print("DEBUG(\(layer.name ?? "")): updateCompleteProgress (progress: \(progress))")
        
        if progress == 0 {
            // Nothing to update
            return
        }
        
        assert(progress <= Double(numberOfSteps),"Unexpected progress \(progress) max \(numberOfSteps) ")
        
        let clmprogress:Double = clamp(progress, lower: 0.0,upper: Double(numberOfSteps))
        
        let stepsDone   = Int(clmprogress);
        let curStep     = clmprogress - floor(clmprogress);
        
        // Initialize the sequential time control vars.
        
        CATransaction.begin()
        beginTime    = CACurrentMediaTime()
        newBeginTime = 0.0
        
        for index:Int in 0..<numberOfSteps {
            
            print("VERBOSE(\(layer.name ?? "")):#\(index) of \(numberOfSteps) in \(progress) : done:\(stepsDone) current:\(curStep)")
            
            setStepProgress(index, stepProgress: (index < stepsDone) ?  1.0 : curStep)
        }
        
        let duration        = (animationDuration / Double(numberOfSteps)) * clmprogress
        let toValue:Double  = clamp((progress / Double(numberOfSteps)),lower: 0.0,upper: 1.0)

        
        weak var delegate = self
        
        ///  center image
        if let centerImageLayer = image  {
            if enableAnimations  {
                // Remove all animations
                centerImageLayer.removeAllAnimations()
                centerImageLayer.animateProgress( 0,
                                                  toValue: toValue,
                                                  beginTime: beginTime,
                                                  duration: duration,
                                                  delegate: delegate)
            }else {
                image.progress = toValue
            }
        }
        
        ///  center number
        if let numberLayer = number {
            if enableAnimations  {
                // Remove all animations
                numberLayer.removeAllAnimations()
                numberLayer.animateNumber(  0.0,
                                            toValue:toValue,
                                            beginTime:beginTime,
                                            duration:duration,
                                            delegate:delegate)
            } else {
                number.number = toValue as NSNumber
            }
        }
        
        CATransaction.commit()
        
        print("DEBUG(\(layer.name ?? "")): updateCompleteProgress (progress: \(clmprogress))")
    }
    
    /**
     * Get the progress of the step by index
     *
     * parameter index:           step index
     * returns:               step progress
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
     * Set step progress at index with animation if is needed
     *
     * parameter index:           step index
     * parameter progressAtIndex: step progress
     *
     */
    func setStepProgress(_ index:Int, stepProgress:Double) {
        
        assert(index <= numberOfSteps, "out of bounds. \(index) max: \(numberOfSteps)")
        
        if (index >= numberOfSteps) {
            return
        }
        
        let oldStepProgress = getStepProgress(index)
        
        print("DEBUG(\(layer.name ?? "")): setStepProgress (index : \(index) old \\ new progress: \(stepProgress) \\ \(oldStepProgress))")
        
        if let step = self[index] {
            if enableAnimations {
                stepAnimation(step, progress:stepProgress)
            } else {
                // Remove the default animation of strokeEnd from the shape layers.
                step.shapeLayer.actions = ["strokeEnd" : NSNull()]
                if let shapeLayerBorder = step.shapeLayerBorder {
                    shapeLayerBorder.actions = ["strokeEnd" : NSNull()]
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
            $0 + ($1 as! CPStepData).angle.length()
        }
    }
    /**
     * Get the total percent of radians done. (2 * M_PI)
     *
     * returns: percent of radian done
     */
    
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
            startAngle  = (dataSteps.lastObject as! CPStepData).angle.end
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
    fileprivate func setUpLayers(_ step:CPStepData, start:Double, end:Double) {
        
        print("DEBUG(\(layer.name ?? "")): setUpLayers: \(stepIndex(step)) \(CPCAngle(start: start, end: end))")
        
        // SetUp the mask layer
        if let maskLayer = step.maskLayer {
            // Update the mask frame
            if maskLayer.frame != bounds {
                maskLayer.frame = bounds
                // Mark the layer for update because has a new frame.
                maskLayer.setNeedsDisplay()
            }
            
        }
        
        setUpProgressLayer(step,start:start,end:end)
        
        // The user wants a well
        
        if self.options.contains(.well) {
            
            print("VERBOSE(\(layer.name ?? "")): Setupping the well layer")
            
            // Set Up the well layer of the progress layer.
            
            #if !DEBUG_NO_WELL
                
                // This layer uses the shape path
                step.well.path            = step.shapeLayer.path
                step.well.backgroundColor = UIColor.clear.cgColor
                step.well.fillColor       = nil
                
                if (step.well.strokeColor == nil) {
                    step.well.strokeColor     = UIColor(white:0.9, alpha:0.8).cgColor
                }
                step.well.lineWidth       = borderWidth
                
                // Activate shadow only if exist space between steps.
                
                //                 step.well.shadowOpacity = 1.0
                //                 step.well.shadowOffset  = CGSize(width:0,height:10)
                //                 step.well.shadowRadius  = 0
                //                 step.well.shadowColor   = UIColor.black.cgColor
                
                
                // Same as shape layer
                
                step.well.lineCap     = step.shapeLayer.lineCap
                step.well.lineJoin    = step.shapeLayer.lineJoin
                step.well.miterLimit  = step.shapeLayer.miterLimit
                
                
                // Add the layer behind the other layers
                containerLayer?.insertSublayer(step.well, at:0)
                //}
            #endif
            
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
    
    fileprivate func setUpProgressLayer(_ step:CPStepData, start:Double, end:Double) {
        
        let shapeLayer = step.shapeLayer
        let name = "step \(stepIndex(step)) shape"
        
        print("DEBUG(\(layer.name ?? ""))(\(name)): setUpProgressLayer(start:\(round(start.radiansToDegrees())) end:\(round(end.radiansToDegrees())))")
        // This assert can be caused when separator Ratio is 1.0
        assert(start != end,
               "The start angle and the end angle cannot be the same. angle: \(round(start.radiansToDegrees()))")
        assert(start < end, "Unexpected start/end angle. \(round(start.radiansToDegrees()))/\(round(end.radiansToDegrees()))");
        
        shapeLayer.name = name
        
        // TODO: the head can be rounded?
        
        let canRoundedHead = true
        let roundedHeadArcAngleStart:Double = 0
        let roundedHeadArcAngleEnd:Double   = 0
        // angle
        let theAngle = CPCAngle(start: start + roundedHeadArcAngleStart,
                               end  : end   - roundedHeadArcAngleEnd)
        
        print("VERBOSE(\(layer.name ?? ""))(\(name)) angle:\(theAngle) Rounded head angle start / end : \(round(roundedHeadArcAngleStart.radiansToDegrees()))° / \(round(roundedHeadArcAngleEnd.radiansToDegrees()))°")
        
        let bezier = UIBezierPath( arcCenter:bounds.size.center(),
                                   radius:midRadius,
                                   startAngle:CGFloat(theAngle.start),
                                   endAngle:CGFloat(theAngle.end),
                                   clockwise: true)
        
        shapeLayer.path            = bezier.cgPath
        shapeLayer.backgroundColor = UIColor.clear.cgColor
        shapeLayer.fillColor       = nil
        shapeLayer.strokeColor     = ( step.maskLayer != nil ) ? UIColor.black.cgColor : step.color.cgColor
        
        if self.options.contains(.roundedHead) && canRoundedHead {
            shapeLayer.lineCap   = kCALineCapRound;
        } else {
            shapeLayer.lineCap   = kCALineCapButt;
        }
        shapeLayer.strokeStart     = 0.0
        shapeLayer.strokeEnd       = 0.0
        
        if step.borderRatio > 0 {
            let borderLayer  = step.border!
            let name = "step \(stepIndex(step)) shape border"
            borderLayer.name = name
            print("INFO(\(layer.name ?? ""))(\(name)): Adding the border layer with the ratio: \(step.borderRatio)")
            assert((shapeLayer.path != nil), "CAShapeLayer with a nil CGPath");
            
            borderLayer.path        = bezier.cgPath
            borderLayer.fillColor   = nil
            
            if(borderLayer.strokeColor == nil) {
                borderLayer.strokeColor = kDefaultBorderColor
            }
            // DEBUG
            let color:UIColor
            if let c = borderLayer.strokeColor {
                color = UIColor(cgColor:c)
            } else {
                color = UIColor(cgColor:kDefaultBorderColor)
            }
            
            print("INFO(\(layer.name ?? ""))(\(name)): Setting the border layer with the color: \(color.shortDescription)")
            
            borderLayer.strokeStart = 0.0
            borderLayer.strokeEnd   = 0.0
            borderLayer.lineWidth   = borderWidth
            
            borderLayer.lineCap     = shapeLayer.lineCap
            borderLayer.lineJoin    = shapeLayer.lineJoin
            borderLayer.miterLimit  = shapeLayer.miterLimit
            
            
            borderLayer.shadowOpacity = step.borderShadow ? 1.0 : 0.0
            borderLayer.shadowOffset  = kDefaultBorderShadowOffset
            borderLayer.shadowRadius  = kDefaultBorderShadowRadius
            borderLayer.shadowColor   = kDefaultBorderShadowColor
            
            shapeLayer.lineWidth = (borderWidth * CGFloat(1.0 - step.borderRatio))
            
            print("INFO(\(layer.name ?? ""))(\(name)): Border layer width \(borderLayer.lineWidth) new shape width: \(shapeLayer.lineWidth)")
            
        } else {
            shapeLayer.lineWidth  = borderWidth
            
            //shapeLayer.shadowOpacity = 1.0
            //shapeLayer.shadowOffset  = CGSize(width:0,height:10)
            //shapeLayer .shadowRadius  = 0
            //shapeLayer.shadowColor   = UIColor.black.cgColor
        }
        
        if let mask = step.maskLayer,let border = step.shapeLayerBorder {
            border.addSublayer(shapeLayer)
            containerLayer!.addSublayer(border)
            mask.mask = shapeLayer
            containerLayer!.addSublayer(mask)
        } else if let mask = step.maskLayer {
            mask.mask = shapeLayer
            containerLayer!.addSublayer(mask)
            #if DEBUG_MASK
                containerLayer.addSublayer(shapeLayer)
            #endif
        } else if let border = step.shapeLayerBorder {
            border.addSublayer(shapeLayer)
            containerLayer!.addSublayer(step.shapeLayerBorder!)
        } else {
            containerLayer!.addSublayer(shapeLayer)
        }
    }
    
    
    /**
     *   Layout the subviews
     */
    override func layoutSubviews() {
        print("DEBUG(\(layer.name ?? "")): layoutSubviews()")
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
    
    fileprivate func angleRect(_ angle:Double, radius:CGFloat, align:CPCRadiusAlignment = .middle, size:CGSize = CGSize.zero) -> CGRect {
        print("DEBUG(\(layer.name ?? "")): anglePointCentered(\(angle) \(radius) \(align) \(size))")
        
        return anglePoint(angle,radius:radius,align: align,size: size).centerRect(size)
        
    }
    fileprivate func anglePoint(_ angle:Double, radius:CGFloat, align:CPCRadiusAlignment = .middle,size:CGSize = CGSize.zero) -> CGPoint {
        print("DEBUG(\(layer.name ?? "")): anglePoint(\(angle) \(radius) \(align) \(size))")
        return CPCAngle.point(angle,center:bounds.size.center(),radius:radius)
    }
    
    
    fileprivate func angleRect(_ angle:Double, align:CPCRadiusAlignment, size:CGSize = CGSize.zero) -> CGRect {
        print("DEBUG(\(layer.name ?? "")): anglePointCentered(\(angle) \(align) \(size))")
        return anglePoint(angle,align: align,size: size).centerRect(size)
        
    }
    fileprivate func anglePoint(_ angle:Double, align:CPCRadiusAlignment, size:CGSize = CGSize.zero) -> CGPoint {
        print("DEBUG(\(layer.name ?? "")): anglePoint(\(angle) \(align) \(size))")
        return CPCAngle.point(angle,center:bounds.size.center(),radius:CGFloat(alignInRadius(align:align ,size: size )))
    }
    
    
    func alignInRadius(align: CPCRadiusAlignment, size:CGSize = CGSize.zero) -> Double
    {
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
        return newRadius;
    }
    

    
    /**
     * Add the created step image layers to the root layer.
     */
    
    fileprivate func addStepImageLayers() {
        print("DEBUG(\(layer.name ?? "")) : addStepImageLayers()")
        for (index, step) in dataSteps.enumerated() {
            let theStep = step as! CPStepData
            theStep.ie.layer.name = "step \(index) image"
            containerLayer!.addSublayer(theStep.ie.layer )
            theStep.ie.shadow = true
        }
    }
    /**
     * Add the created step image layers to the root layer.
     */
    fileprivate func addStepTextLayers() {
        print("DEBUG(\(layer.name ?? "")): addStepTextLayers()")
        for (index, step) in dataSteps.enumerated() {
            let theStep =  step as! CPStepData
            theStep.te.layer .name = "step \(index) text"
            containerLayer!.addSublayer(theStep.te.layer )
            theStep.te.shadow = true
        }
    }
    
    /**
     * SetUp the text layer geometry
     *
     * parameter step: Step Object
     */
    
    
    //sizeOfImage
    //angle
    //angle align
    //image Align
    //imageOrientationToAngle
    

    
    fileprivate func setUpStepImageLayerGeometry(step:CPStepData) {
        print("DEBUG(\(layer.name ?? "")): setUpStepImageLayerGeometric(\(step))")
        let sizeOf = step.ie.layer.image?.size
        // Reset the angle orientation before sets the new frame
        step.ie.layer.setTransformRotationZ(0)
        let angle = step.angle.angle(step.ie.anglePosition)
        print("DEBUG(\(layer.name ?? "")): angle \(round(angle.radiansToDegrees())) text angle position :\(step.ie.anglePosition)")
        let anglePoint = CPCAngle.point(angle,
                                       center:bounds.size.center(),
                                       radius: CGFloat(alignInRadius(align: step.ie.radiusPosition, size: sizeOf!)))
        print("DEBUG(\(layer.name ?? "")): Position in angle \(anglePoint)  position in radius :\(step.ie.radiusPosition)")
        let positionInAngle = anglePoint.centerRect(sizeOf!)
        print("VERBOSE(\(layer.name ?? "")): Frame \(positionInAngle.integral) from the aligned step angle \(angle) and the image size \(sizeOf?.integral())")
        step.ie.layer.frame = positionInAngle
        // Rotate the layer
        if (step.ie.orientationToAngle) {
            let rotationZ = (angle - startAngle)
            print("VERBOSE(\(layer.name ?? "")): Image will be oriented to angle: \(round(rotationZ.radiansToDegrees()))")
            step.ie.layer.setTransformRotationZ(rotationZ)
        }
    }
    
    /**
     * Setup the text layer geometry
     *
     * parameter step: Step Object
     */
    
    fileprivate func setUpStepTextLayerGeometry(_ step:CPStepData) {
        print("DEBUG(\(layer.name ?? "")) : setUpStepTextLayerGeometric(\(step))")
        if step.te.layer.string != nil {
            // Reset the angle orientation before sets the new frame
            step.te.layer.setTransformRotationZ(0.0)
            let sizeOf = step.te.layer.frameSize();
            let angle:Double = step.angle.angle(step.te.anglePosition)
            print("DEBUG(\(layer.name ?? "")): angle \(round(angle.radiansToDegrees())) text angle position :\(step.te.anglePosition)")
            let anglePoint = CPCAngle.point(angle,
                                           center:bounds.size.center(),
                                           radius: CGFloat(alignInRadius(align: step.te.radiusPosition, size: sizeOf)))
            
            print("DEBUG(\(layer.name ?? "")): Position in angle \(anglePoint)  position in radius :\(step.te.radiusPosition)")
            let positionInAngle = anglePoint.centerRect(sizeOf)
            print("VERBOSE(\(layer.name ?? "")): Frame \(positionInAngle.integral) from the aligned step angle \(angle) and the text size \(sizeOf.integral()))")
            step.te.layer.frame = positionInAngle
            if step.te.orientationToAngle {
                let rotationZ = (angle - startAngle)
                print("VERBOSE(\(layer.name ?? "")): Image will be oriented to angle: \(round(rotationZ.radiansToDegrees()))")
                step.te.layer.setTransformRotationZ( rotationZ )
            }
        }
    }
    
    /**
     * Remove all layers from the superlayer.
     */
    func removeSublayers() {
        print("DEBUG(\(layer.name ?? "")) : removeSublayers()")
        if let s = containerLayer!.sublayers {
            for (_, layer) in s.enumerated() {
                layer.removeAllAnimations()
                layer.removeFromSuperlayer()
            }
        }
        containerLayer!.removeAllAnimations()
        containerLayer!.removeFromSuperlayer()
    }
    /**
     *   Add the image layers
     */
    func addImages() {
        #if !NO_IMAGE
            // Add all steps image
            addStepImageLayers()
            // Add the center image layer to the root layer.
            print("INFO(\(layer.name ?? "")): Add the center image layer to the container layer.")
            if let img  = image.image {
                image.frame = bounds.size.center().centerRect(img.size)
                image.name = "center image"
                containerLayer!.addSublayer(image)
                image.shadowOpacity = 1.0
                image.shadowOffset  = kDefaultElementShadowOffset
                image.shadowRadius  = kDefaultElementShadowRadius
                image.shadowColor   = kDefaultElementShadowColor
            }
        #endif
    }
    /**
     *   Add the text layers
     */
    func addTexts() {
        #if !NO_TEXT
            // Add all steps texts
            addStepTextLayers()
            /// Add the text layer.
            if percentText  {
                number.name = "center number"
                containerLayer!.addSublayer(number)
                number.shadowOpacity = 1.0
                number.shadowOffset  = kDefaultElementShadowOffset
                number.shadowRadius  = kDefaultElementShadowRadius
                number.shadowColor   = kDefaultElementShadowColor
                
            }
        #endif
    }
    /**
     *   Dump the internal data
     */
    func debugLayersAndSteps()  {
        #if DEBUG
            #if DUMP_LAYERS
                dumpLayers(0, layer:containerLayer)
            #endif
            #if DUMP_STEPS
                dumpAllSteps()
            #endif
        #endif
    }
    /**
     *   Create or update all the necesary layers
     */
    internal func updateLayerTree() {
        
        print("DEBUG(\(layer.name ?? "")): updateLayerTree()")
        
        if let containerLayer = containerLayer {
            if (containerLayer.superlayer == nil) {
                layer.addSublayer(containerLayer)
            }
        } else {
            containerLayer = layer
        }
        
        if (percentText) {
            updateNumberLayerGeometry()
        }
        
        // Create and setup the position of the text and image step layers
        for (_, step) in dataSteps.enumerated() {
            let data  = step as! CPStepData
            // Image Layer
            if data.ie.layer.image != nil {
                data.ie.layer.name = "step \(stepIndex(data)) image"
                setUpStepImageLayerGeometry(step: data)
            }
            // Text Layer
            if  data.te.layer.string  != nil {
                setUpStepTextLayerGeometry(data)
            }
        }
        
        /// Create the layers for each step.
        for (_, step) in dataSteps.enumerated() {
            let data = step as! CPStepData
            setUpLayers(data, start:data.angle.start, end: data.angle.end)
        }
        
        addImages()
        
        addTexts()
        
        debugLayersAndSteps()
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
    internal func stepIndex(_ step:CPStepData) -> Int {
        return self.dataSteps.index(of: step)
    }
    
    /**
     *  Get/Set the step data, subscripted by index from the list of steps
     */
    
    subscript(stepIndex: Int) -> CPStepData? {
        get {
            assert(stepIndex < numberOfSteps, "out of bounds. \(stepIndex) max: \(numberOfSteps)")
            if stepIndex < numberOfSteps {
                return dataSteps[stepIndex] as? CPStepData
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
     * Each progress step is represented by the object CPStepData
     *
     * parameter start: step start angle
     * parameter end:   step end angle
     * parameter color:      step color
     *
     * returns: return a CPStepData object.
     */
    
    func addStep(_ start:Double, end:Double, color:UIColor!) -> CPStepData? {
        let angle = CPCAngle(start:start,end:end)
        let valid = angle.valid()
        assert(valid,"Invalid angle:\(angle). range in radians : -(2*PI)/+(2*PI)")
        if(!valid) {
            print("WARNING(\(layer.name ?? "")): Invalid angle :\(angle)")
            return nil;
        }
        // Create the step
        let step = CPStepData(angle: angle, color:color)
        
        print("VERBOSE(\(layer.name ?? "")): Adding new step with the angle: \(angle)")
        
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
            print("WARNING(\(layer.name ?? "")): Out of radians: can't create the step. overflow by \(𝜏 - numberOfRad) radians")
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
     * returns: return a CPStepData object.
     */
    
    func addStep(_ angle:Double, color:UIColor!) -> CPStepData? {
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
     * returns: return a CPStepData object.
     */
    
    func addStepWithPercent(_ start:Double, percent:Double, color:UIColor!) -> CPStepData? {
        assert(CPCAngle.inRange(angle: start),
               "Invalid angle:\(startAngle). range in radians : -(2*PI)/+(2*PI)")
        
        // clap the percent.
        let step = CPStepData(start:start,
                              percent:clamp(percent, lower: 0.0,upper: 1.0),
                              color:color)
        
        print("VERBOSE(\(layer.name ?? "")): Adding new step with the angle: \(step.angle!)")
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
     * returns: return a CPStepData object.
     */
    
    func addStepWithPercent(_ percent:Double, color:UIColor!) -> CPStepData? {
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
            print("VERBOSE(\(layer.name ?? "")): \(index): \(step as! CPStepData)")
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
            str += "\(index): \((step as! CPStepData)) "
        }
        str += "]"
        
        return str;
    }
    
}

extension OMCircularProgress : CAAnimationDelegate
{
    /// MARK: CAAnimation delegate
    
    func animationDidStart(_ anim: CAAnimation) {
        print("DEBUG(\(layer.name ?? "")): animationDidStart:\((anim as! CABasicAnimation).keyPath!) : \((anim as! CABasicAnimation).beginTime) ")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            print("DEBUG(\(layer.name ?? "")): animationDidStop:\((anim as! CABasicAnimation).keyPath!) : \((anim as! CABasicAnimation).duration)")
        }
    }
    
    //
    // Animate the shapeLayer and the image for the step
    //
    
    func stepAnimation(_ step:CPStepData, progress:Double) {
        
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
        
        if (progressStyle == .sequential) {
            
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
        
        if let imgLayer = step.ie.layer {
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
            
            print("WARNING(\(layer.name ?? "")): Unable to locate the layer that contains the location \(location)")
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

