//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func transient_FontInProject_descriptor (
       _ self_mNominalSize : Int,        
       _ self_mDescriptiveString : String
) -> BoardFontDescriptor {
//--- START OF USER ZONE 2
  var fontDictionary = BoardFontDictionary ()
  let scanner = Scanner (string: self_mDescriptiveString)
  var ok = true
  while ok && scanner.myTestString ("|") {
    let codePoint = UInt32 (scanner.myScanInt (&ok))
    scanner.myCheckString (":", &ok)
    let advance = scanner.myScanInt (&ok)
    scanner.myCheckString (":", &ok)
    _ = scanner.myScanInt (&ok)  // mWarnsWhenAdvanceIsZero
    scanner.myCheckString (":", &ok)
    _ = scanner.myScanInt (&ok) // mWarnsWhenNoSegment
  //--- Segments
    var segments = [BoardCharSegment] ()
    while ok && scanner.myTestString (",") {
      var x = Int8 (scanner.myScanInt (&ok))
      var y = Int8 (scanner.myScanInt (&ok))
      var singlePoint = true
      while scanner.myTestString (">") {
        singlePoint = false
        let newX = Int8 (scanner.myScanInt (&ok))
        let newY = Int8 (scanner.myScanInt (&ok))
        segments.append (BoardCharSegment (x1: x, y1: y, x2: newX, y2: newY))
        x = newX
        y = newY
      }
      if singlePoint {
        segments.append (BoardCharSegment (x1: x, y1: y, x2: x, y2: y))
      }
    }
    fontDictionary [codePoint] = BoardFontCharacter (advancement: advance, segments: segments)
  }
  return BoardFontDescriptor (nominalSize: self_mNominalSize, dictionary: fontDictionary)
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————