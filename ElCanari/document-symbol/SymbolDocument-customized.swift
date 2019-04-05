//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SYMBOL_GRID_IN_COCOA_UNIT : CGFloat  = milsToCocoaUnit (25.0)
let SYMBOL_GRID_IN_CANARI_UNIT : Int  = milsToCanariUnit (25)

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PMSymbolVersion = "PMSymbolVersion"
let PMSymbolComment = "PMSymbolComment"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let symbolPasteboardType = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.pasteboard.symbol")

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CustomizedSymbolDocument) class CustomizedSymbolDocument : SymbolDocument {

  //····················································································································

  override func metadataStatusForSaving () -> UInt8 {
    return UInt8 (self.mMetadataStatus!.rawValue)
  }

  //····················································································································

  override func saveMetadataDictionary (version : Int, metadataDictionary : inout [String : Any]) {
    metadataDictionary [PMSymbolVersion] = version
    metadataDictionary [PMSymbolComment] = self.rootObject.comments
  }

  //····················································································································

  override func readVersionFromMetadataDictionary (_ metadataDictionary : [String : Any]) -> Int {
    var result = 0
    if let versionNumber = metadataDictionary [PMSymbolVersion] as? Int {
      result = versionNumber
    }
    return result
  }

  //····················································································································
  //    windowControllerDidLoadNib: customization of interface
  //····················································································································

  fileprivate var mSymbolColorObserver = EBOutletEvent ()

  //····················································································································

  override func windowControllerDidLoadNib (_ aController: NSWindowController) {
    super.windowControllerDidLoadNib (aController)
  //--- Symbol color observer
    self.mSymbolColorObserver.mEventCallBack = { [weak self] in self?.updateDragSourceButtons () }
    g_Preferences?.symbolColor_property.addEBObserver (self.mSymbolColorObserver)
  //--- Set pages segmented control
    let pages = [self.mSymbolPageView, self.mInfosPageView]
    self.mPageSegmentedControl?.register (masterView: self.mMasterView, pages)
  //--- Set inspector segmented control
    let inspectors = [self.mSymbolBaseInspectorView, self.mSymbolZoomFlipInspectorView, self.mSymbolIssueInspectorView]
    self.mInspectorSegmentedControl?.register (masterView: self.mSymbolRootInspectorView, inspectors)
  //--- Drag source buttons and destination scroll view
    self.mAddSegmentButton?.register (
      draggedType: symbolPasteboardType,
      entityName: "SymbolSegment",
      scaleProvider: self.mComposedSymbolView
    )

    self.mAddBezierButton?.register (
      draggedType: symbolPasteboardType,
      entityName: "SymbolBezierCurve",
      scaleProvider: self.mComposedSymbolView
    )

    self.mAddSolidOvalButton?.register (
      draggedType: symbolPasteboardType,
      entityName: "SymbolSolidOval",
      scaleProvider: self.mComposedSymbolView
    )

    self.mAddOvalButton?.register (
      draggedType: symbolPasteboardType,
      entityName: "SymbolOval",
      scaleProvider: self.mComposedSymbolView
    )

    self.mAddSolidRectButton?.register (
      draggedType: symbolPasteboardType,
      entityName: "SymbolSolidRect",
      scaleProvider: self.mComposedSymbolView
    )

    self.mAddTextButton?.register (
      draggedType: symbolPasteboardType,
      entityName: "SymbolText",
      scaleProvider: self.mComposedSymbolView
    )

    self.mAddPinButton?.register (
      draggedType: symbolPasteboardType,
      entityName: "SymbolPin",
      scaleProvider: self.mComposedSymbolView
    )

    self.mComposedSymbolScrollView?.register (document: self, draggedTypes: [symbolPasteboardType])
    self.mComposedSymbolView?.set (arrowKeyMagnitude: SYMBOL_GRID_IN_CANARI_UNIT)
    self.mComposedSymbolView?.set (shiftArrowKeyMagnitude: SYMBOL_GRID_IN_CANARI_UNIT * 4)
    self.mComposedSymbolView?.mDraggingObjectsIsAlignedOnArrowKeyMagnitude = true
    self.mComposedSymbolView?.register (pasteboardType: symbolPasteboardType)
    let r = NSRect (x: 0.0, y: 0.0, width: milsToCocoaUnit (10_000.0), height: milsToCocoaUnit (10_000.0))
    self.mComposedSymbolView?.set (minimumRectangle: r)
    self.mComposedSymbolView?.set (mouseGridInCanariUnit: SYMBOL_GRID_IN_CANARI_UNIT)

    DispatchQueue.main.async (execute: {
      if let view = self.mComposedSymbolView {
         _ = view.scrollToVisible (view.objectsAndIssueBoundingBox)
      }
    })

  //--- Register inspector views
    self.mSymbolObjectsController.register (inspectorReceivingView: self.mSymbolBaseInspectorView)
    self.mSymbolObjectsController.register (inspectorView: self.mPinInspectorView, forClass: "SymbolPin")
    self.mSymbolObjectsController.register (inspectorView: self.mTextInspectorView, forClass: "SymbolText")
  //--- Set issue display view
    self.mIssueTableView?.register (issueDisplayView: self.mComposedSymbolView)
    self.mIssueTableView?.register (hideIssueButton: self.mDeselectIssueButton)
    self.mIssueTableView?.register (segmentedControl: self.mInspectorSegmentedControl, segment: 2)
  }

  //····················································································································
  //    Drag and drop destination
  //····················································································································

  override func draggingEntered (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> NSDragOperation {
    return .copy
  }

  //····················································································································

  override func prepareForDragOperation (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> Bool {
    return true
  }

  //····················································································································

  override func performDragOperation (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> Bool {
    var ok = false
    if let documentView = destinationScrollView.documentView {
      let pointInWindow = sender.draggingLocation
      let pointInDestinationView = documentView.convert (pointInWindow, from:nil).aligned (onGrid: SYMBOL_GRID_IN_COCOA_UNIT)
      let pasteboard = sender.draggingPasteboard
      if pasteboard.availableType (from: [symbolPasteboardType]) != nil {
        if let dataDictionary = pasteboard.propertyList (forType: symbolPasteboardType) as? NSDictionary,
           let dictionaryArray = dataDictionary ["OBJECTS"] as? [NSDictionary],
           let X = dataDictionary ["X"] as? Int,
           let Y = dataDictionary ["Y"] as? Int {
          for dictionary in dictionaryArray {
            if let newObject = makeManagedObjectFromDictionary (self.ebUndoManager, dictionary) as? SymbolObject {
              newObject.translate (
                xBy: cocoaToCanariUnit (pointInDestinationView.x) - X,
                yBy: cocoaToCanariUnit (pointInDestinationView.y) - Y
              )
              self.rootObject.symbolObjects_property.add (newObject)
              self.mSymbolObjectsController.select (object: newObject)
            }
          }
          ok = true
        }
      }
    }
    return ok
  }

  //····················································································································

  fileprivate func imageForAddTextButton () ->  NSImage? {
    let r = NSRect (x: 0.0, y: 0.0, width: 20.0, height: 20.0)
    let textAttributes : [NSAttributedString.Key : Any] = [
      NSAttributedString.Key.font : NSFont.systemFont (ofSize: 18.0),
      NSAttributedString.Key.foregroundColor : g_Preferences?.symbolColor ?? NSColor.black
    ]
    let shape = EBTextShape ("T", CGPoint (x: r.midX, y: r.midY - 3.0), textAttributes, .center, .center)
    let imagePDFData = buildPDFimageData (frame: r, shape: shape)
    return NSImage (data: imagePDFData)
  }

  //····················································································································

  fileprivate func imageForAddPinButton () ->  NSImage? {
    let r = NSRect (x: 0.0, y: 0.0, width: 20.0, height: 20.0)
    let circleDiameter : CGFloat = 8.0
    let circle = NSRect (
      x: r.maxX - circleDiameter - 2.0,
      y: r.midY - circleDiameter / 2.0,
      width: circleDiameter,
      height: circleDiameter
    )
    let shape = EBShape ()
    shape.append (EBFilledBezierPathShape ([NSBezierPath (ovalIn: circle)], g_Preferences?.symbolColor ?? NSColor.black))
    let textAttributes : [NSAttributedString.Key : Any] = [
      NSAttributedString.Key.font : NSFont.systemFont (ofSize: 12.0),
      NSAttributedString.Key.foregroundColor : g_Preferences?.symbolColor ?? NSColor.black
    ]
    shape.append (EBTextShape ("#", CGPoint (x: r.minX + 2.0, y: r.midY - 1.0), textAttributes, .left, .center))
    let imagePDFData = buildPDFimageData (frame: r, shape: shape)
    return NSImage (data: imagePDFData)
  }

  //····················································································································

  private func updateDragSourceButtons () {
    self.mAddPinButton?.image = self.imageForAddPinButton ()
    self.mAddTextButton?.image = self.imageForAddTextButton ()
    self.mAddOvalButton?.buildButtonImageFromDraggedObjectTypeName ()
    self.mAddBezierButton?.buildButtonImageFromDraggedObjectTypeName ()
    self.mAddSegmentButton?.buildButtonImageFromDraggedObjectTypeName ()
    self.mAddSolidOvalButton?.buildButtonImageFromDraggedObjectTypeName ()
    self.mAddSolidRectButton?.buildButtonImageFromDraggedObjectTypeName ()
  }

  //····················································································································
  //   removeUserInterface
  //····················································································································

  override func removeUserInterface () {
    super.removeUserInterface ()
    g_Preferences?.symbolColor_property.removeEBObserver (self.mSymbolColorObserver)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
