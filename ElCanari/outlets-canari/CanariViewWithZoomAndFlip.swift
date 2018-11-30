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

  fileprivate var mMinimumBounds : NSRect? = nil

  private func set (canariBounds : CanariRect) {
    let emptyModel = (canariBounds.size.width <= 0) || (canariBounds.size.height <= 0)
    if emptyModel {
      self.mMinimumBounds = nil
    }else{
      self.mMinimumBounds = canariBounds.cocoaRect ()
    }
    self.updateViewFrameAndBounds ()
  }

  //····················································································································

  func updateViewFrameAndBounds () {
    var newRect = self.objectBoundingBox ()
    if let minimumBounds = self.mMinimumBounds {
      newRect = newRect.union (minimumBounds)
    }
//    if let view = self.superview as? NSClipView {
//    //  newRect = newRect.union (view.documentVisibleRect)
//      let r = view.convert (view.documentRect, from: self)
//      newRect = newRect.union (r)
////      NSLog ("\(r)")
//    }
    if self.bounds != newRect {
      self.frame.size = newRect.size
      self.bounds = newRect
      scaleToZoom (self.mZoom, self.mHorizontalFlip, self.mVerticalFlip)
    }
  }

  //····················································································································

  override func updateObjectDisplay (_ inObjectDisplayArray : [EBShape]) {
    super.updateObjectDisplay (inObjectDisplayArray)
    self.updateViewFrameAndBounds ()
  }

  //····················································································································

  override func objectBoundingBox () -> NSRect {
    var r = super.objectBoundingBox ()
    if let issueBezierPath = self.mIssueBezierPath {
      let e = -issueBezierPath.lineWidth / 2.0
      r = r.union (issueBezierPath.bounds.insetBy(dx: e, dy: e))
    }
    return r
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
        self.addPopupButtonItemForZoom (1200)
        self.addPopupButtonItemForZoom (1500)
        self.addPopupButtonItemForZoom (1700)
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

  private var mIssueBezierPath : NSBezierPath? = nil
  private var mIssueKind : CanariIssueKind = .error // Any value, not used if mIssueBezierPath is nil

  //····················································································································

  func setIssue (_ inBezierPath : NSBezierPath?, _ issueKind : CanariIssueKind) {
    if self.mIssueBezierPath != inBezierPath {
      self.mIssueBezierPath = inBezierPath
      self.mIssueKind = issueKind
      self.updateViewFrameAndBounds ()
      self.needsDisplay = true
    }
  }

  //····················································································································

  private func drawIssue (_ inDirtyRect : NSRect) {
    if let issueBezierPath = self.mIssueBezierPath {
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
  //····················································································································

  fileprivate func drawGrid (_ inDirtyRect: NSRect) {
    let r = self.bounds
    let gridDisplayStep = self.mGridStep * CGFloat (self.mGridStepFactor)
    let startX = (r.origin.x / gridDisplayStep).rounded (.down) * gridDisplayStep
    let endX = r.maxX
    let startY = (r.origin.y / gridDisplayStep).rounded (.down) * gridDisplayStep
    let endY = r.maxY
    let displayOffset = 0.5 / self.actualScale ()
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
      bp.lineWidth = 0.0 // 1.0 / self.actualScale ()
      bp.lineCapStyle = .round
      var x = startX
      while x <= r.maxX {
        bp.move (to: NSPoint (x: x + displayOffset, y: startY + displayOffset))
        bp.line (to: NSPoint (x: x + displayOffset, y: endY + displayOffset))
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

  override func draw (_ inDirtyRect: NSRect) {
    self.drawGrid (inDirtyRect)
    super.draw (inDirtyRect)
    self.drawIssue (inDirtyRect)
  }

  //····················································································································
  //    rect binding
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
    self.set (canariBounds: rect)
  }


  //····················································································································
  //    zoom binding
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
  //····················································································································

  private var mHorizontalFlipController : EBReadOnlyController_Bool? = nil

  func bind_horizontalFlip (_ model : EBReadOnlyProperty_Bool, file : String, line : Int) {
    self.mHorizontalFlipController = EBReadOnlyController_Bool (
      model: model,
      callBack: { [weak self] in self?.updateHorizontalFlip (from: model) }
    )
  }

  func unbind_horizontalFlip () {
    self.mHorizontalFlipController?.unregister ()
    self.mHorizontalFlipController = nil
  }

  //····················································································································

  private func updateHorizontalFlip (from model : EBReadOnlyProperty_Bool) {
    switch model.prop {
    case .empty :
      self.setHorizontalFlipFromController (false)
    case .single (let v) :
      self.setHorizontalFlipFromController (v)
    case .multiple :
      self.setHorizontalFlipFromController (false)
    }
  }


  //····················································································································
  //    vertical flip binding
  //····················································································································

  private var mVerticalFlipController : EBReadOnlyController_Bool? = nil

  func bind_verticalFlip (_ model : EBReadOnlyProperty_Bool, file : String, line : Int) {
    self.mVerticalFlipController = EBReadOnlyController_Bool (
      model: model,
      callBack: { [weak self] in self?.updateVerticalFlip (from: model) }
    )
  }

  func unbind_verticalFlip () {
    self.mVerticalFlipController?.unregister ()
    self.mVerticalFlipController = nil
  }

  //····················································································································

  private func updateVerticalFlip (from model : EBReadOnlyProperty_Bool) {
    switch model.prop {
    case .empty :
      self.setVerticalFlipFromController (false)
    case .single (let v) :
      self.setVerticalFlipFromController (v)
    case .multiple :
      self.setVerticalFlipFromController (false)
    }
  }

  //····················································································································
  //    grid binding
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
  //    step binding
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
