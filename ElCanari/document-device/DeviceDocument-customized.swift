//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PMDeviceVersion = "PMDeviceVersion"
let PMDeviceComment = "PMDeviceComment"
let PMDeviceSymbols = "PMDeviceSymbols"
let PMDevicePackages = "PMDevicePackages"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CustomizedDeviceDocument) class CustomizedDeviceDocument : DeviceDocument {

  //····················································································································

  override func metadataStatusForSaving () -> UInt8 {
    return 0
  }

  //····················································································································

  override func saveMetadataDictionary (version : Int, metadataDictionary : inout [String : Any]) {
    metadataDictionary [PMDeviceVersion] = version
    metadataDictionary [PMDeviceComment] = self.rootObject.comments
  }

  //····················································································································

  override func readVersionFromMetadataDictionary (_ metadataDictionary : [String : Any]) -> Int {
    var result = 0
    if let versionNumber = metadataDictionary [PMDeviceVersion] as? Int {
      result = versionNumber
    }
    return result
  }

  //····················································································································
  //    windowControllerDidLoadNib: customization of interface
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
  //--- TEMPORARY
//    self.rootObject.packages_property.setProp ([])
  //---
    self.mInconsistentPackagePadNameSetsMessageTextView?.font = .systemFont (ofSize: 12.0)
    self.mInconsistentPackagePadNameSetsMessageTextView?.textColor = .red
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
