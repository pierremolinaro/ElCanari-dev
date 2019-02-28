//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PMDeviceVersion = "PMDeviceVersion"
let PMDeviceComment = "PMDeviceComment"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//fileprivate let symbolPasteboardType = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.pasteboard.symbol")

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CustomizedDeviceDocument) class CustomizedDeviceDocument : DeviceDocument {

  //····················································································································

  override func metadataStatusForSaving () -> UInt8 {
    return 0 // UInt8 (self.mMetadataStatus!.rawValue)
  }

  //····················································································································

  override func saveMetadataDictionary (version : Int, metadataDictionary : inout NSMutableDictionary) {
    metadataDictionary.setObject (NSNumber (value:version), forKey: PMDeviceVersion as NSCopying)
//    metadataDictionary.setObject (rootObject.comments, forKey: PMDeviceComment as NSCopying)
//    metadataDictionary.setObject (NSNumber (value: self.mMetadataStatus!.rawValue), forKey: STATUS_METADATA_KEY as NSCopying)
  }

  //····················································································································

  override func readVersionFromMetadataDictionary (metadataDictionary : NSDictionary) -> Int {
    var result = 0
    if let versionNumber = metadataDictionary.object (forKey: PMDeviceVersion) as? NSNumber {
      result = versionNumber.intValue
    }
    return result
  }

  //····················································································································
  //    windowControllerDidLoadNib: customization of interface
  //····················································································································

//  fileprivate var mSymbolColorObserver = EBOutletEvent ()

  //····················································································································

  override func windowControllerDidLoadNib (_ aController: NSWindowController) {
    super.windowControllerDidLoadNib (aController)
  //--- Set pages segmented control
    let pages = [
      self.mDescriptionPageView,
      self.mSymbolPageView,
      self.mPackagePageView,
      self.mAssignmentPageView,
      self.mLibraryPageView,
      self.mInfosPageView
    ]
    self.mPageSegmentedControl?.register (masterView: self.mMasterView, pages)
  //---
    self.mDocumentationTableView?.registerDraggedTypesAnd (document: self)

//  //--- Symbol color observer
//    self.mSymbolColorObserver.eventCallBack = { [weak self] in self?.updateDragSourceButtons () }
//    g_Preferences?.symbolColor_property.addEBObserver (self.mSymbolColorObserver)
//  //--- Set inspector segmented control
//    let inspectors = [self.mSymbolBaseInspectorView, self.mSymbolZoomFlipInspectorView, self.mSymbolIssueInspectorView]
//    self.mInspectorSegmentedControl?.register (masterView: self.mSymbolRootInspectorView, inspectors)
//  //--- Drag source buttons and destination scroll view
//    self.mAddSegmentButton?.register (
//      draggedType: symbolPasteboardType,
//      entityName: "SymbolSegment",
//      scaleProvider: self.mComposedSymbolView
//    )
//
//    self.mAddBezierButton?.register (
//      draggedType: symbolPasteboardType,
//      entityName: "SymbolBezierCurve",
//      scaleProvider: self.mComposedSymbolView
//    )
//
//    self.mAddSolidOvalButton?.register (
//      draggedType: symbolPasteboardType,
//      entityName: "SymbolSolidOval",
//      scaleProvider: self.mComposedSymbolView
//    )
//
//    self.mAddOvalButton?.register (
//      draggedType: symbolPasteboardType,
//      entityName: "SymbolOval",
//      scaleProvider: self.mComposedSymbolView
//    )
//
//    self.mAddSolidRectButton?.register (
//      draggedType: symbolPasteboardType,
//      entityName: "SymbolSolidRect",
//      scaleProvider: self.mComposedSymbolView
//    )
//
//    self.mAddTextButton?.register (
//      draggedType: symbolPasteboardType,
//      entityName: "SymbolText",
//      scaleProvider: self.mComposedSymbolView
//    )
//
//    self.mAddPinButton?.register (
//      draggedType: symbolPasteboardType,
//      entityName: "SymbolPin",
//      scaleProvider: self.mComposedSymbolView
//    )
//
//    self.mComposedSymbolScrollView?.register (document: self, draggedTypes: [symbolPasteboardType])
//    self.mComposedSymbolView?.set (arrowKeyMagnitude: SYMBOL_GRID_IN_CANARI_UNIT)
//    self.mComposedSymbolView?.set (shiftArrowKeyMagnitude: SYMBOL_GRID_IN_CANARI_UNIT * 4)
//    self.mComposedSymbolView?.mDraggingObjectsIsAlignedOnArrowKeyMagnitude = true
//    self.mComposedSymbolView?.register (pasteboardType: symbolPasteboardType)
//    let r = NSRect (x: 0.0, y: 0.0, width: milsToCocoaUnit (10_000.0), height: milsToCocoaUnit (10_000.0))
//    self.mComposedSymbolView?.set (minimumRectangle: r)
//    self.mComposedSymbolView?.set (mouseGridInCanariUnit: SYMBOL_GRID_IN_CANARI_UNIT)
//    DispatchQueue.main.async (execute: { _ = self.mComposedSymbolView?.scrollToVisible (NSRect ()) })
//  //--- Register inspector views
//    self.mSymbolObjectsController.register (inspectorView: self.mSymbolBaseInspectorView)
//    self.mSymbolObjectsController.register (inspectorView: self.mPinInspectorView, forClass: "SymbolPin")
//    self.mSymbolObjectsController.register (inspectorView: self.mTextInspectorView, forClass: "SymbolText")
//  //--- Set issue display view
//    self.mIssueTableView?.register (issueDisplayView: self.mComposedSymbolView)
//    self.mIssueTableView?.register (hideIssueButton: self.mDeselectIssueButton)
//    self.mIssueTableView?.register (segmentedControl: self.mInspectorSegmentedControl, segment: 2)
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
    let ok = false
//    if let documentView = destinationScrollView.documentView {
//      let pointInWindow = sender.draggingLocation
//      let pointInDestinationView = documentView.convert (pointInWindow, from:nil).aligned (onGrid: SYMBOL_GRID_IN_COCOA_UNIT)
//      let pasteboard = sender.draggingPasteboard
//      if pasteboard.availableType (from: [symbolPasteboardType]) != nil {
//        if let dataDictionary = pasteboard.propertyList (forType: symbolPasteboardType) as? NSDictionary,
//           let dictionaryArray = dataDictionary ["OBJECTS"] as? [NSDictionary],
//           let X = dataDictionary ["X"] as? Int,
//           let Y = dataDictionary ["Y"] as? Int {
//          for dictionary in dictionaryArray {
//            if let newObject = makeManagedObjectFromDictionary (self.ebUndoManager, dictionary) as? SymbolObject {
//              newObject.translate (
//                xBy: cocoaToCanariUnit (pointInDestinationView.x) - X,
//                yBy: cocoaToCanariUnit (pointInDestinationView.y) - Y
//              )
//              self.rootObject.symbolObjects_property.add (newObject)
//              self.mSymbolObjectsController.select (object: newObject)
//            }
//          }
//          ok = true
//        }
//      }
//    }
    return ok
  }

  //····················································································································
  //   removeWindowController
  //····················································································································

  override func removeUserInterface () {
    super.removeUserInterface ()
//    g_Preferences?.symbolColor_property.removeEBObserver (self.mSymbolColorObserver)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
