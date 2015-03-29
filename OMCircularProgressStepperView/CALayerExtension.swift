//
//  CALayerExtension.swift
//
//  Created by Jorge Ouahbi on 6/3/15.
//  Copyright (c) 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit


/// https://developer.apple.com/library/mac/qa/qa1673/_index.html


/*
// Time warp.
CFTimeInterval currentTime = CACurrentMediaTime();
CFTimeInterval currentTimeInSuperLayer = [self.layer convertTime:currentTime fromLayer:nil];
A.beginTime = currentTimeInSuperLayer + 5; // Delay the appearance of A.
CFTimeInterval currentTimeInLayer = [A convertTime:currentTimeInSuperLayer fromLayer:self.layer];
CFTimeInterval addTime = currentTimeInLayer;
group.beginTime = addTime + 3; // Delay the animatin group.
*/
extension CALayer {
    
    func pause()
    {
        let pausedTime  = self.convertTime(CACurrentMediaTime(),fromLayer:nil);
        self.speed      = 0.0;
        self.timeOffset = pausedTime;
    }
    
    func resume()
    {
        let pausedTime = self.timeOffset;
        self.speed     = 1.0;
        self.timeOffset = 0.0;
        self.beginTime  = 0.0;
        let timeSincePause = self.convertTime(CACurrentMediaTime(), fromLayer:nil) - pausedTime;
        self.beginTime = timeSincePause;
    }
}
