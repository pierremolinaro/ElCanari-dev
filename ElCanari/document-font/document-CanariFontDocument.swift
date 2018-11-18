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

let PMFontVersion = "PMFontVersion"
let PMFontComment = "PMFontComment"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariFontDocument) class CanariFontDocument : PMFontDocument {

  //····················································································································
  //    init
  //····················································································································

  override init () {
    super.init ()

  //--- Add kicad font
//    let font = kicadFont ()
//    let keys = font.keys.sorted ()
//    var characterArray = [FontCharacter] ()
//    for key in keys {
//      let descriptor = font [key]!
//      let newCharacter = FontCharacter (managedObjectContext: managedObjectContext())
//      newCharacter.codePoint = Int (key)
//      newCharacter.advance = descriptor.advancement
//      for segment in descriptor.segments {
//        let newSegment = SegmentForFontCharacter (managedObjectContext: managedObjectContext())
//        newSegment.x1 = segment.x1
//        newSegment.y1 = -segment.y1 - 1
//        newSegment.x2 = segment.x2
//        newSegment.y2 = -segment.y2 - 1
//        newCharacter.segments_property.add (newSegment)
//      }
//      characterArray.append (newCharacter)
//    }
//    rootObject.characters_property.setProp (characterArray)
//    rootObject.nominalSize = 21




  //--- Add empty characters
//    var characterSet = [FontCharacter] ()
//    for codePoint in 0x20 ... 0x7F {
//      let newCharacter = FontCharacter (managedObjectContext: self.managedObjectContext())
//      newCharacter.codePoint = codePoint
//      characterSet.append (newCharacter)
//    }
//    characterSet = characterSet.sorted (by :{$0.codePoint < $1.codePoint})
//    self.rootObject.characters_property.setProp (characterSet)
  }

  //····················································································································

  override func saveMetadataDictionary (version : Int, metadataDictionary : inout NSMutableDictionary) {
     metadataDictionary.setObject (NSNumber (value: version), forKey: PMFontVersion as NSCopying)
     metadataDictionary.setObject (rootObject.comments, forKey:PMFontComment as NSCopying)
  }

  //····················································································································

  override func readVersionFromMetadataDictionary (metadataDictionary : NSDictionary) -> Int {
    var result = 0
    if let versionNumber = metadataDictionary.object (forKey: PMFontVersion) as? NSNumber {
      result = versionNumber.intValue
    }
    return result
  }

  //····················································································································
  //   Method called by CanariCharacterView, when segments of currently selected characters change
  //····················································································································

  func defineSegmentsForCurrentCharacter (_ inSegments : [SegmentForFontCharacterClass]) {
  //--- Search character
    var possibleCurrentCharacter : FontCharacter? = nil
    if let codePoint = g_Preferences?.currentCharacterCodePoint {
      for character in self.rootObject.characters_property.propval {
        if character.codePoint == codePoint {
          possibleCurrentCharacter = character
          break
        }
      }
    }
  //--- Update segments
    if let currentCharacter = possibleCurrentCharacter {
      var newSegmentEntityArray = [SegmentForFontCharacter] ()
      for segment in inSegments {
        let newSegment = SegmentForFontCharacter (managedObjectContext: self.managedObjectContext())
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
  //    HANDLING CURRENT CHARACTER: windowControllerDidLoadNib
  //····················································································································

  override func windowControllerDidLoadNib (_ aController: NSWindowController) {
    super.windowControllerDidLoadNib (aController)
    UserDefaults.standard.addObserver (
      self,
      forKeyPath: Preferences_currentCharacterCodePoint,
      options: .new,
      context: nil
    )
    self.updateCurrentCharacterSelection ()
  }

  //····················································································································

  fileprivate func updateCurrentCharacterSelection () {
    if let codePoint = g_Preferences?.currentCharacterCodePoint {
    //--- Search for character
      var found = false
      for character in self.rootObject.characters_property.propval {
        if character.codePoint == codePoint {
          self.mSelectedCharacterController.select (object: character)
          found = true
          break
        }
      }
    //--- There is no character for this code point: create it
      if !found {
        var characterSet = self.rootObject.characters_property.propval
        let newCharacter = FontCharacter (managedObjectContext: self.managedObjectContext())
        newCharacter.codePoint = codePoint
        characterSet.append (newCharacter)
        characterSet = characterSet.sorted (by: {$0.codePoint < $1.codePoint})
        self.rootObject.characters_property.setProp (characterSet)
        self.mSelectedCharacterController.select (object: newCharacter)
      }
    }
  }

  //····················································································································

  override func observeValue (forKeyPath keyPath: String?,
                              of object: Any?,
                              change: [NSKeyValueChangeKey : Any]?,
                              context: UnsafeMutableRawPointer?) {
    if keyPath == Preferences_currentCharacterCodePoint {
      self.updateCurrentCharacterSelection ()
    }else{
      super.observeValue (forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }

  //····················································································································

  deinit {
    UserDefaults.standard.removeObserver (self, forKeyPath:Preferences_currentCharacterCodePoint, context: nil)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
