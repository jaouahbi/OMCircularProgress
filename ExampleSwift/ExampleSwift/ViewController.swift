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
        progressView.roundedHead    = true
        progressView.startAngle     = -90.degreesToRadians()
        
        let step = OMCircle.RadiansInCircle / 3
        
        let color1 = UIColor.redColor()
        let color2 = UIColor.blueColor()
        let color3 = UIColor.greenColor()
        
        progressView.addProgressStepWithAngle(step,color:color1,image:UIImage(named: "1"))
        
        progressView.addProgressStepWithAngle(step,color:color2,image:UIImage(named: "2"))
        
        progressView.addProgressStepWithAngle(step,color:color3,image:UIImage(named: "3"))
        
        progressView.image = UIImage(named: "center")

        
        var timer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self,
            selector: Selector("timerProc"),
            userInfo: nil,
            repeats: false)
    }

    
    func timerProc()
    {
        self.progressView.progress = 2.1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

