//
//  MenuDropDownView.swift
//  applicationtest
//
//  Created by Xue Yu on 5/24/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit

protocol MenuDropDownDelegate {

    /// This function is called once the user clicks on one of the actions.
    ///
    /// - Parameters:
    ///   - menuDropDown: The menu dropdown view.
    ///   - index: The index that was selected.
    func menuDropDown(_ menuDropDown: MenuDropDownView, didSelectActionAtIndex index: Int)

}

class MenuDropDownView: UIView {

    /// The height for each action
    static let actionHeight: CGFloat = 20.0

    /// Left padding
    static let left_padding: CGFloat = 10.0

    /// Right padding
    static let right_padding: CGFloat = 2.0

    /// The menu that contains the action
    var action: MenuAction?

    /// The delegate that the OSToolBar confroms to.
    var delegate: MenuDropDownDelegate?

    /// The view that holds the buttons.
    var stackView: UIStackView!

    convenience init(action: MenuAction) {
        var height: CGFloat = 0
        var width: CGFloat = 0
        action.subMenus?.forEach{
            ($0.type == .action ) ? (height += MenuDropDownView.actionHeight) : (height += 1)
            let neededWidth = Utils.widthForView($0.title, font: SystemSettings.normalSizeFont, height: MenuDropDownView.actionHeight)
            width = max(width, neededWidth)
        }

        let rect = CGRect(x: 0, y: 0, width: MenuDropDownView.left_padding + width + MenuDropDownView.right_padding, height: height)
        self.init(frame:rect)
        self.action = action
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
        stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        addSubview(stackView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        stackView.frame = bounds
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 10
        layer.cornerRadius = 2
        
        if let actionMenus = action?.subMenus {
            for index in 0..<actionMenus.count {
                let action = actionMenus[index]
                let view = createObjectFor(action: action, index: index)
                
                let constraintHeight = action.type == .action ? MenuDropDownView.actionHeight : 1
                view.heightAnchor.constraint(equalToConstant: constraintHeight).isActive = true
                
                stackView.addArrangedSubview(view)
            }
        }
    }

    @objc func buttonResponder(sender: UIButton){
        print("clicked \(sender.tag)")
        delegate?.menuDropDown(self, didSelectActionAtIndex: sender.tag)
        action?.subMenus?[sender.tag].action?()
    }

    func createObjectFor(action: MenuAction, index: Int) -> UIView {
        switch action.type {
        case .action:
            let button = UIButton(type: .custom)
            button.tag = index
            button.setTitle(action.title, for: [])
            button.titleLabel?.font = SystemSettings.normalSizeFont
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(.white, for: .highlighted)
            button.setTitleColor(.lightGray, for: .disabled)
            button.setBackgroundImage(UIImage(color: .clear), for: [])
            button.setBackgroundImage(UIImage(color: .black), for: .highlighted)
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: MenuDropDownView.left_padding, bottom: 0, right: MenuDropDownView.right_padding)
            // simplify
            button.isEnabled = action.runtimeClosure != nil ? action.runtimeClosure!() : action.enabled
            button.addTarget(self, action: #selector(buttonResponder(sender:)), for: .touchUpInside)
            return button
        case .seperator:
            let seperator = UIView()
            seperator.backgroundColor = .lightGray
            return seperator
        }
    }
}
