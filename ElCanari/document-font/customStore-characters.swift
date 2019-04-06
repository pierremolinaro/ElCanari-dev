//
//  customStore-characters.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let STORE_KEY = "-characters-"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func customStore_FontCharacter_characters (_ inCharacters : [FontCharacter], intoDictionary : NSMutableDictionary) {
  var s = ""
  var firstChar = true
  for char in inCharacters {
    if firstChar {
      firstChar = false
    }else{
      s += "|"
    }
    s += "\(char.codePoint):"
    s += "\(char.advance):"
    s += char.mWarnsWhenAdvanceIsZero ? "1:" : "0:"
    s += char.mWarnsWhenNoSegment ? "1:" : "0:"
    var firstSegment = true
    for segment in char.segments_property.propval {
      if firstSegment {
        firstSegment = false
      }else{
        s += ","
      }
      s += "\(segment.x1) \(segment.y1) \(segment.x2) \(segment.y2)"
    }
  }
  // NSLog ("LENGTH: \(s.utf8.count)")
  intoDictionary.setValue (s, forKey: STORE_KEY)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func customRead_FontCharacter_characters (from inDictionary : NSDictionary, with inUndoManager : EBUndoManager?) -> [FontCharacter] {
  let start = Date ()
  var result = [FontCharacter] ()
  if let s = inDictionary [STORE_KEY] as? String {
    for charDefinition in s.components (separatedBy: "|") {
      let newCharacter = FontCharacter (inUndoManager)
      result.append (newCharacter)
      let charComponents = charDefinition.components (separatedBy: ":")
      newCharacter.codePoint = Int (charComponents [0])!
      newCharacter.advance = Int (charComponents [1])!
      newCharacter.mWarnsWhenAdvanceIsZero = Int (charComponents [2])! != 0
      newCharacter.mWarnsWhenNoSegment = Int (charComponents [3])! != 0
      if charComponents [4] != "" {
        var segments = [SegmentForFontCharacter] ()
        for segment in charComponents [4].components (separatedBy: ",") {
          let newSegment = SegmentForFontCharacter (inUndoManager)
          segments.append (newSegment)
          let xy = segment.components (separatedBy: " ")
          newSegment.x1 = Int (xy [0])!
          newSegment.y1 = Int (xy [1])!
          newSegment.x2 = Int (xy [2])!
          newSegment.y2 = Int (xy [3])!
        }
        newCharacter.segments_property.setProp (segments)
      }
    }
  }
  let duration = Date ().timeIntervalSince (start)
  NSLog ("duration \(duration)")
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

