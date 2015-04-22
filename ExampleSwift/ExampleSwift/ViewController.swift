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
    
    @IBOutlet weak var progressView1: OMCircularProgressView!
    @IBOutlet weak var progressView2: OMCircularProgressView!
    
    @IBOutlet weak var progressView3: OMCircularProgressView!
    @IBOutlet weak var progressView4: OMCircularProgressView!
    
    @IBOutlet weak var progressView5: OMCircularProgressView!
    @IBOutlet weak var progressView6: OMCircularProgressView!
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated);
        
        // TODO:
        // OMCircularProgressView.appearance()
        
        
        self.progressView1.layer.name = "1"
        self.progressView2.layer.name = "2"
        self.progressView3.layer.name = "3"
        self.progressView4.layer.name = "4"
        self.progressView5.layer.name = "5"
        self.progressView6.layer.name = "6"
       
        
        //
        // Setup the progressView examples
        //
        
        self.setup1(self.progressView1);
        self.setupClock(self.progressView2)
        self.setup3(self.progressView3);
        self.setupColorsFull(self.progressView4);
        self.setup5(self.progressView5);
        self.setup6(self.progressView6);
    
        
//        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) * 1)
//        
//        dispatch_after(time, dispatch_get_main_queue()) {
//        }
        
    }
    
    
    func setupColorsFull(theProgressView:OMCircularProgressView)
    {
        theProgressView.progressViewStyle = .SequentialProgress
        
        // Configure the animation
        
        theProgressView.animationDuration  = 2.0
        
        
        /// Configure the separator
        
        // Ratio
        
        theProgressView.stepSeparator  = false
        
        theProgressView.separatorRatio      = 0 //0.75
        theProgressView.separatorIsTheImage = true
        
        theProgressView.thicknessRatio = 1.0      // 70%
        theProgressView.roundedHead    = false

        let colors : [UIColor] = UIColor.rainbowColors(4) as! [UIColor]
        
        let stepAngle = (M_PI * 2.0) / Double(colors.count)
        
        for(var i = 0;i < colors.count ;i++) {
            
            /// Create the step.
            
            let theStep = theProgressView.newStep( stepAngle, color:colors[i] as UIColor)
            
            theStep.gradientType = .Radial
          
        }

        theProgressView.progress = OMCompleteProgress
    }
    
    
    func setup5(theProgressView:OMCircularProgressView)
    {
        theProgressView.progressViewStyle = .SequentialProgress
        
        
        // Configure the animation
        theProgressView.animation          = true;
        theProgressView.animationDuration  = 10
        
        /// Configure the separation
        
        // Ratio
        
        theProgressView.stepSeparator  = true
        theProgressView.separatorRatio   = 0.50
        
        theProgressView.thicknessRatio = 0.5      // 70%
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
        
        let colors : [UIColor] = UIColor.rainbowColors(2) as! [UIColor]
        
        let stepAngle = (M_PI * 2.0) / Double(colors.count)
        
        for(var i = 0;i < colors.count ;i++) {
            
            // Create the step.
            
            theProgressView.newStep( stepAngle, color:colors[i] as UIColor)
            
        }
        
        theProgressView.progress = OMCompleteProgress
    }
    
    
    func setup6(theoProgressView:OMCircularProgressView)
    {
        // TODO:
        theoProgressView.progressViewStyle = .SequentialProgress
        
        // Configure the animation
        theoProgressView.animation          = true;
        theoProgressView.animationDuration  = 10
        
        /// Configure the separation
        
        // Ratio
        
        theoProgressView.stepSeparator  = true
        theoProgressView.separatorRatio  = 0.1
        
        theoProgressView.thicknessRatio = 0.7      // 70%
    
        let colors : [UIColor] = UIColor.rainbowColors(25) as! [UIColor]
        
        let stepAngle = (M_PI * 2.0) / Double(colors.count)
        
        for(var i = 0;i < colors.count ;i++) {
            
            // Create the step.
            
            theoProgressView.newStep( stepAngle, color:colors[i] as UIColor)
        }
        
        theoProgressView.progress = OMCompleteProgress
    }
    
    
    func setup3(theProgressView:OMCircularProgressView)
    {
        theProgressView.progressViewStyle = .SequentialProgress
        
        // Configure the animation
        
        theProgressView.animationDuration  = 4
        
        /// Configure the separator
        
        // Ratio
        
        theProgressView.stepSeparator       = true
        
        
        theProgressView.thicknessRatio      = 0.4      // 70%
        theProgressView.roundedHead         = false
        
        
        let colors : [UIColor] = UIColor.rainbowColors(16) as! [UIColor]
        
        let stepAngle = (M_PI * 2.0) / Double(colors.count)
        
        for(var i = 0;i < colors.count ;i++) {
            
            let step = theProgressView.newStep( stepAngle, color:colors[i] as UIColor)
            
            // Configure the step
            
            step.text                   = "\(i)"
            step.textAlign              = .AlignMid
            step.textOrientationToAngle = true
            
            step.fontName               = "HelveticaNeue-Light"
            step.fontSize               = 9
            step.fontColor              = UIColor.blackColor()
            step.fontBackgroundColor    = UIColor.clearColor()
            step.fontStrokeColor        = UIColor.whiteColor()
            
            if  (i % 2 == 0)  {
                step.image  = UIImage(named: "0")!.addOutterShadow()
            } else if(i % 3 == 0) {
                step.image  = UIImage(named: "1")!.addOutterShadow()
            } else {
                step.image  = UIImage(named: "2")!.addOutterShadow()
            }
            
            step.imageAlign              = .AlignBorder
            step.imageOrientationToAngle = true
        }
        
        theProgressView.image = UIImage(named: "center")!.addOutterShadow()
        
        theProgressView.progress = OMCompleteProgress
    }
    
    func setup1(theoProgressView:OMCircularProgressView)
    {
        
        theoProgressView.progressViewStyle = .SequentialProgress
    
        // Configure the animation duration
        theoProgressView.animationDuration  = 10
        
        /// Configure the separator
        
        // Ratio
        
        theoProgressView.stepSeparator       = true
        theoProgressView.separatorRatio      = 0
        theoProgressView.separatorIsTheImage = true
        
        
        
        theoProgressView.thicknessRatio     = 0.70
        theoProgressView.roundedHead        = false
        theoProgressView.startAngle         = -90.degreesToRadians()
        
        
        let colors : [UIColor] = [UIColor.redColor(),UIColor.yellowColor(),UIColor.greenColor()]
        
        let strings : [String] = ["Apathetic","Normal","Happy"]
        
        let stepAngle = (M_PI * 2.0) / Double(strings.count)
        
        for(var i = 0;i < strings.count ;i++) {
            
            /// Create the step.
            
            let step = theoProgressView.newStep( stepAngle, color:colors[i] as UIColor)
            
            /// Configure the step
            
            // step text
            
            step.text                   = strings[i]
            step.textAlign              = .AlignMid
            step.textOrientationToAngle = true
            
            step.fontName               = "HelveticaNeue"
            step.fontSize               = 12
            step.fontColor              = UIColor.blackColor()
            step.fontBackgroundColor    = UIColor.clearColor()
            step.fontStrokeColor        = UIColor.whiteColor()
            
            // step image
            step.image                   = UIImage(named: String("\(i)"))!.addOutterShadow()
            step.imageAlign              = .AlignBorder
            step.imageOrientationToAngle = true

            
            // Configure the gradient
            step.gradientType            = OMGradientType.Radial
            
        }
        
        // image center
        
        theoProgressView.image = UIImage(named: "center")!.addOutterShadow()
        
        
        theoProgressView.progress = OMCompleteProgress
    }
    
    func setupClock(theProgressView:OMCircularProgressView)
    {
        //
        // Clock
        //

        
        // Unused
        theProgressView.progressViewStyle = .SequentialProgress
    
        
        // Configure the animation
        
        theProgressView.animationDuration  = 6
        
        /// Configure the separator
        
        // Ratio
        
        theProgressView.stepSeparator  = true
        
        theProgressView.separatorRatio = 0.1
        
        theProgressView.thicknessRatio = 0.1      // 10%
        theProgressView.roundedHead    = false
        
        theProgressView.startAngle     = -90.degreesToRadians()
        //
        //
        
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
        
        let clockColors  = UIColor.rainbowColors(romanNumbers.count)
        
        let clockAngle = (M_PI * 2.0) / Double(romanNumbers.count)
        
        for(var i = 0;i < romanNumbers.count ;i++) {
            
            // Create the step.
            
            let step = theProgressView.newStep( clockAngle, color:clockColors[i] as! UIColor)
            
            // Configure the step
            
            step.text                   = romanNumbers[i]
            step.fontName               = "HelveticaNeue"
            step.fontSize               = 10
            step.fontColor              = UIColor.blackColor()
            step.fontBackgroundColor    = UIColor.clearColor()
            step.fontStrokeColor        = UIColor.whiteColor()
            
            
            step.textAlign              = .AlignBorder
            step.textOrientationToAngle = true
            step.textAngleAlign         = .AngleEnd
            
        }
        
        let calendar = NSCalendar(identifier:NSCalendarIdentifierGregorian);
        var hour = calendar!.components(.CalendarUnitHour, fromDate:NSDate()).hour
        
        if(hour > 12) {
            hour -= 12
        }
        
        theProgressView.progress = Double(hour)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

