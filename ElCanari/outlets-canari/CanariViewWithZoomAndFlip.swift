//
//  CanariViewWithZoomAndFlip.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 24/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariViewWithZoomAndFlip
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariViewWithZoomAndFlip : NSView, EBUserClassNameProtocol {

   fileprivate var mHorizontalFlip = false
   fileprivate var mVerticalFlip = false
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
  //  Set size
  //····················································································································

  func setBoardModelSize (width : Int, height : Int) {
    let noModel = (width == 0) || (height == 0)
    let newRect = noModel
      ? CGRect (x:0.0, y:0.0, width:200.0, height:200.0)
      : CGRect (x:0.0, y:0.0, width:canariUnitToCocoa (width), height:canariUnitToCocoa (height))
    self.frame.size = newRect.size
    self.bounds = newRect
    scaleToZoom (mZoom, mHorizontalFlip, mVerticalFlip)
  }

  //····················································································································
  //  scaleToZoom
  //····················································································································

  fileprivate func scaleToZoom (_ inZoom : Int,
                                _ inHorizontalFlip : Bool,
                                _ inVerticalFlip : Bool) { // 0 -> fit to window
    if let clipView = self.superview as? NSClipView {
      let currentUnitSquareSize : NSSize = clipView.convert (NSSize (width: 1.0, height: 1.0), from:nil)
      let currentScale = 1.0 / currentUnitSquareSize.width ;
      let toggleHorizontalFlip : CGFloat = (inHorizontalFlip != mHorizontalFlip) ? -1.0 : 1.0 ;
      let toggleVerticalFlip   : CGFloat = (inVerticalFlip != mVerticalFlip) ? -1.0 : 1.0 ;
      if (0 == inZoom) { // Fit to window
        let clipViewSize = clipView.frame.size
        let currentSize = self.frame.size
        let sx = clipViewSize.width / currentSize.width
        let sy = clipViewSize.height / currentSize.height
        let scale = fmin (sx, sy) / currentScale
        clipView.scaleUnitSquare(to: NSSize (width: toggleHorizontalFlip * scale, height: toggleVerticalFlip * scale))
      }else{
        let scale = CGFloat (inZoom) / (100.0 * currentScale)
        clipView.scaleUnitSquare(to: NSSize (width: toggleHorizontalFlip * scale, height: toggleVerticalFlip * scale))
      }
      let zoomTitle = "\(Int ((self.actualScale () * 100.0).rounded (.toNearestOrEven))) %"
      mZoomPopUpButton?.menu?.item (at:0)?.title = (0 == inZoom) ? ("(" + zoomTitle + ")") : zoomTitle
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

  fileprivate func addPopupButtonItemForZoom (_ inZoom : Int) {
    if let zoomPopUpButton = mZoomPopUpButton {
      zoomPopUpButton.menu?.addItem (withTitle: ("\(inZoom) %"), action:#selector (CanariViewWithZoomAndFlip.setZoomFromPopUpButton(_:)), keyEquivalent: "")
      zoomPopUpButton.lastItem?.target = self
      zoomPopUpButton.lastItem?.tag = inZoom
    }
  }

  //····················································································································

  func setZoomFromPopUpButton (_ inSender : NSMenuItem) {
    scaleToZoom (inSender.tag, mHorizontalFlip, mVerticalFlip)
    mZoom = inSender.tag
    mZoomController?.updateModel (self)
  }

  //····················································································································

  override func viewDidMoveToSuperview () {
    super.viewDidMoveToSuperview ()
    if mZoomPopUpButton == nil, let clipView = self.superview as? NSClipView {
      clipView.postsFrameChangedNotifications = true
      NotificationCenter.default.addObserver (
        self,
        selector: #selector (CanariViewWithZoomAndFlip.updateAfterSuperviewResising(_:)),
        name: NSNotification.Name.NSViewFrameDidChange,
        object: clipView
      )
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
        zoomPopUpButton.menu?.addItem (withTitle:"Fit to Window", action:#selector (CanariViewWithZoomAndFlip.setZoomFromPopUpButton(_:)), keyEquivalent:"")
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
            NotificationCenter.default.removeObserver (
              self,
              name: NSNotification.Name.NSViewFrameDidChange,
              object: clipView
            )
          }
        }
      }
    }
  }

  //····················································································································
  //  magnifyWithEvent
  //····················································································································

  override func magnify (with inEvent : NSEvent) {
    let newZoom = Int ((actualScale () * 100.0 * (inEvent.magnification + 1.0)).rounded (.toNearestOrEven))
    scaleToZoom (newZoom, mHorizontalFlip, mVerticalFlip)
    mZoom = newZoom
  }

  //····················································································································
  //  Super view has been resized
  //····················································································································

  func updateAfterSuperviewResising (_ inSender: Any?) {
    if mZoom == 0 {
      scaleToZoom (mZoom, mHorizontalFlip, mVerticalFlip)
    }
  }

  //····················································································································
  //  Horizontal flip
  //····················································································································

  func setHorizontalFlipFromController (_ inFlip : Bool) {
    scaleToZoom (mZoom, inFlip, mVerticalFlip)
    mHorizontalFlip = inFlip
  }

  //····················································································································
  //  Vertical flip
  //····················································································································

  func setVerticalFlipFromController (_ inFlip : Bool) {
    scaleToZoom (mZoom, mHorizontalFlip, inFlip)
    mVerticalFlip = inFlip
  }

  //····················································································································
  //  Zoom pop up button activation
  //····················································································································

  func setZoomFromController (_ inZoom : Int, _ inActivate : Bool) {
    scaleToZoom (inZoom, mHorizontalFlip, mVerticalFlip)
    mZoom = inZoom
    mZoomPopUpButton?.isEnabled = inActivate
  }

  //····················································································································
  //  Responder chain
  //····················································································································

  override var acceptsFirstResponder : Bool { return true }

  override func becomeFirstResponder () -> Bool { return true }

  override func resignFirstResponder () -> Bool { return true }

  //····················································································································
  //  Focus ring (https://developer.apple.com/library/content/qa/qa1785/_index.html)
  //····················································································································

  override var focusRingMaskBounds : NSRect { return self.bounds }

  //····················································································································

  override func drawFocusRingMask () {
    NSRectFill (self.bounds)
  }

  //····················································································································
  //    size binding
  //····················································································································

  private var mSizeController : Controller_CanariViewWithZoomAndFlip_size?

  func bind_size (_ width:EBReadOnlyProperty_Int, _ height:EBReadOnlyProperty_Int, file:String, line:Int) {
    mSizeController = Controller_CanariViewWithZoomAndFlip_size (width:width, height:height, outlet:self, file:file, line:line)
  }

  func unbind_size () {
    mSizeController?.unregister ()
    mSizeController = nil
  }

  //····················································································································
  //    zoom binding
  //····················································································································

  private var mZoomController : Controller_CanariViewWithZoomAndFlip_zoom?

  func bind_zoom (_ zoom:EBReadWriteProperty_Int, file:String, line:Int) {
    mZoomController = Controller_CanariViewWithZoomAndFlip_zoom (zoom:zoom, outlet:self, file:file, line:line)
  }

  func unbind_zoom () {
    mZoomController?.unregister ()
    mZoomController = nil
  }

  //····················································································································
  //    horizontal flip binding
  //····················································································································

  private var mHorizontalFlipController : Controller_CanariViewWithZoomAndFlip_horizontalFlip?

  func bind_horizontalFlip (_ flip:EBReadOnlyProperty_Bool, file:String, line:Int) {
    mHorizontalFlipController = Controller_CanariViewWithZoomAndFlip_horizontalFlip (flip:flip, outlet:self, file:file, line:line)
  }

  func unbind_horizontalFlip () {
    mHorizontalFlipController?.unregister ()
    mHorizontalFlipController = nil
  }

  //····················································································································
  //    vertical flip binding
  //····················································································································

  private var mVerticalFlipController : Controller_CanariViewWithZoomAndFlip_verticalFlip?

  func bind_verticalFlip (_ flip:EBReadOnlyProperty_Bool, file:String, line:Int) {
    mVerticalFlipController = Controller_CanariViewWithZoomAndFlip_verticalFlip (flip:flip, outlet:self, file:file, line:line)
  }

  func unbind_verticalFlip () {
    mVerticalFlipController?.unregister ()
    mVerticalFlipController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariViewWithZoomAndFlip_size
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariViewWithZoomAndFlip_size : EBSimpleController {

  private let mWidth : EBReadOnlyProperty_Int
  private let mHeight : EBReadOnlyProperty_Int
  private let mOutlet : CanariViewWithZoomAndFlip

  //····················································································································

  init (width : EBReadOnlyProperty_Int, height : EBReadOnlyProperty_Int, outlet : CanariViewWithZoomAndFlip, file : String, line : Int) {
    mWidth = width
    mHeight = height
    mOutlet = outlet
    super.init (observedObjects:[width, height], outlet:outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    var newWidth = 0
    switch mWidth.prop {
    case .empty :
      ()
    case .single (let v) :
      newWidth = v
    case .multiple :
      ()
    }
    var newHeight = 0
    switch mHeight.prop {
    case .empty :
      ()
    case .single (let v) :
      newHeight = v
    case .multiple :
      ()
    }
    //NSLog ("width \(newWidth), height \(newHeight)")
    mOutlet.setBoardModelSize (width:newWidth, height:newHeight)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariViewWithZoomAndFlip_zoom
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariViewWithZoomAndFlip_zoom : EBSimpleController {

  private let mZoom : EBReadWriteProperty_Int
  private let mOutlet : CanariViewWithZoomAndFlip

  //····················································································································

  init (zoom : EBReadWriteProperty_Int, outlet : CanariViewWithZoomAndFlip, file : String, line : Int) {
    mZoom = zoom
    mOutlet = outlet
    super.init (observedObjects:[zoom], outlet:outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch mZoom.prop {
    case .empty :
      mOutlet.setZoomFromController (100, false)
    case .single (let v) :
      mOutlet.setZoomFromController (v, true)
    case .multiple :
      mOutlet.setZoomFromController (100, false)
    }
  }

  //····················································································································

  func updateModel (_ sender : CanariViewWithZoomAndFlip) {
    _ = mZoom.validateAndSetProp (mOutlet.mZoom, windowForSheet:sender.window)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariViewWithZoomAndFlip_horizontalFlip
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariViewWithZoomAndFlip_horizontalFlip : EBSimpleController {

  private let mFlip : EBReadOnlyProperty_Bool
  private let mOutlet : CanariViewWithZoomAndFlip

  //····················································································································

  init (flip : EBReadOnlyProperty_Bool, outlet : CanariViewWithZoomAndFlip, file : String, line : Int) {
    mFlip = flip
    mOutlet = outlet
    super.init (observedObjects:[flip], outlet:outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch mFlip.prop {
    case .empty :
      mOutlet.setHorizontalFlipFromController (false)
    case .single (let v) :
      mOutlet.setHorizontalFlipFromController (v)
    case .multiple :
      mOutlet.setHorizontalFlipFromController (false)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariViewWithZoomAndFlip_verticalFlip
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariViewWithZoomAndFlip_verticalFlip : EBSimpleController {

  private let mFlip : EBReadOnlyProperty_Bool
  private let mOutlet : CanariViewWithZoomAndFlip

  //····················································································································

  init (flip : EBReadOnlyProperty_Bool, outlet : CanariViewWithZoomAndFlip, file : String, line : Int) {
    mFlip = flip
    mOutlet = outlet
    super.init (observedObjects:[flip], outlet:outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch mFlip.prop {
    case .empty :
      mOutlet.setVerticalFlipFromController (false)
    case .single (let v) :
      mOutlet.setVerticalFlipFromController (v)
    case .multiple :
      mOutlet.setVerticalFlipFromController (false)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
