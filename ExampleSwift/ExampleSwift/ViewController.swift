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

class ProgressExampleViewController: UIViewController {
    
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
        
        self.progressViewMood.layer.name = "Mood"
        self.progressViewClock.layer.name = "Clock"
        self.progressViewImagesWithDifferentsSize.layer.name = "ImagesWithDifferentsSize"
        self.progressViewSimple.layer.name = "Simple"
        self.progressViewGradientMask.layer.name = "GradientMask"
        self.progressViewFlower.layer.name = "Flower"
        
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
        
        setupClock()
        
        // mood example
        
        setupTopLeftProgressViewExample(self.progressViewMood);
        setupWithImagesWithDifferentsSize(self.progressViewImagesWithDifferentsSize);
        setupColorsFullWithGradientMaskAndDirectProgress(self.progressViewSimple);
        setupWithGradientMask(self.progressViewGradientMask);
        setupFlower(self.progressViewFlower);
        
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
                             selector: #selector(ProgressExampleViewController.timerProc),
                             userInfo: nil,
                             repeats: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateClockRadius()
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
        
        theProgressView.animationDuration  = 20.0
        theProgressView.thicknessRatio     = 1.0      // 100%
        
        let colors : [UIColor] = [UIColor(red:0.294, green:0.780, blue:0.812, alpha:1.0),
                                  UIColor(red:0.114, green:0.675, blue:0.839, alpha:1.0),
                                  UIColor(red:0.294, green:0.780, blue:0.812, alpha:1.0)]
        
        let stepAngle = OMCircleAngle.step(elements: Double(colors.count))
        
        for i in 0 ..< colors.count  {
            
            // Create the step.
            
            let theStep = theProgressView.addStep(stepAngle, color:colors[i])
            
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
            gradientLayer.slopeFunction  = Linear
            
            // mask it
            theStep!.maskLayer        = gradientLayer
        }
        
        
        theProgressView.centerImage = UIImage(named: "8")
        //theProgressView.centerImageLayer?.progress = 1.0

    }
    
    func setupWithGradientMask(_ theProgressView:OMCircularProgress)
    {
        
        // Configure the animation
        theProgressView.animation          = true;
        theProgressView.animationDuration  = 10
        theProgressView.thicknessRatio     = 0.5      // 50%
        
        /// Configure the text
        
        theProgressView.percentText    = true
        
        // Configure the font of text
        
        let textLayer = theProgressView.centerText()
        textLayer.font = UIFont(name: "HelveticaNeue-Bold",size:50)
        textLayer.foregroundColor = UIColor.black
        textLayer.fontBackgroundColor = UIColor.clear
        textLayer.fontStrokeColor = UIColor.white
        
        // Colors, angles and other steps configurations.
        
        let colors : [UIColor] = UIColor.rainbow(2, hue: 0)
        
        let stepAngle = OMCircleAngle.step(elements: Double(colors.count))
        
        for i in 0 ..< colors.count  {
            
            // Create the step.
            
            let theStep = theProgressView.addStep(stepAngle, color:colors[i])
            
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
    
    
    func setupFlower(_ theProgressView:OMCircularProgress) {
        
        // Configure the animation
        
        theProgressView.animationDuration  = 10       // 20 seconds
        theProgressView.thicknessRatio     = 0.7      // 70%
        
        let colors : [UIColor] = UIColor.rainbow(25, hue: 0)
        
        let stepAngle = OMCircleAngle.step(elements: Double(colors.count))
        
        for i in 0 ..< colors.count  {
            
            let color = colors[i]
            // Create the step.
            let step = theProgressView.addStep( stepAngle, color:color)
            // Configure the gradient
            let gradientLayer       = OMShadingGradientLayer(type:.axial)
            
            gradientLayer.function  = .exponential
            gradientLayer.frame     = theProgressView.bounds
            gradientLayer.colors    = [color,
                                       UIColor(white:0,alpha: 0.8),
                                       color]
            // Axial gradient
            let points = gradientLayer.gradientPointsToAngle(step!.angle.norm())
            gradientLayer.startPoint = points.0
            gradientLayer.endPoint   = points.1
            
            gradientLayer.extendsPastEnd     = true
            gradientLayer.extendsBeforeStart = true
            
            // mask it
            step!.maskLayer        = gradientLayer
        }
    }
    
    
    func setupWithImagesWithDifferentsSize(_ theProgressView:OMCircularProgress) {
        
        theProgressView.animationDuration  = 4
        theProgressView.thicknessRatio     = 0.4      // 40%
        
        let colors : [UIColor] = UIColor.rainbow(16, hue: 0)
        
        let stepAngle = (M_PI * 2.0) / Double(colors.count)
        
        for i in 0 ..< colors.count  {
            
            let theStep = theProgressView.addStep( stepAngle, color:colors[i] )!
            
            //if(i == 0){
            //    theStep.image = UIImage(named: "5")
        //    }else
            if  (i % 4 == 0)  {
                theStep.image  = UIImage(named: "5")
            }
        //else if(i % 3 == 0) {
          //      theStep.image  = UIImage(named: "5")
           // } else {
           //     theStep.image  = UIImage(named: "5")
                //
           // }
            
            theStep.borderRatio     = 0.1
            theStep.imageAlign      = .middle
            
            // configure the gradient
            let gradientLayer       = OMShadingGradientLayer(type:.axial)
            
            gradientLayer.function  = .linear
            gradientLayer.frame     = theProgressView.bounds
            gradientLayer.colors    = [colors[i],UIColor(white:0,alpha: 0.8),colors[i]]
            
            let points =  gradientLayer.gradientPointsToAngle(theStep.angle.norm())
            
            // axial gradient
            gradientLayer.startPoint = points.0
            gradientLayer.endPoint   = points.1
            
            gradientLayer.extendsPastEnd     = true
            gradientLayer.extendsBeforeStart = true
            
            // mask it
            theStep.maskLayer        = gradientLayer
        }
        
        theProgressView.centerImage = UIImage(named: "5")
    }
    
    func setupTopLeftProgressViewExample(_ theProgressView:OMCircularProgress) {
        
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
        
        let images  : [String] = ["6","6","6","6"]
        
        let stepAngle = OMCircleAngle.step(elements:Double(strings.count))
        
        let centerColor = UIColor(white:0,alpha: 0.8)
        
        for i in 0 ..< strings.count {
            
            // Create and configure the step
            
            let theStep = theProgressView.addStep( stepAngle, color:colorsFrom[i])!
            
            // Step text
            
            // step image
            theStep.image                   = UIImage(named: images[i])
            theStep.imageOrientationToAngle = false;
            
            // configure the gradient
            let gradientLayer       = OMShadingGradientLayer(type:.axial)
            
            gradientLayer.function  = .exponential
            gradientLayer.frame     = theProgressView.bounds
            gradientLayer.colors    = [colorsFrom[i],centerColor,colorsTo[i]]
            
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
        
        // theProgressView.image = UIImage(named: "center")
        theProgressView.centerImage = UIImage(named: "6")
    }
    
    // MARK: Clock example
    
    // Update the clock layers radius
    func updateClockRadius() {
        let radius = self.progressViewClock.radius / 3
        self.progressViewClockMinutes.radius = radius * 2
        self.progressViewClockSeconds.radius = radius
    }
    
    

    
    func setupClockExample(_ theProgressView:OMCircularProgress) {
        //
        //        let fillLayer = CAShapeLayer()
        //        fillLayer.fillColor = UIColor.white.cgColor
        //        fillLayer.opacity   = 1.0
        //
        //        let rd : CGFloat = theProgressView.outerRadius * 2
        //
        //        let pathRect    = theProgressView.bounds
        //        let circleRect  = CGRect(x: 0, y: 0, width: rd, height: rd).center(pathRect)
        //
        //        let path = UIBezierPath(roundedRect: pathRect, cornerRadius: 0.0)
        //        let circlePath = UIBezierPath(roundedRect: circleRect, cornerRadius: rd)
        //        path.append(circlePath)
        //        path.usesEvenOddFillRule = true
        //
        //        fillLayer.path = path.cgPath
        //        fillLayer.fillRule = kCAFillRuleEvenOdd
        //
        //        // mask the OMCircularProgress with a circle.
        //        theProgressView.layer.addSublayer(fillLayer)
        //        theProgressView.backgroundColor = UIColor.black
        
        
        theProgressView.animation = false
        theProgressView.thicknessRatio = 0.33     // 33.3 %
        //theProgressView.roundedHead    = true
        //theProgressView.showWell       = true;
        
        
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
        
        let color : UIColor = UIColor.sunglowCrayolaColor()
        
        let clockAngle = OMCircleAngle.step(elements: Double(romanNumbers.count))
        
        for i in 0 ..< romanNumbers.count  {
            
            // Create the step.
            
            let step = theProgressView.addStep( clockAngle, color:color )!
            
            // Configure the step
            
            step.text.string                 = romanNumbers[i]
            step.text.font                   = UIFont(name:"HelveticaNeue",size:11)
            step.text.foregroundColor        = UIColor.black
            step.text.fontBackgroundColor    = UIColor.clear
            step.text.fontStrokeColor        = UIColor.white
            step.text.fontStrokeWidth        = -4
            
            step.textAlign                   = .middle
            step.textOrientationToAngle      = true
            step.textAngleAlign              = .end
            
            // configure the gradient
            let gradientLayer       = OMShadingGradientLayer(type:.radial)
            
            
            gradientLayer.function  = .linear
            gradientLayer.frame     = theProgressView.bounds
            gradientLayer.colors    = [color,
                                       UIColor.mulberryCrayolaColor(),
                                       UIColor.sunglowCrayolaColor(),
                                       UIColor.wildWatermelonCrayolaColor()]
            
            // axial gradient
            gradientLayer.startPoint = CGPoint(x: 0.5,y: 0.5)
            gradientLayer.endPoint   = CGPoint(x: 0.5,y: 0.5)
            
            gradientLayer.startRadius   = theProgressView.innerRadius
            gradientLayer.endRadius     = theProgressView.outerRadius
            
            gradientLayer.extendsPastEnd  = true
            gradientLayer.extendsBeforeStart = true
            
            // Mask it
            step.maskLayer      = gradientLayer
            
            step.well.strokeColor  = UIColor.sunglowCrayolaColor().cgColor
            
        }
    }
    
    func setupClockSeconds(_ theProgressView:OMCircularProgress)
    {
        // Configure the animation
        
        theProgressView.animation      = false
        theProgressView.thicknessRatio = 1.0     // 100%
       
        
        let minutesPerHour  = 60
        let quartersPerHour = 4
        let quarter         = 60 / quartersPerHour
        
        let color =   UIColor.sunglowCrayolaColor()
        
        let clockAngle = OMCircleAngle.step(elements: Double(minutesPerHour))
        
        for i in 0 ..< minutesPerHour   {
            
            // Create the step.
            
            let step = theProgressView.addStep(clockAngle, color:color)!
            
            // Configure the quarter
            
            if((i % quarter) == 0) {
                
                step.text.string                 = "\(i)"
                step.text.font                   = UIFont(name:"HelveticaNeue",size:7)
                step.text.foregroundColor        = UIColor.black
                step.text.fontBackgroundColor    = UIColor.clear
                step.text.fontStrokeColor        = UIColor.white
                step.text.fontStrokeWidth        = -2
                
                
                step.textOrientationToAngle = false
                step.textAngleAlign         = .start
                
            }
            
            // configure the gradient
            let gradientLayer       = OMShadingGradientLayer(type:.radial)
            
            gradientLayer.function  = .linear
            gradientLayer.frame     = theProgressView.bounds
            gradientLayer.colors    = [color,
                                       UIColor.mulberryCrayolaColor(),
                                       UIColor.sunglowCrayolaColor(),
                                       UIColor.wildWatermelonCrayolaColor()]
            
            
            // axial gradient
            gradientLayer.startPoint = CGPoint(x: 0.5,y: 0.5)
            gradientLayer.endPoint   = CGPoint(x: 0.5,y: 0.5)
            
            gradientLayer.startRadius   = theProgressView.innerRadius
            gradientLayer.endRadius     = theProgressView.outerRadius
            
            gradientLayer.extendsPastEnd     = true
            gradientLayer.extendsBeforeStart = true
            
            // mask it
            step.maskLayer        = gradientLayer
            
        }
    }
    
    
    func setupClockMinute(_ theProgressView:OMCircularProgress)
    {
        // Configure the animation
        theProgressView.animation      = false
        theProgressView.thicknessRatio = 0.5    // 50%
        
        let minutesPerHour  = 60
        
        let color =  UIColor.sunglowCrayolaColor()
        
        let clockAngle = OMCircleAngle.step(elements: Double(minutesPerHour))
        
        for i in 0 ..< minutesPerHour {
            
            // Create one step for each minute
            let step = theProgressView.addStep(clockAngle, color:color)!
            
            if((i % 5) == 0) {
            
                // Configure the text
                
                step.text.string                 = "\(i)"
                step.text.font                   = UIFont(name:"HelveticaNeue",size:9)
                step.text.foregroundColor        = UIColor.black
                step.text.fontBackgroundColor    = UIColor.clear
                step.text.fontStrokeColor        = UIColor.white
                step.text.fontStrokeWidth        = -3
                
                step.textAngleAlign         = .start
            }
            
            // Configure the radial gradient
            let gradientLayer       = OMShadingGradientLayer(type:.radial)
            
            gradientLayer.function  = .linear
            gradientLayer.frame     = theProgressView.bounds
            gradientLayer.colors    = [color,
                                       UIColor.mulberryCrayolaColor(),
                                       UIColor.sunglowCrayolaColor(),
                                       UIColor.wildWatermelonCrayolaColor()]
            
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
    
    
    
    
    func setupClock()
    {
        
        updateClockRadius()
        
        
        setupClockExample(self.progressViewClock)
        setupClockMinute(self.progressViewClockMinutes)
        setupClockSeconds(self.progressViewClockSeconds)
    }
    
}

