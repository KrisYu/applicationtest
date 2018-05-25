//
//  PanelButton.swift
//  faceview
//
//  Created by Xue Yu on 5/23/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit

class PanelButton: UIButton {


    override func draw(_ rect: CGRect) {
        UIColor.black.setStroke()
        innerRectPath().stroke()
    }
    
    func innerRectPath() -> UIBezierPath {
        let lineWidth : CGFloat = 1
        let innerRect = UIBezierPath(rect: CGRect(x: bounds.origin.x + lineWidth,
                                                  y: bounds.origin.y + lineWidth,
                                                  width: bounds.width - lineWidth * 2,
                                                  height: bounds.height - lineWidth * 2))
        innerRect.lineWidth = lineWidth
        return innerRect
    }

}
