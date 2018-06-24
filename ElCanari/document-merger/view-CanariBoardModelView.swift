//
//  CanariBoardModelView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariCharacterView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariBoardModelView : NSView, EBUserClassNameProtocol {

   fileprivate var mBackgroundLayer = CAShapeLayer ()
   fileprivate var mNoModelTextLayer = CATextLayer ()
   fileprivate var mViaLayer = CALayer ()
   fileprivate var mZoom = 100
   fileprivate var mZoomPopUpButton : NSPopUpButton? = nil

  //····················································································································

  override init(frame frameRect: NSRect) {
    super.init (frame: frameRect)
    noteObjectAllocation (self)
  }

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }
  
  //····················································································································
  //  awakeFromNib
  //····················································································································

  final override func awakeFromNib () {
    CATransaction.begin()
    self.layer?.addSublayer (mBackgroundLayer)
    self.layer?.addSublayer (mNoModelTextLayer)
    self.layer?.addSublayer (mViaLayer)
    CATransaction.commit ()
  }

  //····················································································································
  //  Set size
  //····················································································································

  func setSize (width : Int, height : Int) {
    let noModel = (width == 0) || (height == 0)
    if noModel {
      let newRect = CGRect (x:0.0, y:0.0, width:200.0, height:200.0)
      self.bounds = newRect
      self.frame = newRect
      mBackgroundLayer.fillColor = nil
      mBackgroundLayer.strokeColor = nil
      mNoModelTextLayer.frame = newRect
      mNoModelTextLayer.foregroundColor = NSColor.black.cgColor
      mNoModelTextLayer.contentsScale = NSScreen.main ()!.backingScaleFactor
      mNoModelTextLayer.alignmentMode = kCAAlignmentCenter
      mNoModelTextLayer.string = "No Model"
    }else{
      let newRect = CGRect (x:0.0, y:0.0, width:canariUnitToCocoa (width), height:canariUnitToCocoa (height))
      self.bounds = newRect
      self.frame = newRect
      mBackgroundLayer.path = CGPath (rect: self.bounds.insetBy (dx: 0.5, dy: 0.5), transform: nil)
      mBackgroundLayer.position = CGPoint (x:0.0, y:0.0)
      mBackgroundLayer.fillColor = NSColor.white.cgColor
      mBackgroundLayer.strokeColor = NSColor.black.cgColor
      mBackgroundLayer.lineWidth = 1.0
      mNoModelTextLayer.string = ""
    }
    scaleToZoom ()
  }

  //····················································································································
  //  scaleToZoom
  //····················································································································

  func scaleToZoom () { // 0 -> fit to window
    if let clipView = self.superview as? NSClipView {
      let currentUnitSquareSize : NSSize = clipView.convert (NSSize (width: 1.0, height: 1.0), from:nil)
      let currentScale = 1.0 / currentUnitSquareSize.width ;
      if (0 == mZoom) { // Fit to window
        let sfr = clipView.frame
        let fr = self.frame
        let sx = sfr.size.width / fr.size.width
        let sy = sfr.size.height / fr.size.height
        let scale = fmin (sx, sy) / currentScale
        clipView.scaleUnitSquare(to: NSSize (width: scale, height: scale))
      }else{
        let scale = CGFloat (mZoom) / (100.0 * currentScale)
        clipView.scaleUnitSquare(to: NSSize (width: scale, height: scale))
      }
      mZoomPopUpButton?.menu?.item (at:0)?.title = "\(Int (self.actualScale () * 100.0)) %"
      mZoomController?.updateModel (self)
    }
  }
  
  //····················································································································

  func actualScale () -> CGFloat {
    var result : CGFloat = 1.0
    if let clipView = self.superview as? NSClipView {
      let currentScale : NSSize = clipView.convert (NSSize (width:1.0, height:1.0), from:nil)
      result = 1.0 / currentScale.width
    }
    return result
  }

  //····················································································································
  //  Managing zoom popup button
  //····················································································································

  func addPopupButtonItemForZoom (_ inZoom : Int) {
    if let zoomPopUpButton = mZoomPopUpButton {
      zoomPopUpButton.menu?.addItem (withTitle: ("\(inZoom) %"), action:#selector (CanariBoardModelView.setZoomFromPopUpButton(_:)), keyEquivalent: "")
      zoomPopUpButton.lastItem?.target = self
      zoomPopUpButton.lastItem?.tag = inZoom
    }
  }

  //····················································································································

  func setZoomFromPopUpButton (_ inSender : NSMenuItem) {
    mZoom = inSender.tag
    scaleToZoom ()
  }

  //····················································································································

  override func viewDidMoveToSuperview () {
    super.viewDidMoveToSuperview ()
    if mZoomPopUpButton == nil, let clipView = self.superview as? NSClipView {
      if let scrollView = clipView.superview as? CanariScrollViewWithPlacard {
        let r = NSRect (x:0.0, y:0.0, width:70.0, height:20.0)
        let zoomPopUpButton = NSPopUpButton (frame:r, pullsDown:true)
        mZoomPopUpButton = zoomPopUpButton
        zoomPopUpButton.font = NSFont.systemFont (ofSize:NSFont.smallSystemFontSize ())
        zoomPopUpButton.autoenablesItems = false
        zoomPopUpButton.bezelStyle = NSShadowlessSquareBezelStyle
        if let popUpButtonCell = zoomPopUpButton.cell as? NSPopUpButtonCell {
          popUpButtonCell.arrowPosition = .arrowAtBottom
        }
        zoomPopUpButton.isBordered = false
        zoomPopUpButton.menu?.addItem (
          withTitle:"\(Int (self.actualScale () * 100.0)) %",
          action:nil,
          keyEquivalent:""
        )
        self.addPopupButtonItemForZoom (50)
        self.addPopupButtonItemForZoom (100)
        self.addPopupButtonItemForZoom (150)
        self.addPopupButtonItemForZoom (200)
        self.addPopupButtonItemForZoom (250)
        self.addPopupButtonItemForZoom (400)
        self.addPopupButtonItemForZoom (600)
        self.addPopupButtonItemForZoom (1000)
        self.addPopupButtonItemForZoom (1500)
        self.addPopupButtonItemForZoom (2000)
        zoomPopUpButton.menu?.addItem (withTitle:"Fit to Window", action:#selector (CanariBoardModelView.setZoomFromPopUpButton(_:)), keyEquivalent:"")
        zoomPopUpButton.lastItem?.target = self
        zoomPopUpButton.lastItem?.tag = 0
        scrollView.addPlacard (zoomPopUpButton)
      }
    }
  }

  //····················································································································

  override func viewWillMove (toSuperview inSuperview : NSView?) {
     super.viewWillMove (toSuperview:inSuperview)
  //--- Remove from superview ?
    if nil == inSuperview {
      if let clipView = self.superview as? NSClipView {
        if let zoomPopUpButton = mZoomPopUpButton {
          if let scrollView = clipView.superview as? CanariScrollViewWithPlacard {
            scrollView.removePlacard (zoomPopUpButton)
            mZoomPopUpButton = nil ;
          }
        }
      }
    }
  }

  //····················································································································
  //  Zoom pop up button activation
  //····················································································································

  func setZoomFromController (_ inZoom : Int, _ inActivate : Bool) {
    mZoom = inZoom
    scaleToZoom ()
    mZoomPopUpButton?.isEnabled = inActivate
  }

  //····················································································································
  //  First responder
  //····················································································································

  override var acceptsFirstResponder : Bool { get { return true } }

  //····················································································································
  //  Focus ring (https://developer.apple.com/library/content/qa/qa1785/_index.html)
  //····················································································································

  override var focusRingMaskBounds: NSRect { get { return self.bounds } }

  //····················································································································

  override func drawFocusRingMask () {
    NSRectFill (self.bounds)
  }

  //····················································································································
  //    size binding
  //····················································································································

  private var mSizeController : Controller_CanariBoardModelView_size?

  func bind_size (_ width:EBReadOnlyProperty_Int, _ height:EBReadOnlyProperty_Int, file:String, line:Int) {
    mSizeController = Controller_CanariBoardModelView_size (width:width, height:height, outlet:self, file:file, line:line)
  }

  func unbind_size () {
    mSizeController?.unregister ()
    mSizeController = nil
  }

  //····················································································································
  //    zoom binding
  //····················································································································

  private var mZoomController : Controller_CanariBoardModelView_zoom?

  func bind_zoom (_ zoom:EBReadWriteProperty_Int, file:String, line:Int) {
    mZoomController = Controller_CanariBoardModelView_zoom (zoom:zoom, outlet:self, file:file, line:line)
  }

  func unbind_zoom () {
    mZoomController?.unregister ()
    mZoomController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardModelView_size
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_size : EBSimpleController {

  private let mWidth : EBReadOnlyProperty_Int
  private let mHeight : EBReadOnlyProperty_Int
  private let mOutlet : CanariBoardModelView

  //····················································································································

  init (width : EBReadOnlyProperty_Int, height : EBReadOnlyProperty_Int, outlet : CanariBoardModelView, file : String, line : Int) {
    mWidth = width
    mHeight = height
    mOutlet = outlet
    super.init (objects:[width, height], outlet:outlet)
    mWidth.addEBObserver (self)
    mHeight.addEBObserver (self)
  }

  //····················································································································
  
  func unregister () {
    mWidth.removeEBObserver (self)
    mHeight.removeEBObserver (self)
  }

  //····················································································································

  override func sendUpdateEvent () {
    var newWidth = 0
    switch mWidth.prop {
    case .noSelection :
      ()
    case .singleSelection (let v) :
      newWidth = v
    case .multipleSelection :
      ()
    }
    var newHeight = 0
    switch mHeight.prop {
    case .noSelection :
      ()
    case .singleSelection (let v) :
      newHeight = v
    case .multipleSelection :
      ()
    }
    //NSLog ("width \(newWidth), height \(newHeight)")
    mOutlet.setSize (width:newWidth, height:newHeight)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardModelView_zoom
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_zoom : EBSimpleController {

  private let mZoom : EBReadWriteProperty_Int
  private let mOutlet : CanariBoardModelView

  //····················································································································

  init (zoom : EBReadWriteProperty_Int, outlet : CanariBoardModelView, file : String, line : Int) {
    mZoom = zoom
    mOutlet = outlet
    super.init (objects:[zoom], outlet:outlet)
    mZoom.addEBObserver (self)
  }

  //····················································································································
  
  func unregister () {
    mZoom.removeEBObserver (self)
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mZoom.prop {
    case .noSelection :
      mOutlet.setZoomFromController (100, false)
    case .singleSelection (let v) :
      mOutlet.setZoomFromController (v, true)
    case .multipleSelection :
      mOutlet.setZoomFromController (100, false)
    }
  }

  //····················································································································

  func updateModel (_ sender : CanariBoardModelView) {
    _ = mZoom.validateAndSetProp (mOutlet.mZoom, windowForSheet:sender.window)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
