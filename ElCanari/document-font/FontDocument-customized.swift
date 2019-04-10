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
//        let newSegment = SegmentForFontCharacter (self.ebUndoManager)
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

  override func metadataStatusForSaving () -> UInt8 {
    return UInt8 (self.mMetadataStatus!.rawValue)
  }

  //····················································································································
  //    buildUserInterface: customization of interface
  //····················································································································

  private var mCurrentCharacterCodePointObserver : EBModelEvent? = nil

  //····················································································································

  override func windowControllerDidLoadNib (_ aController : NSWindowController) {
    super.windowControllerDidLoadNib (aController)
  //--- Set pages segmented control
    let pages = [self.mFontPageView, self.mInfosPageView]
    self.mPageSegmentedControl?.register (masterView: self.mMasterView, pages)
  //--- Set inspector segmented control
    let inspectors = [self.mSelectedCharacterInspectorView, self.mSampleStringInspectorView, self.mCharacterIssuesInspectorView]
    self.mInspectorSegmentedControl?.register (masterView: self.mMasterFontPageView, inspectors)
  //---
    self.mIssueTableView?.register (segmentedControl : self.mInspectorSegmentedControl, segment: 2)
  //---
    let currentCharacterCodePointObserver = EBModelEvent ()
    currentCharacterCodePointObserver.mEventCallBack = { [weak self] in self?.updateCurrentCharacterSelection () }
    self.rootObject.currentCharacterCodePointString_property.addEBObserver (currentCharacterCodePointObserver)
    self.mCurrentCharacterCodePointObserver = currentCharacterCodePointObserver
  }

  //····················································································································

  override func removeUserInterface () {
    if let currentCharacterCodePointObserver = self.mCurrentCharacterCodePointObserver {
      self.rootObject.currentCharacterCodePointString_property.removeEBObserver (currentCharacterCodePointObserver)
      self.mCurrentCharacterCodePointObserver = nil
    }
    super.removeUserInterface ()
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
    let codePoint = self.rootObject.currentCharacterCodePoint
    for character in self.rootObject.characters_property.propval {
      if character.codePoint == codePoint {
        possibleCurrentCharacter = character
        break
      }
    }
  //--- Update segments
    if let currentCharacter = possibleCurrentCharacter {
      var newSegmentEntityArray = [SegmentForFontCharacter] ()
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
  //    HANDLING CURRENT CHARACTER: windowControllerDidLoadNib
  //····················································································································

  fileprivate func updateCurrentCharacterSelection () {
    let codePoint = self.rootObject.currentCharacterCodePoint
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
      let newCharacter = FontCharacter (self.ebUndoManager)
      newCharacter.codePoint = codePoint
      characterSet.append (newCharacter)
      characterSet = characterSet.sorted { $0.codePoint < $1.codePoint }
      self.rootObject.characters_property.setProp (characterSet)
      self.mSelectedCharacterController.select (object: newCharacter)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
