//
//  AppDelegate.swift
//  applicationtest
//
//  Created by Xue Yu on 5/24/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let windowRect = UIScreen.main.bounds
        
        window = UIWindow.init(frame: windowRect)
        window?.rootViewController = UIViewController()
        
        let ostoolbar = OSToolBar(inWindow: windowRect)
        
        let oswindowview = OSWindowView(frame: windowRect, toolbar: ostoolbar)
        
        oswindowview.backgroundColor = .gray
        oswindowview.layer.cornerRadius = 5
        oswindowview.layer.masksToBounds = true
        
        window?.rootViewController?.view.addSubview(oswindowview)
        
        window?.makeKeyAndVisible()

        return true
    }


}

