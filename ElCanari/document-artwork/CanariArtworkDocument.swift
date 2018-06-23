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

@objc(CanariArtworkDocument) class CanariArtworkDocument : PMArtworkDocument {

  //····················································································································

  override func saveMetadataDictionary (version : Int, metadataDictionary : inout NSMutableDictionary) {
     metadataDictionary.setObject (NSNumber (value:version), forKey:PMArtworkVersion as NSCopying)
     metadataDictionary.setObject (rootObject.comments.propval, forKey:PMArtworkComment as NSCopying)
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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

