//
//  CanariFontDocument.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/11/2015.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariMergerDocument) class CanariMergerDocument : PMMergerDocument {

  //····················································································································
  //    init
  //····················································································································

  override init () {
    super.init ()
    undoManager?.disableUndoRegistration ()
    undoManager?.enableUndoRegistration ()
  }

  //····················································································································

  override func saveMetadataDictionary (version : Int, metadataDictionary : inout NSMutableDictionary) {
//     metadataDictionary.setObject (NSNumber (value:version), forKey:PMFontVersion as NSCopying)
//     metadataDictionary.setObject (rootObject.comments.propval, forKey:PMFontComment as NSCopying)
  }

  //····················································································································

//  override func readVersionFromMetadataDictionary (metadataDictionary : NSDictionary) -> Int {
//    var result = 0
//    if let versionNumber = metadataDictionary.object (forKey: PMFontVersion) as? NSNumber {
//      result = versionNumber.intValue
//    }
//    return result
//  }

  //····················································································································
  //    windowControllerDidLoadNib
  //····················································································································

//  override func windowControllerDidLoadNib (_ aController: NSWindowController) {
//    super.windowControllerDidLoadNib (aController)
//    windowForSheet?.acceptsMouseMovedEvents = true
//  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
