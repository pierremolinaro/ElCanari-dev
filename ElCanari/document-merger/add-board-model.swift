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

fileprivate func intArray (fromString inString : String, _ errorArray : inout [String]) -> [Int] {
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

extension PMMergerDocument {

  //····················································································································

  func addBoardModel (fromDictionary boardArchiveDict : NSDictionary, named inName : String) {
  //  NSLog ("\(boardArchiveDict)")
    let boardModel = BoardModelEntity (managedObjectContext:self.managedObjectContext())
  //--- Populate board model from dictionary (accumulate error messages in errorArray variable)
    var errorArray = [String] ()
    boardModel.name.setProp (inName)
    boardModel.artworkName.setProp (string (fromDict: boardArchiveDict, key: "ARTWORK", &errorArray))
    boardModel.boardWidth.setProp (int (fromDict: boardArchiveDict, key: "BOARD-WIDTH", &errorArray))
    boardModel.boardWidthUnit.setProp (int (fromDict: boardArchiveDict, key: "BOARD-WIDTH-UNIT", &errorArray))
    boardModel.boardHeight.setProp (int (fromDict: boardArchiveDict, key: "BOARD-HEIGHT", &errorArray))
    boardModel.boardHeightUnit.setProp (int (fromDict: boardArchiveDict, key: "BOARD-HEIGHT-UNIT", &errorArray))
  //--- Tracks
    let tracks = dictArray (fromDict: boardArchiveDict, key: "TRACKS", &errorArray)
    for t in tracks {
      let track = BoardModelTrackSegmentEntity (managedObjectContext:self.managedObjectContext())
      track.x1.setProp (int (fromDict: t, key: "X1", &errorArray))
      track.y1.setProp (int (fromDict: t, key: "Y1", &errorArray))
      track.x2.setProp (int (fromDict: t, key: "X2", &errorArray))
      track.y2.setProp (int (fromDict: t, key: "Y2", &errorArray))
      track.width.setProp (int (fromDict: t, key: "WIDTH", &errorArray))
      let sideString = string (fromDict: t, key: "SIDE", &errorArray)
      if sideString == "TOP" {
        track.side.setProp (.front)
      }else if sideString == "BACK" {
        track.side.setProp (.back)
      }else{
        errorArray.append ("Invalid track side \"\(sideString)\".")
      }
      boardModel.tracks.add (track)
    }
  //--- Vias
    let vias = dictArray (fromDict: boardArchiveDict, key: "VIAS", &errorArray)
    for viaDict in vias {
      let via = BoardModelViaEntity (managedObjectContext:self.managedObjectContext())
      via.x.setProp (int (fromDict: viaDict, key: "X", &errorArray))
      via.y.setProp (int (fromDict: viaDict, key: "Y", &errorArray))
      via.holeDiameter.setProp (int (fromDict: viaDict, key: "HOLE-DIAMETER", &errorArray))
      via.padDiameter.setProp (int (fromDict: viaDict, key: "PAD-DIAMETER", &errorArray))
      boardModel.vias.add (via)
    }
  //--- Packages
    let packages = dictArray (fromDict: boardArchiveDict, key: "PACKAGES", &errorArray)
    for packageDict in packages {
      let package = BoardModelPackageEntity (managedObjectContext:self.managedObjectContext())
      package.name.setProp (string (fromDict: packageDict, key: "NAME", &errorArray))
      package.padRotation.setProp (int (fromDict: packageDict, key: "PAD-ROTATION", &errorArray))
    //--- Package side
      let componentSideString = string (fromDict: packageDict, key: "SIDE", &errorArray)
      if componentSideString == "TOP" {
        package.side.setProp (.front)
      }else if componentSideString == "BACK" {
        package.side.setProp (.back)
      }else{
        errorArray.append ("Invalid pad side \"\(componentSideString)\".")
      }
    //--- Component name segments
      var segmentArray = stringArray (fromDict: packageDict, key: "COMPONENT-NAME-SEGMENTS", &errorArray)
      for str in segmentArray {
        let ints = intArray (fromString: str, &errorArray)
        let segment = BoardModelComponentNameSegmentEntity (managedObjectContext:self.managedObjectContext())
        segment.x1.setProp (ints [0])
        segment.y1.setProp (ints [1])
        segment.x2.setProp (ints [2])
        segment.y2.setProp (ints [3])
        segment.width.setProp (ints [4])
        package.componentNameSegments.add (segment)
      }
    //--- Component value segments
      segmentArray = stringArray (fromDict: packageDict, key: "COMPONENT-VALUE-SEGMENTS", &errorArray)
      for str in segmentArray {
        let segment = BoardModelValueNameSegmentEntity (managedObjectContext:self.managedObjectContext())
        let ints = intArray (fromString: str, &errorArray)
        segment.x1.setProp (ints [0])
        segment.y1.setProp (ints [1])
        segment.x2.setProp (ints [2])
        segment.y2.setProp (ints [3])
        package.componentValueSegments.add (segment)
      }
    //--- Pads
      let padDictArray = dictArray (fromDict: packageDict, key: "PADS", &errorArray)
      for padDict in padDictArray {
        let pad = BoardModelPadEntity (managedObjectContext:self.managedObjectContext())
        pad.name.setProp (string (fromDict: padDict, key: "QUALIFIED-NAME", &errorArray))
        pad.x.setProp (int (fromDict: padDict, key: "X", &errorArray))
        pad.y.setProp (int (fromDict: padDict, key: "Y", &errorArray))
        pad.width.setProp (int (fromDict: padDict, key: "WIDTH", &errorArray))
        pad.height.setProp (int (fromDict: padDict, key: "HEIGHT", &errorArray))
        pad.holeDiameter.setProp (int (fromDict: padDict, key: "HOLE-DIAMETER", &errorArray))
        let shapeString = string (fromDict: padDict, key: "SHAPE", &errorArray)
        if shapeString == "RECT" {
          pad.shape.setProp (.rectangular)
        }else if shapeString == "ROUND" {
          pad.shape.setProp (.round)
        }else{
          errorArray.append ("Invalid pad shape \"\(shapeString)\".")
        }
        let sideString = string (fromDict: padDict, key: "SIDE", &errorArray)
        if sideString == "TRAVERSING" {
          pad.side.setProp (.traversing)
        }else if sideString == "SURFACE" {
          pad.side.setProp (.surface)
        }else{
          errorArray.append ("Invalid pad side \"\(sideString)\".")
        }
        let kindString = string (fromDict: padDict, key: "KIND", &errorArray)
        if kindString == "MASTER" {
          pad.kind.setProp (.master)
        }else if kindString == "SLAVE" {
          pad.kind.setProp (.slave)
        }else{
          errorArray.append ("Invalid pad kind \"\(kindString)\".")
        }
        package.pads.add (pad)
      }
    //---
      boardModel.packages.add (package)
    }
  //--- Dictionary import ok ?
    if errorArray.count == 0 { // Ok
      self.rootObject.boardModels.add (boardModel)
      self.mBoardModelController.select (object:boardModel)
    }else{ // Error
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
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
