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
  for char in inCharacters {
    s += "|"
    s += "\(char.codePoint):"
    s += "\(char.advance):"
    s += char.mWarnsWhenAdvanceIsZero ? "1:" : "0:"
    s += char.mWarnsWhenNoSegment ? "1" : "0"
    var x = Int.min
    var y = Int.min
    for segment in char.segments_property.propval {
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
//  NSLog ("LENGTH: \(s.utf8.count)")
  intoDictionary.setValue (s, forKey: STORE_KEY)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func customRead_FontCharacter_characters (from inDictionary : NSDictionary, with inUndoManager : EBUndoManager?) -> [FontCharacter] {
//  let start = Date ()
  var result = [FontCharacter] ()
  if let s = inDictionary [STORE_KEY] as? String {
    // Swift.print (s)
    let scanner = Scanner (string: s)
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
      var segments = [SegmentForFontCharacter] ()
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
//    NSLog ("ok \(ok)")
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
    let b = self.scanString (inString, into: nil)
    ioOk = ioOk && b
  }

  //··················································································································

  func myTestString (_ inString : String) -> Bool {
    return self.scanString (inString, into: nil)
  }

  //··················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
