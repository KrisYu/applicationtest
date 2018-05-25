//
//  SystemSettings.swift
//  faceview
//
//  Created by Xue Yu on 5/23/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit

struct SystemSettings {
    
    static var normalSizeFont : UIFont = {
        var font = UIFont(name: "Menlo-Regular", size: 13)!
        return font
    }()
    
    static var notePadFont: UIFont = {
        var font = UIFont(name: "Menlo-Regular", size: 10)!
        return font
    }()

}

