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
//  Version             Changes
//
//  1.0                 Update to Xcode 9 beta4 Swift jom:(18/8/2017)
//
//

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

/// Constants

let 𝜏   = 2.0 * .pi

// MARK: - Constant Definitions

let kControlInset:CGFloat = 0.0//20.0

let kCompleteProgress:Double = Double.infinity

let kDefaultStartAngle:Double = -90.degreesToRadians()

let kDefaultBorderColor:CGColor       = UIColor.black.cgColor

// Image Shadow
let kDefaultElementShadowOpacity:Float   = 1 // opaque
let kDefaultElementShadowOffset:CGSize   = CGSize(width:0.0,height: 10.0)
let kDefaultElementShadowRadius:CGFloat  = 3
let kDefaultElementShadowColor:CGColor   = UIColor.black.cgColor


// Border Shadow
let kDefaultBorderShadowOffset:CGSize  = CGSize(width:0.0,height: 2.5)
let kDefaultBorderShadowRadius:CGFloat = 2
let kDefaultBorderShadowColor:CGColor  = UIColor(white:0.3,alpha:1.0).cgColor

///
/// The OMCircularProgress delegate Protocol
///

@objc protocol OMCircularProgressProtocol {
    ///
    /// Notificate the layer hit
    ///
    /// - parameter ctl:      The object caller
    /// - parameter layer:    The layer hitted
    /// - parameter location: The CGPoint where the layer was hitted
    
    @objc optional func layerHit(_ ctl:UIControl, layer:CALayer, location:CGPoint)
}

// MARK: - Types

/// OMCPCOptions
///
/// The options for the circular progress control.
///
/// well        : Show the well layer (default: false)
/// roundedHead : Set the rounded head to each step representation  (default: false)
///

public struct OMCPCOptions : OptionSet {
    
    public let rawValue: UInt
    public init(rawValue: UInt)  { self.rawValue = rawValue }
    public static let well          = OMCPCOptions(rawValue: 1 << 0)
    public static let roundedHead   = OMCPCOptions(rawValue: 1 << 1)
}


/// OMCPCStyle
///
/// The styles permitted for the circular progress control.
///
/// direct     : direct step progress
/// sequential : sequential step progress
///
/// @note: You can set and retrieve the current style of progress
///        view through the progressStyle property.

public enum OMCPCStyle : Int
{
    case direct
    case sequential
    init() {
        self = .sequential
    }
}


/// OMCPCRadiusPosition
///
/// Image and text radius position
///
/// inner : center radius position
/// middle: middle radius position
/// border: border radius position
/// outer:  outer radius position

enum OMCPCRadiusPosition : Int
{
    case inner
    case middle
    case border
    case outer
    init() {
        self = .middle
    }
}


/// Angle position
///
/// start : start of the angle
/// middle: middle of the angle
/// end   : end of the angle
///

public enum OMCPCAnglePosition : Int
{
    case start
    case middle
    case end
    init() {
        self = .middle
    }
}

/// + OMAngle operator
///
/// - parameter left:  left OMAngle
/// - parameter right: right OMAngle
///
/// - returns: return left + right
func + (left: OMAngle, right: OMAngle) -> OMAngle {
    return OMAngle(start:left.start,length:left.end+right.length())
}

/// + OMAngle operator
///
/// - parameter left:  left OMAngle
/// - parameter right: right Double
///
/// - returns: return left + right
func + (left: OMAngle, right: Double) -> OMAngle {
    return OMAngle(start:left.start,length:left.end+right)
}


/// - OMAngle operator
///
/// - parameter left:  left OMAngle
/// - parameter right: right Double
///
/// - returns: return left + right
func - (left: OMAngle, right: Double) -> OMAngle {
    return OMAngle(start:left.start,length:left.end-right)
}


/// - OMAngle operator
///
/// - parameter left:  left OMAngle
/// - parameter right: right OMAngle
///
/// - returns: return left - right
func - (left: OMAngle, right: OMAngle) -> OMAngle {
    return OMAngle(start:left.start,length:left.end-right.length())
}

/// == OMAngle operator
///
/// - parameter left:  left OMAngle
/// - parameter right: right OMAngle
///
/// - returns: return left == right
func == (left: OMAngle, right: OMAngle) -> Bool {
    return left.start ==  right.start &&  left.end ==  right.end
}

/// Object that encapsulate a angle

open class OMAngle : CustomDebugStringConvertible {
    
    var start:Double = 0.0                // start of angle in radians
    var end:Double   = 0.0                // end of angle in radians
    
    // MARK: Contructors
    
    ///  Contruct the angle
    ///
    /// - parameter start:  start angle  in radians
    /// - parameter end: end angle  in radians
    ///
    /// - returns: return self
    convenience init(start:Double, end:Double){
        self.init()
        self.start = start
        self.end   = end;
        
        assert(valid())
    }
    
    ///  Contruct the angle
    ///
    /// - parameter start:  start angle  in radians
    /// - parameter length: length in radians
    ///
    /// - returns: return self
    convenience init(start:Double, length:Double){
        self.init()
        self.start = start
        self.end   = start+length;
        
        assert(valid())
    }
    
    ///  Contruct the angle in degree
    ///
    /// - parameter startDegree:  start angle in degree
    /// - parameter endDegree: end angle in degree
    ///
    /// - returns: return self
    convenience init(startDegree:Double, endDegree:Double){
        self.init()
        self.start = startDegree.degreesToRadians()
        self.end   = endDegree.degreesToRadians()
        if(!valid()) {
            Log.w("(OMAngle): Angle overflow. \(self)")
        }
    }
    
    ///  Contruct the angle in degree
    ///
    /// - parameter startDegree:  start angle in degree
    /// - parameter lengthDegree: lenght angle in degree
    
    /// - returns: return self
    convenience init(startDegree:Double, lengthDegree:Double){
        self.init()
        let start = startDegree
        let end   = startDegree+lengthDegree
        
        // convert to radians
        self.start =  start.degreesToRadians();
        self.end   =  end.degreesToRadians();
        
        if(!valid()) {
            Log.w("(OMAngle): Angle overflow. \(self)")
        }
    }
    
    ///
    ///  Get the angle arc length
    ///
    ///  - returns: return the angle arc length
    ///  - info   : arc angle = θ / r
    ///
    public func arcAngle(_ radius:CGFloat) -> Double {
        return length() / Double(radius)
    }
    
    ///
    /// Get angle arc length
    ///
    ///  - returns: return the angle arc length
    ///  - info   : arc length = θ × r
    ///
    
    public func arcLength(_ radius:CGFloat) -> Double {
        return length() * Double(radius)
    }
    
    ///
    /// Get the middle angle length
    ///
    /// returns: return middle angle length in radians
    ///
    
    public func mid() -> Double {
        let len = length()
        return start + (len * 0.5)
    }
    
    ///
    /// Get the angle length
    ///
    /// returns: return angle length in radians
    //
    
    public func length() -> Double {
        return end - start
    }
    
    ///
    /// Check if the angle is valid
    ///
    /// returns: return if the angle is valid
    ///
    
    public func valid() -> Bool {
        let len = length()
        return len >= 0.0 && len <= 𝜏
    }
    
    ///  Angle in range
    ///
    /// - parameter angle: angle in radians
    ///
    /// - returns: return Bool
    static func inRange(angle:Double) -> Bool {
        return (angle > 𝜏 || angle < -𝜏) == false
    }
    
    /// Get the normalized angle
    ///
    /// returns: return angle length in radians
    ///
    
    func norm() -> Double {
        return self.start / 𝜏
    }
    
    
    /// Aling angle to CPCAnglePosition
    ///
    /// - parameter position: position in angle
    ///
    /// - returns: angle anligned to PositionInAngle
    public func angle(_ position:OMCPCAnglePosition) -> Double {
        switch(position) {
        case .middle:
            return self.mid()
        case .start:
            return self.start
        case .end:
            return self.end
        }
    }
    
    /// Format the angle
    ///
    /// - parameter angle: angle in radians
    ///
    /// - returns: String formatted
    public class func format(_ angle:Double) -> String {
        return "\(round(angle.radiansToDegrees()))°"
    }
    
    
    /// Rectangle of a angle
    ///
    /// - parameter angle:  angle
    /// - parameter center: center
    /// - parameter radius: radius
    ///
    /// - returns: CGRect
    
    public class func rectOfAngle(_ angle:OMAngle, center:CGPoint, radius: CGFloat) -> CGRect{
        let p1  = OMAngle.pointOfAngle(angle.start, center: center, radius: radius)
        let p2  = OMAngle.pointOfAngle(angle.end, center: center, radius: radius)
        return CGRect(x:min(p1.x, p2.x),
                      y:min(p1.y, p2.y),
                      width:abs(p1.x - p2.x),
                      height:abs(p1.y - p2.y));
    }
    
    ///  Point in a angle
    ///
    /// - parameter angle:  angle
    /// - parameter center: center
    /// - parameter radius: radius
    ///
    /// - returns: CGPoint
    public class func pointOfAngle(_ angle:Double, center:CGPoint, radius: CGFloat) -> CGPoint {
        
        // Given a radius length r and an angle in radians and a circle's center (x,y),
        // calculate the coordinates of a point on the circumference
        
        let theta = CGFloat( angle )
        
        // Cartesian angle to polar.
        
        return CGPoint(x: center.x + CGFloat(radius) * cos(theta), y: center.y + CGFloat(radius) * sin(theta))
    }
    
    // MARK: DebugPrintable protocol
    
    open var debugDescription: String {
        let sizeOfAngle = OMAngle.format(length())
        let degreeS     = OMAngle.format(start)
        let degreeE     = OMAngle.format(end)
        return "[\(degreeS) \(degreeE)] \(sizeOfAngle)"
    }
}

///  Generic layer element

open class OMCPCElement<T:CALayer> {
    var radiusPosition      : OMCPCRadiusPosition  = .border  // element position in radius. Default : .border
    var anglePosition       : OMCPCAnglePosition   = .start   // element position in angle. Default : .start
    var orientationToAngle  : Bool = true                     // is the imagen oriented to the step angle. Default : true
    func correctedShadowOffsetForTransformRotationZ(_ angle:Double,offset:CGSize)-> CGSize {
        return CGSize(width :offset.height*CGFloat(sin(angle)) + offset.width*CGFloat(cos(angle)),
                      height:offset.height*CGFloat(cos(angle)) - offset.width*CGFloat(sin(angle)))
    }
    
    /* The color of the shadow. Defaults to opaque black. Colors created
     * from patterns are currently NOT supported. Animatable. */
    
    /** Shadow properties. **/
    open var shadowColor: CGColor = kDefaultElementShadowColor
    
    /* The opacity of the shadow. Defaults to 0. Specifying a value outside the
     * [0,1] range will give undefined results. Animatable. */
    
    open var shadowOpacity: Float = kDefaultElementShadowOpacity
    
    /* The shadow offset. Defaults to (0, -3). Animatable. */
    
    open var shadowOffset: CGSize = kDefaultElementShadowOffset
    
    /* The blur radius used to create the shadow. Defaults to 3. Animatable. */
    
    open var shadowRadius: CGFloat = kDefaultElementShadowRadius
    
    open var shadowPath: CGPath?
    
    /// Enable element shadow
    var shadow:Bool = false {
        didSet {
            if (shadow) {
                layer.shadowRadius   = self.shadowRadius
                layer.shadowColor    = self.shadowColor
                layer.shadowOffset   = self.shadowOffset
                layer.shadowOpacity  = self.shadowOpacity
                if orientationToAngle {
                    let angle = layer.getTransformRotationZ()
                    layer.shadowOffset = correctedShadowOffsetForTransformRotationZ(angle, offset: layer.shadowOffset)
                    Log.d("\(layer.name ?? "")):shadowOffset: \(layer.shadowOffset) angle:\(OMAngle.format(angle)))")
                }
            } else {
                // Trasparent
                layer.shadowOpacity = 0
            }
        }
    }
    internal var internalLayer:T? = nil                // layer for the text
    lazy var layer : T! = {
        if self.internalLayer  == nil {
            self.internalLayer = T()
        }
        return self.internalLayer!
    }()
    
}

/// The OMCPStepData object represent each step element data in the circular progress control

open class OMCPStepData : CustomDebugStringConvertible {
    /// Basic step data
    var angle:OMAngle!                                      // step angle
    var color:UIColor!                                       // step color
    internal var shapeLayer:CAShapeLayer = CAShapeLayer()    // progress shape
    var maskLayer:CALayer? = nil                             // optional layer mask
    
    // CPElements
    
    var imageElement:OMCPCElement<OMProgressImageLayer> = OMCPCElement<OMProgressImageLayer>()
    var textElement:OMCPCElement<OMTextLayer>           = OMCPCElement<OMTextLayer>()
    
    
    /// Setup the step layer geometry
    ///
    /// - Parameters:
    ///   - element: <#element description#>
    ///   - radius: <#radius description#>
    ///   - rect: <#rect description#>
    ///   - sizeOf: <#sizeOf description#>
    ///   - startAngle: <#startAngle description#>
    func setUpStepLayerGeometry(element:OMCPCElement<CALayer>,
                                radius:CGFloat,
                                rect:CGRect,
                                sizeOf:CGSize,
                                startAngle:Double  = -90.0.degreesToRadians() ) {
        
        OMCPStepData.setUpStepLayerGeometry(element: element,
                                            angle: self.angle,
                                            radius:radius,
                                            rect:rect,
                                            sizeOf:sizeOf,
                                            startAngle:startAngle );
        
    }
    
    class func setUpStepLayerGeometry(element:OMCPCElement<CALayer>,
                                      angle:OMAngle,
                                      radius:CGFloat,
                                      rect:CGRect,
                                      sizeOf:CGSize,
                                      startAngle:Double  = -90.0.degreesToRadians() ) {
        
        // Reset the angle orientation before sets the new frame
        
        element.layer.setTransformRotationZ(0.0)
        let angle:Double = angle.angle(element.anglePosition)
        let anglePoint = OMAngle.pointOfAngle(angle, center:rect.size.center(), radius: radius)
        let positionInAngle = anglePoint.centerRect(sizeOf)
        

        Log.d("\(element.layer.name ?? ""): setUpStepLayerGeometry(\(self))")
        Log.d("\(element.layer.name ?? ""): Angle \(OMAngle.format(angle))) position in angle :\(element.anglePosition)")
        Log.d("\(element.layer.name ?? ""): Position in angle \(anglePoint) position in radius :\(element.radiusPosition)")
        Log.d("\(element.layer.name ?? ""): Frame \(positionInAngle.integral) from the aligned step angle \(OMAngle.format(angle)) and the text size \(sizeOf.integral()))")

        
        element.layer.frame = positionInAngle
        if element.orientationToAngle {
            let rotationZ = (angle - startAngle)

            Log.d("\(element.layer.name ?? ""): Image will be oriented to angle: \(OMAngle.format(rotationZ))")

            element.layer.setTransformRotationZ( rotationZ )
        }
    }
    
    /// Border
    var borderRatio:Double  = 0.0                            // border layer ratio. Default: 0%
    var borderShadow:Bool   = true                           // border layer shadow. Default: true
    internal var shapeLayerBorder:CAShapeLayer? = nil        // layer for the border
    lazy var border : CAShapeLayer! = {
        if self.shapeLayerBorder == nil {
            self.shapeLayerBorder = CAShapeLayer()
        }
        return self.shapeLayerBorder!;
    }()
    
    /// Well layer.
    internal var wellLayer:CAShapeLayer?                     // optional well layer
    lazy var well : CAShapeLayer! = {
        if self.wellLayer == nil {
            self.wellLayer = CAShapeLayer()
        }
        return self.wellLayer!;
    }()
    
    
    ///  OMCPStepData convenience constructor.
    ///
    /// - parameter start: step start angle in radians
    /// - parameter percent:    percent of circle
    /// - parameter color:      color step
    ///
    required convenience public init(start:Double, percent:Double, color:UIColor!){
        self.init(start:start,
                  end: start + (𝜏 * percent),
                  color:color)
    }
    
    
    /// OMCPStepData constructor.
    
    /// - parameter angle:      angle object
    /// - parameter color:      color step
    
    convenience init(start:Double, end:Double, color:UIColor!) {
        let angle = OMAngle(start:start, end:end)
        self.init(angle:angle, color:color)
    }
    
    
    
    /// OMCPStepData constructor.
    
    /// - parameter start: step start angle in radians
    /// - parameter end:   step end angle in radians
    /// - parameter color:      color step
    
    init(angle:OMAngle, color:UIColor!) {
        assert(angle.valid())
        self.angle = angle
        self.color = color
    }
    
    ///  Set/Get the step progress from the shape layer
    
    var progress:Double = 0.0 {
        didSet(newValue) {
            //CATransaction.disableActions()
            shapeLayer.strokeEnd = CGFloat(newValue)
            // if exist border
            if self.borderRatio > 0.0 {
                // update the border layer too
                border.strokeEnd = CGFloat(newValue)
            }
        }
    }
    
    ///  MARK : CustomDebugStringConvertible protocol
    
    public var debugDescription: String {
        let str = "[\(angle!) \(color.shortDescription) \(progress) \(borderRatio)]"
        return str
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
    
    required init?(style : OMCPCStyle) {
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
    
    // Array of OMCPStepData
    
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
    
    var progressStyle: OMCPCStyle = .sequential      // Progress style
    var options      : OMCPCOptions       = []       // Progress options
    
    /// The start angle of the all steps. (default: -90 degrees == 12 o'clock)
    
    @IBInspectable var startAngle : Double = kDefaultStartAngle {
        didSet {
            assert(OMAngle.inRange(angle: startAngle),
                   "Invalid angle : \(startAngle).The angle range must be in radians : -(2*PI)/+(2*PI)")
            setNeedsLayout()
        }
    }
    
    internal var numberLayer:OMNumberLayer? = nil                // Layer for the text
    lazy var number : OMNumberLayer! = {
        if self.numberLayer  == nil {
            // Create the numerical text layer with the text centered
            self.numberLayer =  OMNumberLayer()
              #if !DISABLE_LOG
            self.numberLayer?.name = "number layer"
            #endif
        }
        return self.numberLayer!
    }()
    
    
    /// Update the center numerical layer
    
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
    
    fileprivate(set) var suggestedRadiusRatio : CGFloat = 0.0
    
    // Radius of the progress view
    
    var radius : CGFloat {
        
        set(newRadius) {
            
            suggestedRadiusRatio = newRadius
            self.setNeedsLayout()
        }
        
        get {
            
            if suggestedRadiusRatio > 0.0 {
                return suggestedRadiusRatio * (bounds.insetBy(dx: kControlInset, dy: kControlInset).size.min() * 0.5)
            }
            
            return ( bounds.insetBy(dx: kControlInset, dy: kControlInset).size.min() * 0.5)
            
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
    
    public var progress: Double = 0.0 {
        
        didSet(oldValue) {
        
            Log.d("[\(layer.name ?? "")] old\\new progress: \(oldValue)\\\(progress)")

            //let rads = numberOfRadians()
            //assert(abs(rads - 2 * M_PI) < DBL_EPSILON, "Unexpected angle consistence of circle radians (2 * π) != \(rads)")
            
            if (progress == kCompleteProgress) {
                progress = Double(numberOfSteps)
            }
            
            layoutIfNeeded()
            
            updateProgress()
            
            sendActions(for: .valueChanged)
        }
    }
    
    
    /// Update the progress stuff.
    
    fileprivate func updateProgress()
    {

        Log.d("[\(layer.name ?? "")] updateCompleteProgress (progress: \(progress) of \(numberOfSteps))")

        
        if progress == 0 {
            // Nothing to update
            return
        }
        
        //        if 1.0 == self[(Int(progress - 1))]!.progress {
        //            // already update
        //            return
        //        }
        
        assert(progress <= Double(numberOfSteps),"Unexpected progress \(progress) max \(numberOfSteps) ")
        
        let clmprogress:Double = clamp(progress, lowerValue: 0.0,upperValue: Double(numberOfSteps))
        
        let stepsDone   = Int(clmprogress);
        let curStep     = clmprogress - floor(clmprogress);
        
        // Initialize the sequential time control vars.
        
        CATransaction.begin()
        beginTime    = CACurrentMediaTime()
        newBeginTime = 0.0
        
        for index:Int in 0..<numberOfSteps {

            Log.v("[\(layer.name ?? "")]#\(index) of \(numberOfSteps) in \(progress) : done:\(stepsDone) current:\(curStep)")

            
            setStepProgress(index, stepProgress: (index < stepsDone) ?  1.0 : curStep)
        }
        
        let duration        = (animationDuration / Double(numberOfSteps)) * clmprogress
        let toValue:Double  = clamp((progress / Double(numberOfSteps)),lowerValue: 0.0,upperValue: 1.0)
        
        weak var delegate = self
        
        // Center image
        if let centerImageLayer = image  {
            if enableAnimations  {
                // Remove all animations
                centerImageLayer.removeAllAnimations()
                centerImageLayer.animateProgress( 0,
                                                  toValue: toValue,
                                                  beginTime: beginTime,
                                                  duration: duration,
                                                  delegate: delegate)
            } else {
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
        
        Log.d("[\(layer.name ?? "")] updateCompleteProgress (progress: \(clmprogress) of \(numberOfSteps))")

    }
    
    /// Get the progress of the step by index
    ///
    /// - parameter index:  step index
    ///
    /// - returns: step progress
    
    func getStepProgress(_ index:Int) -> Double
    {
        assert(index <= numberOfSteps, "out of bounds. \(index) max: \(numberOfSteps)")
        
        if(index >= numberOfSteps) {
            return 0
        }
        
        return self[index]!.progress
    }
    
    
    ///  Set step progress at index with animation if is needed
    ///
    ///  - parameter index:           step index
    ///  - parameter progressAtIndex: step progress
    ///
    
    func setStepProgress(_ index:Int, stepProgress:Double) {
        
        assert(index <= numberOfSteps, "out of bounds. \(index) max: \(numberOfSteps)")
        
        if (index >= numberOfSteps) {
            return
        }
        
        let oldStepProgress = getStepProgress(index)

        Log.d("[\(layer.name ?? "")] setStepProgress (index : \(index) old \\ new progress: \(stepProgress) \\ \(oldStepProgress))")

        
        if let step = self[index] {
            if enableAnimations {
                stepAnimation(step, progress:stepProgress)
            } else {
                
                // Remove the default animation of strokeEnd from the shape layers.
                //step.shapeLayer.actions = ["strokeEnd" : NSNull()]
                //if let shapeLayerBorder = step.shapeLayerBorder {
                //    shapeLayerBorder.actions = ["strokeEnd" : NSNull()]
                //}
                // Simply assign the new step value
                step.progress = stepProgress
            }
        }
    }
    
    ///
    /// Get the total number of radians
    ///
    /// returns: number of radians
    ///
    
    func numberOfRadians() -> Double {
        return dataSteps.reduce(0){
            $0 + ($1 as! OMCPStepData).angle.length()
        }
    }
    ///
    /// Get the total percent of radians done. (2 * M_PI)
    ///
    /// returns: percent of radian done
    ///
    
    func percentDone() -> Double {
        let radians =  numberOfRadians()
        if radians > 0 {
            return radians / (.pi * 2.0)
        }
        return 0;
    }
    
    
    /// Get the last angle used. If do not found any. Uses startAngle.
    ///
    /// - returns: return the last used angle end
    
    fileprivate func getLastAngle() -> Double {
        var startAngle = self.startAngle;
        if (dataSteps.count > 0) {
            // The new startAngle is the last endAngle
            startAngle  = (dataSteps.lastObject as! OMCPStepData).angle.end
        }
        return startAngle;
    }
    
    
    /// Set up the basic layers.
    ///
    /// - parameter step:  step data
    /// - parameter start: start angle of the  step
    /// - parameter end:   end angle of the step
    ///
    /// - note: This function has a start/end angle for future development
    fileprivate func setUpLayers(_ step:OMCPStepData, start:Double, end:Double) {

        Log.d("[\(layer.name ?? "")] setUpLayers: \(stepIndex(step)) \(OMAngle(start: start, end: end))")

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

            Log.v("[\(layer.name ?? "")] Setupping the well layer")

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
            #endif
            
        } else {
            step.wellLayer?.removeFromSuperlayer()
        }
    }
    
    ///
    /// Set Up the progress (shape) layer
    ///
    /// - parameter step:  step data
    /// - parameter start: start angle of the  step
    /// - parameter end:   end angle of the step
    ///
    /// - note: This function has a start/end angle for future development
    fileprivate func setUpProgressLayer(_ step:OMCPStepData, start:Double, end:Double) {
        
        let shapeLayer = step.shapeLayer
        let name = "step \(stepIndex(step)) shape"
        

        Log.d("\(layer.name ?? "")(\(name)): setUpProgressLayer(start:\(OMAngle.format(start))) end:\(OMAngle.format(end)))")

        // This assert can be caused when separator Ratio is 1.0
        assert(start != end,
               "The start angle and the end angle cannot be the same. angle: \(OMAngle.format(start))")
        assert(start < end, "Unexpected start/end angle. \(OMAngle.format(start))/\(OMAngle.format(end))");
        
        #if !DISABLE_LOG
            shapeLayer.name = name
        #endif
        
        // TODO: the head can be rounded?
        let canRoundedHead = true
        let roundedHeadArcAngleStart:Double = 0
        let roundedHeadArcAngleEnd:Double   = 0
        // angle
        let theAngle = OMAngle(start: start + roundedHeadArcAngleStart,
                               end  : end   - roundedHeadArcAngleEnd)
        

        Log.v("\(layer.name ?? "")(\(name)) angle:\(theAngle) Rounded head angle start / end : \(OMAngle.format(roundedHeadArcAngleStart)) / \(OMAngle.format(roundedHeadArcAngleEnd))")
        
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
            #if !DISABLE_LOG
                borderLayer.name = name
            #endif

            Log.i("\(layer.name ?? "")(\(name)): Adding the border layer with the ratio: \(step.borderRatio)")

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
            

            Log.i("\(layer.name ?? "")(\(name)): Setting the border layer with the color: \(color.shortDescription)")
            
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
            
         
            Log.i("\(layer.name ?? "")(\(name)): Border layer width \(borderLayer.lineWidth) new shape width: \(shapeLayer.lineWidth)")

            
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
    
    ///  Layout the subviews
    override func layoutSubviews() {

        Log.d("[\(layer.name ?? "")] layoutSubviews()")

        super.layoutSubviews()
        updateLayerTree()
    }
    
    
    
    /// Calculate the center rect for the image and/or text at the angle.
    ///
    /// - parameter angle: element angle
    /// - parameter align: desired element position in radius  default: .middle
    /// - parameter size:  optional element size  default: CGSize.zero
    ///
    /// returns: return a element final CGPoint
    ///
    
    fileprivate func angleRect(_ angle:Double, align:OMCPCRadiusPosition, size:CGSize = CGSize.zero) -> CGRect {

        Log.d("[\(layer.name ?? "")] angleRect(\(angle) \(align) \(size))")

        return anglePoint(angle,align: align,size: size).centerRect(size)
    }
    
    /// Calculate the center rect for the image and/or text at the angle.
    ///
    /// - parameter angle: element angle
    /// - parameter radius: element radius
    /// - parameter align: desired element position in radius  default: .middle
    /// - parameter size:  optional element size  default: CGSize.zero
    ///
    /// returns: return a element final CGPoint
    ///
    
    fileprivate func angleRect(_ angle:Double, radius:CGFloat, align:OMCPCRadiusPosition = .middle, size:CGSize = CGSize.zero) -> CGRect {

        Log.d("[\(layer.name ?? "")] angleRect(\(angle) \(radius) \(align) \(size))")

        return anglePoint(angle,radius:radius,align: align,size: size).centerRect(size)
    }
    
    /// Calculate the center point for the image and/or text at the angle.
    ///
    /// - parameter angle: element angle
    /// - parameter radius: element radius
    /// - parameter align: desired element position in radius  default: .middle
    /// - parameter size:  optional element size  default: CGSize.zero
    ///
    /// returns: return a element final CGPoint
    ///
    
    fileprivate func anglePoint(_ angle:Double, radius:CGFloat, align:OMCPCRadiusPosition = .middle,size:CGSize = CGSize.zero) -> CGPoint {

        Log.d("[\(layer.name ?? "")] anglePoint(\(angle) \(radius) \(align) \(size))")

        return OMAngle.pointOfAngle(angle,center:bounds.size.center(),radius:radius)
    }
    
    /// Calculate the center point for the image and/or text at the angle.
    ///
    /// - parameter angle: element angle
    /// - parameter align: desired element position in radius  default: .middle
    /// - parameter size:  optional element size  default: CGSize.zero
    ///
    /// returns: return a element final CGPoint
    ///
    
    fileprivate func anglePoint(_ angle:Double, align:OMCPCRadiusPosition, size:CGSize = CGSize.zero) -> CGPoint {

        Log.d("[\(layer.name ?? "")] anglePoint(\(angle) \(align) \(size))")

        return OMAngle.pointOfAngle(angle,center:bounds.size.center(),radius:CGFloat(positionInRadius(align ,size: size )))
    }
    
    /// Get the position in the radius
    ///
    /// - parameter position: position in radius
    /// - parameter size:  optional size
    ///
    /// - returns: return the position in the radius
    
    internal func positionInRadius(_ position : OMCPCRadiusPosition, size:CGSize = CGSize.zero) -> Double {
        let newRadius:Double
        switch(position){
        case .middle:
            newRadius = Double(midRadius)
            break
        case .inner:
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
    
    /// Add the created step image layers to the root layer.
    fileprivate func addStepImageLayers() {

        Log.d("[\(layer.name ?? "")] addStepImageLayers()")

        for (index, step) in dataSteps.enumerated() {
            let theStep = step as! OMCPStepData
              #if !DISABLE_LOG
            theStep.imageElement.layer.name = "step \(index) image"
            #endif
            containerLayer!.addSublayer(theStep.imageElement.layer )
            theStep.imageElement.shadow = true
        }
    }
    
    /// Add the created step image layers to the root layer.
    fileprivate func addStepTextLayers() {

        Log.d("[\(layer.name ?? "")] addStepTextLayers()")

        for (index, step) in dataSteps.enumerated() {
            let theStep =  step as! OMCPStepData
            #if !DISABLE_LOG
                theStep.textElement.layer .name = "step \(index) text"
            #endif
            containerLayer!.addSublayer(theStep.textElement.layer )
        }
    }
    
    ///
    /// SetUp the text layer geometry
    ///
    /// - parameter step: step object
    ///
    fileprivate func setUpStepImageLayerGeometry(_ step:OMCPStepData) {
        
        let sizeOf = step.imageElement.layer.image?.size
        // Reset the angle orientation before sets the new frame
        step.imageElement.layer.setTransformRotationZ(0)
        let angle = step.angle.angle(step.imageElement.anglePosition)
        
        let anglePoint = OMAngle.pointOfAngle(angle,
                                              center:bounds.size.center(),
                                              radius: CGFloat(positionInRadius(step.imageElement.radiusPosition, size: sizeOf!)))
        
        let positionInAngle = anglePoint.centerRect(sizeOf!)

        Log.d("[\(layer.name ?? "")] setUpStepImageLayerGeometric(\(step))")
        Log.d("[\(layer.name ?? "")] angle \(round(angle.radiansToDegrees())) text angle position :\(step.imageElement.anglePosition)")
        Log.d("[\(layer.name ?? "")] Position in angle \(anglePoint)  position in radius :\(step.imageElement.radiusPosition)")
        Log.v("[\(layer.name ?? "")] Frame \(positionInAngle.integral) from the aligned step angle \(OMAngle.format(angle)) and the image size \((sizeOf?.integral())!)")

        
        // Set the new frame
        step.imageElement.layer.frame = positionInAngle
        // Rotate the layer
        if (step.imageElement.orientationToAngle) {
            let rotationZ = (angle - startAngle)

            Log.v("[\(layer.name ?? "")] Image will be oriented to angle: \(OMAngle.format(rotationZ))")

            step.imageElement.layer.setTransformRotationZ(rotationZ)
        }
    }
    
    ///
    /// Setup the text layer geometry
    ///
    /// - parameter step: step object
    ///
    
    fileprivate func setUpStepTextLayerGeometry(_ step:OMCPStepData) {
        Log.d("[\(layer.name ?? "")] setUpStepTextLayerGeometric(\(step))")

        if step.textElement.layer.string != nil {
            // Reset the angle orientation before sets the new frame
            step.textElement.layer.setTransformRotationZ(0.0)
            
            // We must to have the same center and the same bounds
            if (step.textElement.layer.radiusRatio > 0) {
                step.textElement.layer.frame = self.bounds
            } else {
                let sizeOf = step.textElement.layer.frameSize();
                let angle:Double = step.angle.angle(step.textElement.anglePosition)
                
                let anglePoint = OMAngle.pointOfAngle(angle,
                                                      center:bounds.size.center(),
                                                      radius: CGFloat(positionInRadius(step.textElement.radiusPosition, size: sizeOf)))
                let frame = anglePoint.centerRect(sizeOf)
                

                Log.d("[\(layer.name ?? "")] angle \(OMAngle.format(angle)) text angle position :\(step.textElement.anglePosition)")
                Log.d("[\(layer.name ?? "")] Position in angle \(anglePoint)  position in radius :\(step.textElement.radiusPosition)")
                Log.v("[\(layer.name ?? "")] Frame \(frame.integral) from the aligned step angle \(OMAngle.format(angle)) and the text size \(sizeOf.integral()))")

                
                // Set the new frame
                step.textElement.layer.frame = frame
            }
            
            if step.textElement.orientationToAngle {
                let angle = step.angle.angle(step.textElement.anglePosition)
                let rotationZ = (angle - startAngle)
    
                Log.v("[\(layer.name ?? "")] Image will be oriented to angle: \(round(rotationZ.radiansToDegrees()))")

                step.textElement.layer.setTransformRotationZ( rotationZ )
            }
        }
    }
    
    /// Remove all layers from the superlayer.
    
    internal func removeSublayers() {
        Log.d("[\(layer.name ?? "")] removeSublayers() \((containerLayer!.sublayers != nil) ? containerLayer!.sublayers!.count : 0)")
        if let s = containerLayer!.sublayers {
            for (_, layer) in s.enumerated() {
                layer.removeAllAnimations()
                layer.removeFromSuperlayer()
            }
        }
        containerLayer!.removeAllAnimations()
        containerLayer!.removeFromSuperlayer()
    }
    
    /// Add the image layers
    internal func addImages() {
        // Add all steps image
        addStepImageLayers()
        if let img  = image.image {
            // Add the center image layer to the root layer.
            #if !DISABLE_LOG
                image.name = "center image"
            #endif
            
            image.frame = bounds.size.center().centerRect(img.size)
  
            Log.i("[\(layer.name ?? "")] Add the center image layer to the container layer. \(img)")
            Log.i("[\(layer.name ?? "")] Set the image layer frame \(image.frame.integral)")

            containerLayer!.addSublayer(image)
            image.shadowOpacity = 1.0
            image.shadowOffset  = kDefaultElementShadowOffset
            image.shadowRadius  = kDefaultElementShadowRadius
            image.shadowColor   = kDefaultElementShadowColor
        }
    }
    /// Add the text layers
    internal func addTexts() {
        // Add all steps texts
        addStepTextLayers()
        // Add the text layer.
        if percentText  {
            #if !DISABLE_LOG
                number.name = "center number"
            #endif
            containerLayer!.addSublayer(number)
            number.shadowOpacity = 1.0
            number.shadowOffset  = kDefaultElementShadowOffset
            number.shadowRadius  = kDefaultElementShadowRadius
            number.shadowColor   = kDefaultElementShadowColor
        }
    }
    
    /// Dump the internal data
    internal func debugLayersAndSteps()  {
        #if DEBUG
        dumpLayers(0, layer:containerLayer)
        dumpAllSteps()
        #endif
    }
    
    /// Add the layers to the container layer
    internal func addLayers() {
        // Special case for the center numerial text layer
        if percentText {
            updateNumberLayerGeometry()
        }
        
        // Create and setup the position of the text and image step layers
        for (_, step) in dataSteps.enumerated() {
            let data  = step as! OMCPStepData
            // Image Layer
            if data.imageElement.layer.image != nil {
                #if !DISABLE_LOG
                    data.imageElement.layer.name = "step \(stepIndex(data)) image"
                #endif
                setUpStepImageLayerGeometry(data)
            }
            // Text Layer
            if  data.textElement.layer.string != nil {
                #if !DISABLE_LOG
                    data.textElement.layer.name = "step \(stepIndex(data)) text"
                #endif
                setUpStepTextLayerGeometry(data)
            }
        }
        
        // Create the layers for each step.
        for (_, step) in dataSteps.enumerated() {
            let data = step as! OMCPStepData
            setUpLayers(data, start:data.angle.start, end: data.angle.end)
        }
    }
    
    ///  Create or update all the necesary layers
    internal func updateLayerTree() {

        Log.d("[\(layer.name ?? "")] updateLayerTree()")

        // Set the container layer.
        // I use a container layer for use CATransformLayer in a future development
        containerLayer = layer
        addLayers()
        addImages()
        addTexts()
        #if DEBUG
            debugLayersAndSteps()
        #endif
    }
}


// MARK: OMCircularProgress data steps extension

extension OMCircularProgress {
    /// Get the number of steps
    public var numberOfSteps : Int {
        return self.dataSteps.count;
    }
    /// Step to index in the steps array
    internal func stepIndex(_ step:OMCPStepData) -> Int {
        return self.dataSteps.index(of: step)
    }
    /// Get/Set the step data, subscripted by index from the list of steps
    subscript(stepIndex: Int) -> OMCPStepData? {
        get {
            assert(stepIndex < numberOfSteps, "out of bounds. \(stepIndex) max: \(numberOfSteps)")
            if stepIndex < numberOfSteps {
                return dataSteps[stepIndex] as? OMCPStepData
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
    
    ///
    ///  Create a new progress step.
    ///
    ///  Each progress step is represented by the object OMCPStepData
    ///
    ///  - parameter start: step start angle
    ///  - parameter end:   step end angle
    ///  - parameter color: step color
    ///
    ///  returns: return a OMCPStepData object.
    
    func addStep(_ start:Double, end:Double, color:UIColor!) -> OMCPStepData? {
        let angle = OMAngle(start:start,end:end)
        // Validate the angle
        let valid = angle.valid()
        assert(valid,"Invalid angle:\(angle). range in radians : -(2*PI)/+(2*PI)")
        if(!valid) {
            Log.w("[\(layer.name ?? "")] Invalid angle :\(angle)")
            return nil;
        }
        // Create the step
        let step = OMCPStepData(angle: angle, color:color)
        Log.v("[\(layer.name ?? "")] Adding new step#\(numberOfSteps) with the angle:\(String(describing: step.angle))")
        let overflow = overflowBy(lenght: step.angle.length());
        if (overflow > 0) {
            // remove the overflow.
            step.angle.end -= overflow;
        }
        // Save the step
        dataSteps.add(step)
        return step
    }
    
    /// Remove all steps.
    func removeAllSteps() {
        self.dataSteps.removeAllObjects()
        assert(self.dataSteps.count == 0)
        removeSublayers()
        layoutSubviews()
    }
    
    /// Check if the lenght will overflow the angle.
    ///
    /// - parameter lenght:   Double lenght
    ///
    /// - returns: Bool
    
    internal func overflowBy(lenght:Double) -> Double {
        let kOverflowEpsilon = Double.ulpOfOne // Double.ulpOfOne == "0.0000000000000002"
        let numberOfRad = (numberOfRadians() + lenght)
        let diference   = (numberOfRad - 𝜏)
        // Check angle the overflow
        if diference > kOverflowEpsilon {
            Log.w("[\(layer.name ?? "")] Unable to create the step \(self.dataSteps.count + 1): Angle is out of radians. Overflow by \(String(format: "%.16f", diference)) radians, maximun: \(String(format: "%.16f", kOverflowEpsilon))")
            return diference
        }
        return 0
    }
    
    /// Create a new step progress.
    ///
    /// - parameter angle:   step end angle
    /// - parameter color:   step color
    ///
    /// - returns: return a OMCPStepData object.
    func addStep(_ angle:Double, color:UIColor!) -> OMCPStepData? {
        let lastAngle = getLastAngle()
        return  addStep( lastAngle, end:lastAngle + angle, color:color );
    }
    /// Create a new step progress.
    ///
    /// - parameter start:   step start angle
    /// - parameter percent: step end angle expresed as percent of complete circle.
    /// - parameter color:   step color
    ///
    /// - returns: the new step data
    func addStepWithPercent(_ start:Double, percent:Double, color:UIColor!) -> OMCPStepData? {
        // validate angle
        let inRange = OMAngle.inRange(angle: start)
        assert(inRange, "Invalid start angle:\(startAngle). Range in radians: -(2*PI)/+(2*PI)")
        if (!inRange){
            Log.w("[\(layer.name ?? "")] Invalid start angle: \(OMAngle.format(start))")
            return nil;
        }
        // clap the percent.
        let step = OMCPStepData(start:start,
                                percent:Double(clamp(CGFloat(percent), lowerValue: 0.0,upperValue: 1.0)),
                                color:color)
        Log.v("\(layer.name ?? "")): Adding new step#\(numberOfSteps) with the angle: \(step.angle!)")
        let overflow = overflowBy(lenght: step.angle.length());
        if (overflow > 0) {
            // remove the overflow.
            step.angle.end -= overflow;
        }
        
        dataSteps.add(step)
        return step
    }
    /// Create a new step progress.
    ///
    /// - parameter percent: step angle expresed as percent of complete circle.
    /// - parameter color:   step color
    ///
    /// - returns: optional new step data
    func addStepWithPercent(_ percent:Double, color:UIColor!) -> OMCPStepData? {
        return addStepWithPercent(getLastAngle(), percent: percent, color: color);
    }
}

// MARK: OMCircularProgress debug extension

extension OMCircularProgress
{
    // MARK: Debug functions
    
    /// Debug print all steps
    
    func dumpAllSteps() {
        for (index, step) in dataSteps.enumerated() {
            Log.v("\(layer.name ?? "")): \(index): \(step as! OMCPStepData)")
        }
    }
    
    /// Debug print all layers
    ///
    /// - parameter level: recursion level
    /// - parameter layer: layer to debug print
    
    func dumpLayers(_ level:UInt, layer:CALayer) {
        if (layer.sublayers != nil) {
            for (_, curLayer) in layer.sublayers!.enumerated() {
                let name = curLayer.name ?? String(describing: curLayer)
                Log.d("[\(level):\(name)]")
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
        str += " Radius : \(radius) Inner Radius: \(innerRadius) Outer Radius: \(outerRadius) Mid Radius: \(midRadius) Border : \(borderWidth) "
        str += " Steps:[ "
        for (index, step) in dataSteps.enumerated() {
            str += "\(index): \((step as! OMCPStepData)) "
        }
        str += "]"
        
        return str;
    }
    
}

// MARK: OMCircularProgress animations extension

extension OMCircularProgress : CAAnimationDelegate
{
    /// MARK: CAAnimation delegate
   #if !DISABLE_LOG
    func animationDidStart(_ anim: CAAnimation) {
        Log.d("[\(layer.name ?? "")] animationDidStart:\((anim as! CABasicAnimation).keyPath!) : \((anim as! CABasicAnimation).beginTime) ")
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            Log.d("[\(layer.name ?? "")] animationDidStop:\((anim as! CABasicAnimation).keyPath!) : \((anim as! CABasicAnimation).duration)")
        }
    }
    #endif
    
    /// Animate the shapeLayer and the image for the step
    ///
    /// - parameter step:     step data
    /// - parameter progress: progress
    
    func stepAnimation(_ step:OMCPStepData, progress:Double) {
        
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
        
        // Add animation to the stroke of the shape layer.
        
        step.shapeLayer.add(strokeAnimation, forKey: "strokeEnd")
        
        if let shapeLayerBorder = step.shapeLayerBorder {
            shapeLayerBorder.add(strokeAnimation, forKey: "strokeEnd")
        }
        
        if let imgLayer = step.imageElement.layer {
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

// MARK: OMCircularProgress events extension

extension OMCircularProgress
{
    /// Get the correct layer for the location
    ///
    /// - parameter location: point location in the view
    ///
    /// - returns: return the layer that contains the point
    
    func layerForLocation( _ location:CGPoint ) -> CALayer? {
        // hitTest Returns the farthest descendant of the layer (Copy of layer)
        
        if let player = self.layer.presentation() {
            let hitPresentationLayer = player.hitTest(location)
            if let hitplayer = hitPresentationLayer {
                // Real layer
                return hitplayer.model()
            }
        
            Log.w("[\(layer.name ?? "")] Unable to locate the layer that contains the location \(location)")
        }
        
        return nil;
    }
    
    // MARK: UIResponder
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            var location:CGPoint = touch.location(in: self);
            location = self.convert(location, to:nil)
            if let layerOfLocation = self.layerForLocation(location) {
                if((self.delegate) != nil && (self.delegate!.layerHit) != nil) {
                    self.delegate!.layerHit!(self, layer: layerOfLocation, location: location)
                }
            }
        }
        super.touchesBegan(touches , with:event)
        sendActions(for: .allTouchEvents)
    }
}

