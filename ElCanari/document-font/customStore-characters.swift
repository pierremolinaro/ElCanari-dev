//
//  customStore-characters.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let KEY_FOR_FontCharacter_characters = "-characters-"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Custom_FontCharacter_StoredArrayOf_FontCharacter : StoredArrayOf_FontCharacter {

  //····················································································································
  //   Read
  //····················································································································

  override func initialize (fromDictionary inDictionary : [String : Any],
                            managedObjectArray inManagedObjectArray : [EBManagedObject]) {
    if let key = self.key, let string = inDictionary [key] as? String {
      let objectArray = self.customRead_FontCharacter_characters (fromString: string)
      self.setProp (objectArray)
    }
  }

  //····················································································································

  override func initialize (fromRange inRange : NSRange, ofData inData : Data, _ inRawObjectArray : [RawObject]) {
    if let s = String (data: inData [inRange.location ..< inRange.location + inRange.length], encoding: .utf8) {
      let objectArray = self.customRead_FontCharacter_characters (fromString: s)
      self.setProp (objectArray)
    }
  }

  //····················································································································

  private func customRead_FontCharacter_characters (fromString inString : String) -> EBReferenceArray <FontCharacter> {
    var result = EBReferenceArray <FontCharacter> ()
    let scanner = Scanner (string: inString)
    var ok = true
    while ok && scanner.myTestString ("|") {
      let newCharacter = FontCharacter (self.undoManager)
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
          let newSegment = SegmentForFontCharacter (self.undoManager)
          segments.append (newSegment)
          newSegment.x1 = x
          newSegment.y1 = y
          x = scanner.myScanInt (&ok)
          y = scanner.myScanInt (&ok)
          newSegment.x2 = x
          newSegment.y2 = y
        }
        if singlePoint {
          let newSegment = SegmentForFontCharacter (self.undoManager)
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

  //····················································································································
  //   Store
  //····················································································································

  override func enterRelationshipObjects (intoArray ioArray : inout [EBManagedObject]) {
  }

  //····················································································································

  override func store (inDictionary ioDictionary : inout [String : Any]) {
    if let key = self.key, self.mInternalArrayValue.count > 0 {
      let s = self.customStore_FontCharacter_characters ()
      ioDictionary [key] = s
    }
  }

  //····················································································································

  override func appendValueTo (data ioData : inout Data) {
    let s = self.customStore_FontCharacter_characters ()
    let data = s.data (using: .utf8)!
    ioData += data
  }

  //····················································································································

  final private func customStore_FontCharacter_characters () -> String {
    var s = ""
    for char in self.mInternalArrayValue.values {
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
    return s
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//@MainActor func customStore_FontCharacter_characters (_ inCharacters : [FontCharacter]) -> String {
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
//  return s
//}

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
