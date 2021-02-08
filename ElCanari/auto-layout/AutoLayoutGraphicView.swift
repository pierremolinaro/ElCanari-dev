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
  var mZoomPopUpButton : NSPopUpButton? = nil

  //····················································································································

  init (minZoom inMinZoom : Int, maxZoom inMaxZoom : Int) {
    super.init ()
    let hStack = AutoLayoutHorizontalStackView ().setTopMargin (8.0)
    let zoomPopUp = buildZoomPopUpButton (minZoom: inMinZoom, maxZoom: inMaxZoom)
    self.mZoomPopUpButton = zoomPopUp
    hStack.appendView (zoomPopUp)
    let zoomToFitButton = AutoLayoutButton (title: "Zoom to Fit", small: true)
    zoomToFitButton.target = self
    zoomToFitButton.action = #selector (Self.setZoomToFitButton (_:))
    hStack.appendView (zoomToFitButton)
    let helperTextField = AutoLayoutStaticLabel (title: "helper...", bold: false, small: true)
    hStack.appendView (helperTextField)
    hStack.appendView (AutoLayoutFlexibleSpace ())
    self.appendView (hStack)
    let enclosingView = AutoLayoutHorizontalStackView ().set (margins: 8)
    let scrollView = EBScrollView ()
    scrollView.minMagnification = CGFloat (inMinZoom) / 100.0
    scrollView.maxMagnification = CGFloat (inMaxZoom) / 100.0
    scrollView.allowsMagnification = true
    scrollView.hasHorizontalScroller = true
    scrollView.hasVerticalScroller = true
    scrollView.autohidesScrollers = false
    scrollView.contentView = NSClipView (frame: NSRect ())
    scrollView.documentView = self.mGraphicView
    enclosingView.appendView (scrollView)
    self.appendView (enclosingView)

    self.mGraphicView.mZoomDidChangeCallback = {
      [weak self] (_ inZoom : Int) in self?.mZoomPopUpButton?.menu?.item (at:0)?.title = "\(inZoom) %"
    }
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
     self.mGraphicView.setZoomFromPopUpButton (inSender)
  }

 //····················································································································

  @objc func setZoomToFitButton (_ inSender : Any?) {
     self.mGraphicView.setZoomToFitButton (inSender)
  }

  //····················································································································
  //  BINDINGS
  //····················································································································

  func bind_backgroundImageData (_ inObject : EBGenericReadOnlyProperty <Data>) -> Self {
    self.mGraphicView.bind_backgroundImageData (inObject, file: #file, line: #line)
    return self
  }

  //····················································································································

  func bind_underObjectsDisplay (_ inObject : EBGenericReadOnlyProperty <EBShape>) -> Self {
    self.mGraphicView.bind_underObjectsDisplay (inObject, file: #file, line: #line)
    return self
  }

  //····················································································································


  func bind_horizontalFlip (_ inObject : EBGenericReadOnlyProperty <Bool>) -> Self {
    self.mGraphicView.bind_horizontalFlip (inObject, file: #file, line: #line)
    return self
  }

  //····················································································································


  func bind_verticalFlip (_ inObject : EBGenericReadOnlyProperty <Bool>) -> Self {
    self.mGraphicView.bind_verticalFlip (inObject, file: #file, line: #line)
    return self
  }

  //····················································································································


  func bind_mouseGrid (_ inObject : EBGenericReadOnlyProperty <Int>) -> Self {
    self.mGraphicView.bind_mouseGrid (inObject, file: #file, line: #line)
    return self
  }

  //····················································································································


  func bind_gridStep (_ inObject : EBGenericReadOnlyProperty <Int>) -> Self {
    self.mGraphicView.bind_gridStep (inObject, file: #file, line: #line)
    return self
  }

  //····················································································································


  func bind_arrowKeyMagnitude (_ inObject : EBGenericReadOnlyProperty <Int>) -> Self {
    self.mGraphicView.bind_arrowKeyMagnitude (inObject, file: #file, line: #line)
    return self
  }

  //····················································································································


  func bind_gridStyle (_ inObject : EBReadOnlyProperty_GridStyle) -> Self {
    self.mGraphicView.bind_gridStyle (inObject, file: #file, line: #line)
    return self
  }

  //····················································································································


  func bind_gridDisplayFactor (_ inObject : EBGenericReadOnlyProperty <Int>) -> Self {
    self.mGraphicView.bind_gridDisplayFactor (inObject, file: #file, line: #line)
    return self
  }

  //····················································································································


  func bind_gridLineColor (_ inObject : EBGenericReadOnlyProperty <NSColor>) -> Self {
    self.mGraphicView.bind_gridLineColor (inObject, file: #file, line: #line)
    return self
  }

  //····················································································································


  func bind_gridCrossColor (_ inObject : EBGenericReadOnlyProperty <NSColor>) -> Self {
    self.mGraphicView.bind_gridCrossColor (inObject, file: #file, line: #line)
    return self
  }

  //····················································································································


  func bind_zoom (_ inObject : EBGenericReadWriteProperty <Int>) -> Self {
    self.mGraphicView.bind_zoom (inObject, file: #file, line: #line)
    return self
  }

  //····················································································································


  func bind_backColor (_ inObject : EBGenericReadOnlyProperty <NSColor>) -> Self {
    self.mGraphicView.bind_backColor (inObject, file: #file, line: #line)
    return self
  }

  //····················································································································


  func bind_xPlacardUnit (_ inObject : EBGenericReadWriteProperty <Int>) -> Self {
    self.mGraphicView.bind_xPlacardUnit (inObject, file: #file, line: #line)
    return self
  }

  //····················································································································


  func bind_yPlacardUnit (_ inObject : EBGenericReadWriteProperty <Int>) -> Self {
    self.mGraphicView.bind_yPlacardUnit (inObject, file: #file, line: #line)
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
