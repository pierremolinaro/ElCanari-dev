//
//  document-AutoLayoutDeviceDocument-sub-class.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 28/06/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

let DEVICE_VERSION_METADATA_DICTIONARY_KEY = "DeviceVersion"
let DEVICE_COMMENT_METADATA_DICTIONARY_KEY = "DeviceComment"
let DEVICE_SYMBOL_METADATA_DICTIONARY_KEY  = "DeviceSymbols"
let DEVICE_PACKAGE_METADATA_DICTIONARY_KEY = "DevicePackages"
let DEVICE_CATEGORY_KEY = "Category"

//--------------------------------------------------------------------------------------------------

@objc(AutoLayoutDeviceDocumentSubClass) final class AutoLayoutDeviceDocumentSubClass : AutoLayoutDeviceDocument {

 //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func ebBuildUserInterface () {
    super.ebBuildUserInterface ()
    self.packageDisplayController.mAfterObjectRemovingCallback = { [weak self] in
      self?.rootObject.updatePadProxies ()
    }
  //--- Remove unused symbol types
    for symbolType in self.rootObject.mSymbolTypes.values {
      if symbolType.mInstances.count == 0 {
        self.rootObject.mSymbolTypes_property.remove (symbolType)
      }
    }
  //--- Check embedded packages and symbols
    self.triggerStandAlonePropertyComputationForDeviceDocument ()
  }

 // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -····················

  override func metadataStatusForSaving () -> UInt8 {
    return UInt8 (self.metadataStatus?.rawValue ?? 0)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func saveMetadataDictionary (version inVersion : Int,
                                        metadataDictionary ioMetadataDictionary : inout [String : Any]) {
  //--- Version
    ioMetadataDictionary [DEVICE_VERSION_METADATA_DICTIONARY_KEY] = inVersion
  //--- Comments
    ioMetadataDictionary [DEVICE_COMMENT_METADATA_DICTIONARY_KEY] = self.rootObject.mComments
  //--- Packages
    var packageDictionary = [String : Int] ()
    for package in self.rootObject.mPackages.values.sorted (by: { $0.mName < $1.mName }) {
      packageDictionary [package.mName] = package.mVersion
    }
    ioMetadataDictionary [DEVICE_PACKAGE_METADATA_DICTIONARY_KEY] = packageDictionary
  //--- Symbol Types
    var symbolDictionary = [String : Int] ()
    for symbolType in self.rootObject.mSymbolTypes.values.sorted (by: { $0.mTypeName < $1.mTypeName }) {
      symbolDictionary [symbolType.mTypeName] = symbolType.mVersion
    }
    ioMetadataDictionary [DEVICE_SYMBOL_METADATA_DICTIONARY_KEY] = symbolDictionary
  //--- Category
    ioMetadataDictionary [DEVICE_CATEGORY_KEY] = self.rootObject.mCategory_property.propval
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func readVersionFromMetadataDictionary (_ inMetadataDictionary : [String : Any]) -> Int {
    var result = 0
    if let versionNumber = inMetadataDictionary [DEVICE_VERSION_METADATA_DICTIONARY_KEY] as? Int {
      result = versionNumber
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override final func defaultDraftName () -> String {
    return "untitled"
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
