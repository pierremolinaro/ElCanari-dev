//
//  add-board-model.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func double (fromDict inDictionary : NSDictionary, key inKey : String, _ errorArray : inout [String]) -> Double {
  let object : Any? = inDictionary.value (forKey: inKey)
  var result = 0.0 // Default result
  if object == nil {
    errorArray.append ("No \"\(inKey)\" key.")
  }else if let number = object as? NSNumber {
    result = number.doubleValue
  }else{
    errorArray.append ("The \"\(inKey)\" key value is not a double.")
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func int (fromDict inDictionary : NSDictionary, key inKey : String, _ errorArray : inout [String]) -> Int {
  let object : Any? = inDictionary.value (forKey: inKey)
  var result = 0 // Default result
  if object == nil {
    errorArray.append ("No \"\(inKey)\" key.")
  }else if let number = object as? NSNumber {
    result = number.intValue
  }else{
    errorArray.append ("The \"\(inKey)\" key value is not an integer.")
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func intOrZero (fromDict inDictionary : NSDictionary, key inKey : String, _ errorArray : inout [String]) -> Int {
  let object : Any? = inDictionary.value (forKey: inKey)
  var result = 0 // Default result
  if let number = object as? NSNumber {
    result = number.intValue
  }else if object != nil {
    errorArray.append ("The \"\(inKey)\" key value is not an integer.")
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func string (fromDict inDictionary : NSDictionary, key inKey : String, _ errorArray : inout [String]) -> String {
  let object : Any? = inDictionary.value (forKey: inKey)
  var result = "" // Default result
  if object == nil {
    errorArray.append ("No \"\(inKey)\" key.")
  }else if let s = object as? String {
    result = s
  }else{
    errorArray.append ("The \"\(inKey)\" key value is not a string.")
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func dictArray (fromDict inDictionary : NSDictionary, key inKey : String, _ errorArray : inout [String]) -> [NSDictionary] {
  let object : Any? = inDictionary.value (forKey: inKey)
  var result = [NSDictionary] () // Default result
  if object == nil {
    errorArray.append ("No \"\(inKey)\" key.")
  }else if let s = object as? [NSDictionary] {
    result = s
  }else{
    errorArray.append ("The \"\(inKey)\" key value is not an array of dictionaries.")
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func stringArray (fromDict inDictionary : NSDictionary, key inKey : String, _ errorArray : inout [String]) -> [String] {
  let object : Any? = inDictionary.value (forKey: inKey)
  var result = [String] () // Default result
  if object == nil {
    errorArray.append ("No \"\(inKey)\" key.")
  }else if let s = object as? [String] {
    result = s
  }else{
    errorArray.append ("The \"\(inKey)\" key value is not an array of string.")
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func array4int (fromString inString : String, _ errorArray : inout [String]) -> [Int] {
  let strArray : [String] = inString.components(separatedBy: " ")
  var result = [Int] () // Default result
  if strArray.count != 4 {
    errorArray.append ("The string is not a four integer array.")
  }else{
    for s in strArray {
      let possibleInt : Int? = Int (s)
      if let n = possibleInt {
        result.append (n)
      }else{
        errorArray.append ("The string is not a four integer array.")
      }
    }
  }
//--- If an error occurs, add fake int to get a five element vector
  while result.count < 4 {
    result.append (0)
  }
//---
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func array5int (fromString inString : String, _ errorArray : inout [String]) -> [Int] {
  let strArray : [String] = inString.components(separatedBy: " ")
  var result = [Int] () // Default result
  if strArray.count != 5 {
    errorArray.append ("The string is not a five integer array.")
  }else{
    for s in strArray {
      let possibleInt : Int? = Int (s)
      if let n = possibleInt {
        result.append (n)
      }else{
        errorArray.append ("The string is not a five integer array.")
      }
    }
  }
//--- If an error occurs, add fake int to get a five element vector
  while result.count < 5 {
    result.append (0)
  }
//---
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension MergerDocument {

  //····················································································································

  func parseBoardModel (fromDictionary boardArchiveDict : NSDictionary, named inName : String) -> BoardModel? {
  //  NSLog ("\(boardArchiveDict)")
    let boardModel = BoardModel (managedObjectContext:self.managedObjectContext())
  //--- Populate board model from dictionary (accumulate error messages in errorArray variable)
    var errorArray = [String] ()
    boardModel.name = inName
    boardModel.artworkName = string (fromDict: boardArchiveDict, key: "ARTWORK", &errorArray)
    boardModel.modelWidth = int (fromDict: boardArchiveDict, key: "BOARD-WIDTH", &errorArray)
    boardModel.modelWidthUnit = int (fromDict: boardArchiveDict, key: "BOARD-WIDTH-UNIT", &errorArray)
    boardModel.modelHeight = int (fromDict: boardArchiveDict, key: "BOARD-HEIGHT", &errorArray)
    boardModel.modelHeightUnit = int (fromDict: boardArchiveDict, key: "BOARD-HEIGHT-UNIT", &errorArray)
    boardModel.modelLimitWidth = int (fromDict: boardArchiveDict, key: "BOARD-LINE-WIDTH", &errorArray)
    boardModel.modelLimitWidthUnit = int (fromDict: boardArchiveDict, key: "BOARD-LINE-WIDTH-UNIT", &errorArray)
  //--- Front tracks
    var frontTrackEntities = [CanariSegment] ()
    let frontTracks = stringArray (fromDict: boardArchiveDict, key: "TRACKS-FRONT", &errorArray)
    for str in frontTracks {
      let track = CanariSegment (managedObjectContext:self.managedObjectContext())
      let ints = array5int (fromString: str, &errorArray)
      track.x1 = ints [0]
      track.y1 = ints [1]
      track.x2 = ints [2]
      track.y2 = ints [3]
      track.width = ints [4]
      frontTrackEntities.append (track)
    }
    boardModel.frontTracks_property.setProp (frontTrackEntities)
  //--- Back tracks
    var backTrackEntities = [CanariSegment] ()
    let backTracks = stringArray (fromDict: boardArchiveDict, key: "TRACKS-BACK", &errorArray)
    for str in backTracks {
      let track = CanariSegment (managedObjectContext:self.managedObjectContext())
      let ints = array5int (fromString: str, &errorArray)
      track.x1 = ints [0]
      track.y1 = ints [1]
      track.x2 = ints [2]
      track.y2 = ints [3]
      track.width = ints [4]
      backTrackEntities.append (track)
    }
    boardModel.backTracks_property.setProp (backTrackEntities)
  //--- Vias
    var viaEntities = [BoardModelVia] ()
    let vias = stringArray (fromDict: boardArchiveDict, key: "VIAS", &errorArray)
    for str in vias {
      let via = BoardModelVia (managedObjectContext:self.managedObjectContext())
      let ints = array4int (fromString: str, &errorArray)
      via.x = ints [0]
      via.y = ints [1]
      via.padDiameter = ints [2]
      via.holeDiameter = ints [3]
      viaEntities.append (via)
    }
    boardModel.vias_property.setProp (viaEntities)
  //--- Front Layout texts
    var frontLayoutTextEntities = [CanariSegment] ()
    let frontLayoutTexts = stringArray (fromDict: boardArchiveDict, key: "TEXTS-LAYOUT-FRONT", &errorArray)
    for str in frontLayoutTexts {
      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
      let ints = array5int (fromString: str, &errorArray)
      segment.x1 = ints [0]
      segment.y1 = ints [1]
      segment.x2 = ints [2]
      segment.y2 = ints [3]
      segment.width = ints [4]
      frontLayoutTextEntities.append (segment)
    }
    boardModel.frontLayoutTexts_property.setProp (frontLayoutTextEntities)
  //--- Back Layout texts
    var backLayoutTextEntities = [CanariSegment] ()
    let backLayoutTexts = stringArray (fromDict: boardArchiveDict, key: "TEXTS-LAYOUT-BACK", &errorArray)
    for str in backLayoutTexts {
      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
      let ints = array5int (fromString: str, &errorArray)
      segment.x1 = ints [0]
      segment.y1 = ints [1]
      segment.x2 = ints [2]
      segment.y2 = ints [3]
      segment.width = ints [4]
      backLayoutTextEntities.append (segment)
    }
    boardModel.backLayoutTexts_property.setProp (backLayoutTextEntities)
  //--- Back Legend texts
    var backLegendTextEntities = [CanariSegment] ()
    let backLegendTexts = stringArray (fromDict: boardArchiveDict, key: "TEXTS-LEGEND-BACK", &errorArray)
    for str in backLegendTexts {
      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
      let ints = array5int (fromString: str, &errorArray)
      segment.x1 = ints [0]
      segment.y1 = ints [1]
      segment.x2 = ints [2]
      segment.y2 = ints [3]
      segment.width = ints [4]
      backLegendTextEntities.append (segment)
    }
    boardModel.backLegendTexts_property.setProp (backLegendTextEntities)
  //--- Front Legend texts
    var frontLegendTextEntities = [CanariSegment] ()
    let frontTexts = stringArray (fromDict: boardArchiveDict, key: "TEXTS-LEGEND-FRONT", &errorArray)
    for str in frontTexts {
      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
      let ints = array5int (fromString: str, &errorArray)
      segment.x1 = ints [0]
      segment.y1 = ints [1]
      segment.x2 = ints [2]
      segment.y2 = ints [3]
      segment.width = ints [4]
      frontLegendTextEntities.append (segment)
    }
    boardModel.frontLegendTexts_property.setProp (frontLegendTextEntities)
  //--- Back packages
    var backPackagesEntities = [CanariSegment] ()
    let backPackages = stringArray (fromDict: boardArchiveDict, key: "PACKAGES-BACK", &errorArray)
    for str in backPackages {
      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
      let ints = array5int (fromString: str, &errorArray)
      segment.x1 = ints [0]
      segment.y1 = ints [1]
      segment.x2 = ints [2]
      segment.y2 = ints [3]
      segment.width = ints [4]
      backPackagesEntities.append (segment)
    }
    boardModel.backPackages_property.setProp (backPackagesEntities)
  //--- Front packages
    var frontPackagesEntities = [CanariSegment] ()
    let frontPackages = stringArray (fromDict: boardArchiveDict, key: "PACKAGES-FRONT", &errorArray)
    for str in frontPackages {
      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
      let ints = array5int (fromString: str, &errorArray)
      segment.x1 = ints [0]
      segment.y1 = ints [1]
      segment.x2 = ints [2]
      segment.y2 = ints [3]
      segment.width = ints [4]
      frontPackagesEntities.append (segment)
    }
    boardModel.frontPackages_property.setProp (frontPackagesEntities)
  //--- Back component names
    var backComponentNamesEntities = [CanariSegment] ()
    let backComponentNames = stringArray (fromDict: boardArchiveDict, key: "COMPONENT-NAMES-BACK", &errorArray)
    for str in backComponentNames {
//      NSLog ("\(str)")
      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
      let ints = array5int (fromString: str, &errorArray)
      segment.x1 = ints [0]
      segment.y1 = ints [1]
      segment.x2 = ints [2]
      segment.y2 = ints [3]
      segment.width = ints [4]
      backComponentNamesEntities.append (segment)
    }
//    NSLog ("--------")
    boardModel.backComponentNames_property.setProp (backComponentNamesEntities)
//    for object in boardModel.backComponentNames_property.propval {
//      NSLog ("\(object.x1) \(object.y1) \(object.x2) \(object.y2) \(object.width)")
//    }
//    NSLog ("+++++++++")
  //--- Front component names
    var frontComponentNamesEntities = [CanariSegment] ()
    let frontComponentNames = stringArray (fromDict: boardArchiveDict, key: "COMPONENT-NAMES-FRONT", &errorArray)
    for str in frontComponentNames {
      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
      let ints = array5int (fromString: str, &errorArray)
      segment.x1 = ints [0]
      segment.y1 = ints [1]
      segment.x2 = ints [2]
      segment.y2 = ints [3]
      segment.width = ints [4]
      frontComponentNamesEntities.append (segment)
    }
    boardModel.frontComponentNames_property.setProp (frontComponentNamesEntities)
  //--- Front component values
    var frontComponentValuesEntities = [CanariSegment] ()
    let frontComponentValues = stringArray (fromDict: boardArchiveDict, key: "COMPONENT-VALUES-FRONT", &errorArray)
    for str in frontComponentValues {
      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
      let ints = array5int (fromString: str, &errorArray)
      segment.x1 = ints [0]
      segment.y1 = ints [1]
      segment.x2 = ints [2]
      segment.y2 = ints [3]
      segment.width = ints [4]
      frontComponentValuesEntities.append (segment)
    }
    boardModel.frontComponentValues_property.setProp (frontComponentValuesEntities)
  //--- Back component values
    var backComponentValuesEntities = [CanariSegment] ()
    let backComponentValues = stringArray (fromDict: boardArchiveDict, key: "COMPONENT-VALUES-BACK", &errorArray)
    for str in backComponentValues {
      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
      let ints = array5int (fromString: str, &errorArray)
      segment.x1 = ints [0]
      segment.y1 = ints [1]
      segment.x2 = ints [2]
      segment.y2 = ints [3]
      segment.width = ints [4]
      backComponentValuesEntities.append (segment)
    }
    boardModel.backComponentValues_property.setProp (backComponentValuesEntities)
  //--- Pads
    var padEntities = [BoardModelPad] ()
    let padDictArray = dictArray (fromDict: boardArchiveDict, key: "PADS", &errorArray)
    for padDict in padDictArray {
      let pad = BoardModelPad (managedObjectContext:self.managedObjectContext())
      pad.qualifiedName = string (fromDict: padDict, key: "QUALIFIED-NAME", &errorArray)
      pad.x = int (fromDict: padDict, key: "X", &errorArray)
      pad.y = int (fromDict: padDict, key: "Y", &errorArray)
      pad.width = int (fromDict: padDict, key: "WIDTH", &errorArray)
      pad.height = int (fromDict: padDict, key: "HEIGHT", &errorArray)
      pad.holeDiameter = intOrZero (fromDict: padDict, key: "HOLE-DIAMETER", &errorArray)
      pad.rotation = int (fromDict: padDict, key: "ROTATION", &errorArray)
      let shapeString = string (fromDict: padDict, key: "SHAPE", &errorArray)
      if shapeString == "RECT" {
        pad.shape = .rectangular
      }else if shapeString == "ROUND" {
        pad.shape = .round
      }else{
        errorArray.append ("Invalid pad shape \"\(shapeString)\".")
      }
      let sideString = string (fromDict: padDict, key: "SIDE", &errorArray)
      if sideString == "TRAVERSING" {
        pad.side = .traversing
      }else if sideString == "FRONT" {
        pad.side = .front
      }else if sideString == "BACK" {
        pad.side = .back
      }else{
        errorArray.append ("Invalid pad side \"\(sideString)\".")
      }
      padEntities.append (pad)
    }
    boardModel.pads_property.setProp (padEntities)
  //--- Dictionary import ok ?
    if errorArray.count != 0 { // Error
      var s = ""
      for anError in errorArray {
        if s != "" {
          s += "\n"
        }
        s += anError
      }
      let alert = NSAlert ()
      alert.messageText = "Cannot Analyse file contents"
      alert.addButton (withTitle: "Ok")
      alert.informativeText = s
      alert.beginSheetModal (for: self.windowForSheet!, completionHandler: {(NSModalResponse) in})
    }
  //--- Return 
    return (errorArray.count == 0) ? boardModel : nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
