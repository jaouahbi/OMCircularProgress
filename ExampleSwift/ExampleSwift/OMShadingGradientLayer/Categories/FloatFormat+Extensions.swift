//
//  CGFloat+Extensions.swift
//
//  Created by Jorge Ouahbi on 19/8/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//
// v1.0

import UIKit


extension CGFloat {
    func format(_ short:Bool)->String {
        if(short){
            return String(format: "%.1f", self)
        }else{
            return String(format: "%.6f", self)
        }
    }
}

extension Float {
    func format(_ short:Bool)->String {
        return CGFloat(self).format(short)
    }
}
