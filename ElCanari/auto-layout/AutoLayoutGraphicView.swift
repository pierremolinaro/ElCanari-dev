//
//  AutoLayoutGraphicView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/02/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   AutoLayoutGraphicView
//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutGraphicView : AutoLayoutVerticalStackView {

  //····················································································································

  let mGraphicView = EBGraphicView (frame: NSRect ())
  var mScrollView : EBScrollView? = nil
  fileprivate var mZoomPopUpButton : InternalAutoLayoutPopUpButton? = nil
  fileprivate var mZoomToFitButton : InternalAutoLayoutButton? = nil
  fileprivate var mHelperTextField : NSTextField? = nil
  fileprivate var mFocusRing : AutoLayoutPrivateFocusRingView? = nil

  //····················································································································

  init (minZoom inMinZoom : Int, maxZoom inMaxZoom : Int) {
    super.init ()
  //---
    _ = self.set (spacing: 0)
  //---
    let MARGIN = Int (FOCUS_RING_MARGIN)
    let hStack = AutoLayoutHorizontalStackView ().set (margins: MARGIN)
    hStack.alignment = .firstBaseline
    self.appendView (hStack)
  //--- Build popup button
    let zoomPopUp = buildZoomPopUpButton (minZoom: inMinZoom, maxZoom: inMaxZoom)
    hStack.appendView (zoomPopUp)
    self.mZoomPopUpButton = zoomPopUp
  //--- Build zoom to fit button
    let zoomToFitButton = buildZoomToFitButton ()
    hStack.appendView (zoomToFitButton)
    self.mZoomToFitButton = zoomToFitButton
  //--- Build helper text
    let helperTextField = buildHelperTextField ()
    hStack.appendView (helperTextField)
    self.mHelperTextField = helperTextField
    hStack.appendView (AutoLayoutFlexibleSpace ())
  //--- Build focus ring
    let focusRingView = AutoLayoutPrivateFocusRingView ().set (margins: MARGIN)
    self.appendView (focusRingView)
    self.mFocusRing = focusRingView
    // focusRingView.setFocusRing (true)
    self.mGraphicView.set (focusRingView: focusRingView)
  //--- Build scroll view
    let scrollView = buildScrollView (minZoom: inMinZoom, maxZoom: inMaxZoom)
    focusRingView.appendView (scrollView)
    self.mScrollView = scrollView

    self.mGraphicView.mZoomDidChangeCallback = {
      [weak self] (_ inZoom : Int) in self?.mZoomPopUpButton?.menu?.item (at:0)?.title = "\(inZoom) %"
    }
    self.mGraphicView.mHelperStringDidChangeCallback = {
      [weak self] (_ inString : String) in self?.mHelperTextField?.stringValue = inString
    }
  }

  //····················································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  fileprivate func buildScrollView (minZoom inMinZoom : Int, maxZoom inMaxZoom : Int) -> EBScrollView {
    let view = EBScrollView (frame: NSRect ())
    view.minMagnification = CGFloat (inMinZoom) / 100.0
    view.maxMagnification = CGFloat (inMaxZoom) / 100.0
    view.allowsMagnification = true
    view.hasHorizontalScroller = true
    view.hasVerticalScroller = true
    view.autohidesScrollers = false
    view.contentView = NSClipView (frame: NSRect ())
    view.documentView = self.mGraphicView
    return view
  }

  //····················································································································

  fileprivate func buildHelperTextField () -> NSTextField {
    let tf = NSTextField (frame: NSRect ())
    tf.isBezeled = false
    tf.isBordered = false
    tf.drawsBackground = false
//      tf.stringValue = "Hello"
//      tf.backgroundColor = NSColor.white
//      tf.drawsBackground = true
    tf.textColor = .black
    tf.isEnabled = true
    tf.isEditable = false
    tf.alignment = .left
    tf.controlSize = .small
    tf.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: tf.controlSize))
    return tf
  }

  //····················································································································

  fileprivate func buildZoomToFitButton () -> InternalAutoLayoutButton {
    let button = InternalAutoLayoutButton (title: "Zoom to Fit", small: true)
//    button.title = "Zoom to Fit"
//    button.controlSize = .small
//    button.font = NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
//    button.bezelStyle = autoLayoutCurrentStyle ().buttonStyle
    button.target = self
    button.action = #selector (Self.setZoomToFitButton (_:))
    return button
  }

  //····················································································································

  fileprivate func buildZoomPopUpButton (minZoom inMinZoom : Int, maxZoom inMaxZoom : Int) -> InternalAutoLayoutPopUpButton {
    let zoomPopUpButton = InternalAutoLayoutPopUpButton (pullsDown: true, small: true)
//    zoomPopUpButton.controlSize = .small
//    zoomPopUpButton.font = NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
//    zoomPopUpButton.autoenablesItems = false
//    zoomPopUpButton.bezelStyle = autoLayoutCurrentStyle ().buttonStyle
//    if let popUpButtonCell = zoomPopUpButton.cell as? NSPopUpButtonCell {
//      popUpButtonCell.arrowPosition = .arrowAtBottom
//    }
//    zoomPopUpButton.isBordered = true
    zoomPopUpButton.menu?.addItem (
      withTitle:"\(Int (self.mGraphicView.actualScale * 100.0)) %",
      action:nil,
      keyEquivalent:""
    )
    self.addPopupButtonItemForZoom (10, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (25, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (50, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (75, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (100, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (150, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (200, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (250, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (400, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (500, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (600, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (800, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (1_000, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (1_200, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (1_500, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (1_700, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (2_000, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (2_500, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (3_000, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (3_500, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (4_000, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (5_000, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (8_000, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (10_000, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (15_000, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (20_000, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    return zoomPopUpButton
  }

 //····················································································································

  final fileprivate func addPopupButtonItemForZoom (_ inZoom : Int,
                                                    _ inPopUp : InternalAutoLayoutPopUpButton,
                                                    minZoom inMinZoom : Int,
                                                    maxZoom inMaxZoom : Int) {
    if (inZoom >= inMinZoom) && (inZoom <= inMaxZoom) {
      inPopUp.addItem (withTitle: "\(inZoom) %")
      inPopUp.lastItem?.target = self
      inPopUp.lastItem?.action = #selector (Self.setZoomFromPopUpButton(_:))
      inPopUp.lastItem?.tag = inZoom
    }
  }

 //····················································································································

  @objc func setZoomFromPopUpButton (_ inSender : NSMenuItem) {
     self.mGraphicView.set (zoom: inSender.tag)
  }

 //····················································································································

  @objc func setZoomToFitButton (_ inSender : Any?) {
     self.mGraphicView.performZoomToFit ()
  }

  //····················································································································
  //  BINDINGS
  //····················································································································

  final func bind_foregroundImageOpacity (_ inObject : EBGenericReadOnlyProperty <Double>) -> Self {
    self.mGraphicView.bind_foregroundImageOpacity (inObject)
    return self
  }

  //····················································································································

  final func bind_foregroundImageData (_ inObject : EBGenericReadOnlyProperty <Data>) -> Self {
    self.mGraphicView.bind_foregroundImageData (inObject)
    return self
  }

  //····················································································································

  final func bind_backgroundImageData (_ inObject : EBGenericReadOnlyProperty <Data>) -> Self {
    self.mGraphicView.bind_backgroundImageData (inObject)
    return self
  }

  //····················································································································

  final func bind_overObjectsDisplay (_ inObject : EBGenericReadOnlyProperty <EBShape>) -> Self {
    self.mGraphicView.bind_overObjectsDisplay (inObject)
    return self
  }

  //····················································································································

  final func bind_underObjectsDisplay (_ inObject : EBGenericReadOnlyProperty <EBShape>) -> Self {
    self.mGraphicView.bind_underObjectsDisplay (inObject)
    return self
  }

  //····················································································································

  final func bind_horizontalFlip (_ inObject : EBGenericReadOnlyProperty <Bool>) -> Self {
    self.mGraphicView.bind_horizontalFlip (inObject)
    return self
  }

  //····················································································································

  final func bind_verticalFlip (_ inObject : EBGenericReadOnlyProperty <Bool>) -> Self {
    self.mGraphicView.bind_verticalFlip (inObject)
    return self
  }

  //····················································································································

  final func bind_mouseGrid (_ inObject : EBGenericReadOnlyProperty <Int>) -> Self {
    self.mGraphicView.bind_mouseGrid (inObject)
    return self
  }

  //····················································································································

  final func bind_gridStep (_ inObject : EBGenericReadOnlyProperty <Int>) -> Self {
    self.mGraphicView.bind_gridStep (inObject)
    return self
  }

  //····················································································································

  final func bind_arrowKeyMagnitude (_ inObject : EBGenericReadOnlyProperty <Int>) -> Self {
    self.mGraphicView.bind_arrowKeyMagnitude (inObject)
    return self
  }

  //····················································································································

  final func bind_shiftArrowKeyMagnitude (_ inObject : EBGenericReadOnlyProperty <Int>) -> Self {
    self.mGraphicView.bind_shiftArrowKeyMagnitude (inObject)
    return self
  }

  //····················································································································

  final func bind_gridStyle (_ inObject : EBReadOnlyProperty_GridStyle) -> Self {
    self.mGraphicView.bind_gridStyle (inObject)
    return self
  }

  //····················································································································

  final func bind_gridDisplayFactor (_ inObject : EBGenericReadOnlyProperty <Int>) -> Self {
    self.mGraphicView.bind_gridDisplayFactor (inObject)
    return self
  }

  //····················································································································

  final func bind_gridLineColor (_ inObject : EBGenericReadOnlyProperty <NSColor>) -> Self {
    self.mGraphicView.bind_gridLineColor (inObject)
    return self
  }

  //····················································································································

  final func bind_gridCrossColor (_ inObject : EBGenericReadOnlyProperty <NSColor>) -> Self {
    self.mGraphicView.bind_gridCrossColor (inObject)
    return self
  }

  //····················································································································

  final func bind_zoom (_ inObject : EBGenericReadWriteProperty <Int>) -> Self {
    self.mGraphicView.bind_zoom (inObject)
    return self
  }

  //····················································································································

  final func bind_backColor (_ inObject : EBGenericReadOnlyProperty <NSColor>) -> Self {
    self.mGraphicView.bind_backColor (inObject)
    return self
  }

  //····················································································································

  final func bind_xPlacardUnit (_ inObject : EBGenericReadWriteProperty <Int>) -> Self {
    self.mGraphicView.bind_xPlacardUnit (inObject)
    return self
  }

  //····················································································································

  final func bind_yPlacardUnit (_ inObject : EBGenericReadWriteProperty <Int>) -> Self {
    self.mGraphicView.bind_yPlacardUnit (inObject)
    return self
  }

  //····················································································································

  final func bind_graphic_controller (_ inController : EBGraphicViewControllerProtocol) -> Self {
    inController.bind_ebView (self.mGraphicView)
    return self
  }

  //····················································································································

  final func setIssue (_ inBezierPathes : [EBBezierPath], _ issueKind : CanariIssueKind) {
    self.mGraphicView.setIssue (inBezierPathes, issueKind)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------

fileprivate class AutoLayoutPrivateFocusRingView : AutoLayoutHorizontalStackView, EBFocusRingViewProtocol {

  //····················································································································
  //  FOCUS RING
  //····················································································································

  private var mHasFocusRing = false {
    didSet {
      self.needsDisplay = true
    }
  }

  //····················································································································

  func setFocusRing (_ inValue : Bool) {
    self.mHasFocusRing = inValue
  }

  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    super.draw (inDirtyRect)
    if self.mHasFocusRing {
      let w = (FOCUS_RING_MARGIN - 1.0) / 2.0
      let r = self.bounds.insetBy (dx: w, dy: w)
      let bp = NSBezierPath (roundedRect: r, xRadius: w / 2.0, yRadius: w / 2.0)
      bp.lineWidth = w * 2.0
      RING_COLOR.setStroke ()
      bp.stroke ()
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
