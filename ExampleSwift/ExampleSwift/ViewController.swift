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
    @IBOutlet weak var progressViewClockHours: OMCircularProgress!
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
        
        
        //var pogressViewAppearance = OMCircularProgress.appearance()
        
        self.progressViewMood.layer.name = "Mood"
        self.progressViewClockHours.layer.name = "Clock"
        self.progressViewImagesWithDifferentsSize.layer.name = "ImagesWithDifferentsSize"
        self.progressViewSimple.layer.name = "Simple"
        self.progressViewGradientMask.layer.name = "GradientMask"
        self.progressViewFlower.layer.name = "Flower"
        
        self.progressViewMood.layer.borderWidth = 1;
        self.progressViewClockHours.layer.borderWidth = 1;
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
        setupDirectProgressExample(self.progressViewSimple);
        setupWithGradientMask(self.progressViewGradientMask);
        setupFlower(self.progressViewFlower);
        
        let time = DispatchTime.now() + Double(Int64(NSEC_PER_SEC) * 1) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: time) {
            
            // diferents progress for each step
            let stepProgress =  [0.1,0.9,0.9]
            for i:Int in 0 ..< self.progressViewSimple.numberOfSteps {
                self.progressViewSimple.setStepProgress(i, stepProgress: stepProgress[i])
            }
            
            // full progress
            self.progressViewImagesWithDifferentsSize.progress  = kCompleteProgress
            self.progressViewMood.progress                      = kCompleteProgress
            self.progressViewGradientMask.progress              = kCompleteProgress
            self.progressViewFlower.progress                    = kCompleteProgress
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
        
        self.progressViewClockHours.progress = Double(hour!)
        
        // DBG
        // println("\(hour) : \(minutes) : \(seconds)")
        
    }
    
    func setupDirectProgressExample(_ progress:OMCircularProgress)
    {
        progress.progressStyle = .directProgress
        
        // Configure the animation
        
        progress.animationDuration  = 20.0
        progress.thicknessRatio     = 1.0      // 100%
        
        let colors : [UIColor] = [UIColor.crayolaSeaSerpentColor,
                                  UIColor.crayolaCeruleanColor,
                                  UIColor.crayolaSeaSerpentColor]
        
        let stepAngle = OMCircleAngle.step(elements: Double(colors.count))
        
        for i in 0 ..< colors.count  {
            
            // Create the step.
            
            let color   = colors[i]
            let theStep = progress.addStep(stepAngle, color:color)
            
            theStep?.borderRatio            = 0.1
            theStep?.border.strokeColor     = color.cgColor
            
            // configure the gradient
            let gradient       = OMShadingGradientLayer(type:.radial)
            
            gradient.colors    = [colors[2].darkerColor(percent: 0.4),
                                  colors[1],
                                  colors[0],
                                  color.lighterColor(percent: 0.1) ]

            gradient.frame     = progress.bounds
            //gradient.function  = .exponential
            gradient.slopeFunction =  BounceEaseInOut
            
            
            gradient.startRadius   = progress.innerRadius
            gradient.endRadius     = progress.outerRadius
            
            gradient.extendsPastEnd  = true
            gradient.extendsBeforeStart     = false
            gradient.slopeFunction  = Linear
            
            // mask it
            theStep!.maskLayer        = gradient
        }
        
        
        progress.image.image = UIImage(named: "8")
        //progress.centerImageLayer?.progress = 1.0

    }
    
    func setupWithGradientMask(_ progress:OMCircularProgress)
    {
        // Configure the animation
        progress.animation          = true;
        progress.animationDuration  = 10
        progress.thicknessRatio     = 0.5      // 50%
        
        /// Configure the text
        
        progress.percentText    = true
        
        // Configure the font of text
        
        let textLayer = progress.centerText()
        
        let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 100 : 50
        
        textLayer.font = UIFont(name: "HelveticaNeue-Bold",size:CGFloat(fontSize))
        textLayer.foregroundColor = UIColor.black
        textLayer.fontBackgroundColor = UIColor.clear
        textLayer.fontStrokeColor = UIColor.white
        
        // Colors, angles and other steps configurations.
        
        let colors : [UIColor] = UIColor.rainbow(2, hue: 0)
        
        let stepAngle = OMCircleAngle.step(elements: Double(colors.count))
        
        for i in 0 ..< colors.count  {
            
            // Create the step.
            
            let theStep = progress.addStep(stepAngle, color:colors[i])
            
            // configure the gradient
            let gradient       = OMShadingGradientLayer(type:.axial)
            
            gradient.function  = .exponential
            gradient.frame     = progress.bounds
            gradient.colors    = [colors[i],UIColor(white:0,alpha: 0.8),colors[i]]
            
            let points = gradient.gradientPointsToAngle(theStep!.angle.norm())
            
            // axial gradient
            gradient.startPoint = points.0
            gradient.endPoint   = points.1
            
            // mask it
            theStep!.maskLayer     = gradient
            
            theStep!.borderRatio             = 0.1
            theStep!.border.strokeColor     = colors[i].darkerColor(percent: 0.6).cgColor
            
        }
    }
    
    
    func setupFlower(_ progress:OMCircularProgress) {
        
        // Configure the animation
        
        progress.animationDuration  = 10       // 20 seconds
        progress.thicknessRatio     = 0.7      // 70%
        
        let colors : [UIColor] = UIColor.rainbow(25, hue: 0)
        
        let stepAngle = OMCircleAngle.step(elements: Double(colors.count))
        
        for i in 0 ..< colors.count  {
            
            let color = colors[i]
            // Create the step.
            let step = progress.addStep( stepAngle, color:color)
            // Configure the gradient
            let gradient       = OMShadingGradientLayer(type:.axial)
            
            gradient.function  = .exponential
            gradient.frame     = progress.bounds
            gradient.colors    = [color,
                                       UIColor(white:0,alpha: 0.8),
                                       color]
            // Axial gradient
            let points = gradient.gradientPointsToAngle(step!.angle.norm())
            gradient.startPoint = points.0
            gradient.endPoint   = points.1
            
            // mask it
            step!.maskLayer        = gradient
        }
    }
    
    
    func setupWithImagesWithDifferentsSize(_ progress:OMCircularProgress) {
        
        progress.animationDuration  = 4
        progress.thicknessRatio     = 0.4      // 40%
        
        let colors : [UIColor] = UIColor.rainbow(16, hue: 0)
        
        let stepAngle = (M_PI * 2.0) / Double(colors.count)
        
        for i in 0 ..< colors.count  {
            
            let theStep = progress.addStep(stepAngle,color:colors[i])!
        
            if  (i % 4 == 0)  {
                theStep.image.image  = UIImage(named: "5")
            }

            let color = colors[i]
       
            theStep.borderRatio             = 0.1
            theStep.border.strokeColor     = color.darkerColor(percent: 0.6).cgColor
            theStep.imageAlign              = .middle
            
            // configure the gradient
            let gradient       = OMShadingGradientLayer(type:.radial)
            
            gradient.function  = .linear
            gradient.frame     = progress.bounds
        
            gradient.colors    = [color.darkerColor(percent: 0.65),
                                       color.lighterColor(percent: 1.0),
                                       color.darkerColor(percent: 0.35)]
            
            gradient.startRadius   = progress.innerRadius
            gradient.endRadius     = progress.outerRadius
            
            // mask it
            theStep.maskLayer        = gradient
        }
        
        progress.image.image = UIImage(named: "5")
    }
    
    func setupTopLeftProgressViewExample(_ progress:OMCircularProgress) {
        
        // Configure the animation duration
        progress.animationDuration  = 10
        progress.thicknessRatio     = 0.70
        
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
            
            let theStep = progress.addStep(stepAngle, color:colorsFrom[i])!
            
            // Step text
            
            // step image
            theStep.image.image                   = UIImage(named: images[i])
            theStep.imageOrientationToAngle = false;
            
            // configure the gradient
            let gradient       = OMShadingGradientLayer(type:.axial)
            
            gradient.function  = .exponential
            gradient.frame     = progress.bounds
            gradient.colors    = [colorsFrom[i],centerColor,colorsTo[i]]
            
            let points =  gradient.gradientPointsToAngle(theStep.angle.norm())
            
            // axial gradient
            gradient.startPoint = points.0
            gradient.endPoint   = points.1

            // mask it
            theStep.maskLayer        = gradient
            
        }
        
        // image center
        
        // progress.image = UIImage(named: "center")
        progress.image.image = UIImage(named: "6")
    }
    
    // MARK: Clock example
    
    // Update the clock layers radius
    func updateClockRadius() {
        let radius = self.progressViewClockHours.radius / 3
        self.progressViewClockMinutes.radius = radius * 2
        self.progressViewClockSeconds.radius = radius
    }
    
    

    
    func setupClockHours(_ progress:OMCircularProgress) {
        //
        //        let fillLayer = CAShapeLayer()
        //        fillLayer.fillColor = UIColor.white.cgColor
        //        fillLayer.opacity   = 1.0
        //
        //        let rd : CGFloat = progress.outerRadius * 2
        //
        //        let pathRect    = progress.bounds
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
        //        progress.layer.addSublayer(fillLayer)
        //        progress.backgroundColor = UIColor.black
        
        
        progress.animation = false
        progress.thicknessRatio = 0.33     // 33.3 %
        //progress.roundedHead    = true
        //progress.showWell       = true;
        
        
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
        
        let color : UIColor = UIColor.crayolaQuickSilverColor
        
        let clockAngle = OMCircleAngle.step(elements: Double(romanNumbers.count))
        
        for i in 0 ..< romanNumbers.count  {
            
            // Create the step.
            
            let step = progress.addStep( clockAngle, color:color )!
            
            // Configure the step
            
            
            let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 22 : 11
            
            step.text.string                 = romanNumbers[i]
            step.text.font                   = UIFont(name:"HelveticaNeue",size:CGFloat(fontSize))
            step.text.foregroundColor        = UIColor.black
            step.text.fontBackgroundColor    = UIColor.clear
            step.text.fontStrokeColor        = UIColor.white
            step.text.fontStrokeWidth        = -4
            
            step.textAlign                   = .middle
            step.textOrientationToAngle      = true
            step.textAngleAlign              = .end
            
            // configure the gradient
            let gradient       = OMShadingGradientLayer(type:.radial)
            
            
            gradient.function  = .linear
            gradient.frame     = progress.bounds
            
            gradient.colors    = [color.darkerColor(percent: 0.65),
                                  color.lighterColor(percent:  0.81),
                                  color.darkerColor(percent: 0.35)]
            
            gradient.startRadius   = progress.innerRadius
            gradient.endRadius     = progress.outerRadius

            // Mask it
            step.maskLayer      = gradient
            
            step.well.strokeColor  = color.cgColor
        }
    }
    
    func setupClockSeconds(_ progress:OMCircularProgress)
    {
        // Configure the animation
        
        progress.animation      = false
        progress.thicknessRatio = 1.0     // 100%
       
        
        let minutesPerHour  = 60
        let quartersPerHour = 4
        let quarter         = 60 / quartersPerHour
        
        let color =   UIColor.crayolaQuickSilverColor
        
        let clockAngle = OMCircleAngle.step(elements: Double(minutesPerHour))
        
        let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 16 : 8
        
        let font = UIFont(name:"HelveticaNeue",size:CGFloat(fontSize))
        
        for i in 0 ..< minutesPerHour   {
            
            // Create the step.
            
            let step = progress.addStep(clockAngle, color:color)!
            
            // Configure the quarter
            
            if((i % quarter) == 0) {
                
                
                step.text.string                 = "\(i)"
                step.text.font                   = font
            
                step.text.foregroundColor        = UIColor.black
                step.text.fontBackgroundColor    = UIColor.clear
                step.text.fontStrokeColor        = UIColor.white
                step.text.fontStrokeWidth        = -2
                
                
                step.textOrientationToAngle = false
                step.textAngleAlign         = .start
                
            }
            
            // configure the gradient
            let gradient       = OMShadingGradientLayer(type:.radial)
            
            gradient.function  = .linear
            gradient.frame     = progress.bounds
            gradient.colors    = [color.darkerColor(percent: 0.65),
                                      color.lighterColor(percent: 0.81),
                                      color.darkerColor(percent: 0.35)]
            
            
            gradient.startRadius   = progress.innerRadius
            gradient.endRadius     = progress.outerRadius

            // mask it
            step.maskLayer        = gradient
            
        }
    }
    
    
    func setupClockMinute(_ progress:OMCircularProgress)
    {
        // Configure the animation
        progress.animation      = false
        progress.thicknessRatio = 0.5    // 50%
        
        let minutesPerHour  = 60
        
        let color =  UIColor.crayolaQuickSilverColor
        
        let clockAngle = OMCircleAngle.step(elements: Double(minutesPerHour))
        
        let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 18 : 9
        let font = UIFont(name:"HelveticaNeue",size:CGFloat(fontSize))
        
        for i in 0 ..< minutesPerHour {
            
            // Create one step for each minute
            let step = progress.addStep(clockAngle, color:color)!
            
            if((i % 5) == 0) {
            
                // Configure the text layer
                
                step.text.string                 = "\(i)"
                step.text.font                   = font
                step.text.foregroundColor        = UIColor.black
                step.text.fontBackgroundColor    = UIColor.clear
                step.text.fontStrokeColor        = UIColor.white
                step.text.fontStrokeWidth        = -3
                
                step.textAngleAlign               = .start
            }
            
            // Configure the radial gradient
            let gradient       = OMShadingGradientLayer(type:.radial)
            
            gradient.function  = .linear
            gradient.frame     = progress.bounds
            
            gradient.colors    = [color.darkerColor(percent: 0.65),
                                  color.lighterColor(percent:  0.81),
                                  color.darkerColor(percent: 0.35)]
            
            gradient.startRadius   = progress.innerRadius
            gradient.endRadius     = progress.outerRadius
            
            // mask it
            step.maskLayer        = gradient
        }
    }
    
    func setupClock() {
        updateClockRadius()
        setupClockHours(self.progressViewClockHours)
        setupClockMinute(self.progressViewClockMinutes)
        setupClockSeconds(self.progressViewClockSeconds)
    }
    
}

