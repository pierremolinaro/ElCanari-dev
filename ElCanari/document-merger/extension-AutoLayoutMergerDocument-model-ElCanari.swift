//
//  extension-AutoLayoutMergerDocument-lmodel-ElCanari.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/06/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import Compression

//--------------------------------------------------------------------------------------------------

extension AutoLayoutMergerDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Load from JSON archive
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func loadBoardModelELCanariBoardArchive (filePath inFilePath : String, windowForSheet inWindow : NSWindow) {
  //--- Load file, as plist
    let optionalFileData : Data? = FileManager ().contents (atPath: inFilePath)
    if let fileData = optionalFileData {
      let s = inFilePath.lastPathComponent.deletingPathExtension
      self.parseBoardModelELCanariBoardArchive (fromData: fileData, named : s, callBack: { self.registerBoardModelCallBack ($0) } )
    }else{ // Cannot read file
      let alert = NSAlert ()
      alert.messageText = "Cannot read file"
      alert.informativeText = "The file \(inFilePath) cannot be read."
      alert.beginSheetModal (for: inWindow)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func parseBoardModelELCanariBoardArchive (fromData inData : Data,
                                            named inName : String,
                                            callBack inCallBack : @escaping (BoardModel) -> Void) {
    if let product = ProductRepresentation (fromJSONCompressedData: inData, using: COMPRESSION_LZMA) {
      self.internalLoadELCanariBoardArchive (product, named: inName, callBack: inCallBack)
    }else{
      let alert = NSAlert ()
      alert.messageText = "Cannot Analyse JSON contents"
      alert.beginSheetModal (for: self.windowForSheet!)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func internalLoadELCanariBoardArchive (_ inProduct : ProductRepresentation,
                                         named inName : String,
                                         callBack inCallBack : @escaping (BoardModel) -> Void) {
    let boardModel = BoardModel (self.undoManager)
  //--- Populate board model from dictionary (accumulate error messages in errorArray variable)
    boardModel.modelVersion = MERGER_ARCHIVE_VERSION
    boardModel.ignoreModelVersionError = false
    boardModel.name = inName
    boardModel.modelData = inProduct.encodedJSONCompressedData (prettyPrinted: true, using: COMPRESSION_LZMA)
    boardModel.artworkName = inProduct.artworkName
    boardModel.modelWidth = inProduct.boardWidth.valueInCanariUnit
    boardModel.modelHeight = inProduct.boardHeight.valueInCanariUnit
    boardModel.modelLimitWidth = inProduct.boardLimitWidth.valueInCanariUnit
    boardModel.modelWidthUnit = inProduct.boardWidthUnit
    boardModel.modelHeightUnit = inProduct.boardHeightUnit
    boardModel.modelLimitWidthUnit = inProduct.boardLimitWidthUnit
    boardModel.layerConfiguration = inProduct.layerConfiguration
  //--- Internal board limits
    boardModel.internalBoardsLimits = inProduct.segmentEntities (self.undoManager, forLayers: .boardLimits)
  //--- Front tracks
    boardModel.frontTracks = inProduct.segmentEntities (self.undoManager, forLayers: .frontSideTrack)
  //--- Back tracks
    boardModel.backTracks = inProduct.segmentEntities (self.undoManager, forLayers: .backSideTrack)
  //--- Front exposed tracks
    boardModel.frontTracksNoSilkScreen = inProduct.segmentEntities (self.undoManager, forLayers: .frontSideExposedTrack)
  //--- Back exposed tracks
    boardModel.backTracksNoSilkScreen = inProduct.segmentEntities (self.undoManager, forLayers: .backSideExposedTrack)
  //--- Via pads
    do{
      var viaEntities = EBReferenceArray <BoardModelVia> ()
      for circle in inProduct.circles (forLayers: .viaPad) {
        let via = BoardModelVia (self.undoManager)
        via.x = circle.x.valueInCanariUnit
        via.y = circle.y.valueInCanariUnit
        via.padDiameter = circle.d.valueInCanariUnit
        viaEntities.append (via)
      }
      boardModel.vias = viaEntities
    }
  //--- Back Legend lines
    boardModel.backLegendLines = inProduct.segmentEntities (self.undoManager, forLayers: .backSideLegendLine)
  //--- Front Legend lines
    boardModel.frontLegendLines = inProduct.segmentEntities (self.undoManager, forLayers: .frontSideLegendLine)
  //--- Front Layout texts
    boardModel.frontLayoutTexts = inProduct.segmentEntities (self.undoManager, forLayers: .frontSideLayoutText)
  //--- Back Layout texts
    boardModel.backLayoutTexts = inProduct.segmentEntities (self.undoManager, forLayers: .backSideLayoutText)
  //--- Back Legend texts
    boardModel.backLegendTexts = inProduct.segmentEntities (self.undoManager, forLayers: .backSideLegendText)
  //--- Front Legend texts
    boardModel.frontLegendTexts = inProduct.segmentEntities (self.undoManager, forLayers: .frontSideLegendText)
  //--- Legend Front Images
    boardModel.legendFrontImages = inProduct.rectangleEntities (self.undoManager, forLayers: .frontSideImage)
  //--- Legend Back Images
    boardModel.legendBackImages = inProduct.rectangleEntities (self.undoManager, forLayers: .backSideImage)
  //--- Legend Front QR Codes
    boardModel.legendFrontQRCodes = inProduct.rectangleEntities (self.undoManager, forLayers: .frontSideQRCode)
  //--- Legend Back QR Codes
    boardModel.legendBackQRCodes = inProduct.rectangleEntities (self.undoManager, forLayers: .backSideQRCode)
  //--- Back packages
    boardModel.backPackages = inProduct.segmentEntities (self.undoManager, forLayers: .backSidePackageLegend)
  //--- Front packages
    boardModel.frontPackages = inProduct.segmentEntities (self.undoManager, forLayers: .frontSidePackageLegend)
  //--- Back component names
    boardModel.backComponentNames = inProduct.segmentEntities (self.undoManager, forLayers: .backSideComponentName)
  //--- Front component names
    boardModel.frontComponentNames = inProduct.segmentEntities (self.undoManager, forLayers: .frontSideComponentName)
  //--- Front component values
    boardModel.frontComponentValues = inProduct.segmentEntities (self.undoManager, forLayers: .frontSideComponentValue)
  //--- Back component values
    boardModel.backComponentValues = inProduct.segmentEntities (self.undoManager, forLayers: .backSideComponentValue)
  //--- Drills
    do{
      var drillEntities = EBReferenceArray <SegmentEntity> ()
      for hole in inProduct.circles (forLayers: .hole) {
        let drill = SegmentEntity (self.undoManager)
        drill.x1 = hole.x.valueInCanariUnit
        drill.y1 = hole.y.valueInCanariUnit
        drill.x2 = hole.x.valueInCanariUnit
        drill.y2 = hole.y.valueInCanariUnit
        drill.width = hole.d.valueInCanariUnit
        drillEntities.append (drill)
      }
      for hole in inProduct.roundSegments (forLayers: .hole) {
        let drill = SegmentEntity (self.undoManager)
        drill.x1 = hole.x1.valueInCanariUnit
        drill.y1 = hole.y1.valueInCanariUnit
        drill.x2 = hole.x2.valueInCanariUnit
        drill.y2 = hole.y2.valueInCanariUnit
        drill.width = hole.width.valueInCanariUnit
        drillEntities.append (drill)
      }
      boardModel.drills = drillEntities
    }
  //--- Back pads
    boardModel.backPads = inProduct.pads (self.undoManager, forLayers: .backSideComponentPad)
  //--- Front pads
    boardModel.frontPads = inProduct.pads (self.undoManager, forLayers: .frontSideComponentPad)
  //--- Return
    inCallBack (boardModel)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func registerBoardModelCallBack (_ inBoardModel : BoardModel) {
    self.rootObject.boardModels_property.add (inBoardModel)
    self.mBoardModelController.select (object: inBoardModel)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
