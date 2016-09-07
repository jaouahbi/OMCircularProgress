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
//  ViewController.swift
//
//  Created by Jorge Ouahbi on 19/1/15.
//

import UIKit

public enum GradientFadePoints {
    case Head
    case Tail
}

class ViewController: UIViewController {
    
    @IBOutlet weak var progressViewMood: OMCircularProgress!
    @IBOutlet weak var progressViewClock: OMCircularProgress!
    @IBOutlet weak var progressViewClockMinutes: OMCircularProgress!
    @IBOutlet weak var progressViewClockSeconds: OMCircularProgress!
    
    @IBOutlet weak var progressViewImagesWithDifferentsSize: OMCircularProgress!
    @IBOutlet weak var progressViewSimple: OMCircularProgress!
    
    @IBOutlet weak var progressViewGradientMask: OMCircularProgress!
    @IBOutlet weak var progressViewFlower: OMCircularProgress!
    
    var calendar:NSCalendar = NSCalendar(identifier:NSCalendarIdentifierGregorian)!;
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated);
        
        // TODO:
        // OMCircularProgressView.appearance()
        
        self.progressViewMood.layer.name = "1"
        self.progressViewClock.layer.name = "2"
        self.progressViewImagesWithDifferentsSize.layer.name = "3"
        self.progressViewSimple.layer.name = "4"
        self.progressViewGradientMask.layer.name = "5"
        self.progressViewFlower.layer.name = "6"
        
        
        self.progressViewMood.layer.borderWidth = 1;
        self.progressViewClock.layer.borderWidth = 1;
        self.progressViewImagesWithDifferentsSize.layer.borderWidth = 1;
        self.progressViewSimple.layer.borderWidth = 1;
        self.progressViewGradientMask.layer.borderWidth = 1;
        self.progressViewFlower.layer.borderWidth = 1;
        
        self.view.layoutIfNeeded()
        
        let r = self.progressViewClock.radius / 3
        
        self.progressViewClockMinutes.radius = r * 2
        
        self.progressViewClockSeconds.radius = r
        
        //
        // Setup the progressView examples
        //
        
        self.setupMood(self.progressViewMood);
        
        // clock
        
        self.setupClock(self.progressViewClock)
        self.setupClockMinute(self.progressViewClockMinutes)
        self.setupClockSeconds(self.progressViewClockSeconds)
        
        
        self.setupWithImagesWithDifferentsSize(self.progressViewImagesWithDifferentsSize);
        self.setupColorsFullWithGradientMaskAndDirectProgress(self.progressViewSimple);
        self.setupWithGradientMask(self.progressViewGradientMask);
        self.setupFlower(self.progressViewFlower);
        
        
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) * 1)
        
        dispatch_after(time, dispatch_get_main_queue()) {
            
            for i:Int in 0 ..< self.progressViewSimple.numberOfSteps {
                self.progressViewSimple.setProgressAtIndex(i, progressAtIndex: [0.2,0.7,0.6,0.9][Int(i)])
            }
            
            self.progressViewImagesWithDifferentsSize.progress  = OMCompleteProgress
            self.progressViewMood.progress                      = OMCompleteProgress
            self.progressViewGradientMask.progress              = OMCompleteProgress
            self.progressViewFlower.progress                    = OMCompleteProgress
        }
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.timerProc), userInfo: nil, repeats: true)
    }
    
    
    func timerProc()
    {
        let seconds = calendar.components(.Second, fromDate:NSDate()).second
        let minutes = calendar.components(.Minute, fromDate:NSDate()).minute
        var hour    = calendar.components(.Hour, fromDate:NSDate()).hour
        
        self.progressViewClockSeconds.progress = Double(seconds)
        
        self.progressViewClockMinutes.progress = Double(minutes)
        
        if(hour > 12) {
            hour -= 12
        }
        
        self.progressViewClock.progress = Double(hour)
        
        // DBG
        // println("\(hour) : \(minutes) : \(seconds)")
        
    }
    
    func setupColorsFullWithGradientMaskAndDirectProgress(theProgressView:OMCircularProgress)
    {
        theProgressView.progressStyle = .DirectProgress
        
        // Configure the animation
        
        theProgressView.animationDuration  = 2.0
        
        theProgressView.thicknessRatio    = 1.0      // 100%
        
        let colors : [UIColor] = [UIColor(white:0.80, alpha: 1.0),
                                  UIColor(white:0.80, alpha: 1.0),
                                  UIColor(white:0.80, alpha: 1.0)]
        
        let stepAngle = (M_PI * 2.0) / Double(colors.count)
        
        for i in 0 ..< colors.count  {
            
            // Create the step.
            
            let theStep = theProgressView.addStep( stepAngle, color:colors[i] as UIColor)
            
            theStep!.wellColor  = nil
            
            let gradientLayer   = OMCGGradientLayer(type:.Radial)
            
            gradientLayer.frame = theProgressView.bounds
            
            let color     = colors[i]
            
            gradientLayer.colors     = [
                color,
                UIColor.lightGrayColor(),
                color,
                UIColor.whiteColor()]
            
            gradientLayer.locations     = [
                0.05,
                0.20,
                0.80,
                0.95]
            
            gradientLayer.startPoint  = CGPoint(x: 0.5,y: 0.5)
            gradientLayer.endPoint    = CGPoint(x: 0.5,y: 0.5)
            
            gradientLayer.startRadius = theProgressView.outerRadius
            gradientLayer.endRadius   = theProgressView.innerRadius
            
            gradientLayer.extendsPastEnd  = true
            gradientLayer.extendsBeforeStart = true
            
            theStep!.maskLayer = gradientLayer
        }
    }
    
    func setupWithGradientMask(theProgressView:OMCircularProgress)
    {
        theProgressView.progressStyle = .SequentialProgress
        
        // Configure the animation
        theProgressView.animation          = true;
        theProgressView.animationDuration  = 10
        
        /// Configure the separation
        
        // Ratio
        
        //theProgressView.separatorRatio    = 0.5
        
        theProgressView.thicknessRatio    = 0.5      // 50%
        //theoProgressView.roundedHead    = false
        
        
        /// Configure the text
        
        theProgressView.percentText    = true
        
        // Configure the font of text
        
        theProgressView.fontName = "HelveticaNeue-Bold"
        theProgressView.fontSize = 50
        theProgressView.fontColor = UIColor.blackColor()
        theProgressView.fontBackgroundColor = UIColor.clearColor()
        theProgressView.fontStrokeColor = UIColor.whiteColor()
        
        // Colors, angles and other steps configurations.
        
        let colors : [UIColor] = UIColor.rainbow(2, hue: 0)
        
        let stepAngle = (M_PI * 2.0) / Double(colors.count)
        
        for i in 0 ..< colors.count  {
            
            // Create the step.
            
            let step = theProgressView.addStep(stepAngle, color:colors[i])
            
            step?.wellColor = nil
            
//            let gradientLayer   = OMCGGradientLayer(type:.Axial)
//            gradientLayer.frame = theProgressView.bounds
//            
//            let color = colors[i]
//            
//            gradientLayer.colors  = [color.next()!,color]
//            
//            let points = calcLinearGradientFadePoints(gradientLayer.frame, fadeOptions: .Tail)
//            
//            // Simple vertical axial gradient
//            
//            gradientLayer.startPoint = points.0
//            gradientLayer.endPoint  =  points.1
//            
//            gradientLayer.extendsPastEnd  = true
//            gradientLayer.extendsBeforeStart = true
//            
//            step!.maskLayer = gradientLayer
        }
    }
    
    
    func setupFlower(theProgressView:OMCircularProgress)
    {
        theProgressView.progressStyle = .SequentialProgress
        
        // Configure the animation
        
        theProgressView.animationDuration  = 10
        
        /// Configure the separation ratio
        
        // theProgressView.separatorRatio  = 0.1
        
        theProgressView.thicknessRatio  = 0.7      // 70%
        
        let colors : [UIColor] = UIColor.rainbow(25, hue: 0) as [UIColor]
        
        let stepAngle = (M_PI * 2.0) / Double(colors.count)
        
        for i in 0 ..< colors.count  {
            
            // Create the step.
            
            theProgressView.addStep( stepAngle, color:colors[i] as UIColor)
        }
    }
    
    
    func setupWithImagesWithDifferentsSize(theProgressView:OMCircularProgress)
    {
        theProgressView.progressStyle = .SequentialProgress
        
        theProgressView.animationDuration  = 4
        
        theProgressView.thicknessRatio     = 0.4      // 40%
        
        //   theProgressView.separatorRatio     = 0.1
        
        let colors : [UIColor] = UIColor.rainbow(16, hue: 0)
        
        let stepAngle = (M_PI * 2.0) / Double(colors.count)
        
        for i in 0 ..< colors.count  {
            
            let step = theProgressView.addStep( stepAngle, color:colors[i] as UIColor)!
            
            // Configure the step
            
            step.text                   = "\(i)"
            step.textAlign              = .Center
            step.textOrientationToAngle = true
            
            step.fontName               = "HelveticaNeue-Light"
            step.fontSize               = 9
            step.fontColor              = UIColor.blackColor()
            step.fontBackgroundColor    = UIColor.clearColor()
            step.fontStrokeColor        = UIColor.whiteColor()
            
            if(i == 0){
                step.image = UIImage(named: "center")
            }else if  (i % 2 == 0)  {
                step.image  = UIImage(named: "0")
                //step.imageIsSeparator = true
            } else if(i % 3 == 0) {
                step.image  = UIImage(named: "1")
            } else {
                step.image  = UIImage(named: "2")
                //
            }
            
            step.imageAlign              = .Middle
            step.imageOrientationToAngle = true
        }
        
        theProgressView.image = UIImage(named: "center")
    }
    

    // Create gradient points based on direction.
    
    func calcLinearGradientFadePoints(rect:CGRect, fadeOptions:GradientFadePoints) -> (CGPoint,CGPoint) {
        let fadeWidth = min(rect.size.height * 2, floor(rect.size.width / 4))
        let minX = CGRectGetMinX(rect)
        let maxX = CGRectGetMaxX(rect)
        switch fadeOptions {
        case .Tail:
                let startX = maxX - fadeWidth;
                return (CGPoint(x: startX, y: CGRectGetMidY(rect)) / rect.size ,CGPoint(x: maxX, y: CGRectGetMidY(rect)) / rect.size)
        case .Head:
                let startX = minX + fadeWidth;
                return ( CGPoint(x: startX, y: CGRectGetMidY(rect)) / rect.size ,CGPoint(x: minX, y: CGRectGetMidY(rect)) / rect.size)
        }
    }
    
    func setupMood(theProgressView:OMCircularProgress)
    {
        theProgressView.progressStyle = .SequentialProgress
        
        // Configure the animation duration
        
        theProgressView.animationDuration  = 10
        
        theProgressView.thicknessRatio     = 0.70
        
        let colors : [UIColor] = [UIColor.redColor(),UIColor.yellowColor(),UIColor.greenColor()]
        
        let strings : [String] = ["Normal","Happy","Very Happy"]
        
        let stepAngle = (M_PI * 2.0) / Double(strings.count)
        
        for i in 0 ..< strings.count {
            
            /// Create the step.
            
            let theStep = theProgressView.addStep( stepAngle, color:colors[i] as UIColor)!
            
            /// Configure the step
            
            // step text
            
            theStep.text                   = strings[i]
            theStep.textAlign              = .Middle
            theStep.textOrientationToAngle = true
            
            theStep.fontName               = "HelveticaNeue"
            theStep.fontSize               = 12
            theStep.fontColor              = UIColor.blackColor()
            theStep.fontBackgroundColor    = UIColor.clearColor()
            theStep.fontStrokeColor        = UIColor.whiteColor()
            
            // step image
            theStep.image                   = UIImage(named: String("\(i)"))
            theStep.imageAlign              = .Border
            theStep.imageOrientationToAngle = true
            
//            // configure the gradient
//            let gradientLayer       = OMCGGradientLayer(type:.Axial)
//            let colors              = colors[i]
//            
//            gradientLayer.frame     = theProgressView.bounds
//            gradientLayer.colors    = [colors.next()!,colors]
//            
//            let points = calcLinearGradientFadePoints(gradientLayer.frame, fadeOptions: .Head)
//            
//            // vertical axial gradient
//            gradientLayer.startPoint = points.0
//            gradientLayer.endPoint   = points.1
//            
//            gradientLayer.extendsPastEnd  = true
//            gradientLayer.extendsBeforeStart = true
//            
//            // mask it
//            theStep.maskLayer        = gradientLayer
            
        }
        
        // image center
        
        theProgressView.image = UIImage(named: "center")
        
    }
    
    //
    // Clock
    //
    
    
    func setupClock(theProgressView:OMCircularProgress) {
        
        let fillLayer = CAShapeLayer()
        fillLayer.fillColor = UIColor.whiteColor().CGColor
        fillLayer.opacity = 1.0
        
        let rd : CGFloat = theProgressView.outerRadius * 2
        
        let pathRect    = theProgressView.bounds
        let circleRect  = CGRect(x: 0, y: 0, width: rd, height: rd).centeredInRect(pathRect)
        
        let path = UIBezierPath(roundedRect: pathRect, cornerRadius: 0.0)
        let circlePath = UIBezierPath(roundedRect: circleRect, cornerRadius: rd)
        path.appendPath(circlePath)
        path.usesEvenOddFillRule = true
        
        fillLayer.path = path.CGPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        
        // mask the OMCircularProgress with a circle.
        theProgressView.layer.addSublayer(fillLayer)
        theProgressView.backgroundColor = UIColor.blackColor()
        
        theProgressView.progressStyle = .SequentialProgress
        theProgressView.animation = false
        
        // Ratio
        
        //     theProgressView.separatorRatio = 0.0
        
        theProgressView.thicknessRatio = 0.33     // 33.3 %
        theProgressView.roundedHead    = false
        
        //theProgressView.startAngle     = -90.degreesToRadians()
        
        /// Unicode roman numbers.
        
        let romanNumbers : [String] = ["Ⅰ",
                                       "Ⅱ",
                                       "Ⅲ",
                                       "Ⅳ",
                                       "Ⅴ",
                                       "Ⅵ",
                                       "Ⅶ",
                                       "Ⅷ",
                                       "Ⅸ",
                                       "Ⅹ",
                                       "Ⅺ",
                                       "Ⅻ"]
        
        let color = UIColor(red: 0,green: 0,blue: 0,alpha: 0.5)
        
        let clockAngle = (M_PI * 2.0) / Double(romanNumbers.count)
        
        for i in 0 ..< romanNumbers.count  {
            
            // Create the step.
            
            let step = theProgressView.addStep( clockAngle, color:color )!
            
            // without well
            
            step.wellColor = nil;
            
            // Configure the step
            
            step.text                   = romanNumbers[i]
            step.fontName               = "HelveticaNeue"
            step.fontSize               = 14
            step.fontColor              = UIColor.whiteColor()
            step.fontBackgroundColor    = UIColor.clearColor()
            step.fontStrokeColor        = UIColor.grayColor()
            
            
            step.textAlign              = .Middle
            step.textOrientationToAngle = true
            step.textAngleAlign         = .End
            
            
            let gradientLayer           = OMShadingGradientLayer(type:.Radial)
            gradientLayer.frame        = theProgressView.bounds
            
            gradientLayer.colors        = [ UIColor.lightGrayColor(), color,UIColor.lightGrayColor()]
            
            gradientLayer.startPoint   = CGPoint(x: 0.5,y: 0.5)
            gradientLayer.endPoint     = CGPoint(x: 0.5,y: 0.5)
            
            gradientLayer.startRadius   = theProgressView.innerRadius
            gradientLayer.endRadius     = theProgressView.outerRadius
            gradientLayer.extendsPastEnd  = true
            gradientLayer.extendsBeforeStart = true
            //gradientLayer.function      =  .Exponential
            
            // set the mask
            step.maskLayer              = gradientLayer
            
        }
    }
    
    func setupClockSeconds(theProgressView:OMCircularProgress)
    {
        theProgressView.progressStyle = .SequentialProgress
        
        // Configure the animation
        
        theProgressView.animation      = false
        theProgressView.thicknessRatio = 1.0     // 100%
        
        let minutesPerHour  = 60
        let quartersPerHour = 4
        let quarter         = 60 / quartersPerHour
        
        let color = UIColor(red: 0,green: 0,blue: 0,alpha: 1.0)
        
        let clockAngle = (M_PI * 2.0) / Double(minutesPerHour)
        
        for i in 0 ..< minutesPerHour   {
            
            // Create the step.
            
            let step = theProgressView.addStep(clockAngle, color:color)!
            
            step.wellColor = nil;
            
            // Configure the quarter
            
            if((i % quarter) == 0) {
                
                step.text                   = "\(i)"
                step.fontName               = "HelveticaNeue-Light"
                step.fontSize               = 12
                step.fontColor              = UIColor.whiteColor()
                step.fontBackgroundColor    = UIColor.clearColor()
                step.fontStrokeColor        = UIColor.grayColor()
                
            
                step.textOrientationToAngle = false
                step.textAngleAlign         = .Start
                
            }
            
            let gradientLayer         = OMCGGradientLayer(type:.Radial)
            gradientLayer.frame       = theProgressView.bounds
            
            let point = CGPoint(x: 0.5,y: 0.5)
            
            gradientLayer.startPoint = point
            gradientLayer.endPoint = point
            gradientLayer.extendsPastEnd  = true
            gradientLayer.extendsBeforeStart = true
            
            gradientLayer.startRadius   = theProgressView.innerRadius
            gradientLayer.endRadius     = theProgressView.outerRadius
            
            gradientLayer.colors      = [UIColor(red: 1,green: 1,blue: 1,alpha:0.6),
                                         color.colorWithAlphaComponent(0.9)]
            
            step.maskLayer  = gradientLayer
        }
    }
    
    
    func setupClockMinute(theProgressView:OMCircularProgress)
    {
    
        theProgressView.progressStyle = .SequentialProgress
        
        // Configure the animation
        
        theProgressView.animation = false
        
        /// Configure the separator ratio
        
        //   theProgressView.separatorRatio = 0.1 // 10%
        
        theProgressView.thicknessRatio = 0.5 // 50%
        
        // theProgressView.startAngle     = -90.degreesToRadians()
        
        let minutesPerHour  = 60
        
        let color = UIColor(red: 0.6,green: 0.6,blue: 0.6,alpha: 1.0)
        
        let clockAngle = (M_PI * 2.0) / Double(minutesPerHour)
        
        for _ in 0 ..< minutesPerHour   {
            
            // Create the step.
            
            let step = theProgressView.addStep( clockAngle, color:color)!
            
            step.wellColor = nil;
            
            let gradientLayer         = OMCGGradientLayer(type:.Radial)
            gradientLayer.frame       = theProgressView.bounds
            
            
            let point = CGPoint(x: 0.5,y: 0.5)
            
            gradientLayer.startPoint = point
            gradientLayer.endPoint = point
            gradientLayer.extendsPastEnd  = true
            gradientLayer.extendsBeforeStart = true
            
            
            gradientLayer.startRadius   = theProgressView.innerRadius
            gradientLayer.endRadius     = theProgressView.outerRadius
            
            gradientLayer.colors      = [color,color.colorWithAlphaComponent(0.2)]
            //
            step.maskLayer  = gradientLayer
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Update the clock
        
        let r = self.progressViewClock.radius / 3
        
        self.progressViewClockMinutes.radius = r * 2
        
        self.progressViewClockSeconds.radius = r
        
    }
}

