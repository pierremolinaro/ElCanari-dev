//
//  customStore-characters.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let FONT_DOCUMENT_DESCRIPTIVE_STRING_KEY = "-characters-"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func customStore_FontCharacter_characters (_ inCharacters : [FontCharacter]) -> String {
  var s = ""
  for char in inCharacters {
    s += "|"
    s += "\(char.codePoint):"
    s += "\(char.advance):"
    s += char.mWarnsWhenAdvanceIsZero ? "1:" : "0:"
    s += char.mWarnsWhenNoSegment ? "1" : "0"
    var x = Int.min
    var y = Int.min
    for segment in char.segments_property.propval.values {
      if (segment.x1 == x) && (segment.y1 == y) {
        s += ">\(segment.x2) \(segment.y2)"
      }else if (segment.x1 == segment.x2) && (segment.y1 == segment.y2) {
        s += ",\(segment.x1) \(segment.y1)"
      }else{
        s += ",\(segment.x1) \(segment.y1)>\(segment.x2) \(segment.y2)"
      }
      x = segment.x2
      y = segment.y2
    }
  }
  // Swift.print ("STR: '\(s)'")
//  ioDictionary? [FONT_DOCUMENT_DESCRIPTIVE_STRING_KEY] = s
//  inDictionary?.setValue (s, forKey: FONT_DOCUMENT_DESCRIPTIVE_STRING_KEY)
  return s
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func customStore_FontCharacter_characters (_ inCharacters : [FontCharacter],
                                                      intoDictionary ioDictionary : inout [String : Any]) {
  let s = customStore_FontCharacter_characters (inCharacters)
//  var s = ""
//  for char in inCharacters {
//    s += "|"
//    s += "\(char.codePoint):"
//    s += "\(char.advance):"
//    s += char.mWarnsWhenAdvanceIsZero ? "1:" : "0:"
//    s += char.mWarnsWhenNoSegment ? "1" : "0"
//    var x = Int.min
//    var y = Int.min
//    for segment in char.segments_property.propval.values {
//      if (segment.x1 == x) && (segment.y1 == y) {
//        s += ">\(segment.x2) \(segment.y2)"
//      }else if (segment.x1 == segment.x2) && (segment.y1 == segment.y2) {
//        s += ",\(segment.x1) \(segment.y1)"
//      }else{
//        s += ",\(segment.x1) \(segment.y1)>\(segment.x2) \(segment.y2)"
//      }
//      x = segment.x2
//      y = segment.y2
//    }
//  }
  // Swift.print ("STR: '\(s)'")
  ioDictionary [FONT_DOCUMENT_DESCRIPTIVE_STRING_KEY] = s
//  inDictionary?.setValue (s, forKey: FONT_DOCUMENT_DESCRIPTIVE_STRING_KEY)
//  return s
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func customRead_FontCharacter_characters (fromString inString : String,
                                                     with inUndoManager : UndoManager?) -> [FontCharacter] {
  var result = [FontCharacter] ()
  let scanner = Scanner (string: inString)
  var ok = true
  while ok && scanner.myTestString ("|") {
    let newCharacter = FontCharacter (inUndoManager)
    result.append (newCharacter)
    newCharacter.codePoint = scanner.myScanInt (&ok)
    scanner.myCheckString (":", &ok)
    newCharacter.advance = scanner.myScanInt (&ok)
    scanner.myCheckString (":", &ok)
    newCharacter.mWarnsWhenAdvanceIsZero = scanner.myScanInt (&ok) != 0
    scanner.myCheckString (":", &ok)
    newCharacter.mWarnsWhenNoSegment = scanner.myScanInt (&ok) != 0
  //--- Segments
    var segments = EBReferenceArray <SegmentForFontCharacter> ()
    while ok && scanner.myTestString (",") {
      var x = scanner.myScanInt (&ok)
      var y = scanner.myScanInt (&ok)
      var singlePoint = true
      while scanner.myTestString (">") {
        singlePoint = false
        let newSegment = SegmentForFontCharacter (inUndoManager)
        segments.append (newSegment)
        newSegment.x1 = x
        newSegment.y1 = y
        x = scanner.myScanInt (&ok)
        y = scanner.myScanInt (&ok)
        newSegment.x2 = x
        newSegment.y2 = y
      }
      if singlePoint {
        let newSegment = SegmentForFontCharacter (inUndoManager)
        segments.append (newSegment)
        newSegment.x1 = x
        newSegment.y1 = y
        newSegment.x2 = x
        newSegment.y2 = y
      }
      // Swift.print ("Segment \(newSegment.x1) \(newSegment.y1) \(newSegment.x2) \(newSegment.y2) > \(ok)")
    }
    newCharacter.segments_property.setProp (segments)
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func customRead_FontCharacter_characters (fromDictionary inDictionary : [String : Any],
                                                     with inUndoManager : UndoManager?) -> [FontCharacter] {
  var result = [FontCharacter] ()
  if let s = inDictionary [FONT_DOCUMENT_DESCRIPTIVE_STRING_KEY] as? String {
    result = customRead_FontCharacter_characters (fromString: s, with: inUndoManager)
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func extractProjectFontDictionary (from inDictionary : [String : Any]) -> FontDictionaryForProject {
//  let start = Date ()
  var result = FontDictionaryForProject ()
  if let s = inDictionary [FONT_DOCUMENT_DESCRIPTIVE_STRING_KEY] as? String {
    // Swift.print (s)
    let scanner = Scanner (string: s)
    var ok = true
    while ok && scanner.myTestString ("|") {
      let codePoint = scanner.myScanInt (&ok)
      scanner.myCheckString (":", &ok)
      let advance = scanner.myScanInt (&ok)
      scanner.myCheckString (":", &ok)
      _ = scanner.myScanInt (&ok) != 0 // mWarnsWhenAdvanceIsZero
      scanner.myCheckString (":", &ok)
      _ = scanner.myScanInt (&ok) != 0 // mWarnsWhenNoSegment
    //--- Segments
      var segments = [FontSegmentForProject] ()
      while ok && scanner.myTestString (",") {
        var x = scanner.myScanInt (&ok)
        var y = scanner.myScanInt (&ok)
        var singlePoint = true
        while scanner.myTestString (">") {
          singlePoint = false
          let newX = scanner.myScanInt (&ok)
          let newY = scanner.myScanInt (&ok)
          let newSegment = FontSegmentForProject (x1: x, y1: y, x2: newX, y2: newY)
          segments.append (newSegment)
          x = newX
          y = newY
        }
        if singlePoint {
          let newSegment = FontSegmentForProject (x1: x, y1: y, x2: y, y2: y)
          segments.append (newSegment)        }
      }
      let character = FontCharacterForProject (advance: advance, segments: segments)
      result [codePoint] = character
    }
 //   NSLog ("ok \(ok)")
  }
//  let duration = Date ().timeIntervalSince (start)
//  NSLog ("duration \(duration)")
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Scanner {

  //··················································································································

  func myScanInt (_ ioOk : inout Bool) -> Int {
    var value = 0
    let b = self.scanInt (&value)
    ioOk = ioOk && b
    return value
  }

  //··················································································································

  func myCheckString (_ inString : String, _ ioOk : inout Bool) {
    let s = self.scanString (inString)
    ioOk = ioOk && (s != nil)
  }

  //··················································································································

  func myTestString (_ inString : String) -> Bool {
    return self.scanString (inString) != nil
  }

  //··················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct FontSegmentForProject : Hashable {

  //··················································································································

  let x1 : Int
  let y1 : Int
  let x2 : Int
  let y2 : Int

  //··················································································································

  init (x1 inX1 : Int, y1 inY1 : Int, x2 inX2 : Int, y2 inY2 : Int) {
    x1 = inX1
    y1 = inY1
    x2 = inX2
    y2 = inY2
  }

  //··················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct FontCharacterForProject : Hashable {

  //··················································································································

  let advance : Int
  let segments : [FontSegmentForProject]

  //··················································································································

  init (advance inAdvance : Int, segments inSegments : [FontSegmentForProject]) {
    advance = inAdvance
    segments = inSegments
  }

  //··················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias FontDictionaryForProject = [Int : FontCharacterForProject]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
