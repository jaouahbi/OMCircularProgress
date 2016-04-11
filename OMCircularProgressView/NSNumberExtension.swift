//
//  NSNumberExtension.swift
//  Test
//
//  Created by Jorge on 26/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit

//
//  NSNumber extension.
//

extension NSNumber {
    func format(formatStyle:CFNumberFormatterStyle,locale:CFLocale = CFLocaleCopyCurrent()) -> String! {
        let fmt = CFNumberFormatterCreate( kCFAllocatorDefault , locale,formatStyle)
        return CFNumberFormatterCreateStringWithNumber(nil,fmt,self)  as String
    }
}