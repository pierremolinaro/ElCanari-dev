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

fileprivate class KicadItem {
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

  func getFloat (_ inPath : [String], _ inIndex : Int, _ ioErrorArray : inout [(String, Int)]) -> Double? {
    var result : Double? = nil
    if inPath [0] == self.key {
      if inPath.count == 1 {
        if let r = Double (self.items [inIndex].key) {
          result = r
        }else{
          ioErrorArray.append (("Key \(self.items [inIndex].key) is not a float", #line))
        }
      }else{
        var search = true
        var idx = 0
        while search {
          let item = self.items [idx]
          if item.key == inPath [1] {
            result = item.getFloat ([String] (inPath.dropFirst ()), inIndex, &ioErrorArray)
            search = false
          }else{
            idx += 1
            search = idx < self.items.count
          }
        }
        if idx == self.items.count {
          ioErrorArray.append (("Key \(inPath [0]) not found", #line))
        }
      }
    }else{
      ioErrorArray.append (("Invalid key \(self.key) instead of \(inPath [0])", #line))
    }
    return result
  }

  //····················································································································

  func getString (_ inPath : [String], _ inIndex : Int, _ ioErrorArray : inout [(String, Int)]) -> String? {
    var result : String? = nil
    if inPath [0] == self.key {
      if inPath.count == 1 {
        result = self.items [inIndex].key
      }else{
        var search = true
        var idx = 0
        while search {
          let item = self.items [idx]
          if item.key == inPath [1] {
            result = item.getString ([String] (inPath.dropFirst ()), inIndex, &ioErrorArray)
            search = false
          }else{
            idx += 1
            search = idx < self.items.count
          }
        }
        if idx == self.items.count {
          ioErrorArray.append (("Key \(inPath [0]) not found", #line))
        }
      }
    }else{
      ioErrorArray.append (("Invalid key \(self.key) instead of \(inPath [0])", #line))
    }
    return result
  }

  //····················································································································

  func getInt (_ inPath : [String], _ inIndex : Int, _ ioErrorArray : inout [(String, Int)]) -> Int? {
    var result : Int? = nil
    if inPath [0] == self.key {
      if inPath.count == 1 {
        if let r = Int (self.items [inIndex].key) {
          result = r
        }else{
          ioErrorArray.append (("Key \(self.items [inIndex].key) is not an int", #line))
        }
      }else{
        var search = true
        var idx = 0
        while search {
          let item = self.items [idx]
          if item.key == inPath [1] {
            result = item.getInt ([String] (inPath.dropFirst ()), inIndex, &ioErrorArray)
            search = false
          }else{
            idx += 1
            search = idx < self.items.count
          }
        }
        if idx == self.items.count {
          ioErrorArray.append (("Key \(inPath [0]) not found", #line))
        }
      }
    }else{
      ioErrorArray.append (("Invalid key \(self.key) instead of \(inPath [0])", #line))
    }
    return result
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension KicadItem {

  //····················································································································

  func collectTracks (_ ioFrontTrackEntities : inout [CanariSegment],
                      _ ioBackTrackEntities : inout [CanariSegment],
                      _ inModelLeftMM  : Double,
                      _ inModelBottomMM : Double,
                      _ ioErrorArray : inout [(String, Int)],
                      _ inMOC : EBManagedObjectContext) {
    if self.key == "segment" {
      if let startX = self.getFloat (["segment", "start"], 0, &ioErrorArray),
         let startY = self.getFloat (["segment", "start"], 1, &ioErrorArray),
         let endX = self.getFloat (["segment", "end"], 0, &ioErrorArray),
         let endY = self.getFloat (["segment", "end"], 1, &ioErrorArray),
         let width = self.getFloat (["segment", "width"], 0, &ioErrorArray),
         let layer = self.getString (["segment", "layer"], 0, &ioErrorArray) {
        let segment = CanariSegment (managedObjectContext: inMOC)
        segment.x1 = millimeterToCanariUnit (startX - inModelLeftMM)
        segment.y1 = millimeterToCanariUnit (startY - inModelBottomMM)
        segment.x2 = millimeterToCanariUnit (endX - inModelLeftMM)
        segment.y2 = millimeterToCanariUnit (endY - inModelBottomMM)
        segment.width = millimeterToCanariUnit (width)
        if layer == "F.Cu" {
          ioFrontTrackEntities.append (segment)
        }else if layer == "B.Cu" {
          ioBackTrackEntities.append (segment)
        }else{
          ioErrorArray.append (("Invalid segment layer \(layer)", #line))
        }
      }
    }else{
      for item in self.items {
        item.collectTracks (&ioFrontTrackEntities, &ioBackTrackEntities, inModelLeftMM, inModelBottomMM, &ioErrorArray, inMOC)
      }
    }
  }

  //····················································································································

  func collectVias (_ ioViaEntities : inout [BoardModelVia],
                    _ inModelLeftMM  : Double,
                    _ inModelBottomMM : Double,
                    _ inNetArray : [KicadNetClass],
                    _ ioErrorArray : inout [(String, Int)],
                    _ inMOC : EBManagedObjectContext) {
    if self.key == "via" {
      if let x = self.getFloat (["via", "at"], 0, &ioErrorArray),
         let y = self.getFloat (["via", "at"], 1, &ioErrorArray),
         let diameter = self.getFloat (["via", "size"], 0, &ioErrorArray),
         let netIndex = self.getInt (["via", "net"], 0, &ioErrorArray) {
        let via = BoardModelVia (managedObjectContext: inMOC)
        via.x = millimeterToCanariUnit (x - inModelLeftMM)
        via.y = millimeterToCanariUnit (y - inModelBottomMM)
        via.padDiameter = millimeterToCanariUnit (diameter)
        let netClass = inNetArray [netIndex]
        via.holeDiameter = netClass.drillDiameter
        ioViaEntities.append (via)
      }
    }else{
      for item in self.items {
        item.collectVias (&ioViaEntities, inModelLeftMM, inModelBottomMM, inNetArray, &ioErrorArray, inMOC)
      }
    }
  }

  //····················································································································

  func collectNetNameArray (_ ioNetNameArray : inout [String],
                            _ ioNetClassArray : inout [KicadNetClass],
                            _ ioErrorArray : inout [(String, Int)]) {
    var idx = 0
    for item in self.items {
      if item.key == "net" {
        if let index = item.getInt (["net"], 0, &ioErrorArray), let name = item.getString (["net"], 1, &ioErrorArray) {
          if index != idx {
            ioErrorArray.append (("Invalid net index: \(index) instead of \(idx)", #line))
          }
          ioNetNameArray.append (name)
          idx += 1
        }
      }else if item.key == "net_class" {
        if let padDiameter = item.getFloat (["net_class", "via_dia"], 0, &ioErrorArray),
           let holeDiameter = item.getFloat (["net_class", "via_drill"], 0, &ioErrorArray),
           let name = item.getString (["net_class"], 0, &ioErrorArray) {
          var netNameArray = [String] ()
          for netClassItem in item.items {
            if netClassItem.key == "add_net", let netName = netClassItem.getString (["add_net"], 0, &ioErrorArray) {
              netNameArray.append (netName)
            }
          }
          let netClass = KicadNetClass (
            name: name,
            padDiameter: millimeterToCanariUnit (padDiameter),
            drillDiameter: millimeterToCanariUnit (holeDiameter),
            netNames: netNameArray
          )
          ioNetClassArray.append (netClass)
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate class KicadNetClass {
  let name : String
  let padDiameter : Int
  let drillDiameter : Int
  let netNames : [String]

  //····················································································································

  init (name inName : String, padDiameter inPadDiameter : Int, drillDiameter inDrillDiameter : Int, netNames inNetNames : [String]) {
    name = inName
    padDiameter = inPadDiameter
    drillDiameter = inDrillDiameter
    netNames = inNetNames
  }

  //····················································································································

  init () {
    name = "???"
    padDiameter = 0
    drillDiameter = 0
    netNames = []
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
    var errorArray = [(String, Int)] ()
    var leftMM = 0.0
    if let v = contents?.getFloat (["kicad_pcb", "general", "area"], 0, &errorArray) {
      leftMM = v
    }else{
      errorArray.append (("left is nil", #line))
    }
    var rightMM = 0.0
    if let v = contents?.getFloat (["kicad_pcb", "general", "area"], 2, &errorArray) {
      rightMM = v
    }else{
      errorArray.append (("right is nil", #line))
    }
    var bottomMM = 0.0
    if let v = contents?.getFloat (["kicad_pcb", "general", "area"], 1, &errorArray) {
      bottomMM = v
    }else{
      errorArray.append (("bottom is nil", #line))
    }
    var topMM = 0.0
    if let v = contents?.getFloat (["kicad_pcb", "general", "area"], 3, &errorArray) {
      topMM = v
    }else{
      errorArray.append (("top is nil", #line))
    }
    let modelWidthMM = rightMM - leftMM
    let modelHeightMM = topMM - bottomMM
    // Swift.print ("Board size \(modelWidth) mm • \(modelHeight) mm")
  //--- Collect tracks
    var frontTrackEntities = [CanariSegment] ()
    var backTrackEntities = [CanariSegment] ()
    contents?.collectTracks (&frontTrackEntities, &backTrackEntities, leftMM, bottomMM, &errorArray, self.managedObjectContext ())
  //--- Collect net name array, net class array
    var netNameArray = [String] ()
    var netClassArray = [KicadNetClass] ()
    contents?.collectNetNameArray (&netNameArray, &netClassArray, &errorArray)
  //--- Build dictionary of net class, key by net name
    var netDictionary = [String : KicadNetClass] ()
    for netClass in netClassArray {
      for netName in netClass.netNames {
        netDictionary [netName] = netClass
      }
    }
  //--- Build array of net class, index by net index
  //    Note that net #0 ihas an empty name an is never used
    var netArray = [KicadNetClass] ()
    netArray.append (KicadNetClass ()) // Pseudo net #0
    for netName in netNameArray.dropFirst () {
      if let netClass = netDictionary [netName] {
        netArray.append (netClass)
      }else{
        errorArray.append (("no net named \(netName)", #line))
      }
    }
  //--- Collect vias
    var viaEntities = [BoardModelVia] ()
    contents?.collectVias (&viaEntities, leftMM, bottomMM, netArray, &errorArray, self.managedObjectContext ())





  //  NSLog ("\(boardArchiveDict)")
//    let boardModel = BoardModel (managedObjectContext:self.managedObjectContext())
  //--- Populate board model from dictionary (accumulate error messages in errorArray variable)
//    var errorArray = [String] ()
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
      boardModel?.vias_property.setProp (viaEntities)
    }else{ // Error
      var s = ""
      for anError in errorArray {
        if s != "" {
          s += "\n"
        }
        s += anError.0 + " (line \(anError.1))"
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
      result = KicadItem (key, items)
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
      result = KicadItem (str, [])
    }else if (inContentString [ioIndex] > " ") && (inContentString [ioIndex] != ")") && (inContentString [ioIndex] != "(") {
      var str = String (inContentString [ioIndex])
      ioIndex += 1
      var c = inContentString [ioIndex]
      while (c > " ") && (c < "~") && (c != ")") && (c != "(") {
        str += String (c)
        ioIndex += 1
        c = inContentString [ioIndex]
      }
//      if let integer = Int (str) {
//        result = KicadItemInt (integer)
//      }else if let v = Double (str) {
//        result = KicadItemFloat (v)
//      }else{
        result = KicadItem (str, [])
//      }
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
