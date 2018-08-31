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

fileprivate let DEBUG = false

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

protocol KicadItem : class {

  func display (_ inIndentationString : String, _ ioString : inout String)

  func getFloat (_ inPath : [String], _ inIndex : Int, _ ioErrorArray : inout [String]) -> Double?

  func collectTracks (_ ioFrontTrackEntities : inout [CanariSegment],
                      _ ioBackTrackEntities : inout [CanariSegment],
                      _ inModelLeftMM  : Double,
                      _ inModelBottomMM : Double,
                      _ ioErrorArray : inout [String],
                      _ inMOC : EBManagedObjectContext)

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class KicadItemString : KicadItem {
  let string : String

  //····················································································································

  init (_ inString : String) { string = inString }

  //····················································································································

  func display (_ inIndentationString : String, _ ioString : inout String) {
    ioString += inIndentationString + "String '\(self.string)'\n"
  }

  //····················································································································

  func getFloat (_ inPath : [String], _ inIndex : Int, _ ioErrorArray : inout [String]) -> Double? {
    ioErrorArray.append ("String instead of float")
    return nil
  }

  //····················································································································

  func collectTracks (_ ioFrontTrackEntities : inout [CanariSegment],
                      _ ioBackTrackEntities : inout [CanariSegment],
                      _ inModelLeftMM  : Double,
                      _ inModelBottomMM : Double,
                      _ ioErrorArray : inout [String],
                      _ inMOC : EBManagedObjectContext) {
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class KicadItemInt : KicadItem {
  let value : Int

  //····················································································································

  init (_ inValue : Int) { value = inValue }

  //····················································································································

  func display (_ inIndentationString : String, _ ioString : inout String) {
    ioString += inIndentationString + "Int '\(self.value)'\n"
  }

  //····················································································································

  func getFloat (_ inPath : [String], _ inIndex : Int, _ ioErrorArray : inout [String]) -> Double? {
    ioErrorArray.append ("Int instead of float")
    return nil
  }

  //····················································································································

  func collectTracks (_ ioFrontTrackEntities : inout [CanariSegment],
                      _ ioBackTrackEntities : inout [CanariSegment],
                      _ inModelLeftMM  : Double,
                      _ inModelBottomMM : Double,
                      _ ioErrorArray : inout [String],
                      _ inMOC : EBManagedObjectContext) {
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class KicadItemFloat : KicadItem {
  let value : Double

  //····················································································································

  init (_ inValue : Double) { value = inValue }

  //····················································································································

  func display (_ inIndentationString : String, _ ioString : inout String) {
    ioString += inIndentationString + "Double '\(self.value)'\n"
  }

  //····················································································································

  func getFloat (_ inPath : [String], _ inIndex : Int, _ ioErrorArray : inout [String]) -> Double? {
    return self.value
  }

  //····················································································································

  func collectTracks (_ ioFrontTrackEntities : inout [CanariSegment],
                      _ ioBackTrackEntities : inout [CanariSegment],
                      _ inModelLeftMM  : Double,
                      _ inModelBottomMM : Double,
                      _ ioErrorArray : inout [String],
                      _ inMOC : EBManagedObjectContext) {
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class KicadItemArray : KicadItem {
  let key : String
  let items : [KicadItem]

  //····················································································································

  init (_ inKey : String, _ inValue : [KicadItem]) { key = inKey ; items = inValue }

  //····················································································································

  func display (_ inIndentationString : String, _ ioString : inout String) {
    ioString += inIndentationString + "('\(self.key)'\n"
    for item in self.items {
      item.display (inIndentationString + " ", &ioString)
    }
    ioString += inIndentationString + ")\n"
  }

  //····················································································································

  func getFloat (_ inPath : [String], _ inIndex : Int, _ ioErrorArray : inout [String]) -> Double? {
    var result : Double? = nil
    if inPath [0] == self.key {
      if inPath.count == 1 {
        result = self.items [inIndex].getFloat ([], 0, &ioErrorArray)
      }else{
        var search = true
        var idx = 0
        while search {
          if let item = self.items [idx] as? KicadItemArray, item.key == inPath [1] {
            result = item.getFloat ([String] (inPath.dropFirst ()), inIndex, &ioErrorArray)
            search = false
          }else{
            idx += 1
            search = idx < self.items.count
          }
        }
        if idx == self.items.count {
          ioErrorArray.append ("Key \(inPath [0]) not found")
        }
      }
    }else{
      ioErrorArray.append ("Invalid key \(self.key) instead of \(inPath [0])")
    }
    return result
  }

  //····················································································································

  func collectTracks (_ ioFrontTrackEntities : inout [CanariSegment],
                      _ ioBackTrackEntities : inout [CanariSegment],
                      _ inModelLeftMM  : Double,
                      _ inModelBottomMM : Double,
                      _ ioErrorArray : inout [String],
                      _ inMOC : EBManagedObjectContext) {
    if self.key == "segment" {
      if let startX = self.getFloat (["segment", "start"], 0, &ioErrorArray),
         let startY = self.getFloat (["segment", "start"], 1, &ioErrorArray),
         let endX = self.getFloat (["segment", "end"], 0, &ioErrorArray),
         let endY = self.getFloat (["segment", "end"], 1, &ioErrorArray),
         let width = self.getFloat (["segment", "width"], 0, &ioErrorArray) {
        let segment = CanariSegment (managedObjectContext: inMOC)
        segment.x1 = millimeterToCanariUnit (startX - inModelLeftMM)
        segment.y1 = millimeterToCanariUnit (startY - inModelBottomMM)
        segment.x2 = millimeterToCanariUnit (endX - inModelLeftMM)
        segment.y2 = millimeterToCanariUnit (endY - inModelBottomMM)
        segment.width = millimeterToCanariUnit (width)
        ioFrontTrackEntities.append (segment)
      }
    }else{
      for item in self.items {
        item.collectTracks (&ioFrontTrackEntities, &ioBackTrackEntities, inModelLeftMM, inModelBottomMM, &ioErrorArray, inMOC)
      }
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension MergerDocument {

  //····················································································································

  func loadBoardModel_kicad (filePath inFilePath : String, windowForSheet inWindow : NSWindow) {
  //--- Load file, as plist
    let optionalFileData : Data? = FileManager ().contents (atPath: inFilePath)
    if let fileData = optionalFileData, let contentString = String (data: fileData, encoding: .utf8) {
      let s = inFilePath.lastPathComponent.deletingPathExtension
      let possibleBoardModel = self.parseBoardModel_kicad (fromString: contentString, named : s)
      if let boardModel = possibleBoardModel {
        self.rootObject.boardModels_property.add (boardModel)
        self.mBoardModelController.select (object:boardModel)
      }
    }else{ // Cannot read file
      let alert = NSAlert ()
      alert.messageText = "Cannot read file"
      alert.addButton (withTitle: "Ok")
      alert.informativeText = "The file \(inFilePath) cannot be read."
      alert.beginSheetModal (for: inWindow, completionHandler: {(NSModalResponse) in})
    }
  }

  //····················································································································

  func parseBoardModel_kicad (fromString inContentString : String, named inName : String) -> BoardModel? {
  //--- Transform string into an array of unicode scalars
    var array = [UnicodeScalar] ()
    for scalar in inContentString.unicodeScalars {
      array.append (scalar)
    }
    var index = 0
  //--- Parse
    let contents = parse (array, &index)
  //--- Analyze
//    var str = ""
//    contents?.display ("", &str)
//    Swift.print (str)
  //--- Extraction board rect
    var errorArray = [String] ()
    let possibleLeft = contents?.getFloat (["kicad_pcb", "general", "area"], 0, &errorArray)
    let possibleBottom = contents?.getFloat (["kicad_pcb", "general", "area"], 1, &errorArray)
    let possibleRight = contents?.getFloat (["kicad_pcb", "general", "area"], 2, &errorArray)
    let possibleTop = contents?.getFloat (["kicad_pcb", "general", "area"], 3, &errorArray)
    var leftMM = 0.0
    if let v = possibleLeft {
      leftMM = v
    }else{
      errorArray.append ("left is nil")
    }
    var rightMM = 0.0
    if let v = possibleRight {
      rightMM = v
    }else{
      errorArray.append ("right is nil")
    }
    var bottomMM = 0.0
    if let v = possibleBottom {
      bottomMM = v
    }else{
      errorArray.append ("bottom is nil")
    }
    var topMM = 0.0
    if let v = possibleTop {
      topMM = v
    }else{
      errorArray.append ("top is nil")
    }
    let modelWidthMM = rightMM - leftMM
    let modelHeightMM = topMM - bottomMM
    // Swift.print ("Board size \(modelWidth) mm • \(modelHeight) mm")
  //--- Parse track
    var frontTrackEntities = [CanariSegment] ()
    var backTrackEntities = [CanariSegment] ()
    contents?.collectTracks (&frontTrackEntities, &backTrackEntities, leftMM, bottomMM, &errorArray, self.managedObjectContext ())





  //  NSLog ("\(boardArchiveDict)")
//    let boardModel = BoardModel (managedObjectContext:self.managedObjectContext())
  //--- Populate board model from dictionary (accumulate error messages in errorArray variable)
//    var errorArray = [String] ()
//    boardModel.name = inName
//    boardModel.artworkName = string (fromDict: boardArchiveDict, key: "ARTWORK", &errorArray)
//    boardModel.modelWidth = int (fromDict: boardArchiveDict, key: "BOARD-WIDTH", &errorArray)
//    boardModel.modelWidthUnit = int (fromDict: boardArchiveDict, key: "BOARD-WIDTH-UNIT", &errorArray)
//    boardModel.modelHeight = int (fromDict: boardArchiveDict, key: "BOARD-HEIGHT", &errorArray)
//    boardModel.modelHeightUnit = int (fromDict: boardArchiveDict, key: "BOARD-HEIGHT-UNIT", &errorArray)
//    boardModel.modelLimitWidth = int (fromDict: boardArchiveDict, key: "BOARD-LINE-WIDTH", &errorArray)
//    boardModel.modelLimitWidthUnit = int (fromDict: boardArchiveDict, key: "BOARD-LINE-WIDTH-UNIT", &errorArray)
//  //--- Internal boards limits
//    var internalBoardsLimitsEntities = [CanariSegment] ()
//    let internalBoardsLimits = optionalStringArray (fromDict: boardArchiveDict, key: "INTERNAL-BOARDS-LIMITS", &errorArray)
//    for str in internalBoardsLimits {
//      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
//      let ints = array5int (fromString: str, &errorArray)
//      segment.x1 = ints [0]
//      segment.y1 = ints [1]
//      segment.x2 = ints [2]
//      segment.y2 = ints [3]
//      segment.width = ints [4]
//      internalBoardsLimitsEntities.append (segment)
//    }
//    boardModel.internalBoardsLimits_property.setProp (internalBoardsLimitsEntities)
//  //--- Front tracks
//    var frontTrackEntities = [CanariSegment] ()
//    let frontTracks = stringArray (fromDict: boardArchiveDict, key: "TRACKS-FRONT", &errorArray)
//    for str in frontTracks {
//      let track = CanariSegment (managedObjectContext:self.managedObjectContext())
//      let ints = array5int (fromString: str, &errorArray)
//      track.x1 = ints [0]
//      track.y1 = ints [1]
//      track.x2 = ints [2]
//      track.y2 = ints [3]
//      track.width = ints [4]
//      frontTrackEntities.append (track)
//    }
//    boardModel.frontTracks_property.setProp (frontTrackEntities)
//  //--- Vias
//    var viaEntities = [BoardModelVia] ()
//    let vias = stringArray (fromDict: boardArchiveDict, key: "VIAS", &errorArray)
//    for str in vias {
//      let via = BoardModelVia (managedObjectContext:self.managedObjectContext())
//      let ints = array4int (fromString: str, &errorArray)
//      via.x = ints [0]
//      via.y = ints [1]
//      via.padDiameter = ints [2]
//      via.holeDiameter = ints [3]
//      viaEntities.append (via)
//    }
//    boardModel.vias_property.setProp (viaEntities)
//  //--- Back Legend texts
//    var backLegendLinesEntities = [CanariSegment] ()
//    let backLegendLines = stringArray (fromDict: boardArchiveDict, key: "LINES-BACK", &errorArray)
//    for str in backLegendLines {
//      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
//      let ints = array5int (fromString: str, &errorArray)
//      segment.x1 = ints [0]
//      segment.y1 = ints [1]
//      segment.x2 = ints [2]
//      segment.y2 = ints [3]
//      segment.width = ints [4]
//      backLegendLinesEntities.append (segment)
//    }
//    boardModel.backLegendLines_property.setProp (backLegendLinesEntities)
//  //--- Front Legend texts
//    var frontLegendLinesEntities = [CanariSegment] ()
//    let frontLegendLines = stringArray (fromDict: boardArchiveDict, key: "LINES-FRONT", &errorArray)
//    for str in frontLegendLines {
//      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
//      let ints = array5int (fromString: str, &errorArray)
//      segment.x1 = ints [0]
//      segment.y1 = ints [1]
//      segment.x2 = ints [2]
//      segment.y2 = ints [3]
//      segment.width = ints [4]
//      frontLegendLinesEntities.append (segment)
//    }
//    boardModel.frontLegendLines_property.setProp (frontLegendLinesEntities)
//  //--- Front Layout texts
//    var frontLayoutTextEntities = [CanariSegment] ()
//    let frontLayoutTexts = stringArray (fromDict: boardArchiveDict, key: "TEXTS-LAYOUT-FRONT", &errorArray)
//    for str in frontLayoutTexts {
//      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
//      let ints = array5int (fromString: str, &errorArray)
//      segment.x1 = ints [0]
//      segment.y1 = ints [1]
//      segment.x2 = ints [2]
//      segment.y2 = ints [3]
//      segment.width = ints [4]
//      frontLayoutTextEntities.append (segment)
//    }
//    boardModel.frontLayoutTexts_property.setProp (frontLayoutTextEntities)
//  //--- Back Layout texts
//    var backLayoutTextEntities = [CanariSegment] ()
//    let backLayoutTexts = stringArray (fromDict: boardArchiveDict, key: "TEXTS-LAYOUT-BACK", &errorArray)
//    for str in backLayoutTexts {
//      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
//      let ints = array5int (fromString: str, &errorArray)
//      segment.x1 = ints [0]
//      segment.y1 = ints [1]
//      segment.x2 = ints [2]
//      segment.y2 = ints [3]
//      segment.width = ints [4]
//      backLayoutTextEntities.append (segment)
//    }
//    boardModel.backLayoutTexts_property.setProp (backLayoutTextEntities)
//  //--- Back Legend texts
//    var backLegendTextEntities = [CanariSegment] ()
//    let backLegendTexts = stringArray (fromDict: boardArchiveDict, key: "TEXTS-LEGEND-BACK", &errorArray)
//    for str in backLegendTexts {
//      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
//      let ints = array5int (fromString: str, &errorArray)
//      segment.x1 = ints [0]
//      segment.y1 = ints [1]
//      segment.x2 = ints [2]
//      segment.y2 = ints [3]
//      segment.width = ints [4]
//      backLegendTextEntities.append (segment)
//    }
//    boardModel.backLegendTexts_property.setProp (backLegendTextEntities)
//  //--- Front Legend texts
//    var frontLegendTextEntities = [CanariSegment] ()
//    let frontTexts = stringArray (fromDict: boardArchiveDict, key: "TEXTS-LEGEND-FRONT", &errorArray)
//    for str in frontTexts {
//      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
//      let ints = array5int (fromString: str, &errorArray)
//      segment.x1 = ints [0]
//      segment.y1 = ints [1]
//      segment.x2 = ints [2]
//      segment.y2 = ints [3]
//      segment.width = ints [4]
//      frontLegendTextEntities.append (segment)
//    }
//    boardModel.frontLegendTexts_property.setProp (frontLegendTextEntities)
//  //--- Back packages
//    var backPackagesEntities = [CanariSegment] ()
//    let backPackages = stringArray (fromDict: boardArchiveDict, key: "PACKAGES-BACK", &errorArray)
//    for str in backPackages {
//      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
//      let ints = array5int (fromString: str, &errorArray)
//      segment.x1 = ints [0]
//      segment.y1 = ints [1]
//      segment.x2 = ints [2]
//      segment.y2 = ints [3]
//      segment.width = ints [4]
//      backPackagesEntities.append (segment)
//    }
//    boardModel.backPackages_property.setProp (backPackagesEntities)
//  //--- Front packages
//    var frontPackagesEntities = [CanariSegment] ()
//    let frontPackages = stringArray (fromDict: boardArchiveDict, key: "PACKAGES-FRONT", &errorArray)
//    for str in frontPackages {
//      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
//      let ints = array5int (fromString: str, &errorArray)
//      segment.x1 = ints [0]
//      segment.y1 = ints [1]
//      segment.x2 = ints [2]
//      segment.y2 = ints [3]
//      segment.width = ints [4]
//      frontPackagesEntities.append (segment)
//    }
//    boardModel.frontPackages_property.setProp (frontPackagesEntities)
//  //--- Back component names
//    var backComponentNamesEntities = [CanariSegment] ()
//    let backComponentNames = stringArray (fromDict: boardArchiveDict, key: "COMPONENT-NAMES-BACK", &errorArray)
//    for str in backComponentNames {
//      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
//      let ints = array5int (fromString: str, &errorArray)
//      segment.x1 = ints [0]
//      segment.y1 = ints [1]
//      segment.x2 = ints [2]
//      segment.y2 = ints [3]
//      segment.width = ints [4]
//      backComponentNamesEntities.append (segment)
//    }
//    boardModel.backComponentNames_property.setProp (backComponentNamesEntities)
//  //--- Front component names
//    var frontComponentNamesEntities = [CanariSegment] ()
//    let frontComponentNames = stringArray (fromDict: boardArchiveDict, key: "COMPONENT-NAMES-FRONT", &errorArray)
//    for str in frontComponentNames {
//      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
//      let ints = array5int (fromString: str, &errorArray)
//      segment.x1 = ints [0]
//      segment.y1 = ints [1]
//      segment.x2 = ints [2]
//      segment.y2 = ints [3]
//      segment.width = ints [4]
//      frontComponentNamesEntities.append (segment)
//    }
//    boardModel.frontComponentNames_property.setProp (frontComponentNamesEntities)
//  //--- Front component values
//    var frontComponentValuesEntities = [CanariSegment] ()
//    let frontComponentValues = stringArray (fromDict: boardArchiveDict, key: "COMPONENT-VALUES-FRONT", &errorArray)
//    for str in frontComponentValues {
//      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
//      let ints = array5int (fromString: str, &errorArray)
//      segment.x1 = ints [0]
//      segment.y1 = ints [1]
//      segment.x2 = ints [2]
//      segment.y2 = ints [3]
//      segment.width = ints [4]
//      frontComponentValuesEntities.append (segment)
//    }
//    boardModel.frontComponentValues_property.setProp (frontComponentValuesEntities)
//  //--- Back component values
//    var backComponentValuesEntities = [CanariSegment] ()
//    let backComponentValues = stringArray (fromDict: boardArchiveDict, key: "COMPONENT-VALUES-BACK", &errorArray)
//    for str in backComponentValues {
//      let segment = CanariSegment (managedObjectContext:self.managedObjectContext())
//      let ints = array5int (fromString: str, &errorArray)
//      segment.x1 = ints [0]
//      segment.y1 = ints [1]
//      segment.x2 = ints [2]
//      segment.y2 = ints [3]
//      segment.width = ints [4]
//      backComponentValuesEntities.append (segment)
//    }
//    boardModel.backComponentValues_property.setProp (backComponentValuesEntities)
//  //--- Pads
//    var padEntities = [BoardModelPad] ()
//    let padDictArray = dictArray (fromDict: boardArchiveDict, key: "PADS", &errorArray)
//    for padDict in padDictArray {
//      let pad = BoardModelPad (managedObjectContext:self.managedObjectContext())
//      pad.qualifiedName = string (fromDict: padDict, key: "QUALIFIED-NAME", &errorArray)
//      pad.x = int (fromDict: padDict, key: "X", &errorArray)
//      pad.y = int (fromDict: padDict, key: "Y", &errorArray)
//      pad.width = int (fromDict: padDict, key: "WIDTH", &errorArray)
//      pad.height = int (fromDict: padDict, key: "HEIGHT", &errorArray)
//      pad.holeDiameter = intOrZero (fromDict: padDict, key: "HOLE-DIAMETER", &errorArray)
//      pad.rotation = int (fromDict: padDict, key: "ROTATION", &errorArray)
//      let shapeString = string (fromDict: padDict, key: "SHAPE", &errorArray)
//      if shapeString == "RECT" {
//        pad.shape = .rectangular
//      }else if shapeString == "ROUND" {
//        pad.shape = .round
//      }else{
//        errorArray.append ("Invalid pad shape \"\(shapeString)\".")
//      }
//      let sideString = string (fromDict: padDict, key: "SIDE", &errorArray)
//      if sideString == "TRAVERSING" {
//        pad.side = .traversing
//      }else if sideString == "FRONT" {
//        pad.side = .front
//      }else if sideString == "BACK" {
//        pad.side = .back
//      }else{
//        errorArray.append ("Invalid pad side \"\(sideString)\".")
//      }
//      padEntities.append (pad)
//    }
//    boardModel.pads_property.setProp (padEntities)
  //--- Dictionary import ok ?
    var boardModel : BoardModel? = nil
    if errorArray.count == 0 {
      boardModel = BoardModel (managedObjectContext: self.managedObjectContext ())
      boardModel?.name = inName
      boardModel?.modelWidth  = millimeterToCanariUnit (modelWidthMM)
      boardModel?.modelWidthUnit = ONE_MILLIMETER_IN_CANARI_UNIT
      boardModel?.modelHeight = millimeterToCanariUnit (modelHeightMM)
      boardModel?.modelHeightUnit = ONE_MILLIMETER_IN_CANARI_UNIT
      boardModel?.modelLimitWidth = ONE_MILLIMETER_IN_CANARI_UNIT
      boardModel?.modelLimitWidthUnit = ONE_MILLIMETER_IN_CANARI_UNIT
      boardModel?.backTracks_property.setProp (backTrackEntities)
      boardModel?.frontTracks_property.setProp (frontTrackEntities)
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
  //--- Return
    return boardModel
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func parse (_ inContentString : [UnicodeScalar], _ ioIndex : inout Int) -> KicadItem? {
  passSeparators (inContentString, &ioIndex)
  var result : KicadItem? = nil
  if !atEnd (inContentString, ioIndex) {
    if inContentString [ioIndex] == "(" {
      if DEBUG { print ("FIND (") }
      ioIndex += 1
    //--- Parse key
      passSeparators (inContentString, &ioIndex)
      var key = ""
      var c = inContentString [ioIndex]
      while (c > " ") && (c != ")") && (c != "(") {
        key += String (c)
        ioIndex += 1
        c = inContentString [ioIndex]
      }
      if DEBUG { print ("KEY '\(key)'") }
      var items = [KicadItem] ()
      var parseItems = true
      while parseItems {
        passSeparators (inContentString, &ioIndex)
        if atEnd (inContentString, ioIndex) {
          parseItems = false
        }else if inContentString [ioIndex] == ")" {
          if DEBUG { print ("FIND )") }
          parseItems = false
          ioIndex += 1
        }else if let item = parse (inContentString, &ioIndex) {
          items.append (item)
        }else{
          Swift.print ("Error at index \(ioIndex)")
          parseItems = false
        }
      }
      result = KicadItemArray (key, items)
    }else if inContentString [ioIndex] == "\"" { // String
      ioIndex += 1
      var str = ""
      var c = inContentString [ioIndex]
      ioIndex += 1
      while c != "\"" {
        str += String (c)
        c = inContentString [ioIndex]
        ioIndex += 1
      }
      if DEBUG { print ("STRING '\(str)'") }
      result = KicadItemString (str)
    }else if (inContentString [ioIndex] > " ") && (inContentString [ioIndex] != ")") && (inContentString [ioIndex] != "(") {
      var str = String (inContentString [ioIndex])
      ioIndex += 1
      var c = inContentString [ioIndex]
      while (c > " ") && (c < "~") && (c != ")") && (c != "(") {
        str += String (c)
        ioIndex += 1
        c = inContentString [ioIndex]
      }
      if let integer = Int (str) {
        result = KicadItemInt (integer)
      }else if let v = Double (str) {
        result = KicadItemFloat (v)
      }else{
        result = KicadItemString (str)
      }
    }
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func passSeparators (_ inContentString : [UnicodeScalar], _ ioIndex : inout Int) {
  var loop = true
  while loop && !atEnd (inContentString, ioIndex) {
    let c = inContentString [ioIndex]
    if (c == " ") || (c == "\n") || (c == "\r") {
      ioIndex += 1
    }else{
      loop = false
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func atEnd (_ inContentString : [UnicodeScalar], _ inIndex : Int) -> Bool {
  return inIndex == inContentString.count
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//fileprivate func getItems (_ kicadItem : KicadItem, _ inKey : String, _ ioErrorArray : inout [String]) -> [KicadItem] {
//  var result = [KicadItem] ()
//  switch kicadItem {
//  case .string (let s) :
//    ioErrorArray.append ("String '\(s)' reached")
//  case .integer (let v) :
//    ioErrorArray.append ("Integer '\(v)' reached")
//  case .float (let v) :
//    ioErrorArray.append ("Float '\(v)' reached")
//  case .items (let key, let items) :
//    if key == inKey {
//      result = items
//    }else{
//      ioErrorArray.append ("Invalid '\(key)' key")
//    }
//  case .end :
//    ioErrorArray.append ("End' reached")
//  }
//  return result
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//fileprivate func getItemsFromArray (_ kicadItems : [KicadItem], _ inKey : String, _ ioErrorArray : inout [String]) -> [KicadItem] {
//  for item in kicadItems {
//    switch item {
//    case .string :
//      ()
//    case .integer :
//      ()
//    case .float :
//      ()
//    case .items (let key, let items) :
//      if key == inKey {
//        return items
//      }
//    case .end :
//      ()
//    }
//  }
//  ioErrorArray.append ("Unknown '\(inKey)' key")
//  return [KicadItem] ()
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
