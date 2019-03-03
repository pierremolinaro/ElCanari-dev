//
//  ArtworkDocument+extension.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/11/2015.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PMArtworkVersion = "PMArtworkVersion"
let PMArtworkComment = "PMArtworkComment"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CustomizedArtworkDocument) class CustomizedArtworkDocument : ArtworkDocument {

  //····················································································································

  override func saveMetadataDictionary (version : Int, metadataDictionary : inout [String : Any]) {
    metadataDictionary [PMArtworkVersion] = version
    metadataDictionary [PMArtworkComment] = rootObject.comments
  }

  //····················································································································

  override func readVersionFromMetadataDictionary (metadataDictionary : [String : Any]) -> Int {
    var result = 0
    if let versionNumber = metadataDictionary [PMArtworkVersion] as? Int {
      result = versionNumber
    }
    return result
  }

  //····················································································································
  //    buildUserInterface: customization of interface
  //····················································································································

  override func windowControllerDidLoadNib (_ aController: NSWindowController) {
    super.windowControllerDidLoadNib (aController)
  //--- Set pages segmented control
    let pages = [self.mMinimaPageView, self.mDrillPageView, self.mDataPageView, self.mInfosPageView]
    self.mSegmentedControl?.register (masterView: self.mMasterView, pages)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

