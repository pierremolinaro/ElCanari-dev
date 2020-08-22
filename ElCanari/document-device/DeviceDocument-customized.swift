//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

let DEVICE_VERSION_METADATA_DICTIONARY_KEY = "DeviceVersion"
let DEVICE_COMMENT_METADATA_DICTIONARY_KEY = "DeviceComment"
let DEVICE_SYMBOL_METADATA_DICTIONARY_KEY  = "DeviceSymbols"
let DEVICE_PACKAGE_METADATA_DICTIONARY_KEY = "DevicePackages"

//----------------------------------------------------------------------------------------------------------------------

@objc(CustomizedDeviceDocument) class CustomizedDeviceDocument : DeviceDocument {

  //····················································································································

  override func metadataStatusForSaving () -> UInt8 {
    return UInt8 (self.mMetadataStatus?.rawValue ?? 0)
  }

  //····················································································································

  override func saveMetadataDictionary (version : Int, metadataDictionary : inout [String : Any]) {
  //--- Version
    metadataDictionary [DEVICE_VERSION_METADATA_DICTIONARY_KEY] = version
  //--- Comments
    metadataDictionary [DEVICE_COMMENT_METADATA_DICTIONARY_KEY] = self.rootObject.mComments
  //--- Packages
    var packageDictionary = [String : Int] ()
    for package in self.rootObject.mPackages.sorted (by: { $0.mName < $1.mName }) {
      packageDictionary [package.mName] = package.mVersion
    }
    metadataDictionary [DEVICE_PACKAGE_METADATA_DICTIONARY_KEY] = packageDictionary
  //--- Symbol Types
    var symbolDictionary = [String : Int] ()
    for symbolType in self.rootObject.mSymbolTypes.sorted (by: { $0.mTypeName < $1.mTypeName }) {
      symbolDictionary [symbolType.mTypeName] = symbolType.mVersion
    }
    metadataDictionary [DEVICE_SYMBOL_METADATA_DICTIONARY_KEY] = symbolDictionary  }

  //····················································································································

  override func readVersionFromMetadataDictionary (_ metadataDictionary : [String : Any]) -> Int {
    var result = 0
    if let versionNumber = metadataDictionary [DEVICE_VERSION_METADATA_DICTIONARY_KEY] as? Int {
      result = versionNumber
    }
    return result
  }

  //····················································································································
  //    windowControllerDidLoadNib: customization of interface
  //····················································································································

  override func windowControllerDidLoadNib (_ aController: NSWindowController) {
    super.windowControllerDidLoadNib (aController)
  //--- TEMPORARY: update pad proxies with pin instance names
    for padProxy in self.rootObject.mPadProxies {
      if let symbolPin = padProxy.mPinInstance {
        padProxy.mPinInstanceName = symbolPin.pinName!
      }
    }
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
  //---
    self.packageDisplayController.mAfterObjectRemovingCallback = { [weak self] in self?.updatePadProxies () }
    self.symbolDisplayController.mAfterObjectRemovingCallback = { [weak self] in self?.removeUnusedSymbolTypes () }
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
      let newSymbolInstance = SymbolInstanceInDevice (self.ebUndoManager)
      newSymbolInstance.mType_property.setProp (symbolType)
      self.rootObject.mSymbolInstances_property.add (newSymbolInstance)
      for pinType in symbolType.mPinTypes_property.propval {
        let pinInstance = SymbolPinInstanceInDevice (self.ebUndoManager)
        pinInstance.mType_property.setProp (pinType)
        newSymbolInstance.mPinInstances_property.add (pinInstance)
      }
    }
  }

  //····················································································································

  func removeUnusedSymbolTypes () {
    for symbolType in self.rootObject.mSymbolTypes_property.propval {
      if symbolType.mInstances_property.propval.count == 0 {
        for pinType in symbolType.mPinTypes_property.propval {
          pinType.cleanUpRelationshipsAndRemoveAllObservers ()
        }
        symbolType.cleanUpRelationshipsAndRemoveAllObservers ()
        self.rootObject.mSymbolTypes_property.remove (symbolType)
      }
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
