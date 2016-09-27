//
//  Float+Extensions.swift
//
//  Created by Jorge Ouahbi on 19/8/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

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
