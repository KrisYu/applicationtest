import Foundation
import UIKit

class Finder: MacApp{
    
    var desktopIcon: UIImage?
    
    lazy var uniqueIdentifier: String = {
        return UUID().uuidString
    }()
    
    var identifier: String = "finder"
    
    var shouldDragApplication: Bool = true
    
    var contentMode: ContentStyle = .light
    
    lazy var container: UIView? = FinderView()
    
    var menuActions: [MenuAction]?
    
    var windowTitle: String? = ""
    
    
    var window: OSWindowView?
    
    init() {
        menuActions = [MenuAction]()
        
        var fileMenuList = [MenuAction]()
        fileMenuList.append(MenuAction(title: "Open", action: nil, subMenus: nil, enabled: false))
        fileMenuList.append(MenuAction(title: "Duplicate", action: nil, subMenus: nil, enabled: false))
        fileMenuList.append(MenuAction(title: "Get Info", action: nil, subMenus: nil, enabled: false))
        fileMenuList.append(MenuAction(title: "Put Back", action: nil, subMenus: nil, enabled: false))
        fileMenuList.append(MenuAction(type: .seperator))

        var viewMenuList = [MenuAction]()
        viewMenuList.append(MenuAction(title: "By Icon  ",enabled: false))
        viewMenuList.append(MenuAction(title: "By Name  ",enabled: false))
        viewMenuList.append(MenuAction(title: "By Date  ",enabled: false))
        viewMenuList.append(MenuAction(title: "By Size  ",enabled: false))
        viewMenuList.append(MenuAction(title: "By Kind  ",enabled: false))
        

        var specialMenuList = [MenuAction]()
        specialMenuList.append(MenuAction(title: "Clean Up",enabled: false))
        specialMenuList.append(MenuAction(title: "Empty Trash  ",enabled: false))
        specialMenuList.append(MenuAction(title: "Erase Disk",enabled: false))
        specialMenuList.append(MenuAction(title: "Set Startup",enabled: false))
        

    }
    
    func willLaunchApplication(in view: OSWindowView, withApplicationWindow appWindow: OSApplicationWindow) {
    }
    
    func willTerminateApplication(){
        
    }
    
    func sizeForWindow() -> CGSize {
        return CGSize(width: 364, height: 205)
    }
}

class FinderView: UIView{
    
    
    override func draw(_ rect: CGRect) {
        
        UIColor.white.setFill()
        UIBezierPath(rect: rect).fill()
        
        //draw upper part
            //draw forground rect
        UIColor.black.setFill()
        let upperRect = CGRect(x: 0, y: 0, width: rect.width, height: rect.height * 0.25)
        let upperForground = UIBezierPath(rect: upperRect)
        upperForground.fill()
        
            //draw lines
        UIColor.white.setFill()
        getUpperLines(upperRect).forEach { $0.fill()}
            //draw sun
        let sunRect = CGRect(x: rect.width * 0.59, y: rect.height * 0.10, width: rect.height * 0.25, height: rect.height * 0.25)
        UIBezierPath(roundedRect: sunRect, cornerRadius: sunRect.height / 2).fill()
        
        
        //draw upper mountains
            //draw line
        UIColor.black.set()
        UIColor.black.setFill()
        pathForUpperMountains(rect).stroke()
            //draw objects (shadows)
        getMountainShadows(rect).forEach {$0.fill()}
        
        //draw lower mountains
        
        pathForLowerMountains(rect).fill()
        
        //draw text
        
        
    }
    
    func getMountainShadows(_ rect: CGRect)->[UIBezierPath]{
        let object1 = UIBezierPath()
        object1.move(to: CGPoint(x: rect.width * 0.15, y: rect.height * 0.32))
        object1.addLine(to: CGPoint(x: rect.width * 0.13, y: rect.height * 0.36))
        object1.addLine(to: CGPoint(x: rect.width * 0.15, y: rect.height * 0.40))
        object1.addLine(to: CGPoint(x: rect.width * 0.13, y: rect.height * 0.43))
        object1.addLine(to: CGPoint(x: rect.width * 0.15, y: rect.height * 0.46))
        object1.addLine(to: CGPoint(x: rect.width * 0.18, y: rect.height * 0.46))
        object1.addLine(to: CGPoint(x: rect.width * 0.20, y: rect.height * 0.51))
        object1.addLine(to: CGPoint(x: rect.width * 0.25, y: rect.height * 0.51))
        object1.addLine(to: CGPoint(x: rect.width * 0.28, y: rect.height * 0.47))
        object1.addLine(to: CGPoint(x: rect.width * 0.26, y: rect.height * 0.42))
        object1.addLine(to: CGPoint(x: rect.width * 0.22, y: rect.height * 0.42))
        object1.addLine(to: CGPoint(x: rect.width * 0.22, y: rect.height * 0.38))
        object1.addLine(to: CGPoint(x: rect.width * 0.24, y: rect.height * 0.36))
        object1.close()
        
        let object2 = UIBezierPath()
        object2.move(to: CGPoint(x: rect.width * 0.29, y: rect.height * 0.55))
        object2.addLine(to: CGPoint(x: rect.width * 0.24, y: rect.height * 0.59))
        object2.addLine(to: CGPoint(x: rect.width * 0.29, y: rect.height * 0.62))
        object2.addLine(to: CGPoint(x: rect.width * 0.37, y: rect.height * 0.59))
        object2.addLine(to: CGPoint(x: rect.width * 0.35, y: rect.height * 0.55))
        object2.close()
        
        let object3 = UIBezierPath()
        object3.move(to: CGPoint(x: rect.width * 0.33, y: rect.height * 0.40))
        object3.addLine(to: CGPoint(x: rect.width * 0.35, y: rect.height * 0.42))
        object3.addLine(to: CGPoint(x: rect.width * 0.35, y: rect.height * 0.47))
        object3.addLine(to: CGPoint(x: rect.width * 0.40, y: rect.height * 0.47))
        object3.addLine(to: CGPoint(x: rect.width * 0.42, y: rect.height * 0.43))
        object3.addLine(to: CGPoint(x: rect.width * 0.40, y: rect.height * 0.37))
        object3.close()
        
        let object4 = UIBezierPath()
        object4.move(to: CGPoint(x: rect.width * 0.50, y: rect.height * 0.32))
        object4.addLine(to: CGPoint(x: rect.width * 0.44, y: rect.height * 0.43))
        object4.addLine(to: CGPoint(x: rect.width * 0.46, y: rect.height * 0.47))
        object4.addLine(to: CGPoint(x: rect.width * 0.44, y: rect.height * 0.55))
        object4.addLine(to: CGPoint(x: rect.width * 0.42, y: rect.height * 0.59))
        object4.addLine(to: CGPoint(x: rect.width * 0.44, y: rect.height * 0.66))
        object4.addLine(to: CGPoint(x: rect.width * 0.42, y: rect.height * 0.63))
        object4.addLine(to: CGPoint(x: rect.width * 0.46, y: rect.height * 0.78))
        object4.addLine(to: CGPoint(x: rect.width * 0.50, y: rect.height * 0.78))
        object4.addLine(to: CGPoint(x: rect.width * 0.48, y: rect.height * 0.71))
        object4.addLine(to: CGPoint(x: rect.width * 0.46, y: rect.height * 0.71))
        object4.addLine(to: CGPoint(x: rect.width * 0.46, y: rect.height * 0.66))
        object4.addLine(to: CGPoint(x: rect.width * 0.51, y: rect.height * 0.66))
        object4.addLine(to: CGPoint(x: rect.width * 0.55, y: rect.height * 0.59))
        object4.addLine(to: CGPoint(x: rect.width * 0.61, y: rect.height * 0.66))
        object4.addLine(to: CGPoint(x: rect.width * 0.61, y: rect.height * 0.59))
        object4.addLine(to: CGPoint(x: rect.width * 0.64, y: rect.height * 0.59))
        object4.addLine(to: CGPoint(x: rect.width * 0.66, y: rect.height * 0.55))
        object4.addLine(to: CGPoint(x: rect.width * 0.64, y: rect.height * 0.51))
        object4.addLine(to: CGPoint(x: rect.width * 0.59, y: rect.height * 0.51))
        object4.addLine(to: CGPoint(x: rect.width * 0.59, y: rect.height * 0.47))
        object4.addLine(to: CGPoint(x: rect.width * 0.63, y: rect.height * 0.39))
        object4.close()
        
        let object5 = UIBezierPath()
        object5.move(to: CGPoint(x: rect.width * 0.71, y: rect.height * 0.43))
        object5.addLine(to: CGPoint(x: rect.width * 0.76, y: rect.height * 0.57))
        object5.addLine(to: CGPoint(x: rect.width * 0.80, y: rect.height * 0.55))
        object5.addLine(to: CGPoint(x: rect.width * 0.82, y: rect.height * 0.44))
        object5.addLine(to: CGPoint(x: rect.width * 0.77, y: rect.height * 0.43))
        object5.addLine(to: CGPoint(x: rect.width * 0.80, y: rect.height * 0.40))
        object5.addLine(to: CGPoint(x: rect.width * 0.77, y: rect.height * 0.38))
        object5.close()
        
        let object6 = UIBezierPath()
        object6.move(to: CGPoint(x: rect.width * 1.00, y: rect.height * 0.32))
        object6.addLine(to: CGPoint(x: rect.width * 0.92, y: rect.height * 0.38))
        object6.addLine(to: CGPoint(x: rect.width * 0.95, y: rect.height * 0.47))
        object6.addLine(to: CGPoint(x: rect.width * 0.93, y: rect.height * 0.55))
        object6.addLine(to: CGPoint(x: rect.width * 0.95, y: rect.height * 0.62))
        object6.addLine(to: CGPoint(x: rect.width * 1.00, y: rect.height * 0.62))
        object6.close()
        return [object1,object2,object3,object4,object5,object6]
    }
    
    func pathForLowerMountains(_ rect: CGRect)->UIBezierPath{
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: rect.height * 0.59))
        path.addLine(to: CGPoint(x: rect.width * 0.06, y: rect.height * 0.62))
        path.addLine(to: CGPoint(x: rect.width * 0.11, y: rect.height * 0.70))
        path.addLine(to: CGPoint(x: rect.width * 0.13, y: rect.height * 0.70))
        path.addLine(to: CGPoint(x: rect.width * 0.18, y: rect.height * 0.78))
        path.addLine(to: CGPoint(x: rect.width * 0.22, y: rect.height * 0.75))
        path.addLine(to: CGPoint(x: rect.width * 0.29, y: rect.height * 0.87))
        path.addLine(to: CGPoint(x: rect.width * 0.33, y: rect.height * 0.82))
        path.addLine(to: CGPoint(x: rect.width * 0.37, y: rect.height * 0.87))
        path.addLine(to: CGPoint(x: rect.width * 0.42, y: rect.height * 0.79))
        path.addLine(to: CGPoint(x: rect.width * 0.46, y: rect.height * 0.82))
        path.addLine(to: CGPoint(x: rect.width * 0.60, y: rect.height * 0.83))
        path.addLine(to: CGPoint(x: rect.width * 0.64, y: rect.height * 0.78))
        path.addLine(to: CGPoint(x: rect.width * 0.70, y: rect.height * 0.82))
        path.addLine(to: CGPoint(x: rect.width * 0.77, y: rect.height * 0.79))
        path.addLine(to: CGPoint(x: rect.width * 0.88, y: rect.height * 0.82))
        path.addLine(to: CGPoint(x: rect.width * 0.92, y: rect.height * 0.86))
        path.addLine(to: CGPoint(x: rect.width * 1.00, y: rect.height * 0.80))
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.close()
        return path
    }
    
    func pathForUpperMountains(_ rect: CGRect)->UIBezierPath{
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: rect.height * 0.36))
        path.addLine(to: CGPoint(x: rect.width * 0.15, y: rect.height * 0.32))
        path.addLine(to: CGPoint(x: rect.width * 0.33, y: rect.height * 0.40))
        path.addLine(to: CGPoint(x: rect.width * 0.50, y: rect.height * 0.32))
        path.addLine(to: CGPoint(x: rect.width * 0.71, y: rect.height * 0.43))
        path.addLine(to: CGPoint(x: rect.width * 0.79, y: rect.height * 0.36))
        path.addLine(to: CGPoint(x: rect.width * 0.86, y: rect.height * 0.43))
        path.addLine(to: CGPoint(x: rect.width * 1.00, y: rect.height * 0.32))
        path.lineWidth = rect.height * 0.005
        return path
    }
    
    func getUpperLines(_ rect: CGRect)->[UIBezierPath]{
        
        let h = rect.height
        let startingPoint = rect.height / 2
        let line1 = UIBezierPath(rect: CGRect(x: 0, y: startingPoint, width: rect.width, height: h * 0.02))
        let line2 = UIBezierPath(rect: CGRect(x: 0, y: startingPoint + h * 0.14, width: rect.width, height: h * 0.02))
        let line3 = UIBezierPath(rect: CGRect(x: 0, y: startingPoint + 2 * h * 0.14, width: rect.width, height: h * 0.02))
        let line4 = UIBezierPath(rect: CGRect(x: 0, y: startingPoint + h * (2 * 0.14 + 0.08), width: rect.width, height: h * 0.04))
        let line5 = UIBezierPath(rect: CGRect(x: 0, y: startingPoint + h * (2 * 0.14 + 0.16), width: rect.width, height: h * 0.02))
        return [line1,line2,line3,line4,line5]
    }
}
