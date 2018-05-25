import Foundation
import UIKit

class AlarmClock: MacApp{
    
    var desktopIcon: UIImage?
    
    var identifier: String? = "alarmclock"
    
    var windowTitle: String? = "Clock"
    
    var menuActions: [MenuAction]?

    var container: UIView?

    lazy var uniqueIdentifier: String = {
        return UUID().uuidString
    }()
    
    func sizeForWindow() -> CGSize {
        return CGSize(width: 140, height: 0)
    }
    
    init() {
        container = UIView()
    }
    
    var window: OSApplicationWindow?
    
    var isActive = false
    
    func willLaunchApplication(in view: OSWindowView, withApplicationWindow appWindow: OSApplicationWindow) {
        isActive = true
    }
    
    func willTerminateApplication() {
        isActive = false
    }
    
    func didLaunchApplication(in view: OSWindowView, withApplicationWindow appWindow: OSApplicationWindow) {
        
        if self.window == nil {
            self.window = appWindow
            self.window?.tabBar.drawLines = false
            self.window?.tabBar.title = Utils.extenedTime()
            recusiveTimer()
        }else{
            self.window?.tabBar.title = "lol"
        }
    }
    
    var timer: Timer!
    func recusiveTimer(){
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))
        timer = Timer(timeInterval: 1, repeats: false) { [weak self] (timer) in
            if self != nil{
                self!.window?.tabBar.title = Utils.extenedTime()
                if self!.isActive == false {return}
                self?.recusiveTimer()
            }
        }
        timer.fire()
    }
}
