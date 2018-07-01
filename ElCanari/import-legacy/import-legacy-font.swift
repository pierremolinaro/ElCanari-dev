//
//  legacy-font.swift
//  canari
//
//  Created by Pierre Molinaro on november 11th, 2016.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let FONT_LEGACY_ENTITY_NAME_DICTIONARY : [String : String] = [ // used in import-legacy-document.swift
  "FontRootEntity" : "FontRootEntity", // Canari entity name --> El Canari Entity Name
  "FontCharacterEntity" : "FontCharacterEntity",
  "SegmentForFontCharacterEntity" : "SegmentForFontCharacterEntity"
]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//private func macRomanToElCanariFontIndex (_ inMacRoman : Int) -> Int {
//  let macRomanAsByte = UInt8 (inMacRoman)
//  let macRomanAsString = String (bytes: [macRomanAsByte], encoding: .macOSRoman)
//  let macRomanAsUnicode = macRomanAsString?.unicodeScalars
//  let unicodeArray = macRomanAsUnicode!.map { $0.value }
//  let unicodePoint : Int = Int (unicodeArray [0])
//  // NSLog ("inMacRoman \(inMacRoman), macRomanAsUnicode \(macRomanAsUnicode), unicodeArray \(unicodeArray), unicodePoint \(unicodePoint)")
//  var result = unicodePoint - 32 // Codes before space are not handled
//  if result > (0x7F - 32) {
//    result -= 32 // Codes between 0x80 and 0x9F are not handled
//  }
//  return result
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension FontRootEntity {

  //····················································································································
  // In canari 1, a font handles 224 characters, encoded in Mac Roman
  // objectPropertyDictionary ["characters"] is not ordered
  
  override func additionalSetUpOnLegacyImport (_ objectPropertyDictionary : NSDictionary,
                                               _ legacyImportContext : LegacyImportContext) throws {
    // NSLog ("\(self.className).\(#function)")
    // NSLog ("objectPropertyDictionary \(objectPropertyDictionary)")
  //--- Build a dictionary of imported characters, key is MacRoman character code
    let importedCharacterArray = objectPropertyDictionary ["characters"] as! [NSNumber]
    var newCharacterDictionary = [Int : FontCharacterEntity] ()
    for idx in importedCharacterArray {
      let index : Int = idx.intValue
      let newCharacter = legacyImportContext.mObjectArray [index] as! FontCharacterEntity
      let macRomanCode : Int = (legacyImportContext.mLegacyObjectDictionaryArray [index] ["code"] as! NSNumber).intValue
      // NSLog ("index \(index), macRomanCode \(macRomanCode)")
      newCharacterDictionary [macRomanCode] = newCharacter
    }
  //--- Build a fresh array of characters
    var newCharacterArray = [FontCharacterEntity] ()
    for _ in 0 ..< CANARI_FONT_CHARACTER_COUNT {
      let newCharacter = FontCharacterEntity (managedObjectContext: legacyImportContext.mManagedObjectContext)
      newCharacterArray.append (newCharacter)
    }
  //--- Set characters from dictionary
    for (macRomanCode, character) in newCharacterDictionary {
      let idx = macRomanCode - 32
      if (idx >= 0) && (idx < CANARI_FONT_CHARACTER_COUNT) {
        newCharacterArray [idx] = character
      }
    }
  //--- Set property
    characters_property.setProp (newCharacterArray)
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


extension FontCharacterEntity {

  //····················································································································

  override func additionalSetUpOnLegacyImport (_ objectPropertyDictionary : NSDictionary,
                                               _ legacyImportContext : LegacyImportContext) throws {
    // NSLog ("\(self.className).\(#function)")
    // NSLog ("objectPropertyDictionary \(objectPropertyDictionary)")
  //--- "advancement" in Canari 1 is renamed "advance"
    self.advance = (objectPropertyDictionary ["advancement"] as! NSNumber).intValue
  //--- "glyph" in Canari 1 is renamed "segments
  // objectPropertyDictionary ["glyph"] is an array of object indexes
  // But this array is not ordered: so we need to use the "layer" property to build the new ordered segment array
    let possibleGlyph = objectPropertyDictionary ["glyph"] // is nil if no segment
    if let glyph = possibleGlyph {
      // NSLog ("GLYPH \(glyph)")
      var newSegmentDictionary = [Int : SegmentForFontCharacterEntity] ()
      for idx in glyph as! [NSNumber] {
        let index : Int = idx.intValue
        // NSLog ("\(idx), \(index)")
        let newSegment = legacyImportContext.mObjectArray [index] as! SegmentForFontCharacterEntity
        let layer : Int = (legacyImportContext.mLegacyObjectDictionaryArray [index] ["layer"] as! NSNumber).intValue
        // NSLog ("\(layer)")
        newSegmentDictionary [layer] = newSegment
       // newSegmentArray.append (newSegment)
      }
      var newSegmentArray = [SegmentForFontCharacterEntity] ()
      for idx in 0 ..< (glyph as! [NSNumber]).count {
         newSegmentArray.append(newSegmentDictionary [idx]!)
      }
      segments_property.setProp (newSegmentArray)
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


extension SegmentForFontCharacterEntity {

  //····················································································································
  // In Canari 1, segment points are encoded in strings: stringForP1, and stringForP2
  // In El Canari, segment points are encoded in distinct properties: x1, y1, x2, y2
  
  override func additionalSetUpOnLegacyImport (_ objectPropertyDictionary : NSDictionary,
                                               _ legacyImportContext : LegacyImportContext) throws {
    //NSLog ("\(self.className).\(#function)")
    //NSLog ("objectPropertyDictionary \(objectPropertyDictionary)")
    let DIVISOR = 476_250 // 952500
  //--- P1
    var s : String = objectPropertyDictionary ["stringForP1"] as! String // For example: "2857500 5715000"
    var array = s.components(separatedBy: " ") // --> ["2857500", "5715000"]
    var x : Int = Int (array [0])! // --> 2857500
    var y : Int = Int (array [1])! // --> 5715000
    // Swift.print ("x1 \(x) --> \(x / DIVISOR - 2), y1 \(y) --> \(y / DIVISOR - 6)")
    x1 = x / DIVISOR - 2
    y1 = y / DIVISOR - 6
  //--- P2
    s = objectPropertyDictionary ["stringForP2"] as! String // For example: "2857500 5715000"
    array = s.components(separatedBy: " ") // --> ["2857500", "5715000"]
    x = Int (array [0])! // --> 2857500
    y = Int (array [1])! // --> 5715000
    // Swift.print ("x2 \(x), y2 \(y)")
    x2 = x / DIVISOR - 2
    y2 = y / DIVISOR - 6
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

