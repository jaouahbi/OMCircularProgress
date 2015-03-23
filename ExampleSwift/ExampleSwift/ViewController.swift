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
    
        // Unused
        progressView.progressViewStyle = .Stepper
        
        // Configure the gradient
        progressView.gradient     = true
        progressView.gradientType = OMGradientType.Radial
        
        
        // Configure the animation
        progressView.animation          = true;
        progressView.animationDuration  = 1

        //progressView.animation          = true;
        //progressView.animationDuration  = 10.0
        
        /// Configure the separator
        
        // Ratio of separator
        progressView.separatorRatio = 0 //0.75
        progressView.stepSeparator  = true
        
        progressView.thicknessRatio = 1      // 90%
        progressView.roundedHead    = false

        progressView.startAngle     = -90.degreesToRadians()
        
        // Configure the text

        //progressView.percentText    = true
        progressView.stepText       = true
        
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
            
            step.image      = UIImage(named: "1")
            step.imageAlign = .AlignBorder
            
        }
        
//      
        
        //let colors = [UIColor.redColor(),UIColor.blueColor(),UIColor.greenColor(),UIColor.yellowColor()]
        
//        let colors = [UIColor.redColor(),UIColor.blueColor()]
//        let step = (M_PI * 2.0) / Double(colors.count)
//        
//        
//        progressView.addProgressStepWithAngle(step,color:colors[0],image:UIImage(named: "1"))
//        
//        progressView.addProgressStepWithAngle(step,color:colors[1],image:UIImage(named: "2"))
        
//        progressView.addProgressStepWithAngle(step,color:colors[2],image:UIImage(named: "3"))
//        
//        progressView.addProgressStepWithAngle(step,color:colors[3],image:UIImage(named: "center"))
//        
//        progressView.image = UIImage(named: "center")
        
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

        self.progressView.progress = OMCompleteProgress
        
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

