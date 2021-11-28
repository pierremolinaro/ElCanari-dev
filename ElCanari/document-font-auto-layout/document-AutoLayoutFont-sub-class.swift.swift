//
//  document-AutoLayoutFont-sub-class.swift.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 24/11/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PMFontVersion = "PMFontVersion"
let PMFontComment = "PMFontComment"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

// let packagePasteboardType = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.pasteboard.package")

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(AutoLayoutFontDocumentSubClass) final class AutoLayoutFontDocumentSubClass : AutoLayoutFontDocument {

  //····················································································································

  override func metadataStatusForSaving () -> UInt8 {
    return UInt8 (self.metadataStatus!.rawValue)
  }

  //····················································································································

  override func saveMetadataDictionary (version : Int, metadataDictionary : inout [String : Any]) {
    metadataDictionary [PMFontVersion] = version
    metadataDictionary [PMFontComment] = self.rootObject.comments
  }

  //····················································································································

  override func readVersionFromMetadataDictionary (_ metadataDictionary : [String : Any]) -> Int {
    var result = 0
    if let versionNumber = metadataDictionary [PMFontVersion] as? Int {
      result = versionNumber
    }
    return result
  }

  //····················································································································

  override func windowDefaultSize () -> NSSize {
    return NSSize (width: 800, height: 600)
  }

  //····················································································································

  override final func defaultDraftName () -> String {
    return "untitled"
  }

  //····················································································································
  //   Method called by CanariCharacterView, when segments of currently selected characters change
  //····················································································································

  func defineSegmentsForCurrentCharacter (_ inSegments : [FontCharacterSegment]) {
  //--- Search character
    var possibleCurrentCharacter : FontCharacter? = nil
    let codePoint = self.rootObject.currentCharacterCodePoint
    for character in self.rootObject.characters_property.propval.values {
      if character.codePoint == codePoint {
        possibleCurrentCharacter = character
        break
      }
    }
  //--- Update segments
    if let currentCharacter = possibleCurrentCharacter {
      var newSegmentEntityArray = EBReferenceArray <SegmentForFontCharacter> ()
      for segment in inSegments {
        let newSegment = SegmentForFontCharacter (self.ebUndoManager)
        newSegment.x1 = segment.x1
        newSegment.y1 = segment.y1
        newSegment.x2 = segment.x2
        newSegment.y2 = segment.y2
        newSegmentEntityArray.append (newSegment)
      }
      currentCharacter.segments_property.setProp (newSegmentEntityArray)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


