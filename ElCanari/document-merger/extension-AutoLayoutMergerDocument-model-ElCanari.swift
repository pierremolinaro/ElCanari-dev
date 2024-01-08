//
//  add-board-model.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutMergerDocument {

  //····················································································································

  private func registerBoardModelCallBack (_ inBoardModel : BoardModel) {
    self.rootObject.boardModels_property.add (inBoardModel)
    self.mBoardModelController.select (object: inBoardModel)
  }

  //····················································································································

  func loadBoardModel_ELCanariArchive (filePath inFilePath : String, windowForSheet inWindow : NSWindow) {
  //--- Load file, as plist
    let optionalFileData : Data? = FileManager ().contents (atPath: inFilePath)
    if let fileData = optionalFileData {
      let s = inFilePath.lastPathComponent.deletingPathExtension
      self.parseBoardModel_ELCanariArchive (fromData: fileData, named : s, callBack: { self.registerBoardModelCallBack ($0) } )
    }else{ // Cannot read file
      let alert = NSAlert ()
      alert.messageText = "Cannot read file"
      alert.informativeText = "The file \(inFilePath) cannot be read."
      alert.beginSheetModal (for: inWindow)
    }
  }

  //····················································································································

  func parseBoardModel_ELCanariArchive (fromData inData : Data,
                                        named inName : String,
                                        callBack inCallBack : @escaping (BoardModel) -> Void) {
    do{
      let optionalBoardArchiveDictionary = try PropertyListSerialization.propertyList (
        from: inData,
        options: [],
        format: nil
      )
      if let boardArchiveDict = optionalBoardArchiveDictionary as? [String : Any] {
        self.internal_check_ELCanariArchive_version (boardArchiveDict, named: inName, callBack: inCallBack)
      }
    }catch let error {
      let alert = NSAlert ()
      alert.messageText = "Cannot Analyse file contents"
      alert.informativeText = "\(error)"
      alert.beginSheetModal (for: self.windowForSheet!)
    }
  }

  //····················································································································

  fileprivate func internal_check_ELCanariArchive_version (_ inBoardArchiveDict : [String : Any],
                                                           named inName : String,
                                                           callBack inCallBack : @escaping (BoardModel) -> Void) {
    let version : Int = (inBoardArchiveDict [ARCHIVE_VERSION_KEY] as? Int) ?? 0
    if version != MERGER_ARCHIVE_VERSION {
      let alert = NSAlert ()
      _ = alert.addButton (withTitle: "Ignore Version Error and Continue")
      _ = alert.addButton (withTitle: "Cancel")
      alert.messageText = "Cannot Analyse file contents, archive version is #\(version)."
      alert.informativeText = "Merger requires archive version #\(MERGER_ARCHIVE_VERSION) ; update your archive by generating the production files again."
      alert.beginSheetModal (for: self.windowForSheet!) { (inResponse : NSApplication.ModalResponse) in
        if inResponse == .alertFirstButtonReturn {
          self.internal_parseBoardModel_ELCanariArchive (inBoardArchiveDict, version: version, ignoreVersionError: true, named: inName, callBack: inCallBack)
        }
      }
    }else{
      self.internal_parseBoardModel_ELCanariArchive (inBoardArchiveDict, version: version, ignoreVersionError: false, named: inName, callBack: inCallBack)
    }
  }

  //····················································································································

  fileprivate func internal_parseBoardModel_ELCanariArchive (_ inBoardArchiveDict : [String : Any],
                                                             version inVersion : Int,
                                                             ignoreVersionError inIgnoreVersionError : Bool,
                                                             named inName : String,
                                                             callBack inCallBack : @escaping (BoardModel) -> Void) {
    let boardModel = BoardModel (self.undoManager)
  //--- Populate board model from dictionary (accumulate error messages in errorArray variable)
    var errorArray = [String] ()
    boardModel.modelVersion = inVersion
    boardModel.ignoreModelVersionError = inIgnoreVersionError
    boardModel.name = inName
    boardModel.artworkName = string (fromDict: inBoardArchiveDict, key: ARCHIVE_ARTWORK_KEY, &errorArray)
    boardModel.modelWidth = int (fromDict: inBoardArchiveDict, key: ARCHIVE_BOARD_WIDTH_KEY, &errorArray)
    boardModel.modelWidthUnit = int (fromDict: inBoardArchiveDict, key: ARCHIVE_BOARD_WIDTH_UNIT_KEY, &errorArray)
    boardModel.modelHeight = int (fromDict: inBoardArchiveDict, key: ARCHIVE_BOARD_HEIGHT_KEY, &errorArray)
    boardModel.modelHeightUnit = int (fromDict: inBoardArchiveDict, key: ARCHIVE_BOARD_HEIGHT_UNIT_KEY, &errorArray)
    boardModel.modelLimitWidth = int (fromDict: inBoardArchiveDict, key: ARCHIVE_BOARD_LINE_WIDTH_KEY, &errorArray)
    boardModel.modelLimitWidthUnit = int (fromDict: inBoardArchiveDict, key: ARCHIVE_BOARD_LINE_WIDTH_UNIT_KEY, &errorArray)
    let boardRect_mm = NSRect (
      x: 0.0,
      y: 0.0,
      width: canariUnitToMillimeter (boardModel.modelWidth),
      height: canariUnitToMillimeter (boardModel.modelHeight)
    )
//    Swift.print ("\(canariUnitToMillimeter (boardModel.modelWidth)) \(canariUnitToMillimeter (boardModel.modelHeight))")
  //--- Internal boards limits
    do{
      var internalBoardsLimitsEntities = EBReferenceArray <SegmentEntity> ()
      let internalBoardsLimits = optionalStringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_INTERNAL_BOARDS_LIMITS_KEY, &errorArray)
      for str in internalBoardsLimits {
        let segment = SegmentEntity (self.undoManager)
        let ints = array5int (fromString: str, &errorArray)
        segment.x1 = ints [0]
        segment.y1 = ints [1]
        segment.x2 = ints [2]
        segment.y2 = ints [3]
        segment.width = ints [4]
        internalBoardsLimitsEntities.append (segment)
      }
      boardModel.internalBoardsLimits = internalBoardsLimitsEntities
    }
  //--- Front tracks, no silkscreen
    do{
      var frontTrackEntities = EBReferenceArray <SegmentEntity> ()
      let frontTracks = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_FRONT_TRACKS_WITH_NO_SILK_SCREEN_KEY, &errorArray)
      for str in frontTracks {
        let track = SegmentEntity (self.undoManager)
        let ints = array5int (fromString: str, &errorArray)
        track.x1 = ints [0]
        track.y1 = ints [1]
        track.x2 = ints [2]
        track.y2 = ints [3]
        track.width = ints [4]
        frontTrackEntities.append (track)
      }
      boardModel.frontTracksNoSilkScreen = frontTrackEntities
    }
  //--- Front tracks
    do{
      var frontTrackEntities = EBReferenceArray <SegmentEntity> ()
      let frontTracks = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_TRACKS_FRONT_KEY, &errorArray)
      for str in frontTracks {
        let track = SegmentEntity (self.undoManager)
        let ints = array5int (fromString: str, &errorArray)
        track.x1 = ints [0]
        track.y1 = ints [1]
        track.x2 = ints [2]
        track.y2 = ints [3]
        track.width = ints [4]
        frontTrackEntities.append (track)
      }
      boardModel.frontTracks = frontTrackEntities
    }
  //--- Back tracks
    do{
      var backTrackEntities = EBReferenceArray <SegmentEntity> ()
      let backTracks = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_TRACKS_BACK_KEY, &errorArray)
      for str in backTracks {
        let track = SegmentEntity (self.undoManager)
        let ints = array5int (fromString: str, &errorArray)
        track.x1 = ints [0]
        track.y1 = ints [1]
        track.x2 = ints [2]
        track.y2 = ints [3]
        track.width = ints [4]
        backTrackEntities.append (track)
      }
      boardModel.backTracks = backTrackEntities
    }
  //--- Back tracks, no silk screen
    do{
      var backTrackEntities = EBReferenceArray <SegmentEntity> ()
      let backTracks = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_BACK_TRACKS_WITH_NO_SILK_SCREEN_KEY, &errorArray)
      for str in backTracks {
        let track = SegmentEntity (self.undoManager)
        let ints = array5int (fromString: str, &errorArray)
        track.x1 = ints [0]
        track.y1 = ints [1]
        track.x2 = ints [2]
        track.y2 = ints [3]
        track.width = ints [4]
        backTrackEntities.append (track)
      }
      boardModel.backTracksNoSilkScreen = backTrackEntities
    }
  //--- Vias
    do{
      var viaEntities = EBReferenceArray <BoardModelVia> ()
      let vias = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_VIAS_KEY, &errorArray)
      for str in vias {
        let via = BoardModelVia (self.undoManager)
        let ints = array3int (fromString: str, &errorArray)
        via.x = ints [0]
        via.y = ints [1]
        via.padDiameter = ints [2]
        viaEntities.append (via)
      }
      boardModel.vias = viaEntities
    }
  //--- Back Legend texts
    do{
      var backLegendLinesEntities = EBReferenceArray <SegmentEntity> ()
      let backLegendLines = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_LINES_BACK_KEY, &errorArray)
      for str in backLegendLines {
        let ints = array5int (fromString: str, &errorArray)
        if let segment = clippedSegmentEntity (
          p1_mm: NSPoint (x: canariUnitToMillimeter (ints [0]), y:canariUnitToMillimeter (ints [1])),
          p2_mm: NSPoint (x: canariUnitToMillimeter (ints [2]), y:canariUnitToMillimeter (ints [3])),
          width_mm: canariUnitToMillimeter (ints [4]),
          clipRect_mm: boardRect_mm,
          self.undoManager
        ) {
          backLegendLinesEntities.append (segment)
        }
      }
      boardModel.backLegendLines = backLegendLinesEntities
    }
  //--- Front Legend texts
    do{
      var frontLegendLinesEntities = EBReferenceArray <SegmentEntity> ()
      let frontLegendLines = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_LINES_FRONT_KEY, &errorArray)
      for str in frontLegendLines {
        let ints = array5int (fromString: str, &errorArray)
        if let segment = clippedSegmentEntity (
          p1_mm: NSPoint (x: canariUnitToMillimeter (ints [0]), y:canariUnitToMillimeter (ints [1])),
          p2_mm: NSPoint (x: canariUnitToMillimeter (ints [2]), y:canariUnitToMillimeter (ints [3])),
          width_mm: canariUnitToMillimeter (ints [4]),
          clipRect_mm: boardRect_mm,
          self.undoManager
        ) {
          frontLegendLinesEntities.append (segment)
        }
      }
      boardModel.frontLegendLines = frontLegendLinesEntities
    }
  //--- Front Layout texts
    do{
      var frontLayoutTextEntities = EBReferenceArray <SegmentEntity> ()
      let frontLayoutTexts = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_TEXTS_LAYOUT_FRONT_KEY, &errorArray)
      for str in frontLayoutTexts {
        let segment = SegmentEntity (self.undoManager)
        let ints = array5int (fromString: str, &errorArray)
        segment.x1 = ints [0]
        segment.y1 = ints [1]
        segment.x2 = ints [2]
        segment.y2 = ints [3]
        segment.width = ints [4]
        frontLayoutTextEntities.append (segment)
      }
      boardModel.frontLayoutTexts = frontLayoutTextEntities
    }
  //--- Back Layout texts
    do{
      var backLayoutTextEntities = EBReferenceArray <SegmentEntity> ()
      let backLayoutTexts = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_TEXTS_LAYOUT_BACK_KEY, &errorArray)
      for str in backLayoutTexts {
        let segment = SegmentEntity (self.undoManager)
        let ints = array5int (fromString: str, &errorArray)
        segment.x1 = ints [0]
        segment.y1 = ints [1]
        segment.x2 = ints [2]
        segment.y2 = ints [3]
        segment.width = ints [4]
        backLayoutTextEntities.append (segment)
      }
      boardModel.backLayoutTexts = backLayoutTextEntities
    }
  //--- Back Legend texts
    do{
      var backLegendTextEntities = EBReferenceArray <SegmentEntity> ()
      let backLegendTexts = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_TEXTS_LEGEND_BACK_KEY, &errorArray)
      for str in backLegendTexts {
        let ints = array5int (fromString: str, &errorArray)
        if let segment = clippedSegmentEntity (
          p1_mm: NSPoint (x: canariUnitToMillimeter (ints [0]), y:canariUnitToMillimeter (ints [1])),
          p2_mm: NSPoint (x: canariUnitToMillimeter (ints [2]), y:canariUnitToMillimeter (ints [3])),
          width_mm: canariUnitToMillimeter (ints [4]),
          clipRect_mm: boardRect_mm,
          self.undoManager
        ) {
          backLegendTextEntities.append (segment)
        }
      }
      boardModel.backLegendTexts = backLegendTextEntities
    }
  //--- Front Legend texts
    do{
      var frontLegendTextEntities = EBReferenceArray <SegmentEntity> ()
      let frontTexts = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_TEXTS_LEGEND_FRONT_KEY, &errorArray)
      for str in frontTexts {
        let ints = array5int (fromString: str, &errorArray)
        if let segment = clippedSegmentEntity (
          p1_mm: NSPoint (x: canariUnitToMillimeter (ints [0]), y:canariUnitToMillimeter (ints [1])),
          p2_mm: NSPoint (x: canariUnitToMillimeter (ints [2]), y:canariUnitToMillimeter (ints [3])),
          width_mm: canariUnitToMillimeter (ints [4]),
          clipRect_mm: boardRect_mm,
          self.undoManager
        ) {
          frontLegendTextEntities.append (segment)
        }
      }
      boardModel.frontLegendTexts = frontLegendTextEntities
    }
  //--- Legend Front Images
    do{
      let rectArray = optionalRectArray (fromDict: inBoardArchiveDict, key: ARCHIVE_IMAGES_LEGEND_FRONT_KEY, self.undoManager, &errorArray)
      boardModel.legendFrontImages = EBReferenceArray (rectArray)
    }
  //--- Legend Back Images
    do{
      let rectArray = optionalRectArray (fromDict: inBoardArchiveDict, key: ARCHIVE_IMAGES_LEGEND_BACK_KEY, self.undoManager, &errorArray)
      boardModel.legendBackImages = EBReferenceArray (rectArray)
    }
  //--- Legend Front QR Codes
    do{
      let rectArray = optionalRectArray (fromDict: inBoardArchiveDict, key: ARCHIVE_QRCODES_LEGEND_FRONT_KEY, self.undoManager, &errorArray)
      boardModel.legendFrontQRCodes = EBReferenceArray (rectArray)
    }
  //--- Legend Back QR Codes
    do{
      let rectArray = optionalRectArray (fromDict: inBoardArchiveDict, key: ARCHIVE_QRCODES_LEGEND_BACK_KEY, self.undoManager, &errorArray)
      boardModel.legendBackQRCodes = EBReferenceArray (rectArray)
    }
  //--- Back packages
    do{
      var backPackagesEntities = EBReferenceArray <SegmentEntity> ()
      let backPackages = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_PACKAGES_BACK_KEY, &errorArray)
      for str in backPackages {
        let ints = array5int (fromString: str, &errorArray)
        if let segment = clippedSegmentEntity (
          p1_mm: NSPoint (x: canariUnitToMillimeter (ints [0]), y:canariUnitToMillimeter (ints [1])),
          p2_mm: NSPoint (x: canariUnitToMillimeter (ints [2]), y:canariUnitToMillimeter (ints [3])),
          width_mm: canariUnitToMillimeter (ints [4]),
          clipRect_mm: boardRect_mm,
          self.undoManager
        ) {
          backPackagesEntities.append (segment)
        }
      }
      boardModel.backPackages = backPackagesEntities
    }
  //--- Front packages
    do{
      var frontPackagesEntities = EBReferenceArray <SegmentEntity> ()
      let frontPackages = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_PACKAGES_FRONT_KEY, &errorArray)
      for str in frontPackages {
        let ints = array5int (fromString: str, &errorArray)
        if let segment = clippedSegmentEntity (
          p1_mm: NSPoint (x: canariUnitToMillimeter (ints [0]), y:canariUnitToMillimeter (ints [1])),
          p2_mm: NSPoint (x: canariUnitToMillimeter (ints [2]), y:canariUnitToMillimeter (ints [3])),
          width_mm: canariUnitToMillimeter (ints [4]),
          clipRect_mm: boardRect_mm,
          self.undoManager
        ) {
          frontPackagesEntities.append (segment)
        }
      }
      boardModel.frontPackages = frontPackagesEntities
    }
  //--- Back component names
    do{
      var backComponentNamesEntities = EBReferenceArray <SegmentEntity> ()
      let backComponentNames = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_COMPONENT_NAMES_BACK_KEY, &errorArray)
      for str in backComponentNames {
        let ints = array5int (fromString: str, &errorArray)
        if let segment = clippedSegmentEntity (
          p1_mm: NSPoint (x: canariUnitToMillimeter (ints [0]), y:canariUnitToMillimeter (ints [1])),
          p2_mm: NSPoint (x: canariUnitToMillimeter (ints [2]), y:canariUnitToMillimeter (ints [3])),
          width_mm: canariUnitToMillimeter (ints [4]),
          clipRect_mm: boardRect_mm,
          self.undoManager
        ) {
          backComponentNamesEntities.append (segment)
        }
      }
      boardModel.backComponentNames = backComponentNamesEntities
    }
  //--- Front component names
    do{
      var frontComponentNamesEntities = EBReferenceArray <SegmentEntity> ()
      let frontComponentNames = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_COMPONENT_NAMES_FRONT_KEY, &errorArray)
      for str in frontComponentNames {
        let ints = array5int (fromString: str, &errorArray)
        if let segment = clippedSegmentEntity (
          p1_mm: NSPoint (x: canariUnitToMillimeter (ints [0]), y:canariUnitToMillimeter (ints [1])),
          p2_mm: NSPoint (x: canariUnitToMillimeter (ints [2]), y:canariUnitToMillimeter (ints [3])),
          width_mm: canariUnitToMillimeter (ints [4]),
          clipRect_mm: boardRect_mm,
          self.undoManager
        ) {
          frontComponentNamesEntities.append (segment)
        }
      }
      boardModel.frontComponentNames = frontComponentNamesEntities
    }
  //--- Front component values
    do{
      var frontComponentValuesEntities = EBReferenceArray <SegmentEntity> ()
      let frontComponentValues = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_COMPONENT_VALUES_FRONT_KEY, &errorArray)
      for str in frontComponentValues {
        let ints = array5int (fromString: str, &errorArray)
        if let segment = clippedSegmentEntity (
          p1_mm: NSPoint (x: canariUnitToMillimeter (ints [0]), y: canariUnitToMillimeter (ints [1])),
          p2_mm: NSPoint (x: canariUnitToMillimeter (ints [2]), y: canariUnitToMillimeter (ints [3])),
          width_mm: canariUnitToMillimeter (ints [4]),
          clipRect_mm: boardRect_mm,
          self.undoManager
        ) {
          frontComponentValuesEntities.append (segment)
        }
      }
      boardModel.frontComponentValues = frontComponentValuesEntities
    }
  //--- Back component values
    do{
      var backComponentValuesEntities = EBReferenceArray <SegmentEntity> ()
      let backComponentValues = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_COMPONENT_VALUES_BACK_KEY, &errorArray)
      for str in backComponentValues {
        let ints = array5int (fromString: str, &errorArray)
        if let segment = clippedSegmentEntity (
          p1_mm: NSPoint (x: canariUnitToMillimeter (ints [0]), y: canariUnitToMillimeter (ints [1])),
          p2_mm: NSPoint (x: canariUnitToMillimeter (ints [2]), y: canariUnitToMillimeter (ints [3])),
          width_mm: canariUnitToMillimeter (ints [4]),
          clipRect_mm: boardRect_mm,
          self.undoManager
        ) {
          backComponentValuesEntities.append (segment)
        }
      }
      boardModel.backComponentValues = backComponentValuesEntities
    }
  //--- Drills
    do{
      var drillEntities = EBReferenceArray <SegmentEntity> ()
      let drills = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_DRILLS_KEY, &errorArray)
      for str in drills {
        let segment = SegmentEntity (self.undoManager)
        let ints = array5int (fromString: str, &errorArray)
        segment.x1 = ints [0]
        segment.y1 = ints [1]
        segment.x2 = ints [2]
        segment.y2 = ints [3]
        segment.width = ints [4]
        drillEntities.append (segment)
      }
      boardModel.drills = drillEntities
    }
  //--- Front pads
    do{
      var backPadEntities = EBReferenceArray <BoardModelPad> ()
      let backPadDictArray = dictArray (fromDict: inBoardArchiveDict, key: ARCHIVE_PADS_BACK_KEY, &errorArray)
      for padDict in backPadDictArray {
        let pad = BoardModelPad (self.undoManager)
        pad.x = int (fromDict: padDict, key: "X", &errorArray)
        pad.y = int (fromDict: padDict, key: "Y", &errorArray)
        pad.width = int (fromDict: padDict, key: "WIDTH", &errorArray)
        pad.height = int (fromDict: padDict, key: "HEIGHT", &errorArray)
        pad.rotation = int (fromDict: padDict, key: "ROTATION", &errorArray)
        let shapeString = string (fromDict: padDict, key: "SHAPE", &errorArray)
        if shapeString == "RECT" {
          pad.shape = .rect
        }else if shapeString == "ROUND" {
          pad.shape = .round
        }else if shapeString == "OCTO" {
          pad.shape = .octo
        }else{
          errorArray.append ("Invalid pad shape \"\(shapeString)\".")
        }
        backPadEntities.append (pad)
      }
      boardModel.backPads = backPadEntities
    }
  //--- Front pads
    do{
      var frontPadEntities = EBReferenceArray <BoardModelPad> ()
      let frontPadDictArray = dictArray (fromDict: inBoardArchiveDict, key: ARCHIVE_PADS_FRONT_KEY, &errorArray)
      for padDict in frontPadDictArray {
        let pad = BoardModelPad (self.undoManager)
        pad.x = int (fromDict: padDict, key: "X", &errorArray)
        pad.y = int (fromDict: padDict, key: "Y", &errorArray)
        pad.width = int (fromDict: padDict, key: "WIDTH", &errorArray)
        pad.height = int (fromDict: padDict, key: "HEIGHT", &errorArray)
        pad.rotation = int (fromDict: padDict, key: "ROTATION", &errorArray)
        let shapeString = string (fromDict: padDict, key: "SHAPE", &errorArray)
        if shapeString == "RECT" {
          pad.shape = .rect
        }else if shapeString == "ROUND" {
          pad.shape = .round
        }else if shapeString == "OCTO" {
          pad.shape = .octo
        }else{
          errorArray.append ("Invalid pad shape \"\(shapeString)\".")
        }
        frontPadEntities.append (pad)
      }
      boardModel.frontPads = frontPadEntities
    }
  //--- Import internal layers ?
    let hasInner1 = inBoardArchiveDict [ARCHIVE_TRACKS_INNER1_KEY] != nil
    let hasInner2 = inBoardArchiveDict [ARCHIVE_TRACKS_INNER2_KEY] != nil
    let hasInner3 = inBoardArchiveDict [ARCHIVE_TRACKS_INNER3_KEY] != nil
    let hasInner4 = inBoardArchiveDict [ARCHIVE_TRACKS_INNER4_KEY] != nil
    let hasTraversingPads = inBoardArchiveDict [ARCHIVE_PADS_TRAVERSING_KEY] != nil
    if !hasInner1 && !hasInner2 && !hasInner3 && !hasInner4 && !hasTraversingPads {
      boardModel.layerConfiguration = .twoLayers
    }else if hasInner1 && hasInner2 && !hasInner3 && !hasInner4 && hasTraversingPads {
      boardModel.layerConfiguration = .fourLayers
    }else if hasInner1 && hasInner2 && hasInner3 && hasInner4 && hasTraversingPads {
      boardModel.layerConfiguration = .sixLayers
    }else{
      errorArray.append ("inner layers configuration (\(hasInner1), \(hasInner2), \(hasInner3), \(hasInner4), \(hasTraversingPads)).")
    }
  //--- Import traversing pads
    if hasTraversingPads {
      var traversingPadEntities = EBReferenceArray <BoardModelPad> ()
      let traversingPadDictArray = dictArray (fromDict: inBoardArchiveDict, key: ARCHIVE_PADS_TRAVERSING_KEY, &errorArray)
      for padDict in traversingPadDictArray {
        let pad = BoardModelPad (self.undoManager)
        pad.x = int (fromDict: padDict, key: "X", &errorArray)
        pad.y = int (fromDict: padDict, key: "Y", &errorArray)
        pad.width = int (fromDict: padDict, key: "WIDTH", &errorArray)
        pad.height = int (fromDict: padDict, key: "HEIGHT", &errorArray)
        pad.rotation = int (fromDict: padDict, key: "ROTATION", &errorArray)
        let shapeString = string (fromDict: padDict, key: "SHAPE", &errorArray)
        if shapeString == "RECT" {
          pad.shape = .rect
        }else if shapeString == "ROUND" {
          pad.shape = .round
        }else if shapeString == "OCTO" {
          pad.shape = .octo
        }else{
          errorArray.append ("Invalid pad shape \"\(shapeString)\".")
        }
        traversingPadEntities.append (pad)
      }
      boardModel.traversingPads = traversingPadEntities
    }
  //--- Inner 1 tracks
    if hasInner1 {
      var trackEntities = EBReferenceArray <SegmentEntity> ()
      let tracks = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_TRACKS_INNER1_KEY, &errorArray)
      for str in tracks {
        let track = SegmentEntity (self.undoManager)
        let ints = array5int (fromString: str, &errorArray)
        track.x1 = ints [0]
        track.y1 = ints [1]
        track.x2 = ints [2]
        track.y2 = ints [3]
        track.width = ints [4]
        trackEntities.append (track)
      }
      boardModel.inner1Tracks = trackEntities
    }
  //--- Inner 2 tracks
    if hasInner2 {
      var trackEntities = EBReferenceArray <SegmentEntity> ()
      let tracks = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_TRACKS_INNER2_KEY, &errorArray)
      for str in tracks {
        let track = SegmentEntity (self.undoManager)
        let ints = array5int (fromString: str, &errorArray)
        track.x1 = ints [0]
        track.y1 = ints [1]
        track.x2 = ints [2]
        track.y2 = ints [3]
        track.width = ints [4]
        trackEntities.append (track)
      }
      boardModel.inner2Tracks = trackEntities
    }
  //--- Inner 3 tracks
    if hasInner3 {
      var trackEntities = EBReferenceArray <SegmentEntity> ()
      let tracks = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_TRACKS_INNER3_KEY, &errorArray)
      for str in tracks {
        let track = SegmentEntity (self.undoManager)
        let ints = array5int (fromString: str, &errorArray)
        track.x1 = ints [0]
        track.y1 = ints [1]
        track.x2 = ints [2]
        track.y2 = ints [3]
        track.width = ints [4]
        trackEntities.append (track)
      }
      boardModel.inner3Tracks = trackEntities
    }
  //--- Inner 4 tracks
    if hasInner4 {
      var trackEntities = EBReferenceArray <SegmentEntity> ()
      let tracks = stringArray (fromDict: inBoardArchiveDict, key: ARCHIVE_TRACKS_INNER4_KEY, &errorArray)
      for str in tracks {
        let track = SegmentEntity (self.undoManager)
        let ints = array5int (fromString: str, &errorArray)
        track.x1 = ints [0]
        track.y1 = ints [1]
        track.x2 = ints [2]
        track.y2 = ints [3]
        track.width = ints [4]
        trackEntities.append (track)
      }
      boardModel.inner4Tracks = trackEntities
    }
  //--- Dictionary import ok ?
    if !errorArray.isEmpty { // Error
      var s = ""
      for anError in errorArray {
        if s != "" {
          s += "\n"
        }
        s += anError
      }
      let alert = NSAlert ()
      alert.messageText = "Cannot Analyze file contents"
      alert.informativeText = s
      alert.beginSheetModal (for: self.windowForSheet!)
    }
  //--- Return
    if errorArray.isEmpty {
      inCallBack (boardModel)
    }
//    return errorArray.isEmpty ? boardModel : nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//fileprivate func double (fromDict inDictionary : [String : Any], key inKey : String, _ errorArray : inout [String]) -> Double {
//  let object : Any? = inDictionary [inKey]
//  var result = 0.0 // Default result
//  if object == nil {
//    errorArray.append ("No \"\(inKey)\" key.")
//  }else if let number = object as? NSNumber {
//    result = number.doubleValue
//  }else{
//    errorArray.append ("The \"\(inKey)\" key value is not a double.")
//  }
//  return result
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func int (fromDict inDictionary : [String : Any],
                      key inKey : String,
                      _ errorArray : inout [String]) -> Int {
  let object : Any? = inDictionary [inKey]
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

//fileprivate func intOrZero (fromDict inDictionary : [String : Any],
//                            key inKey : String,
//                            _ errorArray : inout [String]) -> Int {
//  let object : Any? = inDictionary [inKey]
//  var result = 0 // Default result
//  if let number = object as? NSNumber {
//    result = number.intValue
//  }else if object != nil {
//    errorArray.append ("The \"\(inKey)\" key value is not an integer.")
//  }
//  return result
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func string (fromDict inDictionary : [String : Any],
                         key inKey : String,
                         _ errorArray : inout [String]) -> String {
  let object : Any? = inDictionary [inKey]
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

fileprivate func dictArray (fromDict inDictionary : [String : Any],
                            key inKey : String,
                            _ errorArray : inout [String]) -> [[String : Any]] {
  let object : Any? = inDictionary [inKey]
  var result = [[String : Any]] () // Default result
  if object == nil {
    errorArray.append ("No \"\(inKey)\" key.")
  }else if let s = object as? [[String : Any]] {
    result = s
  }else{
    errorArray.append ("The \"\(inKey)\" key value is not an array of dictionaries.")
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func stringArray (fromDict inDictionary : [String : Any],
                              key inKey : String,
                              _ errorArray : inout [String]) -> [String] {
  let object : Any? = inDictionary [inKey]
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

fileprivate func optionalStringArray (fromDict inDictionary : [String : Any],
                                      key inKey : String,
                                      _ errorArray : inout [String]) -> [String] {
  let object : Any? = inDictionary [inKey]
  var result = [String] () // Default result
  if let s = object as? [String] {
    result = s
  }else if object != nil {
    errorArray.append ("The \"\(inKey)\" key value is not an array of string.")
  }
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func array3int (fromString inString : String,
                            _ errorArray : inout [String]) -> [Int] {
  let strArray : [String] = inString.components(separatedBy: " ")
  var result = [Int] () // Default result
  if strArray.count != 3 {
    errorArray.append ("The string is not a three integer array.")
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
//--- If an error occurs, add fake int to get a three element vector
  while result.count < 3 {
    result.append (0)
  }
//---
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//fileprivate func array4int (fromString inString : String,
//                             _ errorArray : inout [String]) -> [Int] {
//  let strArray : [String] = inString.components(separatedBy: " ")
//  var result = [Int] () // Default result
//  if strArray.count != 4 {
//    errorArray.append ("The string is not a four integer array.")
//  }else{
//    for s in strArray {
//      let possibleInt : Int? = Int (s)
//      if let n = possibleInt {
//        result.append (n)
//      }else{
//        errorArray.append ("The string is not a four integer array.")
//      }
//    }
//  }
////--- If an error occurs, add fake int to get a four element vector
//  while result.count < 4 {
//    result.append (0)
//  }
////---
//  return result
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func array5int (fromString inString : String,
                            _ errorArray : inout [String]) -> [Int] {
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
//--- If an error occurs, add fake int(s) to get a five element vector
  while result.count < 5 {
    result.append (0)
  }
//---
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor fileprivate func optionalRectArray (fromDict inBoardArchiveDict : [String : Any],
                                               key inKey : String,
                                               _ inUndoManager : UndoManager?,
                                               _ errorArray : inout [String]) -> [RectangleEntity] {
  var rectangleArray = [RectangleEntity] ()
  let stringArray = optionalStringArray (fromDict: inBoardArchiveDict, key: inKey, &errorArray)
  for str in stringArray {
    let components = str.components (separatedBy: ":")
    var pts = [Int] ()
    for s in components {
      if let v = Int (s) {
        pts.append (v)
      }
    }
    if pts.count != 8 {
      errorArray.append ("The \"\(inKey)\" key value is not an array of 8 int string.")
    }else{
      let r = RectangleEntity (inUndoManager)
      r.p0x = pts [0]
      r.p0y = pts [1]
      r.p1x = pts [2]
      r.p1y = pts [3]
      r.p2x = pts [4]
      r.p2y = pts [5]
      r.p3x = pts [6]
      r.p3y = pts [7]
      rectangleArray.append (r)
    }
  }
  return rectangleArray
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

