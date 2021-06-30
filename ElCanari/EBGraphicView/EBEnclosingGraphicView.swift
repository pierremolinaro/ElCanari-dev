//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBEnclosingGraphicView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class EBEnclosingGraphicView : NSView, EBUserClassNameProtocol {

  //····················································································································
  // Temporary, for IB interface
  //····················································································································

  @IBInspectable var minZoom : Int = 100
  @IBInspectable var maxZoom : Int = 100

  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
    self.wantsLayer = true
  }

  //····················································································································

  override init (frame inFrame : NSRect) {
    super.init (frame: inFrame)
    noteObjectAllocation (self)
    self.wantsLayer = true
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override func awakeFromNib () {
    self.configure ()
    super.awakeFromNib ()
  }

  //····················································································································
  //   Properties
  //····················································································································

  let mGraphicView = EBGraphicView (frame: NSRect ())
  var mZoomPopUpButton : NSPopUpButton? = nil
  var mZoomToFitButton : NSButton? = nil
  var mHelperTextField : NSTextField? = nil
  var mFocusRing : EBFocusRingView? = nil
  var mScrollView : EBScrollView? = nil

  //····················································································································

  fileprivate final func configure () {
  //--- Build popup button
    let zoomPopUp = buildZoomPopUpButton ()
    self.addSubview (zoomPopUp)
    self.mZoomPopUpButton = zoomPopUp
  //--- Build zoom to fit button
    let zoomToFitButton = buildZoomToFitButton ()
    self.addSubview (zoomToFitButton)
    self.mZoomToFitButton = zoomToFitButton
  //--- Build helper text
    let helperTextField = buildHelperTextField ()
    self.addSubview (helperTextField)
    self.mHelperTextField = helperTextField
  //--- Build focus ring
    let focusRingView = buildFocusRingView ()
    self.addSubview (focusRingView)
    self.mFocusRing = focusRingView
    self.mGraphicView.set (focusRingView: focusRingView)
  //--- Build scroll view
    let scrollView = buildScrollView (focusRingView.bounds)
    self.addSubview (scrollView)
    self.mScrollView = scrollView
  //---
    self.mGraphicView.mZoomDidChangeCallback = {
      [weak self] (_ inZoom : Int) in self?.mZoomPopUpButton?.menu?.item (at: 0)?.title = "\(inZoom) %"
    }
    self.mGraphicView.mHelperStringDidChangeCallback = {
      [weak self] (_ inString : String) in self?.mHelperTextField?.stringValue = inString
    }
  }

  //····················································································································

  fileprivate func buildScrollView (_ inEnclosingBounds : NSRect) -> EBScrollView {
    let view = EBScrollView (frame: inEnclosingBounds.insetBy(dx: FOCUS_RING_MARGIN, dy: FOCUS_RING_MARGIN))
    view.autoresizingMask = [.height, .width]
    view.minMagnification = CGFloat (self.minZoom) / 100.0
    view.maxMagnification = CGFloat (self.maxZoom) / 100.0
    view.allowsMagnification = true
    view.hasHorizontalScroller = true
    view.hasVerticalScroller = true
    view.autohidesScrollers = false
    view.contentView = NSClipView (frame: NSRect ())
    view.documentView = self.mGraphicView
    return view
  }

  //····················································································································

  fileprivate func buildFocusRingView () -> EBFocusRingView {
    let r = NSRect (x: 0.0, y: 0.0, width: self.bounds.maxX, height: self.bounds.maxY - 30.0)
    let view = EBFocusRingView (frame: r)
    view.autoresizingMask = [.height, .width]
    return view
  }

  //····················································································································

  fileprivate func buildHelperTextField () -> NSTextField {
    let r = NSRect (x: 200.0 + FOCUS_RING_MARGIN, y: self.bounds.maxY - 26.0, width: self.bounds.maxX - 210.0 - FOCUS_RING_MARGIN, height: 18.0)
    let tf = NSTextField (frame: r)
    tf.autoresizingMask = [.minYMargin, .width]
    tf.isBezeled = false
    tf.isBordered = false
    tf.drawsBackground = false
    tf.textColor = .black
    tf.isEnabled = true
    tf.isEditable = false
    tf.alignment = .left
    tf.font = NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
    return tf
  }

  //····················································································································

  fileprivate func buildZoomToFitButton () -> NSButton {
    let r = NSRect (x: 100.0 + FOCUS_RING_MARGIN, y: self.bounds.maxY - 26.0, width: 90.0, height: 18.0)
    let button = NSButton (frame: r)
    button.autoresizingMask = [.minYMargin, .maxXMargin]
    button.title = "Zoom to Fit"
    button.font = NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
    button.bezelStyle = .roundRect
    button.target = self
    button.action = #selector (Self.setZoomToFitButton (_:))
    return button
  }

  //····················································································································

  fileprivate func buildZoomPopUpButton () -> NSPopUpButton {
    let r = NSRect (x: FOCUS_RING_MARGIN, y: self.bounds.maxY - 26.0, width: 90.0, height: 18.0)
    let zoomPopUpButton = NSPopUpButton (frame: r, pullsDown: true)
    zoomPopUpButton.autoresizingMask = [.minYMargin, .maxXMargin]
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
    self.addPopupButtonItemForZoom (10, zoomPopUpButton)
    self.addPopupButtonItemForZoom (25, zoomPopUpButton)
    self.addPopupButtonItemForZoom (50, zoomPopUpButton)
    self.addPopupButtonItemForZoom (75, zoomPopUpButton)
    self.addPopupButtonItemForZoom (100, zoomPopUpButton)
    self.addPopupButtonItemForZoom (150, zoomPopUpButton)
    self.addPopupButtonItemForZoom (200, zoomPopUpButton)
    self.addPopupButtonItemForZoom (250, zoomPopUpButton)
    self.addPopupButtonItemForZoom (400, zoomPopUpButton)
    self.addPopupButtonItemForZoom (500, zoomPopUpButton)
    self.addPopupButtonItemForZoom (600, zoomPopUpButton)
    self.addPopupButtonItemForZoom (800, zoomPopUpButton)
    self.addPopupButtonItemForZoom (1_000, zoomPopUpButton)
    self.addPopupButtonItemForZoom (1_200, zoomPopUpButton)
    self.addPopupButtonItemForZoom (1_500, zoomPopUpButton)
    self.addPopupButtonItemForZoom (1_700, zoomPopUpButton)
    self.addPopupButtonItemForZoom (2_000, zoomPopUpButton)
    self.addPopupButtonItemForZoom (2_500, zoomPopUpButton)
    self.addPopupButtonItemForZoom (3_000, zoomPopUpButton)
    self.addPopupButtonItemForZoom (3_500, zoomPopUpButton)
    self.addPopupButtonItemForZoom (4_000, zoomPopUpButton)
    self.addPopupButtonItemForZoom (5_000, zoomPopUpButton)
    self.addPopupButtonItemForZoom (8_000, zoomPopUpButton)
    self.addPopupButtonItemForZoom (10_000, zoomPopUpButton)
    self.addPopupButtonItemForZoom (15_000, zoomPopUpButton)
    self.addPopupButtonItemForZoom (20_000, zoomPopUpButton)
    return zoomPopUpButton
  }

 //····················································································································

  final fileprivate func addPopupButtonItemForZoom (_ inZoom : Int, _ inPopUp : NSPopUpButton) {
    if (inZoom >= self.minZoom) && (inZoom <= self.maxZoom) {
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

  final func bind_foregroundImageOpacity (_ inObject : EBGenericReadOnlyProperty <Double>) {
    self.mGraphicView.bind_foregroundImageOpacity (inObject)
  }

  //····················································································································

  final func bind_foregroundImageData (_ inObject : EBGenericReadOnlyProperty <Data>) {
    self.mGraphicView.bind_foregroundImageData (inObject)
  }

  //····················································································································

  final func bind_backgroundImageData (_ inObject : EBGenericReadOnlyProperty <Data>) {
    self.mGraphicView.bind_backgroundImageData (inObject)
  }

  //····················································································································

  final func bind_overObjectsDisplay (_ inObject : EBGenericReadOnlyProperty <EBShape>) {
    self.mGraphicView.bind_overObjectsDisplay (inObject)
  }

  //····················································································································

  final func bind_underObjectsDisplay (_ inObject : EBGenericReadOnlyProperty <EBShape>) {
    self.mGraphicView.bind_underObjectsDisplay (inObject)
  }

  //····················································································································

  final func bind_horizontalFlip (_ inObject : EBGenericReadOnlyProperty <Bool>) {
    self.mGraphicView.bind_horizontalFlip (inObject)
  }

  //····················································································································

  final func bind_verticalFlip (_ inObject : EBGenericReadOnlyProperty <Bool>) {
    self.mGraphicView.bind_verticalFlip (inObject)
  }

  //····················································································································

  final func bind_mouseGrid (_ inObject : EBGenericReadOnlyProperty <Int>) {
    self.mGraphicView.bind_mouseGrid (inObject)
  }

  //····················································································································

  final func bind_gridStep (_ inObject : EBGenericReadOnlyProperty <Int>) {
    self.mGraphicView.bind_gridStep (inObject)
  }

  //····················································································································

  final func bind_arrowKeyMagnitude (_ inObject : EBGenericReadOnlyProperty <Int>) {
    self.mGraphicView.bind_arrowKeyMagnitude (inObject)
  }

  //····················································································································

  final func bind_shiftArrowKeyMagnitude (_ inObject : EBGenericReadOnlyProperty <Int>) {
    self.mGraphicView.bind_shiftArrowKeyMagnitude (inObject)
  }

  //····················································································································

  final func bind_gridStyle (_ inObject : EBReadOnlyProperty_GridStyle) {
    self.mGraphicView.bind_gridStyle (inObject)
  }

  //····················································································································

  final func bind_gridDisplayFactor (_ inObject : EBGenericReadOnlyProperty <Int>) {
    self.mGraphicView.bind_gridDisplayFactor (inObject)
  }

  //····················································································································

  final func bind_gridLineColor (_ inObject : EBGenericReadOnlyProperty <NSColor>) {
    self.mGraphicView.bind_gridLineColor (inObject)
  }

  //····················································································································

  final func bind_gridCrossColor (_ inObject : EBGenericReadOnlyProperty <NSColor>) {
    self.mGraphicView.bind_gridCrossColor (inObject)
  }

  //····················································································································

  final func bind_zoom (_ inObject : EBGenericReadWriteProperty <Int>) {
    self.mGraphicView.bind_zoom (inObject)
  }

  //····················································································································

  final func bind_backColor (_ inObject : EBGenericReadOnlyProperty <NSColor>) {
    self.mGraphicView.bind_backColor (inObject)
  }

  //····················································································································

  final func bind_xPlacardUnit (_ inObject : EBGenericReadWriteProperty <Int>) {
    self.mGraphicView.bind_xPlacardUnit (inObject)
  }

  //····················································································································

  final func bind_yPlacardUnit (_ inObject : EBGenericReadWriteProperty <Int>) {
    self.mGraphicView.bind_yPlacardUnit (inObject)
  }

  //····················································································································

  final func bind_graphic_controller (_ inController : EBGraphicViewControllerProtocol) {
    inController.bind_ebView (self.mGraphicView)
  }

  //····················································································································

  final func unbind_foregroundImageOpacity () {
    self.mGraphicView.unbind_foregroundImageOpacity ()
  }

  //····················································································································

  final func unbind_foregroundImageData () {
    self.mGraphicView.unbind_foregroundImageData ()
  }

  //····················································································································

  final func unbind_backgroundImageData () {
    self.mGraphicView.unbind_backgroundImageData ()
  }

  //····················································································································

  final func unbind_overObjectsDisplay () {
    self.mGraphicView.unbind_overObjectsDisplay ()
  }

  //····················································································································

  final func unbind_underObjectsDisplay () {
    self.mGraphicView.unbind_underObjectsDisplay ()
  }

  //····················································································································

  final func unbind_horizontalFlip () {
    self.mGraphicView.unbind_horizontalFlip ()
  }

  //····················································································································

  final func unbind_verticalFlip () {
    self.mGraphicView.unbind_verticalFlip ()
  }

  //····················································································································

  final func unbind_mouseGrid () {
    self.mGraphicView.unbind_mouseGrid ()
  }

  //····················································································································

  final func unbind_gridStep () {
    self.mGraphicView.unbind_gridStep ()
  }

  //····················································································································

  final func unbind_arrowKeyMagnitude () {
    self.mGraphicView.unbind_arrowKeyMagnitude ()
  }

  //····················································································································

  final func unbind_shiftArrowKeyMagnitude () {
    self.mGraphicView.unbind_shiftArrowKeyMagnitude ()
  }

  //····················································································································


  final func unbind_gridStyle () {
    self.mGraphicView.unbind_gridStyle ()
  }

  //····················································································································


  final func unbind_gridDisplayFactor () {
    self.mGraphicView.unbind_gridDisplayFactor ()
  }

  //····················································································································


  final func unbind_gridLineColor () {
    self.mGraphicView.unbind_gridLineColor ()
  }

  //····················································································································


  final func unbind_gridCrossColor () {
    self.mGraphicView.unbind_gridCrossColor ()
  }

  //····················································································································

  final func unbind_zoom () {
    self.mGraphicView.unbind_zoom ()
  }

  //····················································································································

  final func unbind_backColor () {
    self.mGraphicView.unbind_backColor ()
  }

  //····················································································································

  final func unbind_xPlacardUnit () {
    self.mGraphicView.unbind_xPlacardUnit ()
  }

  //····················································································································

  final func unbind_yPlacardUnit () {
    self.mGraphicView.unbind_yPlacardUnit ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
