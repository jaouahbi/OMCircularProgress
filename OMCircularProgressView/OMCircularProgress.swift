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


// MARK: - Types


/// The styles permitted for the progress bar.
/// NOTE:  You can set and retrieve the current style of progress view through the progressStyle property.

public enum OMCircularProgressStyle : Int
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
    }
    
    var dataSteps: NSMutableArray = []             // Array of OMStepData
    
    /// Private
    
    var imageLayer:CALayer?                // center image layer
    var numberLayer:OMNumberLayer?         // center number layer
    
    // vars for animations
    
    var beginTime: TimeInterval    = 0;
    var newBeginTime: TimeInterval = 0;
    
    /// Public
    
    // Delegate
    
    weak var delegate:OMCircularProgressProtocol?
    
    // Animation
    
    @IBInspectable var animation : Bool = true;
    @IBInspectable var animationDuration : TimeInterval = 1.0
    
    /// Component behavior
    
    var progressStyle:OMCircularProgressStyle = .sequentialProgress
    
    //
    // The start angle of the all steps.
    // default -90 degrees == 12 o'clock
    //
    
    @IBInspectable var startAngle : Double = -90.degreesToRadians() {
        didSet{
            assert(isAngleInCircleRange(startAngle),
                "Invalid angle : \(startAngle).The angle range must be in radians : -(2*PI)/+(2*PI)")
            setNeedsLayout()
        }
    }

    /// Separation ratio between steps of the minimun angle
    
//    @IBInspectable var separatorRatio: Double = 0.0 {
//        didSet{
//            setNeedsLayout()
//        }
//    }
    
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
            return (simpleRadius - 0)//self.alignExtraLength(simpleRadius))
        }
    }

    
    /**
//    <#Description#>
//    
//    - parameter simpleRadius: <#simpleRadius description#>
//    
//    - returns: <#return value description#>
//    */
//    
//    func  alignExtraLength(simpleRadius: CGFloat) -> CGFloat
//    {
//        var outerImageAlign:Int  = 0
//        var borderImageAlign:Int = 0
//        var outerTextAlign:Int   = 0
//        var borderTextAlign:Int  = 0
//        
//        var alignExtraLength:CGFloat = 0.0
//        
//        // Max angle
//        
//        let maxAngle:Double = self.maxAngleLength()
//        
//        // Need the position of the images for calculate the radius without overflow the bounds
//        
//        for (_, step) in dataSteps.enumerate() {
//            
//            let curStep = (step as! OMStepData)
//            
//            // Image
//            outerImageAlign  += (curStep.imageAlign == .Outer) ? 1 : 0
//            borderImageAlign += (curStep.imageAlign == .Border) ? 1 : 0
//            
//            // Text
//            outerTextAlign  += (curStep.textAlign == .Outer) ? 1 : 0
//            borderTextAlign += (curStep.textAlign == .Border) ? 1 : 0
//        }
//        
//        let maxSide = CGFloat(maxAngle) * simpleRadius
//        
//        let minSide = min( maxSide, self.maxImageSize().max() )
//        
//        // TODO:
//        //if ( maxSide < self.maxImageSize().max() ) {
//        
//        if ( outerImageAlign > 0) {
//            alignExtraLength  = minSide
//        } else if ( borderImageAlign > 0) {
//            alignExtraLength = minSide * 0.5
//        }else{
//            
//            // nothing
//        }
//        //}
//        
//        
//        let maxHeight = maxTextHeight()
//        
//        if ( outerTextAlign > 0) {
//            alignExtraLength = max( alignExtraLength, maxHeight )
//        } else if ( borderTextAlign > 0) {
//            alignExtraLength =  max(maxHeight * CGFloat(0.5), alignExtraLength)
//            
//        } else {
//            
//            // nothing
//        }
//        
////        
////        if DEBUG_VERBOSE {
////            SpeedLog.print("alignExtraLength: radius : \(simpleRadius) max image side:\(maxSide) max text size \(maxHeight) extra radius length \( alignExtraLength)")
////        }
//        
//        
//        return alignExtraLength
//        
//    }
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

    @IBInspectable var shadowText : Bool = true {
        didSet{
            setNeedsLayout()
        }
    }
    
    /// Sets shadow to the well layer
    
    @IBInspectable var shadowWell : Bool = true {
        didSet{
            setNeedsLayout()
        }
    }
    
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
            updateNumericalLayer()
        }
    }
    
    /// The text represent a arb. text.
    var stepText:Bool = false {
        didSet{
            updateNumericalLayer()
        }
    }
    
    /// The text font name
    @IBInspectable var fontName : String = "Helvetica" {
        didSet{
            updateNumericalLayer()
        }
    }
    
    /// The text font color
    @IBInspectable var fontColor : UIColor = UIColor.black{
        didSet {
            updateNumericalLayer()
        }
    }
    
    /// The text font size.
    @IBInspectable var fontSize : CGFloat = 12 {
        didSet {
            updateNumericalLayer()
        }
    }
    /// The text font backgound color.
    @IBInspectable var fontBackgroundColor : UIColor = UIColor.clear{
        didSet {
            updateNumericalLayer()
        }
    }
    /// The text font width stroke
    @IBInspectable var fontStrokeWidth : Float = -3 {
        didSet {
            updateNumericalLayer()
        }
    }
    /// The text font width stroke color
    @IBInspectable var fontStrokeColor : UIColor = UIColor.clear{
        didSet {
            updateNumericalLayer()
        }
    }
    
    @IBInspectable var textRadius : CGFloat = 0.0 {
        didSet {
            updateNumericalLayer()
        }
    }

    // MARK: Images
    
   // @IBInspectable var imageShadow : Bool = true

    @IBInspectable var progressImage : UIImage? {
    
        didSet {
            if progressImage != nil {
                if let imageLayer = imageLayer {
                    (imageLayer as! OMProgressImageLayer).image = progressImage
                }else{
                    
                    imageLayer = OMProgressImageLayer(image: progressImage!)
                    
                    #if TAG_LAYERS
                        imageLayer?.name = "progress center image"
                    #endif
                }
            }
        }
        
    }
    
    /// The center image of the component.
    
    @IBInspectable var image: UIImage? {
        didSet {
            if image != nil {
                if(imageLayer != nil){
                    imageLayer!.contents = image?.cgImage
                } else {

                    imageLayer = CALayer()
                    imageLayer?.contents = image?.cgImage
                    
                    #if TAG_LAYERS
                        imageLayer?.name = "center image"
                    #endif
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
    

    /** This function performs the transformation on each plane **/
    func transformSublayers(_ sublyrs:[CALayer], angle:Double)
    {
        //Define the degrees needed for each plane to create a circle
        let degForPlane:Double = Double(360 / sublyrs.count)
        
        //The current angle offset (initially it is 0... it will change through the pan function)
        var theAngle = angle;
        
        for (_, layer) in sublyrs.enumerated() {
        
            //Create the Matrix identity
            var  t = CATransform3DIdentity;
            //Setup the perspective modifying the matrix elementat [3][4]
            t.m34 = 1.0 / -1000.0
            
            //Perform rotate on the matrix identity
            t = CATransform3DRotate(t,CGFloat( angle.degreesToRadians()), CGFloat(0.0), CGFloat(0.1), CGFloat(0.0));
            
            //Perform translate on the current transform matrix (identity + rotate)
            t = CATransform3DTranslate(t, 0.0, 0.0,  250.0);
            
            //Avoid animations
            //[CATransaction setAnimationDuration:0.0];
            
            //apply the transoform on the current layer
            layer.transform = t;
            
            //Add the degree needed for the next plane
            theAngle += degForPlane;
        }
    }
    // MARK:
    
    /**
        Update the progress stuff.
    */
    fileprivate func updateCompleteProgress()
    {
        SpeedLog.print("updateCompleteProgress (progress: \(progress))")
        
        if progress == 0 {
            // Nothing to update
            return
        }
        
        //DEBUG
        //assert(progress <= Double(numberOfSteps),"Unexpected progress \(progress) max \(numberOfSteps) ")
        
        var clamped_progress:Double = progress
        
        clamped_progress.clamp(toLowerValue: 0.0,upperValue: Double(numberOfSteps))
        
        CATransaction.begin()
        
        let stepsDone   = Int(clamped_progress);
        let curStep     = clamped_progress - floor(clamped_progress);
        
        // Initialize the sequential time control vars.
        
        beginTime    = CACurrentMediaTime()
        newBeginTime = 0.0
        
        for index:Int in 0..<numberOfSteps {
        
            SpeedLog.print("#\(index) of \(numberOfSteps) in \(progress) : done:\(stepsDone) current:\(curStep)")
        
            setStepProgress(index, stepProgress: (index < stepsDone) ?  1.0 : curStep)
        }
        
        let duration        = (animationDuration / Double(numberOfSteps)) * clamped_progress
        var toValue:Double  = (progress / Double(numberOfSteps))
            
        toValue.clamp(toLowerValue: 0.0,upperValue: 1.0)
        
        ///  center image
        
        if let imgLayer = imageLayer as? OMProgressImageLayer {
            // Remove all animations
            imgLayer.removeAllAnimations()
            imgLayer.animateProgress( 0,
                toValue: toValue,
                beginTime: beginTime,
                duration: duration,
                delegate: self)
        }
        
        ///  center number
        
        if let numberLayer = numberLayer {
            let number:Double = (stepText) ? Double(numberOfSteps) : toValue
            if animation  {
                // Remove all animations
                numberLayer.removeAllAnimations()
                numberLayer.animateNumber(  0.0,
                    toValue:number,
                    beginTime:beginTime,
                    duration:duration,
                    delegate:self)
            } else {
                numberLayer.number = toValue as NSNumber
            }
        }
        
        CATransaction.commit()
        
        SpeedLog.print("updateCompleteProgress (progress: \(clamped_progress))")
    }
    

    /**
        Get the progress of the step by index
    
        - parameter index:           step index
        - returns:               step progress
    */
    
    func getProgressAtIndex(_ index:Int) -> Double
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
        
        SpeedLog.print("setProgressAtIndex (index : \(index) progress: \(stepProgress))")
        
        if let step = self[index] {
            
            if (animation) {
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

    
    func percentDone() -> Double {
        let radians =  numberOfRadians()
        if radians > 0 {
            return radians / (M_PI * 2.0)
        }
        return 0;
    }
      
    /**
        Get the last angle used. If do not found any. Uses startAngle.
    
        - returns: return the start angle
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
    fileprivate func setUpLayers(_ step:OMStepData, startAngle:Double, endAngle:Double)
    {
        SpeedLog.print("setUpLayers:\(stepIndex(step)) \(OMAngle(startAngle: startAngle, endAngle: endAngle))")
       
        // SetUp the mask layer
        
        if let maskLayer = step.maskLayer {
            
            // Update the mask frame
            
            if (maskLayer.frame != bounds) {
                
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
    Check if all the steps can have the head rounded
    
    - returns: return true if all the step can be the head rounded.
    */
    
    fileprivate func canRoundTheHeads() -> Bool
    {
        for (_, step) in dataSteps.enumerated() {
            
            let step = step as! OMStepData

            /// Calculate the angle of arc length needed for the rounded head in radians
            
            let arcAngle = Double(borderWidth * 0.5) / Double(radius)

            let angleRoundedHead =  OMAngle(startAngle: step.angle.start + arcAngle, endAngle: step.angle.end - arcAngle)
        
            if( !angleRoundedHead.valid() ) {
                
                return false;
            }
        }
        
        return true
    }
    
    
    func addBorderLayer(_ step:OMStepData) {
        
        let layerBorder:CAShapeLayer
        
        if ((step.shapeLayerBorder == nil)) {
            layerBorder = CAShapeLayer()
        } else {
            layerBorder = step.shapeLayerBorder!
        }
        
        assert((step.shapeLayer.path != nil), "shape layer with a nil CGPath");
        
        layerBorder.path      = step.shapeLayer.path
        layerBorder.fillColor = nil
        layerBorder.strokeColor = step.borderColor.cgColor
       
       if  shadowBorder {
            layerBorder.shadowOpacity = shadowOpacity
            layerBorder.shadowOffset  = shadowOffset
            layerBorder.shadowRadius  = shadowRadius
            layerBorder.shadowColor   = shadowColor.cgColor
//             layerBorder.shadowPath    = step.shapeLayer.path
       }
       else {
        
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
        
        step.shapeLayer.lineWidth    = (borderWidth * CGFloat(1.0 - step.borderRatio))
    }
    
    
    /**
        Set Up the progress (shape) layer
    
        - parameter step:       step data
        - parameter startAngle: start angle of the  step
        - parameter endAngle:   end angle of the step
    */
    
    fileprivate func setUpProgressLayer(_ step:OMStepData, startAngle:Double, endAngle:Double)
    {
        // This assert can be caused when separator Ratio is 1.0
        
        assert( startAngle != endAngle,
            "The start angle and the end angle cannot be the same. angle: \(startAngle.radiansToDegrees())")
        
        #if TAG_LAYERS
            step.shapeLayer.name = "step \(stepIndex(step)) shape"
        #endif
        
        // rounded
        let canRoundedHead = canRoundTheHeads()
        
        // arc
        var roundedHeadArcAngle : Double = 0
        
        if ( roundedHead ) {
            if( canRoundedHead ){
                roundedHeadArcAngle = Double(borderWidth * 0.5) / Double(radius)
            }
        }
        
        // angle
        let theAngle = OMAngle(startAngle: startAngle + roundedHeadArcAngle, endAngle: endAngle - roundedHeadArcAngle)
        
        SpeedLog.print("STEP[\(stepIndex(step))] angle:\(theAngle) Rounded head arclen : \(round(roundedHeadArcAngle.radiansToDegrees()))°")
        
        let bezier = UIBezierPath(  arcCenter:bounds.size.center(),
                                    radius: midRadius,
                                    startAngle:CGFloat(theAngle.start),
                                    endAngle:CGFloat(theAngle.end),
                                    clockwise: true)
        
        step.shapeLayer.path            = bezier.cgPath
        step.shapeLayer.backgroundColor = UIColor.clear.cgColor
        step.shapeLayer.fillColor       = nil
        step.shapeLayer.strokeColor     = ( step.maskLayer != nil ) ? UIColor.black.cgColor : step.color.cgColor
        step.shapeLayer.lineCap         = (roundedHead && canRoundedHead) ?  kCALineCapRound : kCALineCapButt;
  
        
        step.shapeLayer.strokeStart = 0.0
        step.shapeLayer.strokeEnd   = 0.0
        
        // DEBUG
        
        step.borderRatio = stepBorderRatio
        
        if step.borderRatio > 0{
            addBorderLayer(step);
        } else {
            step.shapeLayer.lineWidth  = borderWidth
        }
        

        
// MASK CODE
        if step.maskLayer != nil {
            
            // When setting the mask to a new layer, the new layer must have a nil superlayer
            
            step.maskLayer?.mask = step.shapeLayer
        
            layer.addSublayer(step.maskLayer!)
            
            #if DEBUG_MASK
                layer.addSublayer(step.shapeLayer)
            #endif
            
        } else if let borderLayer = step.shapeLayerBorder {
        
            borderLayer.addSublayer(step.shapeLayer)
        
            layer.addSublayer(step.shapeLayerBorder!)
            
        } else {

            layer.addSublayer(step.shapeLayer)
        }
    }
    

    /**
        Set Up the well layer of the progress layer.
    
        - parameter step: step data
    */
    
    fileprivate func setUpWellLayer(_ step:OMStepData)
    {
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
          
            if  shadowWell {
//                
//                step.wellLayer?.shadowOpacity = shadowOpacity
//                step.wellLayer?.shadowOffset  = shadowOffset
//                step.wellLayer?.shadowRadius  = shadowRadius
//                step.wellLayer?.shadowColor   = shadowColor.CGColor
                step.wellLayer?.shadowPath    = step.shapeLayer.path
            }
            else {
                step.wellLayer?.shadowOpacity = 0
            }
            
            // Same as shape layer
            
            step.wellLayer?.lineCap = step.shapeLayer.lineCap
            
            // Add the layer behind the other layers
            
            layer.insertSublayer(step.wellLayer!, at:0)
        }
    }
    
    /**
        Layout the subviews
    */
    override func layoutSubviews() {
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
    
    fileprivate func anglePoint(_ angle:Double, align:OMAlign, size:CGSize = CGSize.zero) -> CGPoint
    {
        // .AlignMid (default)
        
       // var  newRadius = Double( outerRadius )
        
        var newRadius:Double = Double(midRadius)
        
        switch(align){
            case .middle:
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
        
        //
        // Given a radius length r and an angle in radians and a circle's center (x,y),
        // calculate the coordinates of a point on the circumference
        //
        
        let theta = CGFloat( angle )
        
        //
        // cartesian angle to polar.
        //
        
        return CGPoint(x: bounds.size.center().x + CGFloat(newRadius) * cos(theta), y: bounds.size.center().y + CGFloat(newRadius) * sin(theta))
        
    }
    
    /**
        Add the created step image layers to the root layer.
    */
    
    fileprivate func addStepImageLayers() {
        
        for (index, step) in dataSteps.enumerated() {
            let curStep = step as! OMStepData
            
            if(curStep.imageLayer != nil){
                #if TAG_LAYERS
                    curStep.imageLayer!.name = "step \(index) image"
                #endif
                layer.addSublayer(curStep.imageLayer!)
            }
        }
    }
    /**
        Add the created step image layers to the root layer.
    */
    fileprivate func addStepTextLayers() {
        for (index, step) in dataSteps.enumerated() {
            let curStep = step as! OMStepData
            
            if let tl = curStep.textLayer {
                #if TAG_LAYERS
                    tl.name = "step \(index) text"
                #endif

                layer.addSublayer(tl)
            }
        }
    }
    /**
        Add the center image layer
    */
    fileprivate func addCenterImageLayer()
    {
        if let imgLayer = imageLayer, let image = image {
            
            imgLayer.frame = bounds.size.center().centerRect(image.size)
            
            #if TAG_LAYERS
                imgLayer.name = "center image"
            #endif
            
            layer.addSublayer(imgLayer)
        }
    }
    
    func scaleImageIfNeeded(_ curStep:OMStepData)
    {
        if let img = curStep.image {
            
            let curSize = img.size.max()
            
            let angleLength = curStep.angle.length()
            
            let maxSide:CGFloat = CGFloat(angleLength * Double(outerRadius))
            
            //assert(maxSide > 0.0, "overflow side.")
            
            if ( maxSide > 0.0 && maxSide < curSize ) {
                // TODO: the minimun size of the image must be limited
                curStep.imageScaled  = img.scaledToFitToSize(CGSize(width:  maxSide,height: maxSide))
            } else {
                curStep.imageScaled = nil;
            }
        }
    }
    
//    private func setUpSeparator(curStep:OMStepData)  {
//        
//        let radius_2 = Double(radius * 2.0)  // Avoid to divide by 2 each s0 element calculation
//        
//        if ( curStep.imageIsSeparator ) {
//            
//            let halfLength = curStep.angle.length() * 0.5
//            
//            // division by a number mul 2 is the same that div by 2
//            
//            let halfAngle  = Double(curStep.image!.size.hypot()) / radius_2
//            
//            // avoid overflow the angle by the separator
//            
//            let x = halfLength - halfAngle
//            
//            if (x > 0.0){
//                
//                curStep.separatorAngleHalf = halfAngle
//            }
//        }
//    }
    
    fileprivate func setUpImageLayer(_ curStep:OMStepData)
    {
        // Do not use separator.
        
        //curStep.separatorAngleHalf = 0.0
        
        //
        // The separator is a ratio of step angle length
        //
        // :note: Only add separator if exist more than 1 step in the UIControl
        //
        
        //            if  separatorRatio > 0.0  && numberOfSteps > 1 {
        //
        //                curStep.separatorAngleHalf = (separatorRatio * curStep.angle.length()) * 0.5
        //                //curStep.separatorAngleHalf = (separatorRatio * minAngle) * 0.5
        //            }
        
        /// Image
        
        // Scale the image if is necesary
        
        scaleImageIfNeeded(curStep)
        
        // Select the correct image
        
        if let img = curStep.imageScaled ?? curStep.image {
            
            // If separatorRatio has a valid value. Use it.
            
            //FIXME:
            //setUpSeparator()
            
            // Create the progress image layer
            
            if curStep.imageLayer == nil {
                curStep.imageLayer = OMProgressImageLayer(image: img)
                
                #if TAG_LAYERS
                    curStep.imageLayer?.name = "step \(stepIndex(curStep)) image"
                #endif
                
            } else {
                curStep.imageLayer?.image = img
            }
            
            let angle:Double = curStep.angle.align(curStep.imageAngleAlign)
            
            // Reset the angle orientation before sets the new frame
            
            curStep.imageLayer?.setTransformRotationZ(0)
            
            curStep.imageLayer?.frame = anglePoint(angle, align: curStep.imageAlign, size: img.size).centerRect(img.size)
            
            // Rotate the layer
            
            if (curStep.imageOrientationToAngle) {
                curStep.imageLayer?.setTransformRotationZ(angle - startAngle)
            }
            
            // Mark the layer for repaint
            
            curStep.imageLayer?.setNeedsDisplay()
        }
        
    }
    fileprivate func setUpTextLayerFont(_ curStep:OMStepData) {
        
        if (!curStep.fontName.isEmpty) {
            curStep.textLayer?.font = UIFont( name: curStep.fontName, size: curStep.fontSize)
        }
        
        curStep.textLayer?.foregroundColor = curStep.fontColor
        curStep.textLayer?.fontStrokeColor = curStep.fontStrokeColor
        curStep.textLayer?.backgroundColor = curStep.fontBackgroundColor.cgColor
        curStep.textLayer?.fontStrokeWidth = curStep.fontStrokeWidth
    }
    
    
    fileprivate func doFollowAngle(_ step:OMStepData) {
        
        let sizeOfText = step.textLayer?.frameSize();
        
        let angle:Double = step.angle.align(step.textAngleAlign)
        
        //SpeedLog.print("[*] angle \(round(angle.radiansToDegrees())) aling:\(step.textAngleAlign)")
        
        let positionInAngle = anglePoint(angle, align: step.textAlign, size: sizeOfText!)
        
        //SpeedLog.print("[*] position in angle \(positionInAngle)")
        
        step.textLayer?.frame = positionInAngle.centerRect(sizeOfText!)
        
        //step.textLayer?.frame    =  bounds
        
        if(step.textOrientationToAngle){
            
            //step.textLayer?.angleOrientation = -1.0 * Double(PolarAngle(positionInAngle))
            step.textLayer?.setTransformRotationZ( angle - startAngle)
        }
    }
    
    
//    private func doFollowArc(step:OMStepData) {
//        
//        step.textLayer?.frame    =  bounds
//        step.textLayer?.textPath =  UIBezierPath().circlePath(bounds.size.center(),
//            radius : step.textRadius,
//            startAngle : step.angle.start,
//            angle : step.angle.length())
//    }
    
    fileprivate func setUpText(_ step:OMStepData) {
        
        /// Allways must be reset the angle orientation for easy mach
        
        //step.textLayer?.transform = CATransform3DIdentity
        
        
//        if (step.textRadius != 0)  {
//            
//            doFollowArc(step)
//            
//        } else {
        
            step.textLayer?.setTransformRotationZ(0.0)
            doFollowAngle(step)
            
//            let size = (step.textLayer?.frameSizeLengthFromString((step.textLayer?.string)!))!
//            
//            SpeedLog.print("*** \(step.textLayer?.string) with size of \(size)")
//            
//            // Reset the angle orientation before sets a new frame
//            
//            if (step.textOrientationToAngle || step.textLayer?.angleOrientation != 0.0) {
//                step.textLayer?.angleOrientation = 0
//            }
//            
//            let angle:Double = step.angle.align(step.textAngleAlign)
//            
//            SpeedLog.print("[*] angle \(round(angle.radiansToDegrees()))")
//            
//            if (step.textOrientationToAngle) {
//                step.textLayer?.angleOrientation =  (angle - startAngle)
//            }
//
//            step.textLayer?.frame = anglePoint(angle, align: step.textAlign, size: size).centerRect(size)
//        }
        
            SpeedLog.print("text#\(("step \(stepIndex(step)) text")) \(step.text)")
            SpeedLog.print("angleOrientation \(step.textLayer?.getTransformRotationZ().radiansToDegrees())")
            SpeedLog.print("frame \(step.textLayer?.frame)")
            SpeedLog.print("transform: \(step.textLayer!.transform.affine())")
    }
    
    /**
     Remove all layers from the superlayer.
     */
    func removeSublayers()
    {
        for (_, layer) in self.layer.sublayers!.enumerated() {
            layer.removeAllAnimations()
            layer.removeFromSuperlayer()
        }
        
        //        for (_, step) in dataSteps.enumerate() {
        //            let curStep = step as! OMStepData
        //
        //            // Remove the layer mask
        //
        //            curStep.maskLayer?.removeFromSuperlayer()
        //
        //            curStep.wellLayer?.removeFromSuperlayer()
        //
        //            curStep.imageLayer?.removeFromSuperlayer()
        //
        //            curStep.textLayer?.removeFromSuperlayer()
        //
        //            curStep.shapeLayer.removeFromSuperlayer()
        //        }
        //
        //        // Remove the center image layer
        //
        //        imageLayer?.removeFromSuperlayer()
        //        
        //        // Remove the number layer
        //        
        //        numberLayer?.removeFromSuperlayer()
    }
    
    /**
        SetUp the textLayer
    
        - parameter curStep: Step Object
    */
    
    fileprivate func setUpTextLayer(_ step:OMStepData)
    {
        // Update the text layer. If it don't exist, create it.
        
//        if let curTextLayer = step.textLayer {
//            curTextLayer.string = step.text
//            if  DEBUG_LAYERS {
//                curTextLayer.name = "step \(stepIndex(step)) text"
//            }
//            
//        } else {
        
            step.textLayer?.removeFromSuperlayer()
            step.textLayer = OMTextLayer(string: step.text!)
        
//        }
        
        // Configure the step text layer font
        
        setUpTextLayerFont(step);
        
        setUpText(step)
    }
    
    
    internal func addLayers() {
        /// Create the layers for each step.
        
        for (index, step) in dataSteps.enumerated()
        {
            let curStep = step as! OMStepData
            
            //            if  curStep.imageIsSeparator {
            //
            //                if(index + 1 < dataSteps.count ){
            //
            //                    let nextStep = dataSteps[index+1] as! OMStepData
            //
            //                    if DEBUG_VERBOSE {
            //                        println("#\(index) *** Angle ARCLEN :\(nextStep.separatorAngleHalf + step.separatorAngleHalf)")
            //                    }
            //
            //                    assert( OMAngle(startAngle: curStep.angle.start + curStep.separatorAngleHalf, endAngle: curStep.angle.end - nextStep.separatorAngleHalf).valid(), "angle overflow!")
            //
            //
            //                    setUpLayers(curStep,
            //                        startAngle: curStep.angle.start + curStep.separatorAngleHalf,
            //                        endAngle: curStep.angle.end - nextStep.separatorAngleHalf)
            //                }else{
            //                    let firstStep = dataSteps.firstObject as! OMStepData
            //
            //                     if DEBUG_VERBOSE {
            //                        println("#\(index) *** Angle ARCLEN :\(firstStep.separatorAngleHalf + step.separatorAngleHalf)")
            //                    }
            //
            //                    setUpLayers(curStep,
            //                        startAngle:curStep.angle.start + curStep.separatorAngleHalf,
            //                        endAngle:curStep.angle.end - firstStep.separatorAngleHalf)
            //                }
            //            } else {
            setUpLayers(curStep,
                        startAngle:curStep.angle.start,
                        endAngle: curStep.angle.end)
            //            }
        }
    }
    
    /**
     *   Create or update all the necesary layers
     */
    internal func updateLayerTree() {
        
        /// Let's recalculate the step layers.
        
        if percentText || stepText {
            // set up the central numerical text layer.
            setUpNumericalTextLayer()
        }
        
        //let minAngle = minAngleLength()
        
        // Create and setup the position of the text and image step layers
        
        for (_, step) in dataSteps.enumerated() {
            let curStep  = step as! OMStepData
            let hasImage = (curStep.image != nil)   // Image Layer
            let hasText  = (curStep.text  != nil)   // Text Layer
            if hasImage {
                setUpImageLayer(curStep)
            }
            if  hasText {
                setUpTextLayer(curStep)
            }
        }
        
        addLayers()
        
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
            if let numberLayer=numberLayer {
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
    }
}
