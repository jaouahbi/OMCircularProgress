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
//  CALayerExtension.swift
//
//  Created by Jorge Ouahbi on 6/3/15.
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
