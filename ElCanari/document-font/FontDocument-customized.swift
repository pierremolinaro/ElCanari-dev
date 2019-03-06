//
//  FontDocument-customized.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/11/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PMFontVersion = "PMFontVersion"
let PMFontComment = "PMFontComment"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CustomizedFontDocument) class CustomizedFontDocument : FontDocument {

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
//      let newCharacter = FontCharacter (managedObjectContext: managedObjectContext)
//      newCharacter.codePoint = Int (key)
//      newCharacter.advance = descriptor.advancement
//      for segment in descriptor.segments {
//        let newSegment = SegmentForFontCharacter (managedObjectContext: managedObjectContext)
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

  }

  //····················································································································
  //    buildUserInterface: customization of interface
  //····················································································································

  override func windowControllerDidLoadNib (_ aController: NSWindowController) {
    super.windowControllerDidLoadNib (aController)
  //--- Set pages segmented control
    let pages = [self.mFontPageView, self.mInfosPageView]
    self.mPageSegmentedControl?.register (masterView: self.mMasterView, pages)
  //--- Set inspector segmented control
    let inspectors = [self.mSelectedCharacterInspectorView, self.mSampleStringInspectorView]
    self.mInspectorSegmentedControl?.register (masterView: self.mMasterFontPageView, inspectors)
  //---
    UserDefaults.standard.addObserver (
      self,
      forKeyPath: Preferences_currentCharacterCodePoint,
      options: .new,
      context: nil
    )
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
        let newSegment = SegmentForFontCharacter (self.ebUndoManager, file: #file, #line)
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

//  override func windowControllerDidLoadNib (_ aController: NSWindowController) {
//    super.windowControllerDidLoadNib (aController)
//    UserDefaults.standard.addObserver (
//      self,
//      forKeyPath: Preferences_currentCharacterCodePoint,
//      options: .new,
//      context: nil
//    )
////    self.updateCurrentCharacterSelection ()
//  }

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
        let newCharacter = FontCharacter (self.ebUndoManager, file: #file, #line)
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

