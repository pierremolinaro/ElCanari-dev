//
//  document-AutoLayoutFontDocument-extension.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 29/11/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutFontDocument {

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
        let newSegment = SegmentForFontCharacter (self.undoManager)
        newSegment.x1 = segment.x1
        newSegment.y1 = segment.y1
        newSegment.x2 = segment.x2
        newSegment.y2 = segment.y2
        newSegmentEntityArray.append (newSegment)
      }
      currentCharacter.segments_property.setProp (newSegmentEntityArray)
      flushOutletEvents ()
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
