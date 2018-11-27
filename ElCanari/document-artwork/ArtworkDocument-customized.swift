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

  override func saveMetadataDictionary (version : Int, metadataDictionary : inout NSMutableDictionary) {
     metadataDictionary.setObject (NSNumber (value:version), forKey:PMArtworkVersion as NSCopying)
     metadataDictionary.setObject (rootObject.comments, forKey:PMArtworkComment as NSCopying)
  }

  //····················································································································

  override func readVersionFromMetadataDictionary (metadataDictionary : NSDictionary) -> Int {
    var result = 0
    if let versionNumber = metadataDictionary.object (forKey: PMArtworkVersion) as? NSNumber {
      result = versionNumber.intValue
    }
    return result
  }

   //····················································································································
  //    windowControllerDidLoadNib: customization of interface
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

