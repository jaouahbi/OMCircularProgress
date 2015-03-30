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
//  NSArrayExtension.swift
//
//  Created by Jorge Ouahbi on 11/3/15.
//

import UIKit


extension NSArray
{
    func shift(forward:Bool = true) -> NSArray {
        
        // Moves the last / first item in the array to the front / back
        // shifting all the other elements.
        
        let mutable: AnyObject = self.mutableCopy()
        
        if(forward == true)
        {
            if let last: AnyObject = self.lastObject {
                mutable.insertObject(last, atIndex:0)
                mutable.removeLastObject()
            }
        }
        else
        {
            if let first: AnyObject = self.firstObject {
                mutable.addObject(first)
                mutable.removeObjectAtIndex(0)
            }
        }
        
        return NSArray(array: mutable as! [AnyObject]);
    }
}
