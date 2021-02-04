//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

//let PMPackageVersion = "PMPackageVersion"
//let PMPackageComment = "PMPackageComment"

//----------------------------------------------------------------------------------------------------------------------

//fileprivate let packagePasteboardType = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.pasteboard.package")

//----------------------------------------------------------------------------------------------------------------------

@objc(AutoLayoutPackageCustomizedDocument)  class AutoLayoutPackageCustomizedDocument : AutoLayoutPackageDocument {

  //····················································································································

  override func metadataStatusForSaving () -> UInt8 {
    return UInt8 (self.metadataStatus!.rawValue)
  }

  //····················································································································

  override func saveMetadataDictionary (version : Int, metadataDictionary : inout [String : Any]) {
    metadataDictionary [PMPackageVersion] = version
    metadataDictionary [PMPackageComment] = self.rootObject.comments
  }

  //····················································································································

  override func readVersionFromMetadataDictionary (_ metadataDictionary : [String : Any]) -> Int {
    var result = 0
    if let versionNumber = metadataDictionary [PMPackageVersion] as? Int {
      result = versionNumber
    }
    return result
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
