//
//  StringExtension.swift
//  Test
//
//  Created by Jorge on 21/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import Foundation

extension String
{
    static func random(len : Int) -> String? {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++) {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString as String
    }
}
