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
  //--- TEMPORARY
     //    self.rootObject.packages_property.setProp ([])
     //   self.rootObject.mSymbolTypes_property.setProp ([])
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
  //---
    self.mInconsistentPackagePadNameSetsMessageTextView?.font = .systemFont (ofSize: 12.0)
    self.mInconsistentPackagePadNameSetsMessageTextView?.textColor = .red
  //---
    self.mInconsistentSymbolNameMessageTextView?.font = .systemFont (ofSize: 12.0)
    self.mInconsistentSymbolNameMessageTextView?.textColor = .red
  //---
    self.mAddSymbolInstancePullDownButton?.register (document: self)
  }

  //····················································································································

  func addSymbolInstance (named inSymbolTypeName : String ) {
  //--- Find symbol type
    var possibleSymbolType : SymbolTypeInDevice? = nil
    for candidateSymbolType in self.rootObject.mSymbolTypes_property.propval {
      if candidateSymbolType.mTypeName == inSymbolTypeName {
        possibleSymbolType = candidateSymbolType
        break
      }
    }
  //--- Add instance
    if let symbolType = possibleSymbolType {
      let newSymbolInstance = SymbolInstanceInDevice (self.ebUndoManager, file: #file, #line)
      newSymbolInstance.mType_property.setProp (symbolType)
      self.rootObject.mSymbolInstances_property.add (newSymbolInstance)
      for pinType in symbolType.mPinTypes_property.propval {
        let pinInstance = SymbolPinInstanceInDevice (self.ebUndoManager, file: #file, #line)
        pinInstance.mType_property.setProp (pinType)
        newSymbolInstance.mPinInstances_property.add (pinInstance)
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
