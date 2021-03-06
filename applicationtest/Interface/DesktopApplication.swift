//
//  DesktopApplication.swift
//  faceview
//
//  Created by Xue Yu on 5/23/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit

protocol DesktopAppDelegate {

    /// Called when desktop application is double tapped.
    ///
    /// - Parameter application: The current desktop application.
    func didDoubleClick(_ appliction: DesktopApplication)

    /// Called when desktop application is about to start dragging.
    ///
    /// - Parameter application: The current desktop application.
    func willStartDragging(_ appliction: DesktopApplication)

    /// Called when dragging is over.
    ///
    /// - Parameter application: The current desktop application.
    func didFinishDragging(_ appliction: DesktopApplication)

}


/// DesktopViewConnectionDelegate is the bridge between the MacAppDesktopView and the DesktopAppDelegate
protocol DesktopViewConnectionDelegate {

    /// Called when desktop application is double tapped.
    func didDoubleClick()

    /// Called when desktop application is about to start dragging.
    func willStartDragging()

    /// Called when dragging is over.
    func didFinishDragging()

}

/// The DesktopAppDataSource is what provides the display meta data to the Desktop Application View
protocol DesktopAppDataSource {

    /// The image that will be displayed as an icon.
    var image: UIImage { get }

    /// The title/text that will be displayed on the app
    var name: String { get }
}

class DesktopApplication: UIView {

    /// This function  creates an instance of Desktop Application using `MacApp` instance and `OSWindow` instance. Where `MacApp` is used as a data source and the `OSWindow` is used as a delegate.
    ///
    /// - Parameters:
    ///   - app : The app which we want to display on the desktop. Note that this MacApp must have a desktopIcon Value.
    ///   - window: The OSWindow instance in which we are display the destkop application.
    /// - Returns: The new created instance of DesktopApplication
//    static func make(app: MacApp, in window: OSWindowView) -> DesktopApplication {
//        let desktopApp = DesktopApplication(with: window)
//        desktopApp.app = app
//        desktopApp.delegate = window
//        return desktopApp
//    }

    /// The data source for this Desktop Application
    var app: MacApp? {
      didSet {
        view = MacAppDesktopView(dataSource: self)
      }
    }


    /// The delegate for this Desktop Application
    var delegate: DesktopAppDelegate? {
      didSet {
        view?.delegate = self
      }
    }


    /// The Desktop View
    var view: MacAppDesktopView!

    /// A strong reference to the current window, in case the desktop application needs to make some changes to it.
    var windowView: OSWindowView!

    convenience init(with windowView: OSWindowView) {
        self.init(frame: windowView.bounds)
        self.windowView = windowView

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


/// Conform to DesktopViewConnectionDelegate
extension DesktopApplication: DesktopViewConnectionDelegate {

  func didFinishDragging() {
    delegate?.didFinishDragging(self)
  }


  func willStartDragging() {
      print("will start drag DesktopApplication")
      delegate?.willStartDragging(self)
  }

  func didDoubleClick() {
      delegate?.didDoubleClick(self)
  }

}

/// Conforms to DesktopAppDataSource
extension DesktopApplication: DesktopAppDataSource {

  var name: String {
    return app?.windowTitle ?? ""
  }

  var image: UIImage{
    return app!.desktopIcon!
  }

}


/// The MacAppDesktopView

class MacAppDesktopView: UIView {

    /// The data source
    var dataSource: DesktopAppDataSource?

    /// The delegate
    var delegate: DesktopViewConnectionDelegate?

    /// The icon (as image view)
    var icon: UIImageView!

    /// The text Label
    var text: UILabel!

    /// The transition window frame (The border the user sees when the app is being dragged)
    var transitionWindowFrame : MovingApplication!

    /// The last location (A property used for dragging)
    var lastPoint : CGPoint = .zero

    /// The width of desktop application
    static let width : CGFloat = 65.0

    /// The space between the image view and the frame
    static let space: CGFloat = 3.0

    /// The scale of the image relative to the width
    static let imageScale: CGFloat = 0.8

    /// initialization should always be done using this initailizer because a data source is needed in order to calculate the view's frame height.
    ///
    /// - Parameter dataSource: The desktop app data source which contains an image and a string.
    convenience init(dataSource: DesktopAppDataSource) {
        // calculate needed height
        let imageHeight: CGFloat = MacAppDesktopView.imageScale * MacAppDesktopView.width
        let textWidth = MacAppDesktopView.width - MacAppDesktopView.space * 2
        let textHeight = Utils.heightForView(dataSource.name, font: SystemSettings.notePadFont, width: textWidth, numberOfLines: 0)
        let totalHeight = textHeight + imageHeight
        let rect = CGRect(origin: .zero, size: CGSize(width: MacAppDesktopView.width, height: totalHeight))
        self.init(frame: rect)
        self.dataSource = dataSource
        setup()
    }

    /// Never used this
    ///
    /// - Parameter frame: The frame size of the view
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func setup() {

        // set up image view
        let imageWidth = MacAppDesktopView.imageScale * MacAppDesktopView.width


        icon = UIImageView(frame: CGRect(x: (MacAppDesktopView.width - imageWidth)/2 , y: 0, width: imageWidth, height: imageWidth))
        icon.image = dataSource?.image
        icon.contentMode = .scaleAspectFit

        // set up text view
        let textWidth = MacAppDesktopView.width - MacAppDesktopView.space * 2
        let textHeight = Utils.heightForView(dataSource!.name, font: SystemSettings.notePadFont, width: textWidth, numberOfLines: 0)
        text = UILabel(frame: CGRect(x: (MacAppDesktopView.width - textWidth)/2, y: imageWidth, width: textWidth, height: textHeight))
        text.backgroundColor = .white
        text.text = dataSource?.name
        text.font = SystemSettings.notePadFont
        text.textAlignment = .center
        text.numberOfLines = 0

        addSubview(icon)
        addSubview(text)

        // setup transition frame
        transitionWindowFrame = MovingApplication(textHeight: textHeight, textWidth: textWidth, totalWidth: MacAppDesktopView.width)
        transitionWindowFrame.isHidden = true
        transitionWindowFrame.backgroundColor = .clear
        addSubview(transitionWindowFrame)

        // add gesture recognizer
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:))))

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(tapGesture)
    }


    /// Selector function, handles taps
    ///
    /// - Parameter sender: UITapGestureRecognizer
    @objc func handleTap(sender: UITapGestureRecognizer) {
        delegate?.didDoubleClick()
    }

    /// Selector function, handles drag
    ///
    /// - Parameter sender: UIPanGestureRecognizer
    @objc func handlePan(sender: UIPanGestureRecognizer) {

        let transition = sender.translation(in: self.superview!)

        switch sender.state {
        case .began:
          transitionWindowFrame.isHidden = false
          transitionWindowFrame.frame = CGRect(origin: .zero, size: bounds.size)
          transitionWindowFrame.lastLocation = self.transitionWindowFrame.center
          delegate?.willStartDragging()
          break
        case .ended:
          transitionWindowFrame.isHidden = true
          self.center = convert(transitionWindowFrame.center, to : superview)
          delegate?.didFinishDragging()
          return
        default:
          break
        }

        let point = CGPoint(x: transitionWindowFrame.lastLocation.x + transition.x , y: transitionWindowFrame.lastLocation.y + transition.y)
        transitionWindowFrame.center = point
    }
}

/// This is the class of which we create the transitioning window frame
class MovingApplication: UIView {

  var lastLocation = CGPoint.zero

  var width: CGFloat = 0.0

  var imageSize: CGFloat = 0.0

  var textHeight: CGFloat = 0.0

  var textWidth: CGFloat = 0.0 

  convenience init(textHeight: CGFloat, textWidth: CGFloat, totalWidth: CGFloat){
      self.init(frame: CGRect(x: 0, y: 0, width: textWidth, height: totalWidth * MacAppDesktopView.imageScale + textHeight))
      self.textHeight = textHeight
      self.textWidth = textWidth
      self.width = totalWidth
      self.imageSize = totalWidth * MacAppDesktopView.imageScale
  }

  override init(frame: CGRect) {
      super.init(frame: frame)
  }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.lightGray.setStroke()
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: (width - imageSize)/2, y: 0))
        path.addLine(to: CGPoint(x: (width - imageSize)/2, y: imageSize))
        path.addLine(to: CGPoint(x: 0, y: imageSize))
        path.addLine(to: CGPoint(x: 0, y: textHeight + imageSize))
        path.addLine(to: CGPoint(x:textWidth, y: textHeight + imageSize))
        path.addLine(to: CGPoint(x:textWidth, y: imageSize))
        path.addLine(to: CGPoint(x: imageSize, y: imageSize))
        path.addLine(to: CGPoint(x: imageSize, y: 0))
        path.close()
        
        path.lineWidth = 1
        path.stroke()
    }

}
