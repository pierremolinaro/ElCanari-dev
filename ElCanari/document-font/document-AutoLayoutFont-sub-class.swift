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
  //    init : import Kicad font
  //····················································································································

//  override init () {
//    super.init ()
//
//  //--- Add kicad font
//    let font = kicadFont ()
//    let keys = font.keys.sorted ()
//    var characterArray = [FontCharacter] ()
//    for key in keys {
//      let descriptor = font [key]!
//      let newCharacter = FontCharacter (self.ebUndoManager)
//      newCharacter.codePoint = Int (key)
//      newCharacter.advance = descriptor.advancement
//      for segment in descriptor.segments {
//        let newSegment = FontCharacterSegment (self.ebUndoManager)
//        newSegment.x1 = segment.x1
//        newSegment.y1 = -segment.y1 - 1
//        newSegment.x2 = segment.x2
//        newSegment.y2 = -segment.y2 - 1
//        newCharacter.segments_property.add (newSegment)
//      }
//      newCharacter.mWarnsWhenNoSegment = descriptor.segments.count != 0
//      characterArray.append (newCharacter)
//    }
//    rootObject.characters_property.setProp (characterArray)
//    rootObject.nominalSize = 21
//  }

  //····················································································································
  //  Metadata
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
  //    HANDLING CURRENT CHARACTER: windowControllerDidLoadNib
  //····················································································································

  private var mCurrentCharacterCodePointObserver : EBModelEvent? = nil

  //····················································································································

  fileprivate func updateCurrentCharacterSelection () {
    let codePoint = self.rootObject.currentCharacterCodePoint
  //--- Search for character
    var found = false
    for character in self.rootObject.characters_property.propval.values {
      if character.codePoint == codePoint {
        self.selectedCharacterController.select (object: character)
        found = true
        break
      }
    }
  //--- There is no character for this code point: create it
    if !found {
      var characterSet = self.rootObject.characters_property.propval
      let newCharacter = FontCharacter (self.ebUndoManager)
      newCharacter.codePoint = codePoint
      characterSet.append (newCharacter)
      characterSet.sort { $0.codePoint < $1.codePoint }
      self.rootObject.characters_property.setProp (characterSet)
      self.selectedCharacterController.select (object: newCharacter)
    }
  }

  //····················································································································

  override func ebBuildUserInterface () {
    super.ebBuildUserInterface ()
  //---
    let currentCharacterCodePointObserver = EBModelEvent ()
    currentCharacterCodePointObserver.mEventCallBack = {
      [weak self] in self?.updateCurrentCharacterSelection ()
    }
    self.rootObject.currentCharacterCodePointString_property.addEBObserver (currentCharacterCodePointObserver)
    self.mCurrentCharacterCodePointObserver = currentCharacterCodePointObserver
  }

  //····················································································································

/*  override func removeUserInterface () {
    if let currentCharacterCodePointObserver = self.mCurrentCharacterCodePointObserver {
      self.rootObject.currentCharacterCodePointString_property.removeEBObserver (currentCharacterCodePointObserver)
      self.mCurrentCharacterCodePointObserver = nil
    }
    super.removeUserInterface ()
  } */

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


