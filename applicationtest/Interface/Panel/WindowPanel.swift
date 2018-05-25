//
//  WindowPanel.swift
//  faceview
//
//  Created by Xue Yu on 5/23/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit

protocol WindowPanelDelegate {
    func didSelectCloseMenu(_ windowPanel: WindowPanel, panelButton button: PanelButton)
}


class WindowPanel: UIView {
    
    var title: String?{
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
            setNeedsLayout()
        }
    }
    
    var titleLabel: UILabel!
    
    var closeButton: PanelButton!
    
    var delegate: WindowPanelDelegate?
    
    var style: ContentStyle = .default{
        didSet {
            requestContentStyleUpdate()
        }
    }
    
    var drawLines: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = style == .default ? UIColor.black : UIColor.clear
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        titleLabel = UILabel()
        titleLabel.textColor = style == .default ? .black : .white
        titleLabel.backgroundColor = style == .default ? .white : .black
        titleLabel.text = "Title Label"
        titleLabel.textAlignment = .center
        titleLabel.font = SystemSettings.normalSizeFont
        addSubview(titleLabel)
        
        closeButton = PanelButton(type: .custom)
        closeButton.addTarget(self, action: #selector(buttonResponder(sender:)), for: .touchUpInside)
        closeButton.setBackgroundImage(UIImage(color: style == .default ? .black : .white), for: .highlighted)
        closeButton.backgroundColor = style == .default ? .white : .black
        addSubview(closeButton)
    }
    
    
    func requestContentStyleUpdate() {
        
        titleLabel.textColor = style == .default ? .black : .white
        titleLabel.backgroundColor = style == .default ? .white : .black
        closeButton.setBackgroundImage(UIImage(color: style == .default ? .black : .white), for: .highlighted)
        closeButton.backgroundColor = style == .default ? .white : .black
        backgroundColor = style == .default ? UIColor.clear : UIColor.black
        
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        let buttonSize :CGFloat = 10.0
        closeButton.frame = CGRect(x: 10, y: (bounds.height - buttonSize)/2, width: buttonSize, height: buttonSize)
        closeButton.layer.borderColor = UIColor.white.cgColor
        closeButton.layer.borderWidth = 1
        
        let titleWidth = Utils.widthForView(title!, font: titleLabel.font, height: bounds.size.height * 0.9) + 10
        titleLabel.frame = CGRect(x: (bounds.width - titleWidth) / 2, y: 0, width: titleWidth, height: bounds.size.height * 0.9)
    }
    
    override func draw(_ rect: CGRect) {
        
        if style == .default {
            UIColor.black.set()
            if drawLines {
                linesSurroundTitle().forEach{ $0.stroke() }
            }
        }
    }
    
    @objc func buttonResponder(sender: PanelButton) {
        print("close button tapped")
        delegate?.didSelectCloseMenu(self, panelButton: sender)
    }
    
    func linesSurroundTitle() -> [UIBezierPath] {
        
        var arrayOfLines = [UIBezierPath]()
        
        let space: CGFloat = 2
        let sideSpace: CGFloat = 1
        let startingPoint: CGFloat = (bounds.height - space * 5) / 2
        
        for i in 0...5 {
            let path = UIBezierPath()
            let posY = CGFloat(i) * space + startingPoint
            let startX = bounds.minX + sideSpace
            let endX = bounds.maxX - sideSpace
            
            path.move(to: CGPoint(x: startX, y: posY))
            path.addLine(to: CGPoint(x: endX, y: posY))
            path.lineWidth = 1
            
            arrayOfLines.append(path)
        }
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        path.lineWidth = 1
        arrayOfLines.append(path)
        
        return arrayOfLines
    }
}


