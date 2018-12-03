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

  //····················································································································

  func updateViewFrameAndBounds () {
    scaleToZoom (self.mZoom, self.mHorizontalFlip, self.mVerticalFlip)
  }

  //····················································································································

  override func updateObjectDisplay (_ inObjectDisplayArray : [EBShape]) {
    super.updateObjectDisplay (inObjectDisplayArray)
    self.updateViewFrameAndBounds ()
  }

  //····················································································································

  override func objectBoundingBox () -> NSRect {
    var r = super.objectBoundingBox ()
    if let issueBezierPath = self.mIssueBezierPath, !issueBezierPath.isEmpty {
      let e = -issueBezierPath.lineWidth / 2.0
      r = r.union (issueBezierPath.bounds.insetBy (dx: e, dy: e))
    }
    return r
  }

  //····················································································································
  //  NSView overriden methods
  //  MARK: -
  //····················································································································

//  override func viewDidMoveToWindow () {
//    super.viewDidMoveToWindow ()
// //   self.updateViewFrameAndBounds ()
//  }

  //····················································································································

//  override func viewDidEndLiveResize () {
//    super.viewDidEndLiveResize ()
// //   self.updateViewFrameAndBounds ()
//  }

  //····················································································································

  override func viewDidMoveToSuperview () {
    super.viewDidMoveToSuperview ()
    if let scrollView = self.enclosingScrollView as? CanariScrollViewWithPlacard {
      self.installZoomPopUpButton (scrollView)
      self.installXYplacards (scrollView)
    }
  }

  //····················································································································
  //  scaleToZoom
  //  MARK: -
  //····················································································································

  fileprivate var mZoom = 100

  //····················································································································

  fileprivate func scaleToZoom (_ inZoom : Int,  // 0 -> fit to window
                                _ inHorizontalFlip : Bool,
                                _ inVerticalFlip : Bool) {
    if let clipView = self.superview as? NSClipView {
      var newRect = self.objectBoundingBox ()
      if let issueBezierPath = self.mIssueBezierPath, !issueBezierPath.isEmpty {
        newRect = newRect.union (issueBezierPath.bounds)
      }
      if let minimumBounds = self.mMinimumRect {
        newRect = newRect.union (minimumBounds)
      }
      let r = clipView.convert (clipView.documentVisibleRect, from: self)
      newRect = newRect.union (r)
      if self.bounds != newRect {
        self.frame.size = newRect.size
        self.bounds = newRect
      }
      let currentUnitSquareSize : NSSize = clipView.convert (NSSize (width: 1.0, height: 1.0), from:nil)
      let currentScale = 1.0 / currentUnitSquareSize.width
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
      self.mZoomPopUpButton?.menu?.item (at:0)?.title = (0 == inZoom) ? ("(\(zoomTitle))") : zoomTitle
      self.setNeedsDisplay (self.frame)
    }
  }
  
  //····················································································································

  func actualScale () -> CGFloat {
    var result : CGFloat = 1.0
    if let clipView = self.superview as? NSClipView {
      let currentScale : NSSize = clipView.convert (NSSize (width: 1.0, height: 1.0), from:nil)
      result = 1.0 / currentScale.width
    }
    return result
  }

  //····················································································································
  //  Managing zoom popup button
  //  MARK: -
  //····················································································································

  fileprivate var mZoomPopUpButton : NSPopUpButton? = nil

  //····················································································································

  fileprivate func addPopupButtonItemForZoom (_ inZoom : Int) {
    if let zoomPopUpButton = self.mZoomPopUpButton {
      zoomPopUpButton.menu?.addItem (withTitle: ("\(inZoom) %"), action:#selector (CanariViewWithZoomAndFlip.setZoomFromPopUpButton(_:)), keyEquivalent: "")
      zoomPopUpButton.lastItem?.target = self
      zoomPopUpButton.lastItem?.tag = inZoom
    }
  }

  //····················································································································

  @objc func setZoomFromPopUpButton (_ inSender : NSMenuItem) {
    scaleToZoom (inSender.tag, self.mHorizontalFlip, self.mVerticalFlip)
    self.mZoom = inSender.tag
    self.mZoomController?.updateModel (self)
  }

  //····················································································································

  private func installZoomPopUpButton (_ inScrollView : CanariScrollViewWithPlacard) {
    if self.mZoomPopUpButton == nil {
      let r = NSRect (x: 0.0, y: 0.0, width: 70.0, height: 20.0)
      let zoomPopUpButton = NSPopUpButton (frame:r, pullsDown:true)
      self.mZoomPopUpButton = zoomPopUpButton
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
      self.addPopupButtonItemForZoom (1200)
      self.addPopupButtonItemForZoom (1500)
      self.addPopupButtonItemForZoom (1700)
      self.addPopupButtonItemForZoom (2000)
      zoomPopUpButton.menu?.addItem (withTitle:"Fit to Window", action:#selector (CanariViewWithZoomAndFlip.setZoomFromPopUpButton(_:)), keyEquivalent:"")
      zoomPopUpButton.lastItem?.target = self
      zoomPopUpButton.lastItem?.tag = 0
      inScrollView.addPlacard (zoomPopUpButton)
    }
  }

  //····················································································································
  //  Managing mouse location
  //  MARK: -
  //····················································································································

  private var mXPlacard : NSTextField? = nil
  private var mYPlacard : NSTextField? = nil

  //····················································································································

  private func installXYplacards (_ inScrollView : CanariScrollViewWithPlacard) {
    if self.mXPlacard == nil {
      let r = NSRect (x: 0.0, y: 0.0, width: 90.0, height: 20.0)
      let xPlacard = NSTextField (frame: r)
      self.mXPlacard = xPlacard
      xPlacard.font = NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
      xPlacard.isBordered = false
      inScrollView.addPlacard (xPlacard)
    }
    if self.mYPlacard == nil {
      let r = NSRect (x: 0.0, y: 0.0, width: 90.0, height: 20.0)
      let yPlacard = NSTextField (frame: r)
      self.mYPlacard = yPlacard
      yPlacard.font = NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
      yPlacard.isBordered = false
      inScrollView.addPlacard (yPlacard)
    }
  }

  //····················································································································

  private func updateXYplacards (_ inLocationInWindow : NSPoint) {
    let p = self.convert (inLocationInWindow, from: nil)
    let x = stringFrom (valueInCocoaUnit: p.x, displayUnit: self.mXPlacardUnit)
    let y = stringFrom (valueInCocoaUnit: p.y, displayUnit: self.mYPlacardUnit)
    self.mXPlacard?.stringValue = "X = " + x
    self.mYPlacard?.stringValue = "Y = " + y
  }

  //····················································································································

  private func clearXYplacards () {
    self.mXPlacard?.stringValue = ""
    self.mYPlacard?.stringValue = ""
  }

  //····················································································································
  //  Mouse moved and tracking area
  //  MARK: -
  //····················································································································

  fileprivate var mTrackingArea : NSTrackingArea? = nil

  //····················································································································

  override func updateTrackingAreas () { // This is required for receiving mouse moved and mouseExited events
  //---
    self.updateViewFrameAndBounds ()
  //--- Remove tracking area
    if let trackingArea = self.mTrackingArea {
      self.removeTrackingArea (trackingArea)
    }
  //--- Add Updated tracking area
    let trackingArea = NSTrackingArea (
      rect: self.bounds,
      options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow],
      owner: self,
      userInfo: nil
    )
    self.addTrackingArea (trackingArea)
    self.mTrackingArea = trackingArea
  //---
    super.updateTrackingAreas ()
  }

  //····················································································································

  override func mouseMoved (with inEvent : NSEvent) {
    super.mouseMoved (with: inEvent)
    self.updateXYplacards (inEvent.locationInWindow)
  }

  //····················································································································

  override func mouseDragged (with inEvent : NSEvent) {
    super.mouseDragged (with: inEvent)
    self.updateXYplacards (inEvent.locationInWindow)
  }

  //····················································································································

  override func mouseExited (with inEvent : NSEvent) {
    super.mouseExited (with: inEvent)
    self.clearXYplacards ()
  }

  //····················································································································
  // X placard unit binding
  // MARK: -
  //····················································································································

  private var mXPlacardUnitController : EBReadOnlyController_Int? = nil
  private var mXPlacardUnit = 2286 // mils

  func bind_xPlacardUnit (_ model : EBReadOnlyProperty_Int, file : String, line : Int) {
    self.mXPlacardUnitController = EBReadOnlyController_Int (
      model: model,
      callBack: { [weak self] in self?.updateXPlacardUnit (from: model) }
    )
  }

  func unbind_xPlacardUnit () {
    self.mXPlacardUnitController?.unregister ()
    self.mXPlacardUnitController = nil
  }

  //····················································································································

  private func updateXPlacardUnit (from model : EBReadOnlyProperty_Int) {
    switch model.prop {
    case .empty, .multiple :
      self.mXPlacardUnit = 2286 // mils
    case .single (let v) :
      self.mXPlacardUnit = v
    }
  }

  //····················································································································
  // Y placard unit binding
  // MARK: -
  //····················································································································

  private var mYPlacardUnitController : EBReadOnlyController_Int? = nil
  private var mYPlacardUnit = 2286 // mils

  func bind_yPlacardUnit (_ model : EBReadOnlyProperty_Int, file : String, line : Int) {
    self.mYPlacardUnitController = EBReadOnlyController_Int (
      model: model,
      callBack: { [weak self] in self?.updateYPlacardUnit (from: model) }
    )
  }

  func unbind_yPlacardUnit () {
    self.mYPlacardUnitController?.unregister ()
    self.mYPlacardUnitController = nil
  }

  //····················································································································

  private func updateYPlacardUnit (from model : EBReadOnlyProperty_Int) {
    switch model.prop {
    case .empty, .multiple :
      self.mYPlacardUnit = 2286 // mils
    case .single (let v) :
      self.mYPlacardUnit = v
    }
  }

  //····················································································································
  //  Super view has been resized
  //  MARK: -
  //····················································································································

  override func viewWillMove (toSuperview inSuperview : NSView?) {
     super.viewWillMove (toSuperview: inSuperview)
  //--- Remove from superview ?
    if nil == inSuperview,
       let scrollView = self.superview?.superview as? CanariScrollViewWithPlacard,
       let zoomPopUpButton = self.mZoomPopUpButton {
     scrollView.removePlacard (zoomPopUpButton)
     self.mZoomPopUpButton = nil ;
    }
  }

  //····················································································································
  //  magnifyWithEvent
  //····················································································································

  override func magnify (with inEvent : NSEvent) {
    let newZoom = Int ((actualScale () * 100.0 * (inEvent.magnification + 1.0)).rounded (.toNearestOrEven))
    scaleToZoom (newZoom, self.mHorizontalFlip, self.mVerticalFlip)
    self.mZoom = newZoom
  }

  //····················································································································
  //  Zoom pop up button activation
  //····················································································································

  func setZoom (_ inZoom : Int, activateZoomPopUpButton inActivate : Bool) {
    scaleToZoom (inZoom, self.mHorizontalFlip, self.mVerticalFlip)
    self.mZoom = inZoom
    self.mZoomPopUpButton?.isEnabled = inActivate
  }

  //····················································································································
  //  Responder chain
  // MARK: -
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
    NSBezierPath.fill (self.bounds)
  }

  //····················································································································
  //    Grid Style
  // MARK: -
  //····················································································································

  fileprivate var mGridStyle : GridStyle = .noGrid

  func setGridStyle (_ inGrid : GridStyle) {
    if self.mGridStyle != inGrid {
      self.mGridStyle = inGrid
      self.needsDisplay = true
    }
  }

  //····················································································································
  //    Grid Step Factor
  //····················································································································

  fileprivate var mGridStepFactor : Int = 4

  func setGridStepFactor (_ inGridStepFactor : Int) {
    if self.mGridStepFactor != inGridStepFactor {
      self.mGridStepFactor = inGridStepFactor
      self.needsDisplay = true
    }
  }

  //····················································································································
  //    Grid Step
  //····················································································································

  fileprivate var mGridStep : CGFloat = milsToCocoaUnit (25.0)

  func setGridStep (_ inGridStep : CGFloat) {
    if self.mGridStep != inGridStep {
      self.mGridStep = inGridStep
      self.needsDisplay = true
    }
  }

  //····················································································································
  //    Grid Dot color
  //····················································································································

  fileprivate var mGridDotColor : NSColor = .black

  func setGridDotColor (_ inColor : NSColor) {
    if self.mGridDotColor != inColor {
      self.mGridDotColor = inColor
      self.needsDisplay = true
    }
  }

  //····················································································································
  //    Grid Line color
  //····················································································································

  fileprivate var mGridLineColor : NSColor = .black

  func setGridLineColor (_ inColor : NSColor) {
    if self.mGridLineColor != inColor {
      self.mGridLineColor = inColor
      self.needsDisplay = true
    }
  }

  //····················································································································
  //    Set issue
  // MARK: -
  //····················································································································

  private var mIssueBezierPath : NSBezierPath? = nil
  private var mIssueKind : CanariIssueKind = .error // Any value, not used if mIssueBezierPath is nil

  //····················································································································

  func setIssue (_ inBezierPath : NSBezierPath?, _ issueKind : CanariIssueKind) {
    if self.mIssueBezierPath != inBezierPath {
      self.mIssueBezierPath = inBezierPath
      self.mIssueKind = issueKind
      self.updateViewFrameAndBounds ()
    }
  }

  //····················································································································

  private func drawIssue (_ inDirtyRect : NSRect) {
    if let issueBezierPath = self.mIssueBezierPath, !issueBezierPath.isEmpty {
      switch self.mIssueKind {
      case .error :
        NSColor.red.withAlphaComponent (0.15).setFill ()
        issueBezierPath.fill ()
        NSColor.red.setStroke ()
        issueBezierPath.stroke ()
      case .warning :
        NSColor.orange.withAlphaComponent (0.15).setFill ()
        issueBezierPath.fill ()
        NSColor.orange.setStroke ()
        issueBezierPath.stroke ()
      }
    }
  }

  //····················································································································
  //    draw Grid
  // MARK: -
  //····················································································································

  fileprivate func drawGrid (_ inDirtyRect: NSRect) {
    let r = inDirtyRect // self.bounds
    let gridDisplayStep = self.mGridStep * CGFloat (self.mGridStepFactor)
    let startX = (r.origin.x / gridDisplayStep).rounded (.down) * gridDisplayStep
    let endX = r.maxX
    let startY = (r.origin.y / gridDisplayStep).rounded (.down) * gridDisplayStep
    let endY = r.maxY
    let displayOffset = 0.5 / self.actualScale ()
    switch self.mGridStyle {
    case .noGrid :
      ()
    case .cross :
      let bp = NSBezierPath ()
      bp.lineWidth = 0.0
      bp.lineCapStyle = .round
      var x = startX
      while x <= endX {
        var y = startY
        while y <= endY {
          bp.move (to: NSPoint (x: x - 0.5 + displayOffset, y: y + displayOffset))
          bp.line (to: NSPoint (x: x + 0.5 + displayOffset, y: y + displayOffset))
          bp.move (to: NSPoint (x: x + displayOffset,       y: y + 0.5 + displayOffset))
          bp.line (to: NSPoint (x: x + displayOffset,       y: y - 0.5 + displayOffset))
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
        let p1 = NSPoint (x: x + displayOffset, y: startY + displayOffset)
        let p2 = NSPoint (x: x + displayOffset, y: endY + displayOffset)
        bp.move (to: p1)
        bp.line (to: p2)
        x += gridDisplayStep
      }
      var y = startY
      while y <= endY {
        bp.move (to: NSPoint (x: startX + displayOffset, y: y + displayOffset))
        bp.line (to: NSPoint (x: endX   + displayOffset, y: y + displayOffset))
        y += gridDisplayStep
      }
      self.mGridLineColor.setStroke ()
      bp.stroke ()
    }
  }

  //····················································································································
  // Draw dirty rect
  // MARK: -
  //····················································································································

  override func drawUnderObjects (_ inDirtyRect: NSRect) {
    self.drawGrid (inDirtyRect)
    super.drawUnderObjects (inDirtyRect)
  }

  //····················································································································

  override func drawOverObjects (_ inDirtyRect: NSRect) {
    super.drawOverObjects (inDirtyRect)
    self.drawIssue (inDirtyRect)
  }

  //····················································································································
  //    rect binding
  // MARK: -
  //····················································································································

  private var mCanariRectController : EBReadOnlyController_CanariRect? = nil

  func bind_canariRect (_ model : EBReadOnlyProperty_CanariRect, file : String, line : Int) {
   self.mCanariRectController = EBReadOnlyController_CanariRect (
      model: model,
      callBack: { [weak self] in self?.updateRect (from: model) }
    )
  }

  func unbind_canariRect () {
    self.mCanariRectController?.unregister ()
    self.mCanariRectController = nil
  }

  //····················································································································

  private func updateRect (from model : EBReadOnlyProperty_CanariRect) {
    var rect = CanariRect ()
    switch model.prop {
    case .empty :
      ()
    case .single (let v) :
      rect = v
    case .multiple :
      ()
    }
    self.setMinimumRect (rect)
  }

  //····················································································································

  fileprivate var mMinimumRect : NSRect? = nil

  private func setMinimumRect (_ inCanariRect : CanariRect) {
    let emptyModel = (inCanariRect.size.width <= 0) || (inCanariRect.size.height <= 0)
    if emptyModel {
      self.mMinimumRect = nil
    }else{
      self.mMinimumRect = inCanariRect.cocoaRect ()
    }
    self.updateViewFrameAndBounds ()
  }

  //····················································································································
  //    zoom binding
  // MARK: -
  //····················································································································

  private var mZoomController : Controller_CanariViewWithZoomAndFlip_zoom?

  func bind_zoom (_ zoom:EBReadWriteProperty_Int, file:String, line:Int) {
    self.mZoomController = Controller_CanariViewWithZoomAndFlip_zoom (zoom:zoom, outlet:self)
  }

  func unbind_zoom () {
    self.mZoomController?.unregister ()
    self.mZoomController = nil
  }

  //····················································································································
  //    horizontal flip binding
  // MARK: -
  //····················································································································

  private var mHorizontalFlip = false
  private var mHorizontalFlipController : EBReadOnlyController_Bool? = nil

  //····················································································································

  func bind_horizontalFlip (_ model : EBReadOnlyProperty_Bool, file : String, line : Int) {
    self.mHorizontalFlipController = EBReadOnlyController_Bool (
      model: model,
      callBack: { [weak self] in self?.updateHorizontalFlip (from: model) }
    )
  }

  //····················································································································

  func unbind_horizontalFlip () {
    self.mHorizontalFlipController?.unregister ()
    self.mHorizontalFlipController = nil
  }

  //····················································································································

  private func updateHorizontalFlip (from model : EBReadOnlyProperty_Bool) {
    var horizontalFlip = false
    switch model.prop {
    case .empty, .multiple :
      ()
    case .single (let v) :
      horizontalFlip = v
    }
    self.setHorizontalFlip (horizontalFlip)
  }

  //····················································································································

  func setHorizontalFlip (_ inFlip : Bool) {
    scaleToZoom (self.mZoom, inFlip, self.mVerticalFlip)
    self.mHorizontalFlip = inFlip
  }

  //····················································································································

  func horizontalFlip () -> Bool {
    return self.mHorizontalFlip
  }

  //····················································································································
  //    vertical flip binding
  // MARK: -
  //····················································································································

  private var mVerticalFlip = false
  private var mVerticalFlipController : EBReadOnlyController_Bool? = nil

  //····················································································································

  func bind_verticalFlip (_ model : EBReadOnlyProperty_Bool, file : String, line : Int) {
    self.mVerticalFlipController = EBReadOnlyController_Bool (
      model: model,
      callBack: { [weak self] in self?.updateVerticalFlip (from: model) }
    )
  }

  //····················································································································

  func unbind_verticalFlip () {
    self.mVerticalFlipController?.unregister ()
    self.mVerticalFlipController = nil
  }

  //····················································································································

  private func updateVerticalFlip (from model : EBReadOnlyProperty_Bool) {
    switch model.prop {
    case .empty :
      self.setVerticalFlip (false)
    case .single (let v) :
      self.setVerticalFlip (v)
    case .multiple :
      self.setVerticalFlip (false)
    }
  }

  //····················································································································

  func setVerticalFlip (_ inFlip : Bool) {
    scaleToZoom (self.mZoom, self.mHorizontalFlip, inFlip)
    self.mVerticalFlip = inFlip
  }

  //····················································································································

  func verticalFlip () -> Bool {
    return self.mVerticalFlip
  }

  //····················································································································
  //    grid binding
  // MARK: -
  //····················································································································

  private var mGridStyleController : EBReadOnlyController_GridStyle? = nil

  func bind_gridStyle (_ model : EBReadOnlyProperty_GridStyle, file:String, line:Int) {
    self.mGridStyleController = EBReadOnlyController_GridStyle (
      model: model,
      callBack: { [weak self] in self?.updateGridStyle (from: model) }
    )
  }

  func unbind_gridStyle () {
    mGridStyleController?.unregister ()
    mGridStyleController = nil
  }

  //····················································································································

  private func updateGridStyle (from model : EBReadOnlyProperty_GridStyle) {
    switch model.prop {
    case .empty :
      self.setGridStyle (.noGrid)
    case .single (let v) :
      self.setGridStyle (v)
    case .multiple :
      self.setGridStyle (.noGrid)
    }
  }


  //····················································································································
  // step binding
  // MARK: -
  //····················································································································

  private var mGridStepFactorController : EBReadOnlyController_Int? = nil

  func bind_gridStepFactor (_ model : EBReadOnlyProperty_Int, file : String, line : Int) {
    self.mGridStepFactorController = EBReadOnlyController_Int (
      model: model,
      callBack: { [weak self] in self?.updateGridStepFactor (from: model) }
    )
  }

  func unbind_gridStepFactor () {
    self.mGridStepFactorController?.unregister ()
    self.mGridStepFactorController = nil
  }

  //····················································································································

  private func updateGridStepFactor (from model : EBReadOnlyProperty_Int) {
    switch model.prop {
    case .empty :
      self.setGridStepFactor (4)
    case .single (let v) :
      self.setGridStepFactor (v)
    case .multiple :
      self.setGridStepFactor (4)
    }
  }

  //····················································································································
  //    grid line color binding
  // MARK: -
  //····················································································································

  private var mGridLineColorController : EBReadOnlyController_NSColor? = nil

  //····················································································································

  func bind_gridLineColor (_ model: EBReadOnlyProperty_NSColor, file:String, line:Int) {
    mGridLineColorController = EBReadOnlyController_NSColor (
      model: model,
      callBack: { [weak self] in self?.updateLineColor (from: model) }
    )
  }

  //····················································································································

  func unbind_gridLineColor () {
    mGridLineColorController?.unregister ()
    mGridLineColorController = nil
  }

  //····················································································································

  private func updateLineColor (from model : EBReadOnlyProperty_NSColor) {
    switch model.prop {
    case .empty :
      self.setGridLineColor (.black)
    case .single (let v) :
      self.setGridLineColor (v)
    case .multiple :
      self.setGridLineColor (.black)
    }
  }

  //····················································································································
  //    grid dot color binding
  // MARK: -
  //····················································································································

  private var mGridDotColorController : EBReadOnlyController_NSColor? = nil

  //····················································································································

  func bind_gridDotColor (_ model: EBReadOnlyProperty_NSColor, file:String, line:Int) {
    self.mGridDotColorController = EBReadOnlyController_NSColor (
      model: model,
      callBack: { [weak self] in self?.updateGridColor (from: model) }
    )
  }

  //····················································································································

  func unbind_gridDotColor () {
    self.mGridDotColorController?.unregister ()
    self.mGridDotColorController = nil
  }

  //····················································································································

  private func updateGridColor (from model : EBReadOnlyProperty_NSColor) {
    switch model.prop {
    case .empty :
      self.setGridDotColor (.black)
    case .single (let v) :
      self.setGridDotColor (v)
    case .multiple :
      self.setGridDotColor (.black)
    }
  }

  //····················································································································
  //    Dragging destination
  // MARK: -
  //····················································································································
  // https://www.raywenderlich.com/1016-drag-and-drop-tutorial-for-macos

  //····················································································································

  let filteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes : NSImage.imageTypes]

  //····················································································································

  func shouldAllowDrag (_ draggingInfo: NSDraggingInfo) -> Bool {
    let pasteBoard = draggingInfo.draggingPasteboard
    return pasteBoard.canReadObject (forClasses: [NSURL.self], options: filteringOptions)
  }

  //····················································································································

  fileprivate var isReceivingDrag = false {
    didSet {
      self.needsDisplay = true
    }
  }

  //····················································································································

  override func draggingEntered (_ sender: NSDraggingInfo) -> NSDragOperation {
    let allow = shouldAllowDrag (sender)
    self.isReceivingDrag = allow
    return allow ? .copy : NSDragOperation ()
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
    super.init (observedObjects:[zoom])
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
