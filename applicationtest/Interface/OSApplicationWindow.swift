//
//  OSApplicationWindow.swift
//  applicationtest
//
//  Created by Xue Yu on 5/24/18.
//  Copyright © 2018 XueYu. All rights reserved.
//


import UIKit

protocol OSApplicationWindowDelegate {
    
    /// Delegate function called when window is about to be dragged.
    ///
    /// -Parameters:
    ///   - applicationWindow: The current application window.
    ///   - container: The application's view
    func applicationWindow(_ applicationWindow: OSApplicationWindow, willStartDraggingContainer container: UIView)
    
    /// Delegate function called when window has finished dragging.
    ///
    /// -Parameters:
    ///   - applicationWindow: The current application window.
    ///   - container: The application's view
    func applicationWindow(_ applicationWindow: OSApplicationWindow, didFinishDraggingContainer container: UIView)
    
    
    /// Delegate function called when user taps the panel of the OSApplicationWindow.
    ///
    /// -Parameters:
    ///   - applicationWindow: The current application window.
    ///   - panel: The window panel view instance that was tapped.
    ///   - point: The location of the tap.
    func applicationWindow(_ applicationWindow: OSApplicationWindow, didTapWindowPanel panel: WindowPanel, atPoint point: CGPoint)
    
    
    /// Delegate function called when user clicks the "close" button in the panel.
    ///
    /// -Parameters:
    ///   - applicationWindow: The current application window.
    ///   - panel: The window panel view instance that was tapped.
    func applicationWindow(_ applicationWindow: OSApplicationWindow, didCloseWindowWithPanel panel: WindowPanel)
    
    /// Delegate function called after user has finished dragging. not that `point` parameter is an `inout`. This is to allow the class which conforms to this delegate the point to modify the point incase the point that was given isn't good.
    ///
    /// - Parameters:
    ///   - applicationWindow: The current application window.
    ///   - point: The panel which the user dragged with.
    /// - Returns: return true to allow the movement of the window to the point, and false to ignore the movement.
    func applicationWindow(_ applicationWindow: OSApplicationWindow, canMoveToPoint point: inout CGPoint) -> Bool
    
}

class OSApplicationWindow: UIView {
    
    private var lastLocation = CGPoint.zero
    
//    var windowOrigin: MacAppDesktopView?
    
    var delegate: OSApplicationWindowDelegate
    
    
    var dataSource: MacApp
    
    var container: UIView
    
    var windowTitle: String?
    
    var containerSize: CGSize {
        return dataSource.sizeForWindow()
    }
    
    
    var tabBar: WindowPanel
    
    var transitionWindowFrame: MovingWindow
    
    init(delegate: OSApplicationWindowDelegate, dataSource: MacApp) {
        self.delegate = delegate
        self.dataSource = dataSource
        self.tabBar = WindowPanel()
        self.container = UIView()
        self.transitionWindowFrame = MovingWindow()
        super.init(frame: .zero)
        
        
        backgroundColor = .white
        tabBar.style = dataSource.contentMode
        tabBar.delegate = self
        addSubview(tabBar)
        container.backgroundColor = .clear
        addSubview(container)
        windowTitle = dataSource.windowTitle
        tabBar.title = windowTitle
        transitionWindowFrame.isHidden = true
        transitionWindowFrame.backgroundColor = .clear
        addSubview(transitionWindowFrame)
        
        setup()
    }
    
    
    func setup() {
        
        // add gestures to tabBar(windowPanel), thus we can drag
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        tabBar.addGestureRecognizer(gestureRecognizer)
        
        let tapGesutre = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tabBar.addGestureRecognizer(tapGesutre)
    
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        delegate.applicationWindow(self, didTapWindowPanel: tabBar, atPoint: sender.location(in: tabBar))
    }
    
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        
        print("handle pan?")
        
        if dataSource.shouldDragApplication == false {
            return
        }
        
        let translation = sender.translation(in: self.superview!)
        
        switch sender.state {
        case .began:
            transitionWindowFrame.isHidden = false
            transitionWindowFrame.frame = CGRect(origin: .zero, size: bounds.size)
            transitionWindowFrame.lastLocation = transitionWindowFrame.center
            delegate.applicationWindow(self, willStartDraggingContainer: container)
            print("will start drag in OSApplicationWindow")
            dataSource.macApp(self, willStartDraggingContainer: container)
        case .ended:
            transitionWindowFrame.isHidden = true
            var point = convert(transitionWindowFrame.center, to: superview!)
            if delegate.applicationWindow(self, canMoveToPoint: &point) {
                self.center = point
            }
            
            delegate.applicationWindow(self, didFinishDraggingContainer: container)
            dataSource.macApp(self, didFinishDraggingContainer: container)
            return
        default:
            break
        }
        
        let point = CGPoint(x: transitionWindowFrame.lastLocation.x + translation.x, y: transitionWindowFrame.lastLocation.y + translation.y)
        transitionWindowFrame.layer.shadowOpacity = 0
        transitionWindowFrame.center = point
    }
    

    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 5
        layer.cornerRadius = 2
        
        transitionWindowFrame.bounds = CGRect(origin: .zero, size: bounds.size)
        frame.size = CGSize(width: containerSize.width , height: containerSize.height + 20.0)
        tabBar.frame = CGRect(x: 0, y: 0, width: containerSize.width, height: 20)
        container.frame = CGRect(x: 0, y: tabBar.bounds.size.height, width: containerSize.width, height: containerSize.height)
        
    }
    
    override func didMoveToSuperview() {
        tabBar.frame = CGRect(x: 0, y: 0, width: containerSize.width, height: 20)
        tabBar.setNeedsLayout()
        container.frame = CGRect(x: 0, y: tabBar.bounds.size.height, width: containerSize.width, height: containerSize.height)
        frame.size = CGSize(width: containerSize.width, height: containerSize.height + 20)
        
        if let view = dataSource.container {
            view.frame = container.bounds
            container.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
            view.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastLocation = self.center
        super.touchesBegan(touches, with: event)
    }
    
    func close()  {
        self.dataSource.willTerminateApplication()
        self.delegate.applicationWindow(self, didCloseWindowWithPanel: tabBar)
        self.removeFromSuperview()
    }
    
    
}

class MovingWindow: UIView {
    
    var lastLocation = CGPoint.zero
    
    var borderColor = UIColor.gray
    
    
    override func draw(_ rect: CGRect) {
        borderColor.setStroke()
        
        let path = UIBezierPath(rect: rect)
        path.lineWidth = 4
        path.stroke()
    }
}


extension OSApplicationWindow: WindowPanelDelegate {
    func didSelectCloseMenu(_ windowPanel: WindowPanel, panelButton button: PanelButton) {
        self.dataSource.willTerminateApplication()
        self.delegate.applicationWindow(self, didCloseWindowWithPanel: windowPanel)
        self.removeFromSuperview()
    }
}
