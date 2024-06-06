//
//  extension-MergerDocument-generate-product-files.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit
import Compression

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutMergerDocument {

  //································································································

  final func checkLayerConfigurationAndGenerateProductFiles () {
  //--- Layout layer configuration
    var layerSet = Set <LayerConfiguration> ()
    var artworkLayerConfiguration : LayerConfiguration? = nil
    if let artworkLayerConf = self.rootObject.mArtwork?.layerConfiguration {
      layerSet.insert (artworkLayerConf)
      artworkLayerConfiguration = artworkLayerConf
    }
    var boardLayerSet = Set <LayerConfiguration> ()
    for boardModel in self.rootObject.boardModels.values {
      layerSet.insert (boardModel.layerConfiguration)
      boardLayerSet.insert (boardModel.layerConfiguration)
    }
  //---
    if layerSet.count < 2 {
      self.generateProductFiles ()
    }else{
      let alert = NSAlert ()
      alert.messageText = "Inconsistent Board models / Artwork layout layer configuration."
      var s = ""
      for layer in boardLayerSet {
        if !s.isEmpty {
          s += ", "
        }
        switch layer {
        case  .twoLayers : s += "2"
        case .fourLayers : s += "4"
        case  .sixLayers : s += "6"
        }
      }
      var artworkLayerString = "?"
      if let alc = artworkLayerConfiguration {
        switch alc {
        case  .twoLayers : artworkLayerString = "2"
        case .fourLayers : artworkLayerString = "4"
        case  .sixLayers : artworkLayerString = "6"
        }
      }
      alert.informativeText = "Artwork handles \(artworkLayerString) layers, board elements have \(s) layers."
      _ = alert.addButton (withTitle: "Cancel")
      _ = alert.addButton (withTitle: "Proceed anyway")
      alert.beginSheetModal (
        for: self.windowForSheet!,
        completionHandler: {(response : NSApplication.ModalResponse) in
          if response == .alertSecondButtonReturn { // Proceed anyway
            self.generateProductFiles ()
          }
        }
      )
    }
  }

  //································································································

  private func generateProductFiles () {
    do{
    //--- Create product directory
      if let f = self.fileURL?.path.deletingPathExtension {
        self.mLogTextView?.clear ()
        self.mProductPageSegmentedControl?.setSelectedSegment (atIndex: 4)
        let baseName = f.lastPathComponent
        let productDirectory = f.deletingLastPathComponent
        let product = self.generateProductRepresentation ()
      //--- Generate board archive
        if self.rootObject.mGenerateMergerArchive_property.propval {
          if self.rootObject.mUsesNewProductGeneration {
            let boardArchivePath = productDirectory + "/" + baseName + "." + EL_CANARI_MERGER_ARCHIVE
            self.mLogTextView?.appendMessage ("Generating \(boardArchivePath.lastPathComponent)…")
            let data = product.encodedJSONCompressedData (
              prettyPrinted: true,
              using: COMPRESSION_LZMA
            )
            try data.write(to: URL (fileURLWithPath: boardArchivePath), options: .atomic)
            self.mLogTextView?.appendSuccess (" Ok\n")
          }else{
            let boardArchivePath = productDirectory + "/" + baseName + "." + EL_CANARI_LEGACY_MERGER_ARCHIVE
            self.mLogTextView?.appendMessage ("Generating \(boardArchivePath.lastPathComponent)…")
            try self.generateBoardArchive (atPath: boardArchivePath)
            self.mLogTextView?.appendSuccess (" Ok\n")
          }
        }
      //--- Gerber
        let generateGerberAndPDF = self.rootObject.mGenerateGerberAndPDF_property.propval
        let gerberDirectory = productDirectory + "/" + baseName + "-gerber"
        try self.removeAndCreateDirectory (atPath: gerberDirectory, create: generateGerberAndPDF)
        if generateGerberAndPDF {
          let filePath = gerberDirectory + "/" + baseName
          if self.rootObject.mUsesNewProductGeneration {
            try self.generateGerberFiles (product, atPath: filePath)
          }else{
            try self.generateLegacyGerberFiles (atPath: filePath)
          }
        }
      //--- PDF
        let pdfDirectory = productDirectory + "/" + baseName + "-pdf"
        try self.removeAndCreateDirectory (atPath: pdfDirectory, create: generateGerberAndPDF)
        if generateGerberAndPDF {
          let filePath = pdfDirectory + "/" + baseName
          if self.rootObject.mUsesNewProductGeneration {
            try self.generatePDFfiles (product, atPath: filePath)
            try self.writePDFDrillFile (product, atPath: filePath)
          }else{
            try self.generatePDFLegacyFiles (atPath: filePath)
            try self.writePDFLegacyDrillFile (atPath: filePath)
          }
        }
      //--- Done !
        self.mLogTextView?.appendMessage ("Done.")
      }
    }catch let error {
      _ = self.windowForSheet?.presentError (error)
    }
  }

  //································································································

  private func removeAndCreateDirectory (atPath inDirectoryPath : String,
                                         create inCreate : Bool) throws {
    let fm = FileManager ()
    var isDir : ObjCBool = false
    if fm.fileExists (atPath: inDirectoryPath, isDirectory: &isDir) {
      self.mLogTextView?.appendMessage ("Remove recursively \(inDirectoryPath)...")
      try fm.removeItem (atPath: inDirectoryPath) // Remove dir recursively
      self.mLogTextView?.appendSuccess (" ok.\n")
    }
    if inCreate {
      self.mLogTextView?.appendMessage ("Create \(inDirectoryPath)...")
      try fm.createDirectory (atPath: inDirectoryPath, withIntermediateDirectories: true, attributes: nil)
      self.mLogTextView?.appendSuccess (" ok.\n")
    }
  }

  //································································································

  func generateProductRepresentation () -> ProductRepresentation {
    let boardLimitWidth = ProductLength  (valueInCanariUnit: self.rootObject.boardLimitWidth)
    var product = ProductRepresentation (
      boardWidth : ProductLength (valueInCanariUnit: self.rootObject.boardWidth!),
      boardWidthUnit : self.rootObject.boardWidthUnit, // Canari Unit
      boardHeight : ProductLength (valueInCanariUnit: self.rootObject.boardHeight!),
      boardHeightUnit: self.rootObject.boardHeightUnit, // Canari Unit
      boardLimitWidth: boardLimitWidth,
      boardLimitWidthUnit: self.rootObject.boardLimitWidthUnit, // Canari Unit
      artworkName: self.rootObject.mArtworkName,
      layerConfiguration: self.rootObject.mArtwork!.layerConfiguration
    )
  //--- Add Board limits
    let boardRect = CanariRect (
      origin: .zero,
      size: CanariSize (width: self.rootObject.boardWidth!, height: self.rootObject.boardHeight!)
    ).insetBy (dx: self.rootObject.boardLimitWidth / 2, dy: self.rootObject.boardLimitWidth / 2)
    let p0 = ProductPoint (canariPoint: boardRect.bottomLeft)
    let p1 = ProductPoint (canariPoint: boardRect.bottomRight)
    let p2 = ProductPoint (canariPoint: boardRect.topRight)
    let p3 = ProductPoint (canariPoint: boardRect.topLeft)
    product.append (roundSegment: LayeredProductSegment (p1: p0, p2: p1, width: boardLimitWidth, layers: .boardLimits))
    product.append (roundSegment: LayeredProductSegment (p1: p1, p2: p2, width: boardLimitWidth, layers: .boardLimits))
    product.append (roundSegment: LayeredProductSegment (p1: p2, p2: p3, width: boardLimitWidth, layers: .boardLimits))
    product.append (roundSegment: LayeredProductSegment (p1: p3, p2: p0, width: boardLimitWidth, layers: .boardLimits))
  //--- board instances
    for element in self.rootObject.boardInstances.values {
      let boardModel : BoardModel = element.myModel!
      let compressedJSONData = boardModel.modelData
      let modelProduct = ProductRepresentation (
        fromJSONCompressedData: compressedJSONData,
        using: COMPRESSION_LZMA
      )!
      let x = ProductLength (valueInCanariUnit: element.x)
      let y = ProductLength (valueInCanariUnit: element.y)
      product.add (modelProduct, x: x, y: y, quadrantRotation: element.instanceRotation)
    }
    return product
  }

  //································································································

  fileprivate func generateBoardArchive (atPath inFilePath : String) throws {
    var archiveDict = [String : Any] ()
  //---
    archiveDict [ARCHIVE_ARTWORK_KEY] = self.rootObject.mArtworkName
    archiveDict [ARCHIVE_BOARD_HEIGHT_KEY] = self.rootObject.boardHeight ?? 0
    archiveDict [ARCHIVE_BOARD_HEIGHT_UNIT_KEY] = self.rootObject.boardHeightUnit
    archiveDict [ARCHIVE_BOARD_LINE_WIDTH_KEY] = self.rootObject.boardLimitWidth
    archiveDict [ARCHIVE_BOARD_LINE_WIDTH_UNIT_KEY] = self.rootObject.boardLimitWidthUnit
    archiveDict [ARCHIVE_BOARD_WIDTH_KEY] = self.rootObject.boardWidth ?? 0
    archiveDict [ARCHIVE_BOARD_WIDTH_UNIT_KEY] = self.rootObject.boardWidthUnit
    var internalBoardsLimits = [String] ()
    var backComponentNames = [String] ()
    var frontComponentNames = [String] ()
    var backComponentValues = [String] ()
    var frontComponentValues = [String] ()
    var backPackages = [String] ()
    var frontPackages = [String] ()
    var backLayoutTexts = [String] ()
    var frontLayoutTexts = [String] ()
    var backLegendTexts = [String] ()
    var frontLegendTexts = [String] ()
    var backLegendQRCodes = [String] ()
    var frontLegendQRCodes = [String] ()
    var backLegendImages = [String] ()
    var frontLegendImages = [String] ()
    var backTracks = [String] ()
    var inner1Tracks = [String] ()
    var inner2Tracks = [String] ()
    var inner3Tracks = [String] ()
    var inner4Tracks = [String] ()
    var frontTracks = [String] ()
    var frontTracksNoSilkScreen = [String] ()
    var backTracksNoSilkScreen = [String] ()
    var backLegendLines = [String] ()
    var frontLegendLines = [String] ()
    var vias = [String] ()
    var frontPads = [[String : Any]] ()
    var traversingPads = [[String : Any]] ()
    var backPads = [[String : Any]] ()
    var drills = [String] ()
    for board in self.rootObject.boardInstances.values {
      if let myModel : BoardModel = board.myModel {
        let modelWidth  = myModel.modelWidth
        let modelHeight = myModel.modelHeight
        let instanceRotation = board.instanceRotation
        myModel.boardLimitsSegments ().add (toArchiveArray: &internalBoardsLimits, dx: board.x, dy: board.y,
         modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        myModel.internalBoardsLimitsSegments?.add (toArchiveArray: &internalBoardsLimits, dx: board.x, dy: board.y,
         modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        myModel.backComponentNameSegments?.add (toArchiveArray: &backComponentNames, dx: board.x, dy: board.y,
         modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        myModel.frontComponentNameSegments?.add (toArchiveArray: &frontComponentNames, dx: board.x, dy: board.y,
         modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        myModel.backComponentValueSegments?.add (toArchiveArray: &backComponentValues, dx: board.x, dy: board.y,
         modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        myModel.frontComponentValueSegments?.add (toArchiveArray: &frontComponentValues, dx: board.x, dy: board.y,
         modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        myModel.backPackagesSegments?.add (toArchiveArray: &backPackages, dx: board.x, dy: board.y,
         modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        myModel.frontPackagesSegments?.add (toArchiveArray: &frontPackages, dx: board.x, dy: board.y,
         modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        myModel.backLayoutTextsSegments?.add (toArchiveArray: &backLayoutTexts, dx: board.x, dy: board.y,
         modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        myModel.frontLayoutTextsSegments?.add (toArchiveArray: &frontLayoutTexts, dx: board.x, dy: board.y,
         modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        myModel.backLegendTextsSegments?.add (toArchiveArray: &backLegendTexts, dx: board.x, dy: board.y,
         modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        myModel.frontLegendTextsSegments?.add (toArchiveArray: &frontLegendTexts, dx: board.x, dy: board.y,
         modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        myModel.frontLegendBoardImageRectangles?.add (
          toArchiveArray: &frontLegendImages,
          dx: board.x,
          dy: board.y,
          modelWidth: modelWidth,
          modelHeight: modelHeight,
          instanceRotation: instanceRotation
        )
        myModel.backLegendBoardImageRectangles?.add (
          toArchiveArray: &backLegendImages,
          dx: board.x,
          dy: board.y,
          modelWidth: modelWidth,
          modelHeight: modelHeight,
          instanceRotation: instanceRotation
        )
        myModel.frontLegendQRCodeRectangles?.add (
          toArchiveArray: &frontLegendQRCodes,
          dx: board.x,
          dy: board.y,
          modelWidth: modelWidth,
          modelHeight: modelHeight,
          instanceRotation: instanceRotation
        )
        myModel.backLegendQRCodeRectangles?.add (
          toArchiveArray: &backLegendQRCodes,
          dx: board.x,
          dy: board.y,
          modelWidth: modelWidth,
          modelHeight: modelHeight,
          instanceRotation: instanceRotation
        )
        myModel.backTrackSegments?.add (
          toArchiveArray: &backTracks,
          dx: board.x,
          dy: board.y,
          modelWidth: modelWidth,
          modelHeight: modelHeight,
          instanceRotation: instanceRotation
        )
        myModel.inner1TracksSegments?.add (
          toArchiveArray: &inner1Tracks,
          dx: board.x,
          dy: board.y,
          modelWidth: modelWidth,
          modelHeight: modelHeight,
          instanceRotation: instanceRotation
        )
        myModel.inner2TracksSegments?.add (
          toArchiveArray: &inner2Tracks,
          dx: board.x,
          dy: board.y,
          modelWidth: modelWidth,
          modelHeight: modelHeight,
          instanceRotation: instanceRotation
        )
        myModel.inner3TracksSegments?.add (
          toArchiveArray: &inner3Tracks,
          dx: board.x,
          dy: board.y,
          modelWidth: modelWidth,
          modelHeight: modelHeight,
          instanceRotation: instanceRotation
        )
        myModel.inner4TracksSegments?.add (
          toArchiveArray: &inner4Tracks,
          dx: board.x,
          dy: board.y,
          modelWidth: modelWidth,
          modelHeight: modelHeight,
          instanceRotation: instanceRotation
        )
        myModel.frontTrackSegments?.add (
          toArchiveArray: &frontTracks,
          dx: board.x,
          dy: board.y,
          modelWidth: modelWidth,
          modelHeight: modelHeight,
          instanceRotation: instanceRotation
        )
        myModel.frontTracksNoSilkScreen.values.addToArchiveArray (&frontTracksNoSilkScreen,
          dx: board.x,
          dy: board.y,
          modelWidth: modelWidth,
          modelHeight: modelHeight,
          instanceRotation: instanceRotation
        )
        myModel.backTracksNoSilkScreen.values.addToArchiveArray (&backTracksNoSilkScreen,
          dx: board.x,
          dy: board.y,
          modelWidth: modelWidth,
          modelHeight: modelHeight,
          instanceRotation: instanceRotation
        )
        myModel.backLegendLinesSegments?.add (toArchiveArray: &backLegendLines, dx: board.x, dy: board.y,
         modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        myModel.frontLegendLinesSegments?.add (toArchiveArray: &frontLegendLines, dx: board.x, dy: board.y,
         modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        myModel.drillSegments?.add (toArchiveArray: &drills, dx: board.x, dy: board.y,
         modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        for via in myModel.vias_property.propval.values {
          var viaX = board.x
          var viaY = board.y
          switch instanceRotation {
          case .rotation0 :
            viaX += via.x
            viaY += via.y
          case .rotation90 :
            viaX += modelHeight - via.y
            viaY += via.x
          case .rotation180 :
            viaX += modelWidth  - via.x
            viaY += modelHeight - via.y
          case .rotation270 :
            viaX += via.y
            viaY += modelWidth - via.x
          }
          vias.append ("\(viaX) \(viaY) \(via.padDiameter)")
        }
        for pad in myModel.frontPads_property.propval.values {
          var d = [String : Any] ()
          d ["HEIGHT"] = pad.height
          d ["ROTATION"] = (pad.rotation + instanceRotation.rawValue * 90_000) % 360_000
          switch pad.shape {
          case .rect :
            d ["SHAPE"] = "RECT"
          case .octo :
            d ["SHAPE"] = "OCTO"
          case .round :
            d ["SHAPE"] = "ROUND"
          }
          d ["WIDTH"] = pad.width
          switch instanceRotation {
          case .rotation0 :
            d ["X"] = board.x + pad.x
            d ["Y"] = board.y + pad.y
          case .rotation90 :
            d ["X"] = board.x + modelHeight - pad.y
            d ["Y"] = board.y + pad.x
          case .rotation180 :
            d ["X"] = board.x + modelWidth  - pad.x
            d ["Y"] = board.y + modelHeight - pad.y
          case .rotation270 :
            d ["X"] = board.x + pad.y
            d ["Y"] = board.y + modelWidth - pad.x
          }
          frontPads.append (d)
        }
        for pad in myModel.traversingPads_property.propval.values {
          var d = [String : Any] ()
          d ["HEIGHT"] = pad.height
          d ["ROTATION"] = (pad.rotation + instanceRotation.rawValue * 90_000) % 360_000
          switch pad.shape {
          case .rect :
            d ["SHAPE"] = "RECT"
          case .octo :
            d ["SHAPE"] = "OCTO"
          case .round :
            d ["SHAPE"] = "ROUND"
          }
          d ["WIDTH"] = pad.width
          switch instanceRotation {
          case .rotation0 :
            d ["X"] = board.x + pad.x
            d ["Y"] = board.y + pad.y
          case .rotation90 :
            d ["X"] = board.x + modelHeight - pad.y
            d ["Y"] = board.y + pad.x
          case .rotation180 :
            d ["X"] = board.x + modelWidth  - pad.x
            d ["Y"] = board.y + modelHeight - pad.y
          case .rotation270 :
            d ["X"] = board.x + pad.y
            d ["Y"] = board.y + modelWidth - pad.x
          }
          traversingPads.append (d)
        }
        for pad in myModel.backPads_property.propval.values {
          var d = [String : Any] ()
          d ["HEIGHT"] = pad.height
          d ["ROTATION"] = (pad.rotation + instanceRotation.rawValue * 90_000) % 360_000
          switch pad.shape {
          case .rect :
            d ["SHAPE"] = "RECT"
          case .round :
            d ["SHAPE"] = "ROUND"
          case .octo :
            d ["SHAPE"] = "OCTO"
          }
          d ["WIDTH"] = pad.width
          switch instanceRotation {
          case .rotation0 :
            d ["X"] = board.x + pad.x
            d ["Y"] = board.y + pad.y
          case .rotation90 :
            d ["X"] = board.x + modelHeight - pad.y
            d ["Y"] = board.y + pad.x
          case .rotation180 :
            d ["X"] = board.x + modelWidth  - pad.x
            d ["Y"] = board.y + modelHeight - pad.y
          case .rotation270 :
            d ["X"] = board.x + pad.y
            d ["Y"] = board.y + modelWidth - pad.x
          }
          backPads.append (d)
        }
      }
      if let layerConfiguration = self.rootObject.mArtwork?.layerConfiguration {
        switch layerConfiguration {
        case .twoLayers :
          ()
        case .fourLayers :
          archiveDict [ARCHIVE_PADS_TRAVERSING_KEY] = traversingPads
          archiveDict [ARCHIVE_TRACKS_INNER1_KEY] = inner1Tracks.sorted ()
          archiveDict [ARCHIVE_TRACKS_INNER2_KEY] = inner2Tracks.sorted ()
        case .sixLayers :
          archiveDict [ARCHIVE_PADS_TRAVERSING_KEY] = traversingPads
          archiveDict [ARCHIVE_TRACKS_INNER1_KEY] = inner1Tracks.sorted ()
          archiveDict [ARCHIVE_TRACKS_INNER2_KEY] = inner2Tracks.sorted ()
          archiveDict [ARCHIVE_TRACKS_INNER3_KEY] = inner3Tracks.sorted ()
          archiveDict [ARCHIVE_TRACKS_INNER4_KEY] = inner4Tracks.sorted ()
        }
      }
    }
    archiveDict [ARCHIVE_IMAGES_LEGEND_FRONT_KEY] = frontLegendImages
    archiveDict [ARCHIVE_IMAGES_LEGEND_BACK_KEY] = backLegendImages
    archiveDict [ARCHIVE_QRCODES_LEGEND_FRONT_KEY] = frontLegendQRCodes
    archiveDict [ARCHIVE_QRCODES_LEGEND_BACK_KEY] = backLegendQRCodes
    archiveDict [ARCHIVE_INTERNAL_BOARDS_LIMITS_KEY] = internalBoardsLimits // DO NOT SORT
    archiveDict [ARCHIVE_COMPONENT_NAMES_BACK_KEY] = backComponentNames.sorted ()
    archiveDict [ARCHIVE_COMPONENT_NAMES_FRONT_KEY] = frontComponentNames.sorted ()
    archiveDict [ARCHIVE_COMPONENT_VALUES_BACK_KEY] = backComponentValues.sorted ()
    archiveDict [ARCHIVE_COMPONENT_VALUES_FRONT_KEY] = frontComponentValues.sorted ()
    archiveDict [ARCHIVE_PACKAGES_BACK_KEY] = backPackages.sorted ()
    archiveDict [ARCHIVE_PACKAGES_FRONT_KEY] = frontPackages.sorted ()
    archiveDict [ARCHIVE_LINES_BACK_KEY] = backLegendLines.sorted ()
    archiveDict [ARCHIVE_LINES_FRONT_KEY] = frontLegendLines.sorted ()
    archiveDict [ARCHIVE_PADS_FRONT_KEY] = frontPads
    archiveDict [ARCHIVE_PADS_BACK_KEY] = backPads
    archiveDict [ARCHIVE_TEXTS_LAYOUT_BACK_KEY] = backLayoutTexts.sorted ()
    archiveDict [ARCHIVE_TEXTS_LAYOUT_FRONT_KEY] = frontLayoutTexts.sorted ()
    archiveDict [ARCHIVE_TEXTS_LEGEND_BACK_KEY] = backLegendTexts.sorted ()
    archiveDict [ARCHIVE_TEXTS_LEGEND_FRONT_KEY] = frontLegendTexts.sorted ()
    archiveDict [ARCHIVE_TRACKS_BACK_KEY] = backTracks.sorted ()
    archiveDict [ARCHIVE_TRACKS_FRONT_KEY] = frontTracks.sorted ()
    archiveDict [ARCHIVE_FRONT_TRACKS_WITH_NO_SILK_SCREEN_KEY] = frontTracksNoSilkScreen.sorted ()
    archiveDict [ARCHIVE_BACK_TRACKS_WITH_NO_SILK_SCREEN_KEY] = backTracksNoSilkScreen.sorted ()
    archiveDict [ARCHIVE_VIAS_KEY] = vias.sorted ()
    archiveDict [ARCHIVE_DRILLS_KEY] = drills.sorted ()
  //--- Add version
    archiveDict [ARCHIVE_VERSION_KEY] = MERGER_ARCHIVE_VERSION
    // NSLog ("ARCHIVE \(archiveDict)")
  //--- Write file
    let data : Data = try PropertyListSerialization.data (
      fromPropertyList: archiveDict,
      format: .xml,
      options: 0
    )
    try data.write(to: URL (fileURLWithPath: inFilePath), options: .atomic)
  }

  //································································································

  fileprivate func generatePDFfiles (_ inProduct : ProductRepresentation,
                                     atPath inFilePath : String) throws {
    for descriptor in self.rootObject.mArtwork?.fileGenerationParameterArray.values ?? [] {
      let filePath = inFilePath + "." + descriptor.fileExtension + ".pdf"
      self.mLogTextView?.appendMessage ("Generating \(filePath.lastPathComponent)…")
      let mirror : ProductHorizontalMirror = descriptor.horizontalMirror
        ? .mirror (boardWidth: self.rootObject.boardWidth!)
        : .noMirror
      let pdfData = inProduct.pdf (
        items: descriptor.layerItems,
        mirror: mirror,
        backColor: self.rootObject.mPDFBoardBackgroundColor,
        grid: self.rootObject.mPDFProductGrid_property.propval
      )
      try pdfData.write (to: URL (fileURLWithPath: filePath), options: .atomic)
      self.mLogTextView?.appendSuccess (" Ok\n")
    }
  }

  //································································································

  fileprivate func generatePDFLegacyFiles (atPath inFilePath : String) throws {
    if let cocoaBoardRect : NSRect = self.rootObject.boardRect?.cocoaRect {
      let layerConfiguration = self.rootObject.mArtwork!.layerConfiguration
      let boardWidth = self.rootObject.boardWidth ?? 0
      for product in self.rootObject.mArtwork?.fileGenerationParameterArray.values ?? [] {
        let horizontalMirror = product.horizontalMirror
        let filePath = inFilePath + "." + product.fileExtension + ".pdf"
        self.mLogTextView?.appendMessage ("Generating \(filePath.lastPathComponent)…")
        var strokeBezierPaths = [EBBezierPath] ()
        var filledBezierPaths = [EBBezierPath] ()
        if product.drawInternalBoardLimits {
          for board in self.rootObject.boardInstances_property.propval.values {
            let lineWidth : CGFloat = canariUnitToCocoa (board.myModel!.modelLimitWidth)
            let r : NSRect = board.instanceRect!.cocoaRect.insetBy (dx: lineWidth / 2.0, dy: lineWidth / 2.0)
            var bp = EBBezierPath (rect:r)
            bp.lineWidth = lineWidth
            strokeBezierPaths.append (bp)
          }
        }
        if product.drawBoardLimits {
          let boardLineWidth = canariUnitToCocoa (self.rootObject.boardLimitWidth)
          var bp = EBBezierPath (rect: cocoaBoardRect)
          bp.lineWidth = boardLineWidth
          strokeBezierPaths.append (bp)
        }
        if product.drawComponentNamesTopSide {
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  = myModel?.modelWidth  ?? 0
            let modelHeight = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.frontComponentNameSegments?.add (toStrokeBezierPaths: &strokeBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawComponentNamesBottomSide {
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  = myModel?.modelWidth  ?? 0
            let modelHeight = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.backComponentNameSegments?.add (toStrokeBezierPaths: &strokeBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawComponentValuesTopSide {
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.frontComponentValueSegments?.add (toStrokeBezierPaths: &strokeBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawComponentValuesBottomSide {
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.backComponentValueSegments?.add (toStrokeBezierPaths: &strokeBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawPackageLegendTopSide {
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.frontPackagesSegments?.add (toStrokeBezierPaths: &strokeBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawPackageLegendBottomSide {
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.backPackagesSegments?.add (toStrokeBezierPaths: &strokeBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawPadsTopSide {
          for board in self.rootObject.boardInstances_property.propval.values {
            if let myModel : BoardModel = board.myModel_property.propval {
              let modelWidth  : Int = myModel.modelWidth
              let modelHeight : Int = myModel.modelHeight
              let instanceRotation = board.instanceRotation
              myModel.frontPadArray?.addPads (
                toFilledBezierPaths: &filledBezierPaths,
                dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
                modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation
              )
              myModel.frontTracksNoSilkScreen.values.addToStrokeBezierPaths (
                &strokeBezierPaths,
                dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
                modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation
              )
            }
          }
        }
        if product.drawTraversingPads && (layerConfiguration != .twoLayers) {
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.traversingPadArray?.addPads (toFilledBezierPaths: &filledBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawPadsBottomSide {
          for board in self.rootObject.boardInstances_property.propval.values {
            if let myModel : BoardModel = board.myModel_property.propval {
              let modelWidth  : Int = myModel.modelWidth
              let modelHeight : Int = myModel.modelHeight
              let instanceRotation = board.instanceRotation
              myModel.backPadArray?.addPads (toFilledBezierPaths: &filledBezierPaths,
                dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
                modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
              myModel.backTracksNoSilkScreen.values.addToStrokeBezierPaths (
                &strokeBezierPaths,
                dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
                modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation
              )
            }
          }
        }
        if product.drawTextsLayoutTopSide {
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.frontLayoutTextsSegments?.add (toStrokeBezierPaths: &strokeBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawTextsLayoutBottomSide {
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.backLayoutTextsSegments?.add (toStrokeBezierPaths: &strokeBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawTextsLegendTopSide {
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.frontLegendTextsSegments?.add (toStrokeBezierPaths: &strokeBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
            myModel?.frontLegendLinesSegments?.add (toStrokeBezierPaths: &strokeBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
            myModel?.frontLegendQRCodeRectangles?.addRectangles (toFilledBezierPaths: &filledBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
            myModel?.frontLegendBoardImageRectangles?.addRectangles (toFilledBezierPaths: &filledBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawTextsLegendBottomSide {
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.backLegendTextsSegments?.add (toStrokeBezierPaths: &strokeBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
            myModel?.backLegendLinesSegments?.add (toStrokeBezierPaths: &strokeBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
            myModel?.backLegendQRCodeRectangles?.addRectangles (toFilledBezierPaths: &filledBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
            myModel?.backLegendBoardImageRectangles?.addRectangles (toFilledBezierPaths: &filledBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawTracksTopSide {
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.frontTrackSegments?.add (toStrokeBezierPaths: &strokeBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawTracksInner1Layer && (layerConfiguration != .twoLayers) {
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.inner1TracksSegments?.add (toStrokeBezierPaths: &strokeBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawTracksInner2Layer && (layerConfiguration != .twoLayers) {
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.inner2TracksSegments?.add (toStrokeBezierPaths: &strokeBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawTracksInner3Layer && (layerConfiguration == .sixLayers) {
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.inner3TracksSegments?.add (toStrokeBezierPaths: &strokeBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawTracksInner4Layer && (layerConfiguration == .sixLayers) {
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.inner4TracksSegments?.add (toStrokeBezierPaths: &strokeBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawTracksBottomSide {
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.backTrackSegments?.add (toStrokeBezierPaths: &strokeBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawVias {
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.viaShapes?.addPad (toFilledBezierPaths: &filledBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        var drillBezierPaths = [EBBezierPath] ()
        if product.drawPadHolesInPDF {
          let pdfHoleDiameter : CGFloat = canariUnitToCocoa (product.padHoleDiameterInPDF)
          for board in self.rootObject.boardInstances_property.propval.values {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            if product.drawVias {
              myModel?.drillSegments?.addDrillForPDF (
                toStrokeBezierPaths: &drillBezierPaths,
                dx: board.x,
                dy: board.y,
                horizontalMirror: horizontalMirror,
                pdfDrillDiameter: pdfHoleDiameter,
                boardWidth: boardWidth,
                modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation
              )
            }
          }
        }
        var shape = EBShape ()
        shape.add (stroke: strokeBezierPaths, .black)
        shape.add (filled: filledBezierPaths, .black)
        shape.add (stroke: drillBezierPaths, .white)
        let pdfData = buildPDFimageData (frame: cocoaBoardRect, shape: shape, backgroundColor: self.rootObject.mPDFBoardBackgroundColor)
        try pdfData.write (to: URL (fileURLWithPath: filePath), options: .atomic)
        self.mLogTextView?.appendSuccess (" Ok\n")
      }
    }
  }

  //································································································

  fileprivate func writePDFDrillFile (_ inProduct : ProductRepresentation,
                                      atPath inFilePath : String) throws {
    let drillDataFileExtension = self.rootObject.mArtwork?.drillDataFileExtension ?? "??"
    let filePath = inFilePath + "." + drillDataFileExtension + ".pdf"
    self.mLogTextView?.appendMessage ("Generating \(filePath.lastPathComponent)…")
    let pdfData = inProduct.pdf (
      items: .hole,
      mirror: .noMirror,
      backColor: self.rootObject.mPDFBoardBackgroundColor,
      grid: self.rootObject.mPDFProductGrid_property.propval
    )
    try pdfData.write (to: URL (fileURLWithPath: filePath), options: .atomic)
    self.mLogTextView?.appendSuccess (" Ok\n")
  }

  //································································································

  fileprivate func writePDFLegacyDrillFile (atPath inFilePath : String) throws {
    if let cocoaBoardRect : NSRect = self.rootObject.boardRect?.cocoaRect {
      let drillDataFileExtension = self.rootObject.mArtwork?.drillDataFileExtension ?? "??"
      let filePath = inFilePath + "." + drillDataFileExtension + ".pdf"
      self.mLogTextView?.appendMessage ("Generating \(filePath.lastPathComponent)…")
      var drillBezierPaths = [EBBezierPath] ()
      for board in self.rootObject.boardInstances_property.propval.values {
        let myModel : BoardModel? = board.myModel_property.propval
        let modelWidth  : Int = myModel?.modelWidth  ?? 0
        let modelHeight : Int = myModel?.modelHeight ?? 0
        let instanceRotation = board.instanceRotation
        myModel?.drillSegments?.addDrillForPDF (
          toStrokeBezierPaths: &drillBezierPaths,
          dx: board.x,
          dy: board.y,
          modelWidth: modelWidth,
          modelHeight: modelHeight,
          instanceRotation: instanceRotation
        )
      }
      let shape = EBShape (stroke: drillBezierPaths, .black)
      let data = buildPDFimageData (frame: cocoaBoardRect, shape: shape, backgroundColor: self.rootObject.mPDFBoardBackgroundColor)
      try data.write (to: URL (fileURLWithPath: filePath))
      self.mLogTextView?.appendSuccess (" Ok\n")
    }
  }

  //································································································

  fileprivate func generateGerberFiles (_ inProduct : ProductRepresentation, atPath inFilePath : String) throws {
    for descriptor in self.rootObject.mArtwork?.fileGenerationParameterArray.values ?? [] {
      let filePath = inFilePath + "." + descriptor.fileExtension
      self.mLogTextView?.appendMessage ("Generating \(filePath.lastPathComponent)…")
      let mirror : ProductHorizontalMirror = descriptor.horizontalMirror
        ? .mirror (boardWidth: self.rootObject.boardWidth!)
        : .noMirror
      let gerberRepresentation = inProduct.gerber (
        items: descriptor.layerItems,
        mirror: mirror
      )
      let gerberString = gerberRepresentation.gerberString (unit: self.rootObject.mGerberProductUnit)
      let gerberData : Data? = gerberString.data (using: .ascii, allowLossyConversion: false)
      try gerberData?.write (to: URL (fileURLWithPath: filePath), options: .atomic)
      self.mLogTextView?.appendSuccess (" Ok\n")
    }
  //------------------------------------- Generate hole file
    let filePath = inFilePath + "." + (self.rootObject.mArtwork?.drillDataFileExtension ?? "??")
    self.mLogTextView?.appendMessage ("Generating \(filePath.lastPathComponent)…")
//    let gerberRepresentation = inProduct.gerber (
//      items: .hole,
//      mirror: .noMirror
//    )
//    let drillString = gerberRepresentation.gerberString (unit: self.rootObject.mGerberProductUnit)
    let drillString = inProduct.excellonDrillString (unit: self.rootObject.mGerberProductUnit)
    let drillData : Data? = drillString.data (using: .ascii, allowLossyConversion: false)
    try drillData?.write (to: URL (fileURLWithPath: filePath), options: .atomic)
    self.mLogTextView?.appendSuccess (" Ok\n")
  }

  //································································································

  fileprivate func generateLegacyGerberFiles (atPath inFilePath : String) throws {
    let boardWidth = self.rootObject.boardWidth!
    let layerConfiguration = self.rootObject.mArtwork!.layerConfiguration
    for product in self.rootObject.mArtwork?.fileGenerationParameterArray.values ?? [] {
      let horizontalMirror = product.horizontalMirror
      let filePath = inFilePath + "." + product.fileExtension
      self.mLogTextView?.appendMessage ("Generating \(filePath.lastPathComponent)…")
      var s = "%FSLAX24Y24*%\n" // A = Absolute coordinates, 24 = all data are in 2.4 form
      s += "%MOIN*%\n" // length unit is inch
      var apertureDictionary = [String : [String]] ()
      var polygons = [[String]] ()
      if product.drawInternalBoardLimits {
        for board in self.rootObject.boardInstances_property.propval.values {
          let lineWidth : Int = board.myModel_property.propval!.modelLimitWidth
          let r : CanariRect = board.instanceRect!
          let left  = canariUnitToMilTenth (r.left)
          let right = canariUnitToMilTenth (r.left + r.width)
          let bottom = canariUnitToMilTenth (r.bottom)
          let top = canariUnitToMilTenth (r.bottom + r.height)
          var drawings = [String] ()
          drawings.append ("X\( left)Y\(bottom)D02") // Move to
          drawings.append ("X\( left)Y\(   top)D01") // Line to
          drawings.append ("X\(right)Y\(   top)D01") // Line to
          drawings.append ("X\(right)Y\(bottom)D01") // Line to
          drawings.append ("X\( left)Y\(bottom)D01") // Line to
          let apertureString = "C,\(String(format: "%.4f", canariUnitToInch (lineWidth)))"
          if let array = apertureDictionary [apertureString] {
            apertureDictionary [apertureString] = array + drawings
          }else{
            apertureDictionary [apertureString] = drawings
          }
        }
      }
      if product.drawBoardLimits {
        let boardLineWidth = self.rootObject.boardLimitWidth
        let left = canariUnitToMilTenth (boardLineWidth / 2)
        let right = canariUnitToMilTenth (boardWidth + boardLineWidth / 2)
        let bottom = canariUnitToMilTenth (boardLineWidth / 2)
        let top = canariUnitToMilTenth (self.rootObject.boardHeight! + boardLineWidth / 2)
        var drawings = [String] ()
        drawings.append ("X\( left)Y\(bottom)D02") // Move to
        drawings.append ("X\( left)Y\(   top)D01") // Line to
        drawings.append ("X\(right)Y\(   top)D01") // Line to
        drawings.append ("X\(right)Y\(bottom)D01") // Line to
        drawings.append ("X\( left)Y\(bottom)D01") // Line to
        let apertureString = "C,\(String(format: "%.4f", canariUnitToInch (boardLineWidth)))"
        if let array = apertureDictionary [apertureString] {
          apertureDictionary [apertureString] = array + drawings
        }else{
          apertureDictionary [apertureString] = drawings
        }
      }
      if product.drawComponentNamesTopSide {
        for board in self.rootObject.boardInstances_property.propval.values {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  = myModel?.modelWidth  ?? 0
          let modelHeight = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.frontComponentNameSegments?.add (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        }
      }
      if product.drawComponentNamesBottomSide {
        for board in self.rootObject.boardInstances_property.propval.values {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  = myModel?.modelWidth  ?? 0
          let modelHeight = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.backComponentNameSegments?.add (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        }
      }
      if product.drawComponentValuesTopSide {
        for board in self.rootObject.boardInstances_property.propval.values {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.frontComponentValueSegments?.add (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        }
      }
      if product.drawComponentValuesBottomSide {
        for board in self.rootObject.boardInstances_property.propval.values {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.backComponentValueSegments?.add (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        }
      }
      if product.drawPackageLegendTopSide {
        for board in self.rootObject.boardInstances_property.propval.values {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.frontPackagesSegments?.add (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        }
      }
      if product.drawPackageLegendBottomSide {
        for board in self.rootObject.boardInstances_property.propval.values {
          if let myModel : BoardModel = board.myModel_property.propval {
            let modelWidth  : Int = myModel.modelWidth
            let modelHeight : Int = myModel.modelHeight
            let instanceRotation = board.instanceRotation
            myModel.backPackagesSegments?.add (toApertures: &apertureDictionary,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation
            )
          }
        }
      }
      if product.drawPadsTopSide {
        for board in self.rootObject.boardInstances_property.propval.values {
          if let myModel : BoardModel = board.myModel_property.propval {
            let modelWidth  : Int = myModel.modelWidth
            let modelHeight : Int = myModel.modelHeight
            let instanceRotation = board.instanceRotation
            myModel.frontPadArray?.addPads (
              toApertures: &apertureDictionary,
              toPolygones: &polygons,
              dx: board.x,
              dy: board.y,
              horizontalMirror: horizontalMirror,
              boardWidth: boardWidth,
              modelWidth: modelWidth,
              modelHeight: modelHeight,
              instanceRotation: instanceRotation
            )
            myModel.frontTracksNoSilkScreen.values.addToApertureDictionary (
              &apertureDictionary,
              dx: board.x,
              dy: board.y,
              horizontalMirror: horizontalMirror,
              boardWidth: boardWidth,
              modelWidth: modelWidth,
              modelHeight: modelHeight,
              instanceRotation: instanceRotation
            )
          }
        }
      }
      if product.drawTraversingPads && (layerConfiguration != .twoLayers) {
        for board in self.rootObject.boardInstances_property.propval.values {
          if let myModel : BoardModel = board.myModel_property.propval {
            let modelWidth  : Int = myModel.modelWidth
            let modelHeight : Int = myModel.modelHeight
            let instanceRotation = board.instanceRotation
            myModel.traversingPadArray?.addPads (
              toApertures: &apertureDictionary,
              toPolygones: &polygons,
              dx: board.x,
              dy: board.y,
              horizontalMirror: horizontalMirror,
              boardWidth: boardWidth,
              modelWidth: modelWidth,
              modelHeight: modelHeight,
              instanceRotation: instanceRotation
            )
          }
        }
      }
      if product.drawPadsBottomSide {
        for board in self.rootObject.boardInstances_property.propval.values {
          if let myModel : BoardModel = board.myModel_property.propval {
            let modelWidth  : Int = myModel.modelWidth
            let modelHeight : Int = myModel.modelHeight
            let instanceRotation = board.instanceRotation
            myModel.backPadArray?.addPads (
              toApertures: &apertureDictionary,
              toPolygones: &polygons,
              dx: board.x,
              dy: board.y,
              horizontalMirror:horizontalMirror,
              boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation
            )
            myModel.backTracksNoSilkScreen.values.addToApertureDictionary (
              &apertureDictionary,
              dx: board.x,
              dy: board.y,
              horizontalMirror: horizontalMirror,
              boardWidth: boardWidth,
              modelWidth: modelWidth,
              modelHeight: modelHeight,
              instanceRotation: instanceRotation
            )
          }
        }
      }
      if product.drawTextsLayoutTopSide {
        for board in self.rootObject.boardInstances_property.propval.values {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.frontLayoutTextsSegments?.add (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        }
      }
      if product.drawTextsLayoutBottomSide {
        for board in self.rootObject.boardInstances_property.propval.values {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.backLayoutTextsSegments?.add (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        }
      }
      if product.drawTextsLegendTopSide {
        for board in self.rootObject.boardInstances_property.propval.values {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.frontLegendTextsSegments?.add (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          myModel?.frontLegendLinesSegments?.add (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          myModel?.frontLegendQRCodeRectangles?.addPolygons (
            toPolygons: &polygons,
            dx: board.x,
            dy: board.y,
            horizontalMirror: horizontalMirror,
            boardWidth: boardWidth,
            modelWidth: modelWidth,
            modelHeight: modelHeight,
            instanceRotation: instanceRotation
          )
          myModel?.frontLegendBoardImageRectangles?.addPolygons (
            toPolygons: &polygons,
            dx: board.x,
            dy: board.y,
            horizontalMirror: horizontalMirror,
            boardWidth: boardWidth,
            modelWidth: modelWidth,
            modelHeight: modelHeight,
            instanceRotation: instanceRotation
          )
        }
      }
      if product.drawTextsLegendBottomSide {
        for board in self.rootObject.boardInstances_property.propval.values {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.backLegendTextsSegments?.add (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          myModel?.backLegendLinesSegments?.add (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          myModel?.backLegendQRCodeRectangles?.addPolygons (
            toPolygons: &polygons,
            dx: board.x,
            dy: board.y,
            horizontalMirror: horizontalMirror,
            boardWidth: boardWidth,
            modelWidth: modelWidth,
            modelHeight: modelHeight,
            instanceRotation: instanceRotation
          )
          myModel?.backLegendBoardImageRectangles?.addPolygons (
            toPolygons: &polygons,
            dx: board.x,
            dy: board.y,
            horizontalMirror: horizontalMirror,
            boardWidth: boardWidth,
            modelWidth: modelWidth,
            modelHeight: modelHeight,
            instanceRotation: instanceRotation
          )
        }
      }
      if product.drawTracksTopSide {
        for board in self.rootObject.boardInstances_property.propval.values {
          if let myModel : BoardModel = board.myModel_property.propval {
            let modelWidth  : Int = myModel.modelWidth
            let modelHeight : Int = myModel.modelHeight
            let instanceRotation = board.instanceRotation
            myModel.frontTrackSegments?.add (toApertures: &apertureDictionary,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation
            )
          }
        }
      }
      if product.drawTracksInner1Layer && (layerConfiguration != .twoLayers) {
        for board in self.rootObject.boardInstances_property.propval.values {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.inner1TracksSegments?.add (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        }
      }
      if product.drawTracksInner2Layer && (layerConfiguration != .twoLayers) {
        for board in self.rootObject.boardInstances_property.propval.values {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.inner2TracksSegments?.add (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        }
      }
      if product.drawTracksInner3Layer && (layerConfiguration == .sixLayers) {
        for board in self.rootObject.boardInstances_property.propval.values {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.inner3TracksSegments?.add (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        }
      }
      if product.drawTracksInner4Layer && (layerConfiguration == .sixLayers) {
        for board in self.rootObject.boardInstances_property.propval.values {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.inner4TracksSegments?.add (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        }
      }
      if product.drawTracksBottomSide {
        for board in self.rootObject.boardInstances_property.propval.values {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.backTrackSegments?.add (
            toApertures: &apertureDictionary,
            dx: board.x, dy: board.y,
            horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight,
            instanceRotation: instanceRotation
          )
        }
      }
      if product.drawVias {
        for board in self.rootObject.boardInstances_property.propval.values {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.viaShapes?.addPad (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        }
      }
      let keys = apertureDictionary.keys.sorted ()
    //--- Write aperture diameters
      var idx = 10
      for aperture in keys {
        s += "%ADD\(idx)\(aperture)*%\n"
        idx += 1
      }
    //--- Write drawings
      idx = 10
      for aperture in keys {
        s += "D\(idx)*\n"
        s += "G01" // Linear interpolation
        for element in apertureDictionary [aperture]! {
          s += element + "*\n"
        }
        idx += 1
      }
    //--- Write polygon fills
      for poly in polygons {
        s += "G36*\n"
        for str in poly {
          s += str + "*\n"
        }
        s += "G37*\n"
      }
    //--- Write file
      s += "M02*\n"
      let data : Data? = s.data (using: .ascii, allowLossyConversion:false)
      try data?.write (to: URL (fileURLWithPath: filePath), options: .atomic)
      self.mLogTextView?.appendSuccess (" Ok\n")
    }
//------------------------------------- Generate hole file
    let filePath = inFilePath + "." + (self.rootObject.mArtwork?.drillDataFileExtension ?? "??")
    self.mLogTextView?.appendMessage ("Generating \(filePath.lastPathComponent)…")
    var s = "M48\n"
    s += "INCH\n"
 //--- Array of hole diameters
    var holeDictionary = [Int : [(Int, Int, Int, Int)]] ()
    for board in self.rootObject.boardInstances_property.propval.values {
      let myModel : BoardModel? = board.myModel_property.propval
      let modelWidth  : Int = myModel?.modelWidth  ?? 0
      let modelHeight : Int = myModel?.modelHeight ?? 0
      let instanceRotation = board.instanceRotation
      myModel?.drillSegments?.enterDrills (array: &holeDictionary,
        dx: board.x, dy: board.y,
        modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
    }
    let keys = holeDictionary.keys.sorted ()
 //--- Write hole diameters
    var idx = 0
    for diameter in keys {
      idx += 1
      s += "T\(idx)C\(String(format: "%.4f", canariUnitToInch (diameter)))\n"
    }
 //--- Write holes
    s += "%\n"
    s += "G05\n"
    s += "M72\n"
    idx = 0
    for diameter in keys {
      idx += 1
      s += "T\(idx)\n"
      for (x1, y1, x2, y2) in holeDictionary [diameter]! {
        if (x1 == x2) && (y1 == y2) { // Circular
          s += "X\(String(format: "%.4f", canariUnitToInch (x1)))Y\(String(format: "%.4f", canariUnitToInch (y1)))\n"
        }else{ // oblong
          s += "X\(String(format: "%.4f", canariUnitToInch (x1)))Y\(String(format: "%.4f", canariUnitToInch (y1)))"
          s += "G85X\(String(format: "%.4f", canariUnitToInch (x2)))Y\(String(format: "%.4f", canariUnitToInch (y2)))\n"
        }
      }
    }
 //--- End of file
    s += "T0\n"
    s += "M30\n" // End code
 //--- Write file
    let data : Data? = s.data (using: .ascii, allowLossyConversion:false)
    try data?.write (to: URL (fileURLWithPath: filePath), options: .atomic)
    self.mLogTextView?.appendSuccess (" Ok\n")
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
