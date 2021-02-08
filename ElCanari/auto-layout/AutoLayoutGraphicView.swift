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

class AutoLayoutGraphicView : AutoLayoutVerticalStackView {

  //····················································································································

  let mGraphicView = EBGraphicView (frame: NSRect ())
  let mScrollView = EBScrollView (frame: NSRect ())
  var mZoomPopUpButton : NSPopUpButton? = nil
  var mHelperTextField : AutoLayoutStaticLabel? = nil

  //····················································································································

  init (minZoom inMinZoom : Int, maxZoom inMaxZoom : Int) {
    super.init ()

    let zoomPopUp = buildZoomPopUpButton (minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.mZoomPopUpButton = zoomPopUp

    self.mGraphicView.mZoomDidChangeCallback = {
      [weak self] (_ inZoom : Int) in self?.mZoomPopUpButton?.menu?.item (at:0)?.title = "\(inZoom) %"
    }
    self.mGraphicView.mHelperStringDidChangeCallback = {
      [weak self] (_ inString : String) in self?.mHelperTextField?.stringValue = inString
    }

    let hStack = AutoLayoutHorizontalStackView ().setTopMargin (8.0)
    hStack.appendView (zoomPopUp)
    let zoomToFitButton = AutoLayoutButton (title: "Zoom to Fit", small: true)
    zoomToFitButton.target = self
    zoomToFitButton.action = #selector (Self.setZoomToFitButton (_:))
    hStack.appendView (zoomToFitButton)
    let helperTextField = AutoLayoutStaticLabel (title: "", bold: false, small: true)
    self.mHelperTextField = helperTextField
    hStack.appendView (helperTextField)
    hStack.appendView (AutoLayoutFlexibleSpace ())
    self.appendView (hStack)
    let enclosingView = AutoLayoutHorizontalStackView ().set (margins: 8)
    self.mScrollView.minMagnification = CGFloat (inMinZoom) / 100.0
    self.mScrollView.maxMagnification = CGFloat (inMaxZoom) / 100.0
    self.mScrollView.allowsMagnification = true
    self.mScrollView.hasHorizontalScroller = true
    self.mScrollView.hasVerticalScroller = true
    self.mScrollView.autohidesScrollers = false
    self.mScrollView.contentView = NSClipView (frame: NSRect ())
    self.mScrollView.documentView = self.mGraphicView
    enclosingView.appendView (self.mScrollView)
    self.appendView (enclosingView)
  }

  //····················································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  fileprivate func buildZoomPopUpButton (minZoom inMinZoom : Int, maxZoom inMaxZoom : Int) -> NSPopUpButton {
    let zoomPopUpButton = NSPopUpButton (frame: NSRect (), pullsDown: true)
    zoomPopUpButton.font = NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
    zoomPopUpButton.autoenablesItems = false
    zoomPopUpButton.bezelStyle = .roundRect
    if let popUpButtonCell = zoomPopUpButton.cell as? NSPopUpButtonCell {
      popUpButtonCell.arrowPosition = .arrowAtBottom
    }
    zoomPopUpButton.isBordered = true
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
                                                    _ inPopUp : NSPopUpButton,
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

  func bind__foregroundImageOpacity (_ inObject : EBGenericReadOnlyProperty <Double>) -> Self {
    self.mGraphicView.bind_foregroundImageOpacity (inObject)
    return self
  }

  //····················································································································

  func bind__foregroundImageData (_ inObject : EBGenericReadOnlyProperty <Data>) -> Self {
    self.mGraphicView.bind_foregroundImageData (inObject)
    return self
  }

  //····················································································································

  func bind__backgroundImageData (_ inObject : EBGenericReadOnlyProperty <Data>) -> Self {
    self.mGraphicView.bind_backgroundImageData (inObject)
    return self
  }

  //····················································································································

  func bind__overObjectsDisplay (_ inObject : EBGenericReadOnlyProperty <EBShape>) -> Self {
    self.mGraphicView.bind_overObjectsDisplay (inObject)
    return self
  }

  //····················································································································

  func bind__underObjectsDisplay (_ inObject : EBGenericReadOnlyProperty <EBShape>) -> Self {
    self.mGraphicView.bind_underObjectsDisplay (inObject)
    return self
  }

  //····················································································································

  func bind__horizontalFlip (_ inObject : EBGenericReadOnlyProperty <Bool>) -> Self {
    self.mGraphicView.bind_horizontalFlip (inObject)
    return self
  }

  //····················································································································


  func bind__verticalFlip (_ inObject : EBGenericReadOnlyProperty <Bool>) -> Self {
    self.mGraphicView.bind_verticalFlip (inObject)
    return self
  }

  //····················································································································


  func bind__mouseGrid (_ inObject : EBGenericReadOnlyProperty <Int>) -> Self {
    self.mGraphicView.bind_mouseGrid (inObject)
    return self
  }

  //····················································································································


  func bind__gridStep (_ inObject : EBGenericReadOnlyProperty <Int>) -> Self {
    self.mGraphicView.bind_gridStep (inObject)
    return self
  }

  //····················································································································

  func bind__arrowKeyMagnitude (_ inObject : EBGenericReadOnlyProperty <Int>) -> Self {
    self.mGraphicView.bind_arrowKeyMagnitude (inObject)
    return self
  }

  //····················································································································

  func bind__shiftArrowKeyMagnitude (_ inObject : EBGenericReadOnlyProperty <Int>) -> Self {
    self.mGraphicView.bind_shiftArrowKeyMagnitude (inObject)
    return self
  }

  //····················································································································


  func bind__gridStyle (_ inObject : EBReadOnlyProperty_GridStyle) -> Self {
    self.mGraphicView.bind_gridStyle (inObject)
    return self
  }

  //····················································································································


  func bind__gridDisplayFactor (_ inObject : EBGenericReadOnlyProperty <Int>) -> Self {
    self.mGraphicView.bind_gridDisplayFactor (inObject)
    return self
  }

  //····················································································································


  func bind__gridLineColor (_ inObject : EBGenericReadOnlyProperty <NSColor>) -> Self {
    self.mGraphicView.bind_gridLineColor (inObject)
    return self
  }

  //····················································································································


  func bind__gridCrossColor (_ inObject : EBGenericReadOnlyProperty <NSColor>) -> Self {
    self.mGraphicView.bind_gridCrossColor (inObject)
    return self
  }

  //····················································································································


  func bind__zoom (_ inObject : EBGenericReadWriteProperty <Int>) -> Self {
    self.mGraphicView.bind_zoom (inObject)
    return self
  }

  //····················································································································


  func bind__backColor (_ inObject : EBGenericReadOnlyProperty <NSColor>) -> Self {
    self.mGraphicView.bind_backColor (inObject)
    return self
  }

  //····················································································································


  func bind__xPlacardUnit (_ inObject : EBGenericReadWriteProperty <Int>) -> Self {
    self.mGraphicView.bind_xPlacardUnit (inObject)
    return self
  }

  //····················································································································

  func bind__yPlacardUnit (_ inObject : EBGenericReadWriteProperty <Int>) -> Self {
    self.mGraphicView.bind_yPlacardUnit (inObject)
    return self
  }

  //····················································································································

  func bind__graphic_controller (_ inController : EBGraphicViewControllerProtocol) -> Self {
    inController.bind_ebView (self.mGraphicView)
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
