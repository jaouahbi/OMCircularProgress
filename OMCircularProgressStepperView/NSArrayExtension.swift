//
//  NSArrayExtension.swift
//  ExampleSwift
//
//  Created by Jorge Ouahbi on 11/3/15.
//  Copyright (c) 2015 Jorge Ouahbi. All rights reserved.
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
