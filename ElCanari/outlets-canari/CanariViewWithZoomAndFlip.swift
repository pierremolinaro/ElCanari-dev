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

class CanariViewWithZoomAndFlip : EBView {

   fileprivate var mHorizontalFlip = false
   fileprivate var mVerticalFlip = false
   fileprivate var mZoom = 100
   fileprivate var mZoomPopUpButton : NSPopUpButton? = nil

  //····················································································································
  //  Set rect
  //····················································································································

  fileprivate var mConstrainedRect = CGRect (x:0.0, y:0.0, width:500.0, height:500.0)

  func set (rect : CanariRect) {
    let emptyModel = (rect.size.width <= 0) || (rect.size.height <= 0)
    if emptyModel {
      self.mConstrainedRect = CGRect (x:0.0, y:0.0, width:500.0, height:500.0)
    }else{
      self.mConstrainedRect = rect.cocoaRect ()
    }
    self.updateViewFrameAndBounds ()
  }

  //····················································································································

  func updateViewFrameAndBounds () {
    let newRect = self.mConstrainedRect.union (self.objectBoundingBox ())
    self.frame.size = newRect.size
    self.bounds = newRect
    scaleToZoom (self.mZoom, self.mHorizontalFlip, self.mVerticalFlip)
  }

  //····················································································································

  override func updateObjectDisplay (_ inObjectDisplayArray : [EBShape]) {
    super.updateObjectDisplay (inObjectDisplayArray)
    self.updateViewFrameAndBounds ()
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
      let toggleHorizontalFlip : CGFloat = (inHorizontalFlip != self.mHorizontalFlip) ? -1.0 : 1.0 ;
      let toggleVerticalFlip   : CGFloat = (inVerticalFlip != self.mVerticalFlip) ? -1.0 : 1.0 ;
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
      self.mZoomPopUpButton?.menu?.item (at:0)?.title = (0 == inZoom) ? ("(" + zoomTitle + ")") : zoomTitle
      self.setNeedsDisplay (self.frame)
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

  @objc func setZoomFromPopUpButton (_ inSender : NSMenuItem) {
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
        name: NSView.frameDidChangeNotification,
        object: clipView
      )
      if let scrollView = clipView.superview as? CanariScrollViewWithPlacard {
        let r = NSRect (x:0.0, y:0.0, width:70.0, height:20.0)
        let zoomPopUpButton = NSPopUpButton (frame:r, pullsDown:true)
        mZoomPopUpButton = zoomPopUpButton
        zoomPopUpButton.font = NSFont.systemFont (ofSize:NSFont.smallSystemFontSize)
        zoomPopUpButton.autoenablesItems = false
        zoomPopUpButton.bezelStyle = .shadowlessSquare
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
        self.addPopupButtonItemForZoom (500)
        self.addPopupButtonItemForZoom (600)
        self.addPopupButtonItemForZoom (800)
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
              name: NSView.frameDidChangeNotification,
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

  @objc func updateAfterSuperviewResising (_ inSender: Any?) {
    if mZoom == 0 {
      scaleToZoom (mZoom, mHorizontalFlip, mVerticalFlip)
    }
  }

  //····················································································································
  //  Horizontal flip
  //····················································································································

  func horizontalFlip () -> Bool {
    return mHorizontalFlip
  }

  //····················································································································

  func setHorizontalFlipFromController (_ inFlip : Bool) {
    scaleToZoom (mZoom, inFlip, mVerticalFlip)
    mHorizontalFlip = inFlip
  }

  //····················································································································
  //  Vertical flip
  //····················································································································

  func verticalFlip () -> Bool {
    return mVerticalFlip
  }

  //····················································································································

  func setVerticalFlipFromController (_ inFlip : Bool) {
    scaleToZoom (mZoom, mHorizontalFlip, inFlip)
    mVerticalFlip = inFlip
  }

  //····················································································································
  //  Zoom pop up button activation
  //····················································································································

  func setZoom (_ inZoom : Int, activateZoomPopUpButton inActivate : Bool) {
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
    __NSRectFill (self.bounds)
  }

  //····················································································································
  //    Grid Style
  //····················································································································

  fileprivate var mGridStyle : GridStyle = .noGrid

  func setGridStyle (_ inGrid : GridStyle) {
    if mGridStyle != inGrid {
      mGridStyle = inGrid
      self.needsDisplay = true
    }
  }

  //····················································································································
  //    Grid Step Factor
  //····················································································································

  fileprivate var mGridStepFactor : Int = 4

  func setGridStepFactor (_ inGridStepFactor : Int) {
    if mGridStepFactor != inGridStepFactor {
      mGridStepFactor = inGridStepFactor
      self.needsDisplay = true
    }
  }

  //····················································································································
  //    Grid Step
  //····················································································································

  fileprivate var mGridStep : CGFloat = milsToCocoaUnit (25.0)

  func setGridStep (_ inGridStep : CGFloat) {
    if mGridStep != inGridStep {
      mGridStep = inGridStep
      self.needsDisplay = true
    }
  }

  //····················································································································
  //    Grid Dot color
  //····················································································································

  fileprivate var mGridDotColor : NSColor = .black

  func setGridDotColor (_ inColor : NSColor) {
    if mGridDotColor != inColor {
      mGridDotColor = inColor
      self.needsDisplay = true
    }
  }

  //····················································································································
  //    Grid Line color
  //····················································································································

  fileprivate var mGridLineColor : NSColor = .black

  func setGridLineColor (_ inColor : NSColor) {
    if mGridLineColor != inColor {
      mGridLineColor = inColor
      self.needsDisplay = true
    }
  }

  //····················································································································
  //    Set issue
  //····················································································································

  private var mIssueShapes = EBShape ()

  //····················································································································

  func setIssue (_ shapes : EBShape) {
    if mIssueShapes != shapes {
      mIssueShapes = shapes
      self.needsDisplay = true
    }
  }

  //····················································································································
  //    draw
  //····················································································································

  fileprivate func drawGrid (_ inDirtyRect: NSRect) {
    let r = self.bounds
    let gridDisplayStep = self.mGridStep * CGFloat (self.mGridStepFactor)
    let startX = (r.origin.x / gridDisplayStep).rounded (.down) * gridDisplayStep
    let endX = r.maxX
    let startY = (r.origin.y / gridDisplayStep).rounded (.down) * gridDisplayStep
    let endY = r.maxY
    switch self.mGridStyle {
    case .noGrid :
      ()
    case .dot :
      let bp = NSBezierPath ()
      bp.lineWidth = 0.0
      bp.lineCapStyle = .round
      var x = startX
      while x <= endX {
        var y = startY
        while y <= endY {
          bp.move (to: NSPoint (x: x - 0.5, y: y))
          bp.line (to: NSPoint (x: x + 0.5, y: y))
          bp.move (to: NSPoint (x: x,       y: y + 0.5))
          bp.line (to: NSPoint (x: x,       y: y - 0.5))
          y += gridDisplayStep
        }
        x += gridDisplayStep
      }
      self.mGridDotColor.setStroke ()
      bp.stroke ()
    case .line :
      let bp = NSBezierPath ()
      bp.lineWidth = 0.0
      bp.lineCapStyle = .round
      var x = startX
      while x <= r.maxX {
        bp.move (to: NSPoint (x: x, y: startY))
        bp.line (to: NSPoint (x: x, y: endY))
        x += gridDisplayStep
      }
      var y = startY
      while y <= endY {
        bp.move (to: NSPoint (x: startX, y: y))
        bp.line (to: NSPoint (x: endX,   y: y))
        y += gridDisplayStep
      }
      self.mGridLineColor.setStroke ()
      bp.stroke ()
    }
  }

  //····················································································································

  override func draw (_ inDirtyRect: NSRect) {
    self.drawGrid (inDirtyRect)
    super.draw (inDirtyRect)
    self.mIssueShapes.draw (inDirtyRect)
  }

  //····················································································································
  //    rect binding
  //····················································································································

  private var mRectController : Controller_CanariViewWithZoomAndFlip_rect?

  func bind_rect (_ rect:EBReadOnlyProperty_CanariRect, file:String, line:Int) {
    mRectController = Controller_CanariViewWithZoomAndFlip_rect (rect:rect, outlet:self)
  }

  func unbind_rect () {
    mRectController?.unregister ()
    mRectController = nil
  }

  //····················································································································
  //    zoom binding
  //····················································································································

  private var mZoomController : Controller_CanariViewWithZoomAndFlip_zoom?

  func bind_zoom (_ zoom:EBReadWriteProperty_Int, file:String, line:Int) {
    mZoomController = Controller_CanariViewWithZoomAndFlip_zoom (zoom:zoom, outlet:self)
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
    mHorizontalFlipController = Controller_CanariViewWithZoomAndFlip_horizontalFlip (flip:flip, outlet:self)
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
    mVerticalFlipController = Controller_CanariViewWithZoomAndFlip_verticalFlip (flip:flip, outlet:self)
  }

  func unbind_verticalFlip () {
    mVerticalFlipController?.unregister ()
    mVerticalFlipController = nil
  }

  //····················································································································
  //    grid binding
  //····················································································································

  private var mGridStyleController : Controller_CanariViewWithZoomAndFlip_gridStyle?

  func bind_gridStyle (_ model: EBReadOnlyProperty_GridStyle, file:String, line:Int) {
    mGridStyleController = Controller_CanariViewWithZoomAndFlip_gridStyle (model: model, outlet:self)
  }

  func unbind_gridStyle () {
    mGridStyleController?.unregister ()
    mGridStyleController = nil
  }

  //····················································································································
  //    step binding
  //····················································································································

  private var mGridStepFactorController : Controller_CanariViewWithZoomAndFlip_gridStepFactor?

  func bind_gridStepFactor (_ model: EBReadOnlyProperty_Int, file:String, line:Int) {
    self.mGridStepFactorController = Controller_CanariViewWithZoomAndFlip_gridStepFactor (model: model, outlet:self)
  }

  func unbind_gridStepFactor () {
    self.mGridStepFactorController?.unregister ()
    self.mGridStepFactorController = nil
  }

  //····················································································································
  //    grid line color binding
  //····················································································································

  private var mGridLineColorController : Controller_CanariViewWithZoomAndFlip_gridLineColor?

  func bind_gridLineColor (_ model: EBReadOnlyProperty_NSColor, file:String, line:Int) {
    mGridLineColorController = Controller_CanariViewWithZoomAndFlip_gridLineColor (model: model, outlet:self)
  }

  func unbind_gridLineColor () {
    mGridLineColorController?.unregister ()
    mGridLineColorController = nil
  }

  //····················································································································
  //    grid dot color binding
  //····················································································································

  private var mGridDotColorController : Controller_CanariViewWithZoomAndFlip_gridDotColor?

  func bind_gridDotColor (_ model: EBReadOnlyProperty_NSColor, file:String, line:Int) {
    mGridDotColorController = Controller_CanariViewWithZoomAndFlip_gridDotColor (model: model, outlet:self)
  }

  func unbind_gridDotColor () {
    mGridDotColorController?.unregister ()
    mGridDotColorController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariViewWithZoomAndFlip_rect
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariViewWithZoomAndFlip_rect : EBSimpleController {

  private let mRect : EBReadOnlyProperty_CanariRect
  private let mOutlet : CanariViewWithZoomAndFlip

  //····················································································································

  init (rect : EBReadOnlyProperty_CanariRect, outlet : CanariViewWithZoomAndFlip) {
    mRect = rect
    mOutlet = outlet
    super.init (observedObjects:[rect], outlet:outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    var rect = CanariRect ()
    switch mRect.prop {
    case .empty :
      ()
    case .single (let v) :
      rect = v
    case .multiple :
      ()
    }
    mOutlet.set (rect: rect)
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

  init (zoom : EBReadWriteProperty_Int, outlet : CanariViewWithZoomAndFlip) {
    mZoom = zoom
    mOutlet = outlet
    super.init (observedObjects:[zoom], outlet:outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch mZoom.prop {
    case .empty :
      mOutlet.setZoom (100, activateZoomPopUpButton: false)
    case .single (let v) :
      mOutlet.setZoom (v, activateZoomPopUpButton: true)
    case .multiple :
      mOutlet.setZoom (100, activateZoomPopUpButton: false)
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

  init (flip : EBReadOnlyProperty_Bool, outlet : CanariViewWithZoomAndFlip) {
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

  init (flip : EBReadOnlyProperty_Bool, outlet : CanariViewWithZoomAndFlip) {
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
//   Controller_CanariViewWithZoomAndFlip_gridStyle
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariViewWithZoomAndFlip_gridStyle : EBSimpleController {

  private let mModel : EBReadOnlyProperty_GridStyle
  private let mOutlet : CanariViewWithZoomAndFlip

  //····················································································································

  init (model : EBReadOnlyProperty_GridStyle, outlet : CanariViewWithZoomAndFlip) {
    mModel = model
    mOutlet = outlet
    super.init (observedObjects:[model], outlet:outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch mModel.prop {
    case .empty :
      mOutlet.setGridStyle (.noGrid)
    case .single (let v) :
      mOutlet.setGridStyle (v)
    case .multiple :
      mOutlet.setGridStyle (.noGrid)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariViewWithZoomAndFlip_gridStepFactor
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariViewWithZoomAndFlip_gridStepFactor : EBSimpleController {

  private let mModel : EBReadOnlyProperty_Int
  private let mOutlet : CanariViewWithZoomAndFlip

  //····················································································································

  init (model : EBReadOnlyProperty_Int, outlet : CanariViewWithZoomAndFlip) {
    mModel = model
    mOutlet = outlet
    super.init (observedObjects:[model], outlet:outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch mModel.prop {
    case .empty :
      mOutlet.setGridStepFactor (4)
    case .single (let v) :
      mOutlet.setGridStepFactor (v)
    case .multiple :
      mOutlet.setGridStepFactor (4)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariViewWithZoomAndFlip_gridLineColor
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariViewWithZoomAndFlip_gridLineColor : EBSimpleController {

  private let mModel : EBReadOnlyProperty_NSColor
  private let mOutlet : CanariViewWithZoomAndFlip

  //····················································································································

  init (model : EBReadOnlyProperty_NSColor, outlet : CanariViewWithZoomAndFlip) {
    mModel = model
    mOutlet = outlet
    super.init (observedObjects:[model], outlet:outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch mModel.prop {
    case .empty :
      mOutlet.setGridLineColor (.black)
    case .single (let v) :
      mOutlet.setGridLineColor (v)
    case .multiple :
      mOutlet.setGridLineColor (.black)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariViewWithZoomAndFlip_gridDotColor
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariViewWithZoomAndFlip_gridDotColor : EBSimpleController {

  private let mModel : EBReadOnlyProperty_NSColor
  private let mOutlet : CanariViewWithZoomAndFlip

  //····················································································································

  init (model : EBReadOnlyProperty_NSColor, outlet : CanariViewWithZoomAndFlip) {
    mModel = model
    mOutlet = outlet
    super.init (observedObjects:[model], outlet:outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch mModel.prop {
    case .empty :
      mOutlet.setGridDotColor (.black)
    case .single (let v) :
      mOutlet.setGridDotColor (v)
    case .multiple :
      mOutlet.setGridDotColor (.black)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
