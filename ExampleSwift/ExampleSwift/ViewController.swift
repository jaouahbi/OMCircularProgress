//
//  ViewController.swift
//  ExampleSwift
//
//  Created by Jorge Ouahbi on 19/1/15.
//  Copyright (c) 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var progressView: OMCircularProgressStepperView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        progressView.thicknessRatio = 0.05
        progressView.roundedHead    = false
        progressView.stepSeparator  = true
        progressView.startAngle     = -90.degreesToRadians()
        
        // text
        
        progressView.showPercent    = true
        
        // font of text
        
        progressView.fontName = "Helvetica"
        progressView.fontSize = 40
        progressView.fontColor = UIColor.redColor()
        
        let step = (M_PI * 2.0) / 4
        
        let color1 = UIColor.redColor()
        let color2 = UIColor.blueColor()
        let color3 = UIColor.greenColor()
        let color4 = UIColor.yellowColor()
        
        progressView.addProgressStepWithAngle(step,color:color1,image:UIImage(named: "1"))
        
        progressView.addProgressStepWithAngle(step,color:color2,image:UIImage(named: "2"))
        
        progressView.addProgressStepWithAngle(step,color:color3,image:UIImage(named: "3"))
        
        progressView.addProgressStepWithAngle(step,color:color4,image:UIImage(named: "center"))
        
        //progressView.image = UIImage(named: "center")
        
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            
            self.progressView.progress = 3.1
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

