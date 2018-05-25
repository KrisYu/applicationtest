//
//  OSWindow.swift
//  applicationtest
//
//  Created by Xue Yu on 5/24/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit

class OSWindowView: UIView {

    var applicationIdentifiers: [String: OSApplicationWindow] = [:]
    
    /// Other apps
    var activeApplications: [MacApp] = []

    ///
//    var desktopApplications: [DesktopApplication] = []
    
    // The finder app
    lazy var rootApplication: MacApp = { [weak self] in
        let finder = Finder()
        finder.window = self
        return finder
    }()
    
    ///
    var toolBar: OSToolBar


    init(frame: CGRect, toolbar: OSToolBar) {
        self.toolBar = toolbar
        super.init(frame: frame)
        addSubview(toolbar)
        toolbar.dataSource = self
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The applications that appear when clicking the  menu.
    lazy var osMenus: [MenuAction] = {
        var menus = [MenuAction]()
        
        menus.append(MenuAction(title: "About the Finder...",
                                action: {
                                    let newApplicationWindow = self.createApplication(from: self.rootApplication)
                                    self.loadApplication(newApplicationWindow)
        }, subMenus: nil))
        
        menus.append(MenuAction(type: .seperator))
        
        menus.append(MenuAction(title: "Alarm Clock", action: {
            let newApplicationWindow = self.createApplication(from: AlarmClock())
            self.loadApplication(newApplicationWindow)
        }, subMenus: nil))
    
        
        return menus
    }()
    
    
    /// A helper function that creates an instance of OSApplicationWindow using an instance of a MacApp. Note however that if the app exists in memory it will return it.
    func createApplication(from app: MacApp) -> OSApplicationWindow {
        let applicationWindow = OSApplicationWindow(delegate: self, dataSource: app)


        let nApp : OSApplicationWindow = applicationIdentifiers[(applicationWindow.dataSource.identifier) ?? (applicationWindow.dataSource.uniqueIdentifier)] ?? applicationWindow
        
        return nApp
    }
    
    /// Checks if application `MacApp` exists in memory.
    ///
    /// - Parameter app : The app that contains an identifier which we want to check.
    /// - Returns: true if the app exists, else false
    func doseApplicationExistInMemory(app: MacApp) -> Bool {
        if let _ = applicationIdentifiers[(app.identifier ?? app.uniqueIdentifier)] {
            return true
        } else {
            return false
        }
    }
    
    /// Load an OSApplicationWindow
    ///
    /// - Parameter app: The OSApplicationWindow which we want to load into the OSWindow.
    func loadApplication(_ app: OSApplicationWindow) {
        loadApplication(app, under: toolBar)
    }
    
    /// Load an OSApplicationWindow
    ///
    /// - Parameters:
    ///     - app: The OSApplicationWindow which we want to load into the OSWindow.
    ///     - toolbar: The toolbar which we are loading the application under.
    func loadApplication(_ app: OSApplicationWindow, under toolbar: OSToolBar) {
        let nApp = applicationIdentifiers[(app.dataSource.identifier) ?? (app.dataSource.uniqueIdentifier)] ?? app
        
        nApp.dataSource.willLaunchApplication(in: self, withApplicationWindow: app)
    
        if let identifier = app.dataSource.identifier {
            
            // check if unique id exists already
            if let applicationWindow = self.applicationIdentifiers[identifier] {
                
                // check if window is already subview
                if applicationWindow.isDescendant(of: self){
                    // bring to front
                    bringAppToFront(applicationWindow)
                    return
                } else {
                    // add subview
                    toolbar.requestCloseAllMenus()
                    addAppAsSubView(applicationWindow)
                }
            } else {
                // add application to UI and IDs
                applicationIdentifiers[identifier] = app
                toolbar.requestCloseAllMenus()
                addAppAsSubView(app)
            }
        } else {
            // add application to ui without adding unique id
            toolbar.requestCloseAllMenus()
            self.addAppAsSubView(app)
        }
        
        nApp.dataSource.didLaunchApplication(in: self, withApplicationWindow: nApp)
    }
    
    func addAppAsSubView(_ application: OSApplicationWindow) {
        insertSubview(application, belowSubview: toolBar)
        activeApplications.append(application.dataSource)
        if application.frame.origin == .zero {
            application.center = center
        }
        application.layoutIfNeeded()
    }
    
    
    func bringAppToFront(_ application: OSApplicationWindow) {
        
        let id: String = application.dataSource.uniqueIdentifier
        
        var i = 0
        for app in activeApplications {
            if app.uniqueIdentifier == id {
                activeApplications.append(activeApplications.remove(at: i))
                break
            }
            i += 1
        }
        
        bringSubview(toFront: application)
        bringSubview(toFront: toolBar)
    }
    
    
    /// The `close` function is a function that is used to terminate a certain application
    ///
    /// - Parameter app: The app which we want to terminate
    func close(app: MacApp) {
        if let nApp = applicationIdentifiers[(app.identifier ?? (app.uniqueIdentifier))] {
            nApp.close()
        }
    }
    
    /// The `add` function allow us to load desktop applications. The placement of the applications will be set automatically based on already existing applications on the desktop.
    ///
    /// - Parameter app: The app which we want to display on the desktop

 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch began")
    }
    
}


extension OSWindowView: OSApplicationWindowDelegate{
   
    func applicationWindow(_ applicationWindow: OSApplicationWindow, willStartDraggingContainer container: UIView) {
        self.toolBar.requestCloseAllMenus()
        bringAppToFront(applicationWindow)
        print("will start drag in OSApplicationWindowDelegate")
    
    }
    
    func applicationWindow(_ applicationWindow: OSApplicationWindow, didFinishDraggingContainer container: UIView) {
        
    }
    
    func applicationWindow(_ applicationWindow: OSApplicationWindow, didTapWindowPanel panel: WindowPanel, atPoint point: CGPoint) {
        self.toolBar.requestCloseAllMenus()
        bringAppToFront(applicationWindow)
        print("didTapWindowPanel \(point)")
    }
    
    func applicationWindow(_ applicationWindow: OSApplicationWindow, didCloseWindowWithPanel panel: WindowPanel) {
        
    }
    
    func applicationWindow(_ applicationWindow: OSApplicationWindow, canMoveToPoint point: inout CGPoint) -> Bool {
        let halfHeight = applicationWindow.bounds.midY
        let osHeight = self.bounds.height
        
        if point.y < OSToolBar.height + halfHeight {
            point.y = OSToolBar.height + halfHeight
            return true
        } else if point.y > osHeight + halfHeight - OSToolBar.height {
            point.y = osHeight + halfHeight - OSToolBar.height
            return true
        }
        
        return true
    }
    
    
}

extension OSWindowView: OSToolBarDataSource {
    func menuActions(_ toolBar: OSToolBar) -> [MenuAction] {
        let topApp: MacApp = rootApplication
        return topApp.menuActions!
    }
    
    func osMenuActions(_ toolBar: OSToolBar) -> [MenuAction] {
        return self.osMenus
    }
}

//extension OSWindowView: DesktopAppDelegate{
//
//    func didFinishDragging(_ appliction: DesktopApplication) {
//
//    }
//
//    func willStartDragging(_ appliction: DesktopApplication) {
//        self.toolBar.requestCloseAllMenus()
//    }
//
//    func didDoubleClick(_ application: DesktopApplication) {
//        print("double clicked")
//        self.toolBar.requestCloseAllMenus()
//
//        let applicationWindow = self.createApplication(from: application.app!)
//
//        if applicationWindow.isDescendant(of: self){
//
//            // bring it to front
//            bringAppToFront(applicationWindow)
//            return
//        }
//
//        applicationWindow.windowOrigin = application.view
//
//        // create border view
//        let transitionWindowFrame = MovingWindow()
//        transitionWindowFrame.backgroundColor = .clear
//        transitionWindowFrame.borderColor = .lightGray
//
//        let doesExist = doseApplicationExistInMemory(app: application.app!)
//
//        if doesExist {
//            transitionWindowFrame.frame = applicationWindow.frame
//        } else {
//            transitionWindowFrame.frame = CGRect(x: 0,
//                                                 y: 0,
//                                                 width: application.app!.sizeForWindow().width,
//                                                 height: application.app!.sizeForWindow().height + 20)
//        }
//
//
//        // set it's center to match application.center
//        transitionWindowFrame.center = application.view.center
//
//        addSubview(transitionWindowFrame)
//
//        // animate it to origin of the application with
//        UIView.animate(withDuration: 0.2, animations: {
//            if doesExist {
//                transitionWindowFrame.center = applicationWindow.center
//            } else {
//                transitionWindowFrame.center = self.center
//            }
//
//            transitionWindowFrame.transform = .identity
//        }) { (completion) in
//            transitionWindowFrame.removeFromSuperview()
//            self.loadApplication(applicationWindow)
//
//        }
//
//    }
//
//
//
//}

