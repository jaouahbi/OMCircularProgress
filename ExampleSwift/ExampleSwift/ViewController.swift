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

class ViewController: UIViewController {
    
    @IBOutlet weak var progressViewMood: OMCircularProgress!
    @IBOutlet weak var progressViewClock: OMCircularProgress!
    @IBOutlet weak var progressViewClockMinutes: OMCircularProgress!
    @IBOutlet weak var progressViewClockSeconds: OMCircularProgress!
    
    @IBOutlet weak var progressViewImagesWithDifferentsSize: OMCircularProgress!
    @IBOutlet weak var progressViewSimple: OMCircularProgress!
    
    @IBOutlet weak var progressViewGradientMask: OMCircularProgress!
    @IBOutlet weak var progressViewFlower: OMCircularProgress!
    
    var calendar:Calendar = Calendar(identifier:Calendar.Identifier.gregorian);
    
    override func viewDidAppear(_ animated: Bool)
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
        
        //
        // Setup the circular progress examples
        //
        
        
        // clock example
    
        let r = self.progressViewClock.radius / 3
        
        self.progressViewClockMinutes.radius = r * 2
        
        self.progressViewClockSeconds.radius = r
        
        self.setupClockExample(self.progressViewClock)
        self.setupClockMinute(self.progressViewClockMinutes)
        self.setupClockSeconds(self.progressViewClockSeconds)
        
        // mood example
        
        self.setupMoodExample(self.progressViewMood);
        
        
        self.setupWithImagesWithDifferentsSize(self.progressViewImagesWithDifferentsSize);
        self.setupColorsFullWithGradientMaskAndDirectProgress(self.progressViewSimple);
        self.setupWithGradientMask(self.progressViewGradientMask);
        self.setupFlower(self.progressViewFlower);
        
        let time = DispatchTime.now() + Double(Int64(NSEC_PER_SEC) * 1) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: time) {
            
            // diferents progress for each step
            for i:Int in 0 ..< self.progressViewSimple.numberOfSteps {
                self.progressViewSimple.setStepProgress(i, stepProgress: [0.2,0.7,0.6,0.9][Int(i)])
            }
            
            // full progress
            self.progressViewImagesWithDifferentsSize.progress  = OMCompleteProgress
            self.progressViewMood.progress                      = OMCompleteProgress
            self.progressViewGradientMask.progress              = OMCompleteProgress
            self.progressViewFlower.progress                    = OMCompleteProgress
        }
        
        // clock timer
        Timer.scheduledTimer(timeInterval: 1.0,
                             target: self,
                             selector: #selector(ViewController.timerProc),
                             userInfo: nil,
                             repeats: true)
    }
    
    
    func timerProc()
    {
        let seconds = (calendar as NSCalendar).components(.second, from:Date()).second
        let minutes = (calendar as NSCalendar).components(.minute, from:Date()).minute
        var hour    = (calendar as NSCalendar).components(.hour, from:Date()).hour
        
        self.progressViewClockSeconds.progress = Double(seconds!)
        
        self.progressViewClockMinutes.progress = Double(minutes!)
        
        if(hour! > 12) {
            hour! -= 12
        }
        
        self.progressViewClock.progress = Double(hour!)
        
        // DBG
        // println("\(hour) : \(minutes) : \(seconds)")
        
    }
    
    func setupColorsFullWithGradientMaskAndDirectProgress(_ theProgressView:OMCircularProgress)
    {
        theProgressView.progressStyle = .directProgress
        
        // Configure the animation
        
        theProgressView.animationDuration  = 2.0
        
        theProgressView.thicknessRatio    = 1.0      // 100%
        
        let colors : [UIColor] = [UIColor(red:0.294, green:0.780, blue:0.812, alpha:1.0),
        UIColor(red:0.114, green:0.675, blue:0.839, alpha:1.0),
        UIColor(red:0.294, green:0.780, blue:0.812, alpha:1.0)]
        
        let stepAngle = (M_PI * 2.0) / Double(colors.count)
        
        for i in 0 ..< colors.count  {
            
            // Create the step.
            
            let theStep = theProgressView.addStep( stepAngle, color:colors[i] as UIColor)
            
            theStep!.wellColor  = nil
            
            
            // configure the gradient
            let gradientLayer       = OMShadingGradientLayer(type:.radial)
            
            let color     = colors[i]
            
            gradientLayer.colors     = [
                color,
                color.next()!]
//            
//            gradientLayer.locations     = [
//                0.95,
//                0.90]
            
            
            //gradientLayer.function  = .Exponential
            gradientLayer.frame     = theProgressView.bounds
            
            
            // axial gradient
            gradientLayer.startPoint = CGPoint(x: 0.5,y: 0.5)
            gradientLayer.endPoint   = CGPoint(x: 0.5,y: 0.5)
            
            gradientLayer.startRadius   = theProgressView.innerRadius
            gradientLayer.endRadius     = theProgressView.outerRadius
            
            gradientLayer.extendsPastEnd  = true
            gradientLayer.extendsBeforeStart = true
            gradientLayer.slopeFunction = (kEasingFunctions.last)!
            
            // mask it
            theStep!.maskLayer        = gradientLayer
        }
    }
    
    func setupWithGradientMask(_ theProgressView:OMCircularProgress)
    {
        theProgressView.progressStyle = .sequentialProgress
        
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
        theProgressView.fontColor = UIColor.black
        theProgressView.fontBackgroundColor = UIColor.clear
        theProgressView.fontStrokeColor = UIColor.white
        
        // Colors, angles and other steps configurations.
        
        let colors : [UIColor] = UIColor.rainbow(2, hue: 0)
        
        let stepAngle = (M_PI * 2.0) / Double(colors.count)
        
        for i in 0 ..< colors.count  {
            
            // Create the step.
            
            let theStep = theProgressView.addStep(stepAngle, color:colors[i])
            
            theStep?.wellColor = nil
            
            
            // configure the gradient
            let gradientLayer       = OMShadingGradientLayer(type:.axial)
            
            gradientLayer.function  = .exponential
            gradientLayer.frame     = theProgressView.bounds
            gradientLayer.colors    = [colors[i],UIColor(white:0,alpha: 0.8),colors[i]]
            
            let points = gradientLayer.gradientPointsToAngle(theStep!.angle.norm())
            
            // axial gradient
            gradientLayer.startPoint = points.0
            gradientLayer.endPoint   = points.1
            
            gradientLayer.extendsPastEnd  = true
            gradientLayer.extendsBeforeStart = true
            
            
            // mask it
            theStep!.maskLayer        = gradientLayer
        }
    }
    
    
    func setupFlower(_ theProgressView:OMCircularProgress)
    {
        theProgressView.progressStyle = .sequentialProgress
        
        // Configure the animation
        
        theProgressView.animationDuration  = 10
        
        /// Configure the separation ratio
        
        // theProgressView.separatorRatio  = 0.1
        
        theProgressView.thicknessRatio  = 0.7      // 70%
        
        let colors : [UIColor] = UIColor.rainbow(25, hue: 0) as [UIColor]
        
        let stepAngle = (M_PI * 2.0) / Double(colors.count)
        
        for i in 0 ..< colors.count  {
            
            // Create the step.
            
            let theStep = theProgressView.addStep( stepAngle, color:colors[i])
            
            // configure the gradient
            let gradientLayer       = OMShadingGradientLayer(type:.axial)
            
            gradientLayer.function  = .exponential
            gradientLayer.frame     = theProgressView.bounds
            gradientLayer.colors    = [colors[i],UIColor(white:0,alpha: 0.8),colors[i]]
            
            let points = gradientLayer.gradientPointsToAngle(theStep!.angle.norm())
            
            // axial gradient
            gradientLayer.startPoint = points.0
            gradientLayer.endPoint   = points.1
            
            gradientLayer.extendsPastEnd  = true
            gradientLayer.extendsBeforeStart = true
            
            
            // mask it
            theStep!.maskLayer        = gradientLayer
        }
    }
    
    
    func setupWithImagesWithDifferentsSize(_ theProgressView:OMCircularProgress)
    {
        theProgressView.progressStyle = .sequentialProgress
        
        theProgressView.animationDuration  = 4
        
        theProgressView.thicknessRatio     = 0.4      // 40%
        
        //   theProgressView.separatorRatio     = 0.1
        
        let colors : [UIColor] = UIColor.rainbow(16, hue: 0)
        
        let stepAngle = (M_PI * 2.0) / Double(colors.count)
        
        for i in 0 ..< colors.count  {
            
            let theStep = theProgressView.addStep( stepAngle, color:colors[i] as UIColor)!
            
            // Configure the step
            
            theStep.text                   = "\(i)"
            theStep.textAlign              = .center
            theStep.textOrientationToAngle = true
            
            theStep.fontName               = "HelveticaNeue-Light"
            theStep.fontSize               = 9
            theStep.fontBackgroundColor    = UIColor.clear
            theStep.fontStrokeColor        = UIColor.white
            
            if(i == 0){
                theStep.image = UIImage(named: "center")
            }else if  (i % 2 == 0)  {
                theStep.image  = UIImage(named: "0")
                //step.imageIsSeparator = true
            } else if(i % 3 == 0) {
                theStep.image  = UIImage(named: "1")
            } else {
                theStep.image  = UIImage(named: "2")
                //
            }
            
            theStep.imageAlign              = .middle
            theStep.imageOrientationToAngle = true
            
            // configure the gradient
            let gradientLayer       = OMShadingGradientLayer(type:.axial)
            
            gradientLayer.function  = .exponential
            gradientLayer.frame     = theProgressView.bounds
            gradientLayer.colors    = [colors[i],UIColor(white:0,alpha: 0.8),colors[i]]
            
            let points =  gradientLayer.gradientPointsToAngle(theStep.angle.norm())
            
            // axial gradient
            gradientLayer.startPoint = points.0
            gradientLayer.endPoint   = points.1
            
            gradientLayer.extendsPastEnd  = true
            gradientLayer.extendsBeforeStart = true
            
            // mask it
            theStep.maskLayer        = gradientLayer
            
            
        }
        
        theProgressView.image = UIImage(named: "center")
    }
    
    func setupMoodExample(_ theProgressView:OMCircularProgress)
    {
        theProgressView.progressStyle = .sequentialProgress
        
        // Configure the animation duration
        
        theProgressView.animationDuration  = 10
        
        theProgressView.thicknessRatio     = 0.70
        
        // from https://github.com/CaptainRedmuff/UIColor-Crayola
        
        let colorsFrom : [UIColor] = [UIColor(red:0.867 ,green:0.267, blue:0.573, alpha:1.0),
                                      UIColor(red:0.267, green:0.843, blue:0.659, alpha:1.0),
                                      UIColor(red:1.000, green:0.282, blue:0.816, alpha:1.0),
                                      UIColor(red:0.808, green:1.000 ,blue:0.114, alpha:1.0)]
        let colorsTo : [UIColor] = [UIColor(red:0.773, green:0.816, blue:0.902, alpha:1.0),
                                    UIColor(red:0.114, green:0.675, blue:0.839, alpha:1.0),
                                    UIColor(red:0.294, green:0.780, blue:0.812, alpha:1.0),
                                    UIColor(red:0.651, green:0.906, blue:1.000, alpha:1.0)]
        
        let strings : [String] = ["Grumpy", "Normal","Happy","Very Happy"]
        
        let images : [String] = ["3","0","1","2"]
        
        let stepAngle = (M_PI * 2.0) / Double(strings.count)
        
        for i in 0 ..< strings.count {
            
            // Create and configure the step
            
            let theStep = theProgressView.addStep( stepAngle, color:colorsFrom[i])!
            
            // Step text
            theStep.text                   = strings[i]
            theStep.fontName               = "HelveticaNeue"
            theStep.fontSize               = 12
            theStep.fontColor              = UIColor.black
            theStep.fontBackgroundColor    = UIColor.clear
            theStep.fontStrokeColor        = UIColor.white
            theStep.fontStrokeWidth        = -2
            
            // step image
            theStep.image                  = UIImage(named: images[i])
            
            // configure the gradient
            let gradientLayer       = OMShadingGradientLayer(type:.axial)
            
            gradientLayer.function  = .exponential
            gradientLayer.frame     = theProgressView.bounds
            gradientLayer.colors    = [colorsFrom[i],UIColor(white:0,alpha: 0.8),colorsTo[i]]
            
            let points =  gradientLayer.gradientPointsToAngle(theStep.angle.norm())
            
            // axial gradient
            gradientLayer.startPoint = points.0
            gradientLayer.endPoint   = points.1
            
            gradientLayer.extendsPastEnd  = true
            gradientLayer.extendsBeforeStart = true
            
            // mask it
            theStep.maskLayer        = gradientLayer
            
        }
        
        // image center
        
        theProgressView.image = UIImage(named: "center")
        
    }
    
    //
    // Clock
    //
    
    
    func setupClockExample(_ theProgressView:OMCircularProgress) {
        
        let fillLayer = CAShapeLayer()
        fillLayer.fillColor = UIColor.white.cgColor
        fillLayer.opacity   = 1.0
        
        let rd : CGFloat = theProgressView.outerRadius * 2
        
        let pathRect    = theProgressView.bounds
        let circleRect  = CGRect(x: 0, y: 0, width: rd, height: rd).center(pathRect)
        
        let path = UIBezierPath(roundedRect: pathRect, cornerRadius: 0.0)
        let circlePath = UIBezierPath(roundedRect: circleRect, cornerRadius: rd)
        path.append(circlePath)
        path.usesEvenOddFillRule = true
        
        fillLayer.path = path.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        
        // mask the OMCircularProgress with a circle.
        theProgressView.layer.addSublayer(fillLayer)
        theProgressView.backgroundColor = UIColor.black
        
        
        theProgressView.progressStyle = .sequentialProgress
        theProgressView.animation = false
        
        // Ratio
        
        // theProgressView.separatorRatio = 0.0
        
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
            step.fontColor              = UIColor.white
            step.fontBackgroundColor    = UIColor.clear
            step.fontStrokeColor        = UIColor.gray
            
            
            step.textAlign              = .middle
            step.textOrientationToAngle = true
            step.textAngleAlign         = .end
            
            
            let gradientLayer           = OMShadingGradientLayer(type:.radial)
            gradientLayer.frame         = theProgressView.bounds
            
            gradientLayer.colors        = [color,UIColor.lightGray]
            
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
    
    func setupClockSeconds(_ theProgressView:OMCircularProgress)
    {
        theProgressView.progressStyle = .sequentialProgress
        
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
                step.fontColor              = UIColor.white
                step.fontBackgroundColor    = UIColor.clear
                step.fontStrokeColor        = UIColor.gray
                
                
                step.textOrientationToAngle = false
                step.textAngleAlign         = .start
                
            }
            
            // configure the gradient
            let gradientLayer       = OMShadingGradientLayer(type:.radial)
            
            gradientLayer.function  = .exponential
            gradientLayer.frame     = theProgressView.bounds
            //gradientLayer.colors    = [color,UIColor(white:0,alpha: 0.8),color]
            
            
            // axial gradient
            gradientLayer.startPoint = CGPoint(x: 0.5,y: 0.5)
            gradientLayer.endPoint   = CGPoint(x: 0.5,y: 0.5)
            
            gradientLayer.startRadius   = theProgressView.innerRadius
            gradientLayer.endRadius     = theProgressView.outerRadius
            
            gradientLayer.extendsPastEnd  = true
            gradientLayer.extendsBeforeStart = true
            
            
            gradientLayer.colors      = [UIColor(red: 1,green: 1,blue: 1,alpha:0.6),
                                         color.withAlphaComponent(0.9)]
            
            // mask it
            step.maskLayer        = gradientLayer
            
            step.maskLayer  = gradientLayer
        }
    }
    
    
    func setupClockMinute(_ theProgressView:OMCircularProgress)
    {
        
        theProgressView.progressStyle = .sequentialProgress
        
        // Configure the animation
        
        theProgressView.animation = false
        
        /// Configure the separator ratio
        
        //   theProgressView.separatorRatio = 0.1 // 10%
        
        theProgressView.thicknessRatio = 0.5 // 50%
        
        // theProgressView.startAngle     = -90.degreesToRadians()
        
        let minutesPerHour  = 60
        
        let color = UIColor(red: 0.6,green: 0.6,blue: 0.6,alpha: 0.6)
        
        let clockAngle = (M_PI * 2.0) / Double(minutesPerHour)
        
        for _ in 0 ..< minutesPerHour   {
            
            // Create the step.
            
            let step = theProgressView.addStep( clockAngle, color:color)!
            
            step.wellColor = nil;
            
//            let gradientLayer         = OMCGGradientLayer(type:.Radial)
//            gradientLayer.frame       = theProgressView.bounds
//            
//            
//            gradientLayer.startPoint = CGPoint(x: 0.5,y: 0.5)
//            gradientLayer.endPoint = CGPoint(x: 0.5,y: 0.5)
//            gradientLayer.extendsPastEnd  = true
//            gradientLayer.extendsBeforeStart = true
//            
//            
//            gradientLayer.startRadius   = theProgressView.innerRadius
//            gradientLayer.endRadius     = theProgressView.outerRadius
//            
//            gradientLayer.colors      = [color,color.colorWithAlphaComponent(0.2)]
//            //
//            step.maskLayer  = gradientLayer
            
            
            // configure the gradient
            let gradientLayer       = OMShadingGradientLayer(type:.radial)
            
            //gradientLayer.function  = .Exponential
            gradientLayer.frame     = theProgressView.bounds
            gradientLayer.colors    = [color,UIColor(white:0,alpha: 0.8),color]
            
            
            // axial gradient
            gradientLayer.startPoint = CGPoint(x: 0.5,y: 0.5)
            gradientLayer.endPoint   = CGPoint(x: 0.5,y: 0.5)
            
            gradientLayer.startRadius   = theProgressView.innerRadius
            gradientLayer.endRadius     = theProgressView.outerRadius
            
            gradientLayer.extendsPastEnd  = true
            gradientLayer.extendsBeforeStart = true
            
            // mask it
            step.maskLayer        = gradientLayer
            
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

