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
//  TODO: appearance

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

        // DBG
        
        self.progressViewMood.layer.name = "Mood"
        self.progressViewClockHours.layer.name = "Clock Hours"
        self.progressViewClockMinutes.layer.name = "Clock Minutes"
        self.progressViewClockSeconds.layer.name = "Clock Seconds"
        self.progressViewImagesWithDifferentsSize.layer.name = "ImagesWithDifferentsSize"
        self.progressViewSimple.layer.name = "Direct"
        self.progressViewGradientMask.layer.name = "GradientMask"
        self.progressViewFlower.layer.name = "Flower"
    
        // Setup the circular progress examples
        
        setUpExamples()
        
        // Clock timer
        Timer.scheduledTimer(timeInterval: 1.0,
                             target: self,
                             selector: #selector(ProgressExampleViewController.timerProc),
                             userInfo: nil,
                             repeats: true)
    }
    
    
    func setUpExamples()
    {
        // clock example
        
        setupClock()
        
        // mood example
        
        setupMoodProgressViewExample(self.progressViewMood);
        setupWithImagesWithDifferentsSize(self.progressViewImagesWithDifferentsSize);
        setupDirectProgressExample(self.progressViewSimple);
        setupWithGradientMask(self.progressViewGradientMask);
        setupFlower(self.progressViewFlower);
        
        let time = DispatchTime.now() + Double(Int64(NSEC_PER_SEC) * 1) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: time) {
            
            // direct progress
            let numberOfSteps  = self.progressViewSimple.numberOfSteps
            let stepProgress =  [Double](repeating: 0.9, count: numberOfSteps)
            for i:Int in 0 ..< numberOfSteps {
                self.progressViewSimple.setStepProgress(i, stepProgress: stepProgress[i])
            }
            
            // full progress
            self.progressViewImagesWithDifferentsSize.progress  = kCompleteProgress
            self.progressViewMood.progress                      = kCompleteProgress
            self.progressViewGradientMask.progress              = kCompleteProgress
            self.progressViewFlower.progress                    = kCompleteProgress
        }
        
    }

    func timerProc()
    {
        let seconds = (calendar as NSCalendar).components(.second, from:Date()).second
        let minutes = (calendar as NSCalendar).components(.minute, from:Date()).minute
        var hour    = (calendar as NSCalendar).components(.hour, from:Date()).hour
        
        
        if(hour! > 12) {
            hour! -= 12
        }
        
        self.progressViewClockHours.progress = Double(hour!)
        self.progressViewClockMinutes.progress = Double(minutes!)
        self.progressViewClockSeconds.progress = Double(seconds!)
        
        // DBG
        // println("\(hour) : \(minutes) : \(seconds)")
        
    }
    
    func setupDirectProgressExample(_ progress:OMCircularProgress) {
        
        progress.progressStyle = .direct
        
        // Configure the animation
        
        progress.animationDuration  = 40.0
        progress.thicknessRatio     = 1.0      // 100%
        
        let colors : [UIColor] = [UIColor.crayolaSeaSerpentColor,
                                  UIColor.crayolaCeruleanColor,
                                  UIColor.crayolaSeaSerpentColor]
        
        let numberOfSteps = 20
        let stepAngle     = 𝜏 / Double(numberOfSteps)
        let color         = UIColor.crayolaCeruleanColor
        
        for i in 0 ..< numberOfSteps  {
            
            // Create the step.
            let theStep:OMCPStepData?
            // If the step exist, only update the step data
            if progress.dataSteps.count > i {
                theStep = progress[i]
            } else {
                theStep = progress.addStep(stepAngle, color:UIColor.clear)
            }
            
            if let theStep = theStep {
                
                theStep.borderRatio            = 0.1
                theStep.border.strokeColor     = color.cgColor
                
                // configure the gradient
                let gradient       = OMShadingGradientLayer(type:.radial)
                gradient.colors    = [colors[2].darkerColor(percent: 0.4),
                                      colors[1],
                                      colors[0].lighterColor(percent: 0.3),
                                      color.lighterColor(percent: 0.1) ]
                
                gradient.frame         = progress.bounds
                gradient.slopeFunction = Linear
                
                gradient.startRadius   = progress.innerRadius / minRadius(progress.bounds.size)
                gradient.endRadius     = progress.outerRadius / minRadius(progress.bounds.size)
                
                // mask it
                theStep.maskLayer        = gradient
            }
        }
        
        progress.image.image  = UIImage(named: "8")
        progress.image.progress = 1.0
        
    }
    
    func setupWithGradientMask(_ progress:OMCircularProgress)
    {
        /// Configure the animation
        
        progress.animationDuration  = 10
        progress.thicknessRatio     = 0.5      // 50%
        
        /// Configure the text
        
        progress.percentText    = true
        
        /// Configure the font of text
        
        let textLayer = progress.number!
        
        let fontMenlo = UIFont(name:"Menlo-Bold", size:CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 120 : 50))
        
        textLayer.font                = fontMenlo
        textLayer.foregroundColor     = UIColor.black
        textLayer.fontBackgroundColor = UIColor.clear
        textLayer.fontStrokeColor     = UIColor.white
        
        // Colors, angles and other steps configurations.
        
        let colors : [UIColor] = UIColor.rainbow(2, hue: 0)
        
        let stepAngle = 𝜏 /  Double(colors.count)
        
        for i in 0 ..< colors.count  {
            
            // Create the step.
            
            let theStep:OMCPStepData?
            
            // If the step exist, only update the step data
            
            if progress.dataSteps.count > i {
                theStep = progress[i]
            } else {
                theStep = progress.addStep(stepAngle, color:colors[i])
            }
            
            if let theStep = theStep {
                
                // configure the gradient
                let gradient       = OMShadingGradientLayer(type:.axial)
                
                gradient.function  = .exponential
                gradient.frame     = progress.bounds
                gradient.colors    = [colors[i],UIColor(white:0,alpha: 0.8),colors[i]]
                
                let points         = OMGradientLayer.pointsFromNormalizedAngle(theStep.angle.norm())
                
                // axial gradient
                gradient.startPoint = points.0
                gradient.endPoint   = points.1
                
                // mask it
                theStep.maskLayer  = gradient
                
                theStep.borderRatio            = 0.1
                theStep.border.strokeColor     = colors[i].darkerColor(percent: 0.6).cgColor
            }
        }
    }
    
    func setupFlower(_ progress:OMCircularProgress) {
        
        // Configure the animation
        
        progress.animationDuration  = 10       // 20 seconds
        progress.thicknessRatio     = 0.7      // 70%
        
        let colors : [UIColor] = UIColor.rainbow(25, hue: 0)
        
        let stepAngle = 𝜏 /  Double(colors.count)
        
        for i in 0 ..< colors.count  {
            
            let color = colors[i]
            // Create the step.
            let theStep:OMCPStepData?
            
            // If the step exist, only update the step data
            
            if progress.dataSteps.count > i {
                theStep = progress[i]
            } else {
                theStep = progress.addStep(stepAngle, color:color)
            }
            
            if let step = theStep {
                // Configure the gradient
                let gradient       = OMShadingGradientLayer(type:.axial)
                
                gradient.function  = .exponential
                gradient.frame     = progress.bounds
                gradient.colors    = [color,
                                      UIColor(white:0,alpha: 0.8),
                                      color]
                // Axial gradient
                let points = OMGradientLayer.pointsFromNormalizedAngle(step.angle.norm())
                gradient.startPoint = points.0
                gradient.endPoint   = points.1
                
                // mask it
                step.maskLayer        = gradient
                
                step.borderRatio      = drand48()
                step.borderShadow     = false
                step.border.strokeColor = UIColor.white.cgColor
            }
        }
    }
    
    
    func darkerToLighterGradientRadial(progress:OMCircularProgress, color:UIColor) -> OMGradientLayer
    {
        let gradient       = OMShadingGradientLayer(type:.radial)
        
        gradient.function  = .linear
        gradient.frame     = progress.bounds
        
        gradient.colors    = [color.darkerColor(percent: 0.65),
                              color.lighterColor(percent: 1.0),
                              color.darkerColor(percent: 0.35)]
        
        gradient.startRadius   = progress.innerRadius / minRadius(progress.bounds.size)
        gradient.endRadius     = progress.outerRadius  / minRadius(progress.bounds.size)
        
        return gradient;
    }
    
    func lighterToDarkerGradientRadial(progress:OMCircularProgress, color:UIColor) -> OMGradientLayer
    {
        let gradient       = OMShadingGradientLayer(type:.radial)
        
        gradient.function  = .linear
        gradient.frame     = progress.bounds
        
        
        gradient.colors    = [color.lighterColor(percent: 0.65),
                              color.darkerColor(percent: 0.65),
                              color.lighterColor(percent: 0.85)]
        
        gradient.startRadius   = progress.innerRadius / minRadius(progress.bounds.size)
        gradient.endRadius     = progress.outerRadius / minRadius(progress.bounds.size)
        
        return gradient;
    }
    
    func setupWithImagesWithDifferentsSize(_ progress:OMCircularProgress) {
        
        progress.animationDuration  = 4
        progress.thicknessRatio     = 0.4      // 40%
        
        let colors : [UIColor] = UIColor.rainbow(16, hue: 0)
        
        let stepAngle = (M_PI * 2.0) / Double(colors.count)
        
        for i in 0 ..< colors.count  {
            let theStep:OMCPStepData?
            
            // If the step exist, only update the step data
            
            if progress.dataSteps.count > i {
                theStep = progress[i]
            } else {
                theStep = progress.addStep(stepAngle, color:colors[i])
            }
            
            if let theStep = theStep {
                
                if  (i % 4 == 0)  {
                    theStep.ie.layer.image = UIImage(named: "satellite")
                    theStep.ie.orientationToAngle = true
                }
                
                let color = colors[i]
                
                theStep.borderRatio            = 0.1
                theStep.border.strokeColor     = color.darkerColor(percent: 0.6).cgColor
                theStep.ie.radiusPosition      = .middle
                
                // configure the gradient
                let gradient       = OMShadingGradientLayer(type:.radial)
                
                gradient.function  = .linear
                gradient.frame     = progress.bounds
                
                gradient.colors    = [color.darkerColor(percent: 0.65),
                                      color.lighterColor(percent: 1.0),
                                      color.darkerColor(percent: 0.35)]
                
                gradient.startRadius   = progress.innerRadius   / minRadius(progress.bounds.size)
                gradient.endRadius     = progress.outerRadius  / minRadius(progress.bounds.size)
                
                // mask it
                theStep.maskLayer        = gradient
            }
        }
        
        progress.image.image = UIImage(named: "7")
    }
    
    func setupMoodProgressViewExample(_ progress:OMCircularProgress) {
        
        // Configure the animation duration
        progress.animationDuration  = 10
        progress.thicknessRatio     = 0.70
        
        let colorsFrom : [UIColor] = [UIColor.crayolaCeriseColor,
                                      UIColor.crayolaEucalyptusColor,
                                      UIColor.crayolaRazzleDazzleRoseColor,
                                      UIColor.crayolaElectricLimeColor]
        
        let colorsTo : [UIColor] = [UIColor.crayolaPeriwinkleColor,
                                    UIColor.crayolaCeruleanColor,
                                    UIColor.crayolaSeaSerpentColor,
                                    UIColor.crayolaFreshAirColor]
        
        let strings : [String] = ["Angry","Shocked","Cool","Crying"]
        
        let images  : [String] = ["0","1","2","3"]
        
        let stepAngle = 𝜏 /  Double(strings.count)
        
        let centerColor = UIColor(white:0, alpha: 0.8)
        
        let fontCourier = UIFont(name:"Courier", size:CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 30 : 15))
        
        for i in 0 ..< strings.count {
            
            // Create and configure the step
            
            let theStep:OMCPStepData?
            
            // If the step exist, only update the step data
            
            if progress.dataSteps.count > i {
                theStep = progress[i]
            } else {
                theStep = progress.addStep(stepAngle, color:colorsFrom[i])
            }
            
            if let theStep = theStep {
                
                theStep.te.layer.string = strings[i]
                
                if (i == 0) {
            
                    theStep.te.layer.radiusRatio            = 0.80
                    theStep.te.layer.angleLength            = theStep.angle.length()
                    theStep.te.orientationToAngle           = true;
                    
                    theStep.te.layer.font                   = fontCourier
                    theStep.te.layer.foregroundColor        =  UIColor.white
                    theStep.te.layer.fontBackgroundColor    = UIColor.clear
                    theStep.te.layer.fontStrokeColor        = UIColor.crayolaOnyxColor
                    theStep.te.layer.fontStrokeWidth        = -3
                    theStep.te.shadow                       = false
                } else if(i == 1) {
                    theStep.te.layer.radiusRatio            = 0.40
                    theStep.te.layer.angleLength            = theStep.angle.length()
                    theStep.te.orientationToAngle           = true;
                    
                    theStep.te.layer.font                   = fontCourier
                    theStep.te.layer.foregroundColor        = UIColor.crayolaOnyxColor
                    theStep.te.layer.fontBackgroundColor    = UIColor.clear
                    theStep.te.layer.fontStrokeColor        = UIColor.white
                    theStep.te.layer.fontStrokeWidth        = -3
                    theStep.te.shadow                       = false
                } else if(i == 2) {
                    theStep.te.layer.radiusRatio            = 0.80
                    theStep.te.layer.angleLength                  = theStep.angle.length()
                    theStep.te.orientationToAngle           = true;
                    theStep.te.layer.font                   = fontCourier
                    theStep.te.layer.foregroundColor        = UIColor.white
                    theStep.te.layer.fontBackgroundColor    = UIColor.clear
                    theStep.te.layer.fontStrokeColor        =  UIColor.crayolaOnyxColor
                    theStep.te.layer.fontStrokeWidth        = -3
                    theStep.te.shadow                       = false
                } else {
                    theStep.te.layer.font                   = fontCourier
                    theStep.te.layer.foregroundColor        =  UIColor.crayolaOnyxColor
                    theStep.te.layer.fontBackgroundColor    = UIColor.clear
                    theStep.te.layer.fontStrokeColor        = UIColor.white
                    theStep.te.layer.fontStrokeWidth        = -3
                    
                    theStep.te.layer.radiusRatio            = 0.40
                    theStep.te.layer.angleLength            = theStep.angle.length()
                    theStep.te.orientationToAngle           = true
                    theStep.te.shadow                       = false
                }
                
                // the images
                theStep.ie.layer.image = UIImage(named: images[i])
                //theStep.ie.orientationToAngle = true
                theStep.ie.radiusPosition = .middle
                
                // configure the gradient
                let gradient       = OMShadingGradientLayer(type:.axial)
                
                gradient.function  = .exponential
                gradient.frame     = progress.bounds
                gradient.colors    = [colorsFrom[i],centerColor,colorsTo[i]]
                
                let points =  OMGradientLayer.pointsFromNormalizedAngle(theStep.angle.norm())
                
                // axial gradient
                gradient.startPoint = points.0
                gradient.endPoint   = points.1
                
                // mask it
                theStep.maskLayer   = gradient
                theStep.borderRatio = 0.025
                theStep.border.strokeColor = UIColor(white:0.75,alpha: 1.0).cgColor
                theStep.borderShadow = false
            }
        }
        
        // image center
        progress.image.image = UIImage(named: "6")
    }
    
    // MARK: Clock example
    
    // Update the clock layers radius
    func updateClockRadius() {
        self.progressViewClockMinutes.radius = 0.66
        self.progressViewClockSeconds.radius = 0.33
    }
    
    
    func setupClockHours(_ progress:OMCircularProgress) {
        
        progress.enableAnimations = false
        progress.thicknessRatio   = 0.33   // 33.3 %
        progress.options          = [];
        
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
        
        let clockAngle = 𝜏 / Double(romanNumbers.count)
        
        let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 22 : 11
        let font =  UIFont(name:"HelveticaNeue", size:CGFloat(fontSize))
        
        for i in 0 ..< romanNumbers.count  {
            
            // Create the step.
            
            if let step = progress.addStep( clockAngle, color:color ){
                
                // Configure the step
                
                step.te.layer.string                 = romanNumbers[i]
                step.te.layer.font                   = font
                step.te.layer.foregroundColor        = UIColor.black
                step.te.layer.fontBackgroundColor    = UIColor.clear
                step.te.layer.fontStrokeColor        = UIColor.white
                step.te.layer.fontStrokeWidth        = -4
                
                step.te.radiusPosition                = .middle
                step.te.orientationToAngle            = true
                step.te.anglePosition                 = .end
                
                // configure the gradient
                let gradient       = OMShadingGradientLayer(type:.radial)
                
                
                gradient.function  = .linear
                gradient.frame     = progress.bounds
                
                gradient.colors    = [color.darkerColor(percent: 0.65),
                                      color.lighterColor(percent:  0.81),
                                      color.darkerColor(percent: 0.35)]
                
                gradient.startRadius   = progress.innerRadius / minRadius(progress.bounds.size)
                gradient.endRadius     = progress.outerRadius  / minRadius(progress.bounds.size)
                
                // Mask it
                step.maskLayer      = gradient
                
                step.well.strokeColor  = color.cgColor
            }
        }
    }
    
    func setupClockSeconds(_ progress:OMCircularProgress)
    {
        // Configure the animation
        
        progress.enableAnimations   = false
        progress.thicknessRatio     = 1.0      // 100%
        progress.options            = [];
        
        let minutesPerHour  = 60
        let quartersPerHour = 4
        let quarter         = 60 / quartersPerHour
        
        let color =   UIColor.crayolaQuickSilverColor
        
        let clockAngle = 𝜏 / Double(minutesPerHour)
        
        let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 16 : 8
        
        let fontMenlo = UIFont(name:"Menlo", size:CGFloat(fontSize))
        
        for i in 0 ..< minutesPerHour   {
            
            // Create the step.
            
            let theStep:OMCPStepData?
            
            if progress.dataSteps.count > i {
                theStep = progress[i]
            } else {
                theStep = progress.addStep(clockAngle, color:color)
            }
            
            if let step = theStep {
                
                // Configure the quarter
                
                if ((i % quarter) == 0) {
                    
                    step.te.layer.string                 = "\(i)"
                    step.te.layer.font                   = fontMenlo
                    
                    step.te.layer.foregroundColor        = UIColor.black
                    step.te.layer.fontBackgroundColor    = UIColor.clear
                    step.te.layer.fontStrokeColor        = UIColor.white
                    step.te.layer.fontStrokeWidth        = -2
                    
                    step.te.radiusPosition               = .middle
                    step.te.orientationToAngle           = true
                    step.te.anglePosition                = .end
                }
                
                // configure the gradient
                let gradient       = OMShadingGradientLayer(type:.radial)
                
                gradient.function  = .linear
                gradient.frame     = progress.bounds
                gradient.colors    = [color.darkerColor(percent: 0.65),
                                      color.lighterColor(percent: 0.81),
                                      color.darkerColor(percent: 0.35)]
                
                
                gradient.startRadius   = progress.innerRadius  / minRadius(progress.bounds.size)
                gradient.endRadius     = progress.outerRadius  / minRadius(progress.bounds.size)
                
                // mask it
                step.maskLayer        = gradient
            }
        }
    }
    
    
    func setupClockMinute(_ progress:OMCircularProgress)
    {
        // Configure the animation
        progress.enableAnimations      = false
        progress.thicknessRatio        = 0.5    // 50%
        progress.options               = [];
        
        let minutesPerHour  = 60
        
        let color =  UIColor.crayolaQuickSilverColor
        
        let clockAngle = 𝜏 /  Double(minutesPerHour)
        
        let fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 18 : 9
        
        let fontMenlo = UIFont(name:"Menlo", size:CGFloat(fontSize))
        
        for i in 0 ..< minutesPerHour {
            
            // Create one step for each minute
            
            let theStep:OMCPStepData?
            
            if progress.dataSteps.count > i {
                theStep = progress[i]
            } else {
                theStep = progress.addStep(clockAngle, color:color)
            }
            
            if let step = theStep {
                
                if((i % 5) == 0) {
                    
                    // Configure the text layer
                    
                    step.te.layer.string                 = "\(i)"
                    step.te.layer.font                   = fontMenlo
                    step.te.layer.foregroundColor        = UIColor.black
                    step.te.layer.fontBackgroundColor    = UIColor.clear
                    step.te.layer.fontStrokeColor        = UIColor.white
                    step.te.layer.fontStrokeWidth        = -3
                    
                    step.te.radiusPosition                = .middle
                    step.te.orientationToAngle            = true
                    step.te.anglePosition                 = .end
                }
                
                // Configure the radial gradient
                let gradient       = OMShadingGradientLayer(type:.radial)
                
                gradient.function  = .linear
                gradient.frame     = progress.bounds
                
                gradient.colors    = [color.darkerColor(percent: 0.65),
                                      color.lighterColor(percent:  0.81),
                                      color.darkerColor(percent: 0.35)]
                
                gradient.startRadius  = progress.innerRadius  / minRadius(progress.bounds.size)
                gradient.endRadius    = progress.outerRadius / minRadius(progress.bounds.size)
                
                // mask it
                step.maskLayer        = gradient
            }
        }
    }
    
    func setupClock() {
        updateClockRadius()
        setupClockHours(self.progressViewClockHours)
        setupClockMinute(self.progressViewClockMinutes)
        setupClockSeconds(self.progressViewClockSeconds)
    }
}

