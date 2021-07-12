//
//  document-AutoLayoutArtworkDocument-sub-class.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 25/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PMArtworkVersion = "PMArtworkVersion"
let PMArtworkComment = "PMArtworkComment"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(AutoLayoutArtworkDocumentSubClass) class AutoLayoutArtworkDocumentSubClass : AutoLayoutArtworkDocument {

  //····················································································································

  override func metadataStatusForSaving () -> UInt8 {
    return UInt8 (MetadataStatus.ok.rawValue)
  }

  //····················································································································

  override func saveMetadataDictionary (version : Int, metadataDictionary : inout [String : Any]) {
    metadataDictionary [PMArtworkVersion] = version
    metadataDictionary [PMArtworkComment] = self.rootObject.comments
  }

  //····················································································································

  override func readVersionFromMetadataDictionary (_ metadataDictionary : [String : Any]) -> Int {
    var result = 0
    if let versionNumber = metadataDictionary [PMArtworkVersion] as? Int {
      result = versionNumber
    }
    return result
  }

  //····················································································································

  override func windowDefaultSize () -> NSSize {
    return NSSize (width: 620, height: 580)
  }

  //····················································································································

   override func windowStyleMask () -> NSWindow.StyleMask {
    return [.titled, .closable, .miniaturizable]
  }

  //····················································································································

  override final func defaultDraftName () -> String {
    return "untitled"
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
