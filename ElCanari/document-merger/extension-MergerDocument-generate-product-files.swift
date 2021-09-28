//
//  extension-MergerDocument-generate-product-files.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension MergerDocument {

  //····················································································································

  final internal func checkLayerConfigurationAndGenerateProductFiles () {
  //--- Layout layer configuration
    var layerSet = Set <LayerConfiguration> ()
    if let artworkLayerConfiguration = self.rootObject.mArtwork?.layerConfiguration {
      layerSet.insert (artworkLayerConfiguration)
    }
    for boardModel in self.rootObject.boardModels {
      layerSet.insert (boardModel.layerConfiguration)
    }
  //---
    if layerSet.count < 2 {
      self.generateProductFiles ()
    }else{
      let alert = NSAlert ()
      alert.messageText = "Inconsistent Board models / Artwork layout layer configuration."
      var s = ""
      for layer in layerSet {
        if !s.isEmpty {
          s += ", "
        }
        switch layer {
        case  .twoLayers : s += "2"
        case .fourLayers : s += "4"
        case  .sixLayers : s += "6"
        }
      }
      alert.informativeText = "More than one layout layer configuration: \(s)."
      alert.addButton (withTitle: "Ok")
      alert.addButton (withTitle: "Cancel")
      alert.beginSheetModal (
        for: self.windowForSheet!,
        completionHandler: {(response : NSApplication.ModalResponse) in
          if response == .alertFirstButtonReturn { // Proceed anyway
            self.generateProductFiles ()
          }
        }
      )
    }
  }

  //····················································································································

  private func generateProductFiles () {
    do{
    //--- Create product directory
      if let f = self.fileURL?.path.deletingPathExtension {
        self.mLogTextView?.clear ()
        self.mProductGenerationTabView?.selectTabViewItem (at: 2)
        let baseName = f.lastPathComponent
        let productDirectory = f.deletingLastPathComponent
        let fm = FileManager ()
      //--- Generate board archive
        do{
          let boardArchivePath = productDirectory + "/" + baseName + "." + EL_CANARI_MERGER_ARCHIVE
          self.mLogTextView?.appendMessageString("Generating \(boardArchivePath.lastPathComponent)…")
          try self.generateBoardArchive (atPath: boardArchivePath)
          self.mLogTextView?.appendSuccessString (" Ok\n")
        }
      //--- Gerber
        do{
          let gerberDirectory = productDirectory + "/" + baseName + "-gerber"
          if !fm.fileExists (atPath: gerberDirectory) {
            self.mLogTextView?.appendMessageString("Creating \(gerberDirectory) directory…")
            try fm.createDirectory (atPath: gerberDirectory, withIntermediateDirectories: true, attributes: nil)
            self.mLogTextView?.appendSuccessString (" Ok\n")
          }
          let filePath = gerberDirectory + "/" + baseName
          try self.generateGerberFiles (atPath: filePath)
        }
      //--- PDF
        do{
          let pdfDirectory = productDirectory + "/" + baseName + "-pdf"
          if !fm.fileExists (atPath: pdfDirectory) {
            self.mLogTextView?.appendMessageString("Creating \(pdfDirectory) directory…")
            try fm.createDirectory (atPath: pdfDirectory, withIntermediateDirectories: true, attributes: nil)
            self.mLogTextView?.appendSuccessString (" Ok\n")
          }
          let filePath = pdfDirectory + "/" + baseName
          try self.generatePDFfiles (atPath: filePath)
          try self.writePDFDrillFile (atPath: filePath)
        }
      //--- Done !
        self.mLogTextView?.appendMessageString ("Done.")
      }
    }catch let error {
      self.windowForSheet?.presentError (error)
    }
  }

  //····················································································································

  fileprivate func generateBoardArchive (atPath inFilePath : String) throws {
    let archiveDict = NSMutableDictionary ()
  //---
    archiveDict ["ARTWORK"] = self.rootObject.mArtworkName
    archiveDict ["BOARD-HEIGHT"] = self.rootObject.boardHeight ?? 0
    archiveDict ["BOARD-HEIGHT-UNIT"] = self.rootObject.boardHeightUnit
    archiveDict ["BOARD-LINE-WIDTH"] = self.rootObject.boardLimitWidth
    archiveDict ["BOARD-LINE-WIDTH-UNIT"] = self.rootObject.boardLimitWidthUnit
    archiveDict ["BOARD-WIDTH"] = self.rootObject.boardWidth ?? 0
    archiveDict ["BOARD-WIDTH-UNIT"] = self.rootObject.boardWidthUnit
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
    var backTracks = [String] ()
    var inner1Tracks = [String] ()
    var inner2Tracks = [String] ()
    var inner3Tracks = [String] ()
    var inner4Tracks = [String] ()
    var frontTracks = [String] ()
    var backLegendLines = [String] ()
    var frontLegendLines = [String] ()
    var vias = [String] ()
    var frontPads = [[String : Any]] ()
    var traversingPads = [[String : Any]] ()
    var backPads = [[String : Any]] ()
    var drills = [String] ()
    for board in self.rootObject.boardInstances_property.propval {
      let myModel : BoardModel? = board.myModel_property.propval
      let modelWidth  = myModel?.modelWidth  ?? 0
      let modelHeight = myModel?.modelHeight ?? 0
      let instanceRotation = board.instanceRotation
      myModel?.boardLimitsSegments ().add (toArchiveArray: &internalBoardsLimits, dx: board.x, dy: board.y,
       modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
      myModel?.internalBoardsLimitsSegments?.add (toArchiveArray: &internalBoardsLimits, dx: board.x, dy: board.y,
       modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
      myModel?.backComponentNameSegments?.add (toArchiveArray: &backComponentNames, dx: board.x, dy: board.y,
       modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
      myModel?.frontComponentNameSegments?.add (toArchiveArray: &frontComponentNames, dx: board.x, dy: board.y,
       modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
      myModel?.backComponentValueSegments?.add (toArchiveArray: &backComponentValues, dx: board.x, dy: board.y,
       modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
      myModel?.frontComponentValueSegments?.add (toArchiveArray: &frontComponentValues, dx: board.x, dy: board.y,
       modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
      myModel?.backPackagesSegments?.add (toArchiveArray: &backPackages, dx: board.x, dy: board.y,
       modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
      myModel?.frontPackagesSegments?.add (toArchiveArray: &frontPackages, dx: board.x, dy: board.y,
       modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
      myModel?.backLayoutTextsSegments?.add (toArchiveArray: &backLayoutTexts, dx: board.x, dy: board.y,
       modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
      myModel?.frontLayoutTextsSegments?.add (toArchiveArray: &frontLayoutTexts, dx: board.x, dy: board.y,
       modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
      myModel?.backLegendTextsSegments?.add (toArchiveArray: &backLegendTexts, dx: board.x, dy: board.y,
       modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
      myModel?.frontLegendTextsSegments?.add (toArchiveArray: &frontLegendTexts, dx: board.x, dy: board.y,
       modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
      myModel?.backTrackSegments?.add (
        toArchiveArray: &backTracks,
        dx: board.x,
        dy: board.y,
        modelWidth: modelWidth,
        modelHeight: modelHeight,
        instanceRotation: instanceRotation
      )
      myModel?.inner1TracksSegments?.add (
        toArchiveArray: &inner1Tracks,
        dx: board.x,
        dy: board.y,
        modelWidth: modelWidth,
        modelHeight: modelHeight,
        instanceRotation: instanceRotation
      )
      myModel?.inner2TracksSegments?.add (
        toArchiveArray: &inner2Tracks,
        dx: board.x,
        dy: board.y,
        modelWidth: modelWidth,
        modelHeight: modelHeight,
        instanceRotation: instanceRotation
      )
      myModel?.inner3TracksSegments?.add (
        toArchiveArray: &inner3Tracks,
        dx: board.x,
        dy: board.y,
        modelWidth: modelWidth,
        modelHeight: modelHeight,
        instanceRotation: instanceRotation
      )
      myModel?.inner4TracksSegments?.add (
        toArchiveArray: &inner4Tracks,
        dx: board.x,
        dy: board.y,
        modelWidth: modelWidth,
        modelHeight: modelHeight,
        instanceRotation: instanceRotation
      )
      myModel?.frontTrackSegments?.add (
        toArchiveArray: &frontTracks,
        dx: board.x,
        dy: board.y,
        modelWidth: modelWidth,
        modelHeight: modelHeight,
        instanceRotation: instanceRotation
      )
      myModel?.backLegendLinesSegments?.add (toArchiveArray: &backLegendLines, dx: board.x, dy: board.y,
       modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
      myModel?.frontLegendLinesSegments?.add (toArchiveArray: &frontLegendLines, dx: board.x, dy: board.y,
       modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
      myModel?.drillSegments?.add (toArchiveArray: &drills, dx: board.x, dy: board.y,
       modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
      for via in myModel?.vias_property.propval.values ?? [] {
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
      for pad in myModel?.frontPads_property.propval.values ?? [] {
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
      for pad in myModel?.traversingPads_property.propval.values ?? [] {
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
      for pad in myModel?.backPads_property.propval.values ?? [] {
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
        archiveDict ["PADS-TRAVERSING"] = traversingPads // .sorted ()
        archiveDict ["TRACKS-INNER1"] = inner1Tracks.sorted ()
        archiveDict ["TRACKS-INNER2"] = inner2Tracks.sorted ()
      case .sixLayers :
        archiveDict ["PADS-TRAVERSING"] = traversingPads // .sorted ()
        archiveDict ["TRACKS-INNER1"] = inner1Tracks.sorted ()
        archiveDict ["TRACKS-INNER2"] = inner2Tracks.sorted ()
        archiveDict ["TRACKS-INNER3"] = inner3Tracks.sorted ()
        archiveDict ["TRACKS-INNER4"] = inner4Tracks.sorted ()
      }
    }
    archiveDict ["INTERNAL-BOARDS-LIMITS"] = internalBoardsLimits // DO NOT SORT
    archiveDict ["COMPONENT-NAMES-BACK"] = backComponentNames.sorted ()
    archiveDict ["COMPONENT-NAMES-FRONT"] = frontComponentNames.sorted ()
    archiveDict ["COMPONENT-VALUES-BACK"] = backComponentValues.sorted ()
    archiveDict ["COMPONENT-VALUES-FRONT"] = frontComponentValues.sorted ()
    archiveDict ["PACKAGES-BACK"] = backPackages.sorted ()
    archiveDict ["PACKAGES-FRONT"] = frontPackages.sorted ()
    archiveDict ["LINES-BACK"] = backLegendLines.sorted ()
    archiveDict ["LINES-FRONT"] = frontLegendLines.sorted ()
    archiveDict ["PADS-FRONT"] = frontPads // .sorted ()
    archiveDict ["PADS-BACK"] = backPads // .sorted ()
    archiveDict ["TEXTS-LAYOUT-BACK"] = backLayoutTexts.sorted ()
    archiveDict ["TEXTS-LAYOUT-FRONT"] = frontLayoutTexts.sorted ()
    archiveDict ["TEXTS-LEGEND-BACK"] = backLegendTexts.sorted ()
    archiveDict ["TEXTS-LEGEND-FRONT"] = frontLegendTexts.sorted ()
    archiveDict ["TRACKS-BACK"] = backTracks.sorted ()
    archiveDict ["TRACKS-FRONT"] = frontTracks.sorted ()
    archiveDict ["VIAS"] = vias.sorted ()
    archiveDict ["DRILLS"] = drills.sorted ()
    // NSLog ("ARCHIVE \(archiveDict)")
  //--- Write file
    let data : Data = try PropertyListSerialization.data (
      fromPropertyList: archiveDict,
      format: .xml,
      options: 0
    )
    try data.write(to: URL (fileURLWithPath: inFilePath), options: .atomic)
  }

  //····················································································································

  fileprivate func generatePDFfiles (atPath inFilePath : String) throws {
    if let cocoaBoardRect : NSRect = self.rootObject.boardRect?.cocoaRect {
      let layerConfiguration = self.rootObject.mArtwork!.layerConfiguration
      let boardWidth = self.rootObject.boardWidth ?? 0
      for product in self.rootObject.mArtwork_property.propval?.fileGenerationParameterArray_property.propval.values ?? [] {
        let horizontalMirror = product.horizontalMirror
        let filePath = inFilePath + "." + product.fileExtension + ".pdf"
        self.mLogTextView?.appendMessageString ("Generating \(filePath.lastPathComponent)…")
        var strokeBezierPaths = [EBBezierPath] ()
        var filledBezierPaths = [EBBezierPath] ()
        if product.drawInternalBoardLimits {
          for board in self.rootObject.boardInstances_property.propval {
            let lineWidth : CGFloat = canariUnitToCocoa (board.myModel_property.propval!.modelLimitWidth)
            let r : NSRect = board.instanceRect!.cocoaRect.insetBy (dx: lineWidth / 2.0, dy: lineWidth / 2.0)
            var bp = EBBezierPath (rect:r)
            bp.lineWidth = lineWidth
            strokeBezierPaths.append (bp)
          }
        }
        if product.drawBoardLimits {
          let boardLineWidth = canariUnitToCocoa (self.rootObject.boardLimitWidth)
          let r = cocoaBoardRect.insetBy (dx: boardLineWidth / 2.0, dy: boardLineWidth / 2.0)
          var bp = EBBezierPath (rect:r)
          bp.lineWidth = boardLineWidth
          strokeBezierPaths.append (bp)
        }
        if product.drawComponentNamesTopSide {
          for board in self.rootObject.boardInstances_property.propval {
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
          for board in self.rootObject.boardInstances_property.propval {
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
          for board in self.rootObject.boardInstances_property.propval {
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
          for board in self.rootObject.boardInstances_property.propval {
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
          for board in self.rootObject.boardInstances_property.propval {
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
          for board in self.rootObject.boardInstances_property.propval {
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
          for board in self.rootObject.boardInstances_property.propval {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.frontPadArray?.addPads (toFilledBezierPaths: &filledBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawTraversingPads && (layerConfiguration != .twoLayers) {
          for board in self.rootObject.boardInstances_property.propval {
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
          for board in self.rootObject.boardInstances_property.propval {
            let myModel : BoardModel? = board.myModel_property.propval
            let modelWidth  : Int = myModel?.modelWidth  ?? 0
            let modelHeight : Int = myModel?.modelHeight ?? 0
            let instanceRotation = board.instanceRotation
            myModel?.backPadArray?.addPads (toFilledBezierPaths: &filledBezierPaths,
              dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
              modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
          }
        }
        if product.drawTextsLayoutTopSide {
          for board in self.rootObject.boardInstances_property.propval {
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
          for board in self.rootObject.boardInstances_property.propval {
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
          for board in self.rootObject.boardInstances_property.propval {
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
          }
        }
        if product.drawTextsLegendBottomSide {
          for board in self.rootObject.boardInstances_property.propval {
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
          }
        }
        if product.drawTracksTopSide {
          for board in self.rootObject.boardInstances_property.propval {
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
          for board in self.rootObject.boardInstances_property.propval {
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
          for board in self.rootObject.boardInstances_property.propval {
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
          for board in self.rootObject.boardInstances_property.propval {
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
          for board in self.rootObject.boardInstances_property.propval {
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
          for board in self.rootObject.boardInstances_property.propval {
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
          for board in self.rootObject.boardInstances_property.propval {
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
          for board in self.rootObject.boardInstances_property.propval {
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
        self.mLogTextView?.appendSuccessString (" Ok\n")
      }
    }
  }

  //····················································································································

  fileprivate func writePDFDrillFile (atPath inFilePath : String) throws {
    if let cocoaBoardRect : NSRect = self.rootObject.boardRect?.cocoaRect {
      let boardWidth = self.rootObject.boardWidth ?? 0
      let drillDataFileExtension = self.rootObject.mArtwork_property.propval?.drillDataFileExtension ?? "??"
      let filePath = inFilePath + "." + drillDataFileExtension + ".pdf"
      self.mLogTextView?.appendMessageString ("Generating \(filePath.lastPathComponent)…")
      var drillBezierPaths = [EBBezierPath] ()
      for board in self.rootObject.boardInstances_property.propval {
        let myModel : BoardModel? = board.myModel_property.propval
        let modelWidth  : Int = myModel?.modelWidth  ?? 0
        let modelHeight : Int = myModel?.modelHeight ?? 0
        let instanceRotation = board.instanceRotation
        myModel?.drillSegments?.addDrillForPDF (
          toStrokeBezierPaths: &drillBezierPaths,
          dx: board.x,
          dy: board.y,
          boardWidth: boardWidth,
          modelWidth: modelWidth,
          modelHeight: modelHeight,
          instanceRotation: instanceRotation
        )
      }
      let shape = EBShape (stroke: drillBezierPaths, .black)
      let data = buildPDFimageData (frame: cocoaBoardRect, shape: shape, backgroundColor: self.rootObject.mPDFBoardBackgroundColor)
      try data.write (to: URL (fileURLWithPath: filePath))
      self.mLogTextView?.appendSuccessString (" Ok\n")
    }
  }

  //····················································································································

  fileprivate func generateGerberFiles (atPath inFilePath : String) throws {
    let boardWidth = self.rootObject.boardWidth!
    let layerConfiguration = self.rootObject.mArtwork!.layerConfiguration
    for product in self.rootObject.mArtwork_property.propval?.fileGenerationParameterArray_property.propval.values ?? [] {
      let horizontalMirror = product.horizontalMirror
      let filePath = inFilePath + "." + product.fileExtension
      self.mLogTextView?.appendMessageString ("Generating \(filePath.lastPathComponent)…")
      var s = "%FSLAX24Y24*%\n" // A = Absolute coordinates, 24 = all data are in 2.4 form
      s += "%MOIN*%\n" // length unit is inch
      var apertureDictionary = [String : [String]] ()
      var polygons = [[String]] ()
      let minimumApertureMilTenth = canariUnitToMilTenth (self.rootObject.mArtwork_property.propval!.minPPTPTTTW)
      if product.drawInternalBoardLimits {
        for board in self.rootObject.boardInstances_property.propval {
          let lineWidth : Int = board.myModel_property.propval!.modelLimitWidth
          let r : CanariRect = board.instanceRect!
          let left  = canariUnitToMilTenth (r.left + lineWidth / 2)
          let right = canariUnitToMilTenth (r.left + r.width - lineWidth / 2)
          let bottom = canariUnitToMilTenth (r.bottom + lineWidth / 2)
          let top = canariUnitToMilTenth (r.bottom + r.height - lineWidth / 2)
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
        let right = canariUnitToMilTenth (boardWidth - boardLineWidth / 2)
        let bottom = canariUnitToMilTenth (boardLineWidth / 2)
        let top = canariUnitToMilTenth (self.rootObject.boardHeight! - boardLineWidth / 2)
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
        for board in self.rootObject.boardInstances_property.propval {
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
        for board in self.rootObject.boardInstances_property.propval {
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
        for board in self.rootObject.boardInstances_property.propval {
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
        for board in self.rootObject.boardInstances_property.propval {
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
        for board in self.rootObject.boardInstances_property.propval {
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
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.backPackagesSegments?.add (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        }
      }
      if product.drawPadsTopSide {
        // Swift.print ("drawPadsTopSide")
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.frontPadArray?.addPads (
            toApertures: &apertureDictionary,
            toPolygones: &polygons,
            dx: board.x,
            dy: board.y,
            horizontalMirror: horizontalMirror,
            minimumAperture: minimumApertureMilTenth,
            boardWidth: boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation
          )
        }
      }
      if product.drawTraversingPads && (layerConfiguration != .twoLayers) {
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.traversingPadArray?.addPads (
            toApertures: &apertureDictionary,
            toPolygones: &polygons,
            dx: board.x,
            dy: board.y,
            horizontalMirror:horizontalMirror,
            minimumAperture: minimumApertureMilTenth,
            boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation
          )
        }
      }
      if product.drawPadsBottomSide {
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.backPadArray?.addPads (
            toApertures: &apertureDictionary,
            toPolygones: &polygons,
            dx: board.x,
            dy: board.y,
            horizontalMirror:horizontalMirror,
            minimumAperture: minimumApertureMilTenth,
            boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation
          )
        }
      }
      if product.drawTextsLayoutTopSide {
        for board in self.rootObject.boardInstances_property.propval {
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
        for board in self.rootObject.boardInstances_property.propval {
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
        for board in self.rootObject.boardInstances_property.propval {
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
        }
      }
      if product.drawTextsLegendBottomSide {
        for board in self.rootObject.boardInstances_property.propval {
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
        }
      }
      if product.drawTracksTopSide {
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.frontTrackSegments?.add (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        }
      }
      if product.drawTracksInner1Layer && (layerConfiguration != .twoLayers) {
        for board in self.rootObject.boardInstances_property.propval {
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
        for board in self.rootObject.boardInstances_property.propval {
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
        for board in self.rootObject.boardInstances_property.propval {
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
        for board in self.rootObject.boardInstances_property.propval {
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
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          let modelWidth  : Int = myModel?.modelWidth  ?? 0
          let modelHeight : Int = myModel?.modelHeight ?? 0
          let instanceRotation = board.instanceRotation
          myModel?.backTrackSegments?.add (toApertures: &apertureDictionary,
            dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth,
            modelWidth: modelWidth, modelHeight: modelHeight, instanceRotation: instanceRotation)
        }
      }
      if product.drawVias {
        for board in self.rootObject.boardInstances_property.propval {
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
      self.mLogTextView?.appendSuccessString (" Ok\n")
    }
//------------------------------------- Generate hole file
    let filePath = inFilePath + "." + (self.rootObject.mArtwork_property.propval?.drillDataFileExtension ?? "??")
    self.mLogTextView?.appendMessageString ("Generating \(filePath.lastPathComponent)…")
    var s = "M48\n"
    s += "INCH\n"
 //--- Array of hole diameters
    var holeDictionary = [Int : [(Int, Int, Int, Int)]] ()
    for board in self.rootObject.boardInstances_property.propval {
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
    self.mLogTextView?.appendSuccessString (" Ok\n")
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
