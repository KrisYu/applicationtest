//
//  OSToolBar.swift
//  applicationtest
//
//  Created by Xue Yu on 5/24/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit

protocol OSToolBarDataSource {
    
    /// The menu actions that will be displayed on the toolbar.
    ///
    /// - Parameter toolBar: The toolbar instance.
    /// - Returns: An array of MenuAction
    func menuActions(_ toolBar: OSToolBar) -> [MenuAction]
    
    
    /// The menu which displays the OS actions. (mostly applications)
    ///
    /// - Parameter toolBar: The toolbar instance.
    /// - Returns: An array of MenuAction
    func osMenuActions(_ toolBar: OSToolBar) -> [MenuAction]
    
}

class OSToolBar: UIView {
    
    
    /// The height of the tool bar
    static let height: CGFloat = 20.0
    
    /// The logo/icon that is displayed in the toolbar
    var osMenuLogo: UIImage {
        set {
            osMenuButton.setImage(newValue, for: [])
        }
        get {
            return (osMenuButton.image(for: []))!
        }
    }
    
    /// The primary menu button.
    var osMenuButton: UIButton!
    
    /// The stack that holds the other menus
    var menuStackView: UIStackView!
    
    /// The current dropdown menu that is displayed
    var currentDropDownMenu: MenuDropDownView?
    
    /// The seperator view
    var seperatorView: UIView!
    
    /// The data source which is implemented by the OSWindow
    var dataSource: OSToolBarDataSource?
    
    convenience init(inWindow window: CGRect) {
        let rect = CGRect(x: 0, y: 0, width: window.width, height: OSToolBar.height)
        self.init(frame: rect)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        backgroundColor = .white
        
        //setup os menu button
        osMenuButton = UIButton(type: .custom)
        osMenuButton.addTarget(self, action: #selector(didSelectOSMenu(sender:)), for: .touchUpInside)
//        osMenuButton.imageView?.contentMode = .scaleAspectFit
//        osMenuButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        osMenuButton.setTitle("", for: .normal)
        osMenuButton.setTitleColor(.black, for: .normal)
        addSubview(osMenuButton)
        
        //setup action menus
        menuStackView = UIStackView()
        menuStackView.axis = .horizontal
        menuStackView.alignment = .fill
        menuStackView.distribution = .fill
        menuStackView.spacing = 0
        menuStackView.isLayoutMarginsRelativeArrangement = true
        addSubview(menuStackView)
        
        seperatorView = UIView()
        seperatorView.backgroundColor = .black
        addSubview(seperatorView)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let spacing: CGFloat = 10
        osMenuButton.frame = CGRect(x: spacing, y: 0, width: 30, height: OSToolBar.height)
        menuStackView.frame.origin.x = osMenuButton.bounds.width + spacing * 2
        seperatorView.frame = CGRect(x: 0, y: frame.maxY, width: bounds.size.width, height: 1)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        let spacing: CGFloat = 10
        let size = bounds.size
        menuStackView.frame = CGRect(x: osMenuButton.bounds.width + spacing, y: 0, width: size.width - size.width/3, height: OSToolBar.height)
    }
    
    @objc func didSelectOSMenu(sender: UIButton) {
        print("choose os menu")
        showMenuDropDown(sender: sender, isPrimary: true)
    }
    
    @objc func didSelectItemMenu(sender: UIButton) {
        showMenuDropDown(sender: sender, isPrimary: false)
    }
    
    @objc func showMenuDropDown(sender: UIButton, isPrimary primary: Bool) {
        let id = sender.tag
        
        for view in menuStackView.arrangedSubviews {
            (view as! UIButton).isSelected = false
        }
        
        if let current = currentDropDownMenu {
            current.removeFromSuperview()
            if current.tag == id {
                currentDropDownMenu = nil
                return
            }
        }
        
        if primary {
            let action = MenuAction.init(title: "", action: nil, subMenus: dataSource?.osMenuActions(self))
            currentDropDownMenu = MenuDropDownView(action: action)
            currentDropDownMenu?.delegate = self
            currentDropDownMenu?.tag = id
            let senderRect = sender.convert(sender.bounds, to: self.superview)
            currentDropDownMenu?.frame.origin = senderRect.origin
            currentDropDownMenu?.frame.origin.y = currentDropDownMenu!.frame.origin.y + OSToolBar.height
            superview?.insertSubview(currentDropDownMenu!, aboveSubview: self)
        } else {
            
            if let action = dataSource?.menuActions(self)[id - 1]{
                if let _ = action.subMenus {
                    sender.isSelected = true
                    currentDropDownMenu = MenuDropDownView(action: action)
                    currentDropDownMenu?.delegate = self
                    currentDropDownMenu?.tag = id
                    let senderRect = sender.convert(sender.bounds, to: self.superview)
                    currentDropDownMenu?.frame.origin = senderRect.origin
                    currentDropDownMenu?.frame.origin.y = currentDropDownMenu!.frame.origin.y + OSToolBar.height
                    superview?.insertSubview(currentDropDownMenu!, aboveSubview: self)
                } else if let funAction = action.action {
                    funAction()
                }
            }
            
        }
    }
    
    
    /// Request from the tool bar to close all open menus.
    func requestCloseAllMenus() {
        for view in menuStackView.arrangedSubviews {
            (view as! UIButton).isSelected = false
        }
        
        if let current = currentDropDownMenu {
            current.removeFromSuperview()
            currentDropDownMenu = nil
        }
    }
    
    
    /// Request from the tool bar to refresh it's menus (if needed)
    func requestApplicationMenuUpdate() {
        if let buttonStack = self.menuStackView {
            
            // remove
            buttonStack.subviews.forEach { $0.removeFromSuperview() }
            
            // add new items
            if let actions = dataSource?.menuActions(self) {
                for i in 1...actions.count {
                    let button = createMenuButtonFrom(action: actions[i-1], index: i)
                    buttonStack.addArrangedSubview(button)
                }
            }
            
            var stackWidth: CGFloat = 0
            let spacing: CGFloat = 20
            
            for arrangedView in buttonStack.arrangedSubviews {
                let button = (arrangedView as! UIButton)
                let buttonNeededWidth = Utils.widthForView(button.title(for: [])!, font: (button.titleLabel?.font)!, height: OSToolBar.height)
                button.widthAnchor.constraint(equalToConstant: buttonNeededWidth + spacing).isActive = true
                stackWidth += buttonNeededWidth
            }
            
            buttonStack.bounds.size.width = stackWidth + CGFloat(buttonStack.arrangedSubviews.count) * spacing
            buttonStack.removeConstraints(buttonStack.constraints)
            buttonStack.layoutIfNeeded()
        }
    }
    
    
    func createMenuButtonFrom(action: MenuAction, index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.tag = index
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.setTitle(action.title, for: [])
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.setTitleColor(.white, for: .selected)
        button.setBackgroundImage(UIImage(color: .clear), for: [])
        button.setBackgroundImage(UIImage(color: .black), for: .highlighted)
        button.setBackgroundImage(UIImage(color: .black), for: .selected)
        button.addTarget(self, action: #selector(didSelectItemMenu(sender:)), for: .touchUpInside)
        button.titleLabel?.font = SystemSettings.normalSizeFont
        return button

    }
    
}

extension OSToolBar: MenuDropDownDelegate {
    func menuDropDown(_ menuDropDown: MenuDropDownView, didSelectActionAtIndex index: Int) {
        requestCloseAllMenus()
    }
    
    
}
