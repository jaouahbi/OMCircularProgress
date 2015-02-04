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
        
        progressView.thicknessRatio = 0.08
        progressView.roundedHead    = true
        progressView.startAngle     = Angular.degreesToRadians(-90);
        
        let step = Circle.RadiansInCircle / 3.0
        
        let color1 = UIColor.redColor()
        let color2 = UIColor.blueColor()
        let color3 = UIColor.greenColor()
        
        progressView.addProgressStepWithAngle(step,color:color1,image:UIImage(named: "image_1_color"))
        
        progressView.addProgressStepWithAngle(step,color:color2,image:UIImage(named: "image_2_color"))
        
        progressView.addProgressStepWithAngle(step,color:color3,image:UIImage(named: "image_3_color"))
        
        progressView.image = UIImage(named: "image_color")
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self,
            selector: Selector("timerProc"),
            userInfo: nil,
            repeats: false)
    }

    
    func timerProc()
    {
        self.progressView.setProgress(3.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

