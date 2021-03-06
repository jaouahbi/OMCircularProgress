//
//  UIFont+Extensions.swift
//
//  Created by Jorge Ouahbi on 17/11/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

import UIKit


extension UIFont {
    func stringSize(s:String,size:CGSize) -> CGSize {
        for i in (4...32).reversed() {
            let d = [NSAttributedString.Key.font:UIFont(name:fontName, size:CGFloat(i))!]
            let sz = (s as NSString).size(withAttributes: d)
            if sz.width <= size.width && sz.height <= size.height {
                return sz
            }
        }
        return CGSize.zero
    }
    
    static func stringSize(s:String,fontName:String,size:CGSize) -> CGSize {
        for i in (4...32).reversed() {
            let d = [NSAttributedString.Key.font:UIFont(name:fontName, size:CGFloat(i))!]
            let sz = (s as NSString).size(withAttributes: d)
            if sz.width <= size.width && sz.height <= size.height {
                return sz
            }
        }
        return CGSize.zero
    }
}
