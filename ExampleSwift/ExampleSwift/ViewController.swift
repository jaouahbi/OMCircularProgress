//
//  ViewController.swift
//  ExampleSwift
//
//  Created by Jorge Ouahbi on 19/1/15.
//  Copyright (c) 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var progressView: OMCircularProgressStepperView!
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated);
        
        // blab,blab...
        //OMCircularProgressStepperView.appearance()
    
        progressView.backgroundColor = UIColor(white: 0, alpha: 1.0)
        
        // Unused
        progressView.progressViewStyle = .Stepper
        
        // Configure the gradient
        progressView.gradient     = true
        progressView.gradientType = OMGradientType.Radial
        
        
        // Configure the animation
        progressView.animation          = true;
        progressView.animationDuration  = 10

        //progressView.animation          = true;
        //progressView.animationDuration  = 10.0
        
        /// Configure the separator
        
        // Ratio of separator
        progressView.separatorRatio = 0 //0.75
        progressView.stepSeparator  = true
        
        progressView.thicknessRatio = 0.70      // 70%
        progressView.roundedHead    = false

        progressView.startAngle     = -90.degreesToRadians()
        
        // Configure the text

        //progressView.percentText    = true
        //progressView.stepText       = true
        
        // Configure the font of text
        
        progressView.fontName = "HelveticaNeue-Bold"
        progressView.fontSize = 50
        progressView.fontColor = UIColor.blackColor()
        progressView.fontBackgroundColor = UIColor.clearColor()
        progressView.fontStrokeColor = UIColor.whiteColor()
        
        // shadow
        
        //progressView.shadowOpacity = 0
        
        let colors = UIColor.rainbowColors()
      
        let stepAngle = (M_PI * 2.0) / Double(colors.count)
        
        for(var i = 0;i <  colors.count;i++) {
            
            // Create the step.
            let step = progressView.newStep( stepAngle, color:colors[i] as! UIColor)
            
            // Configure the step

            step.text = "\(i)"
            step.textAlign = .AlignMid
            
            if(i%2==0)
            {
                step.image  = UIImage(named: "1")
            }
            else if(i%3==0)
            {
                step.image  = UIImage(named: "2")
            }
            else{
                step.image  = UIImage(named: "3")
            }
            
            step.imageAlign = .AlignBorder
            step.imageRotate = true
        }
        
//        
        progressView.image = UIImage(named: "center")
        
//        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
//        
//        dispatch_after(time, dispatch_get_main_queue()) {
//            self.progressView.progress =  OMCompleteProgress
//        }
        
        
//        let timer = NSTimer.scheduledTimerWithTimeInterval(1,
//            target: self,
//            selector: Selector("timerProc"),
//            userInfo:nil,
//            repeats: true)

        self.progressView.progress = OMCompleteProgress // Double(colors.count - 2) //
        
    }
    
//    func timerProc()
//    {
//        self.progressView.progress--
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
          }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

