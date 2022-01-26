//
//  AutoLayoutGraphicView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutGraphicView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutGraphicView : AutoLayoutVerticalStackView {

  //····················································································································

  let mGraphicView = EBGraphicView ()
  var mScrollView : EBScrollView? = nil
  fileprivate var mZoomPopUpButton : AutoLayoutBase_NSPopUpButton? = nil
  fileprivate var mZoomToFitButton : AutoLayoutBase_NSButton? = nil
  fileprivate var mHelperTextField : NSTextField? = nil
  fileprivate var mFocusRing : EBFocusRingView? = nil

  //····················································································································

  init (minZoom inMinZoom : Int, maxZoom inMaxZoom : Int) {
    super.init ()
  //---
    _ = self.set (spacing: 0)
  //---
    let hStack = AutoLayoutHorizontalStackView ().set (margins: FOCUS_RING_MARGIN)
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
    let focusRingView = EBFocusRingView ()
    self.appendView (focusRingView)
    self.mFocusRing = focusRingView
    self.mGraphicView.set (focusRingView: focusRingView)
  //--- Build scroll view
    let scrollView = self.buildScrollView (minZoom: inMinZoom, maxZoom: inMaxZoom)
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
    let scrollView = EBScrollView (frame: .zero)
    scrollView.minMagnification = CGFloat (inMinZoom) / 100.0
    scrollView.maxMagnification = CGFloat (inMaxZoom) / 100.0
    scrollView.allowsMagnification = true
    scrollView.hasHorizontalScroller = true
    scrollView.hasVerticalScroller = true
    scrollView.autohidesScrollers = false
    scrollView.contentView = NSClipView (frame: .zero)
    scrollView.documentView = self.mGraphicView
    scrollView.drawsBackground = false
    scrollView.contentView.drawsBackground = false
//    Swift.print ("drawsBackground -> \(scrollView.drawsBackground)")
    return scrollView
  }

  //····················································································································

  fileprivate func buildHelperTextField () -> NSTextField {
    let tf = NSTextField (frame: .zero)
    tf.isBezeled = false
    tf.isBordered = false
    tf.drawsBackground = false
    tf.textColor = .black
    tf.isEnabled = true
    tf.isEditable = false
    tf.alignment = .left
    tf.controlSize = .small
    tf.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: tf.controlSize))
    return tf
  }

  //····················································································································

  fileprivate func buildZoomToFitButton () -> AutoLayoutBase_NSButton {
    let button = AutoLayoutBase_NSButton (title: "Zoom to Fit", size: .small)
    button.target = self
    button.action = #selector (Self.setZoomToFitButton (_:))
    return button
  }

  //····················································································································

  fileprivate func buildZoomPopUpButton (minZoom inMinZoom : Int, maxZoom inMaxZoom : Int) -> AutoLayoutBase_NSPopUpButton {
    let zoomPopUpButton = AutoLayoutBase_NSPopUpButton (pullsDown: true, size: .small)
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
    self.addPopupButtonItemForZoom (12_000, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (15_000, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.addPopupButtonItemForZoom (20_000, zoomPopUpButton, minZoom: inMinZoom, maxZoom: inMaxZoom)
    return zoomPopUpButton
  }

 //····················································································································

  final fileprivate func addPopupButtonItemForZoom (_ inZoom : Int,
                                                    _ inPopUp : AutoLayoutBase_NSPopUpButton,
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

  final func bind_foregroundImageOpacity (_ inObject : EBObservableProperty <Double>) -> Self {
    self.mGraphicView.bind_foregroundImageOpacity (inObject)
    return self
  }

  //····················································································································

  final func bind_foregroundImageData (_ inObject : EBObservableProperty <Data>) -> Self {
    self.mGraphicView.bind_foregroundImageData (inObject)
    return self
  }

  //····················································································································

  final func bind_backgroundImageData (_ inObject : EBObservableProperty <Data>) -> Self {
    self.mGraphicView.bind_backgroundImageData (inObject)
    return self
  }

  //····················································································································

  final func bind_overObjectsDisplay (_ inObject : EBObservableProperty <EBShape>) -> Self {
    self.mGraphicView.bind_overObjectsDisplay (inObject)
    return self
  }

  //····················································································································

  final func bind_underObjectsDisplay (_ inObject : EBObservableProperty <EBShape>) -> Self {
    self.mGraphicView.bind_underObjectsDisplay (inObject)
    return self
  }

  //····················································································································

  final func bind_horizontalFlip (_ inObject : EBObservableProperty <Bool>) -> Self {
    self.mGraphicView.bind_horizontalFlip (inObject)
    return self
  }

  //····················································································································

  final func bind_verticalFlip (_ inObject : EBObservableProperty <Bool>) -> Self {
    self.mGraphicView.bind_verticalFlip (inObject)
    return self
  }

  //····················································································································

  final func bind_mouseGrid (_ inObject : EBObservableProperty <Int>) -> Self {
    self.mGraphicView.bind_mouseGrid (inObject)
    return self
  }

  //····················································································································

  final func bind_gridStep (_ inObject : EBObservableProperty <Int>) -> Self {
    self.mGraphicView.bind_gridStep (inObject)
    return self
  }

  //····················································································································

  final func bind_arrowKeyMagnitude (_ inObject : EBObservableProperty <Int>) -> Self {
    self.mGraphicView.bind_arrowKeyMagnitude (inObject)
    return self
  }

  //····················································································································

  final func bind_shiftArrowKeyMagnitude (_ inObject : EBObservableProperty <Int>) -> Self {
    self.mGraphicView.bind_shiftArrowKeyMagnitude (inObject)
    return self
  }

  //····················································································································

  final func bind_gridStyle (_ inObject : EBReadOnlyProperty_GridStyle) -> Self {
    self.mGraphicView.bind_gridStyle (inObject)
    return self
  }

  //····················································································································

  final func bind_gridDisplayFactor (_ inObject : EBObservableProperty <Int>) -> Self {
    self.mGraphicView.bind_gridDisplayFactor (inObject)
    return self
  }

  //····················································································································

  final func bind_gridLineColor (_ inObject : EBObservableProperty <NSColor>) -> Self {
    self.mGraphicView.bind_gridLineColor (inObject)
    return self
  }

  //····················································································································

  final func bind_gridCrossColor (_ inObject : EBObservableProperty <NSColor>) -> Self {
    self.mGraphicView.bind_gridCrossColor (inObject)
    return self
  }

  //····················································································································

  final func bind_zoom (_ inObject : EBObservableMutableProperty <Int>) -> Self {
    self.mGraphicView.bind_zoom (inObject)
    return self
  }

  //····················································································································

  final func bind_backColor (_ inObject : EBObservableProperty <NSColor>) -> Self {
    self.mGraphicView.bind_backColor (inObject)
    return self
  }

  //····················································································································

  final func bind_xPlacardUnit (_ inObject : EBObservableMutableProperty <Int>) -> Self {
    self.mGraphicView.bind_xPlacardUnit (inObject)
    return self
  }

  //····················································································································

  final func bind_yPlacardUnit (_ inObject : EBObservableMutableProperty <Int>) -> Self {
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
  //  ACCESSORS
  //····················································································································

  final var grid : Int {
    return self.mGraphicView.mGridStepInCanariUnit
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
