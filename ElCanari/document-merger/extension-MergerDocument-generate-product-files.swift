//
//  extension-MergerDocument-generate-product-files.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/07/2018.
//
//
import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension MergerDocument {

  //····················································································································

  func generateProductFiles () {
    do{
    //--- Create product directory
      if let productDirectory = self.fileURL?.path.deletingPathExtension {
        mLogTextView?.clear ()
        let baseName = productDirectory.lastPathComponent
        let fm = FileManager ()
      //--- Library directory
        if !fm.fileExists (atPath: productDirectory) {
          mLogTextView?.appendMessageString("Creating \(productDirectory) directory…")
          try fm.createDirectory (atPath: productDirectory, withIntermediateDirectories:true, attributes:nil)
          mLogTextView?.appendSuccessString (" Ok\n")
        }
      //--- Generate board archive
        if self.rootObject.generatedBoardArchiveFormat != .noGeneration {
          let boardArchivePath = productDirectory + "/" + baseName + ".ElCanariBoardArchive"
          mLogTextView?.appendMessageString("Generating \(boardArchivePath.lastPathComponent)…")
          try generateBoardArchive (atPath:boardArchivePath)
          mLogTextView?.appendSuccessString (" Ok\n")
        }
      //--- Generate Gerber files
        if self.rootObject.generateGerberProductFile {
          let filePath = productDirectory + "/" + baseName
          try generateGerberFiles (atPath:filePath)
        }
      //--- Generate PDF files
        if self.rootObject.generatePDFProductFile {
          let filePath = productDirectory + "/" + baseName
          try generatePDFfiles (atPath:filePath)
        }
      }
    }catch let error {
      self.windowForSheet?.presentError (error)
    }
  }

  //····················································································································

  fileprivate func generateBoardArchive (atPath inFilePath : String) throws {
    let archiveDict = NSMutableDictionary ()
  //---
    archiveDict ["ARTWORK"] = self.rootObject.artworkName
    archiveDict ["BOARD-HEIGHT"] = self.rootObject.boardHeight ?? 0
    archiveDict ["BOARD-HEIGHT-UNIT"] = self.rootObject.boardHeightUnit
    archiveDict ["BOARD-LINE-WIDTH"] = self.rootObject.boardLimitWidth
    archiveDict ["BOARD-LINE-WIDTH-UNIT"] = self.rootObject.boardLimitWidthUnit
    archiveDict ["BOARD-WIDTH"] = self.rootObject.boardWidth ?? 0
    archiveDict ["BOARD-WIDTH-UNIT"] = self.rootObject.boardWidthUnit
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
    var frontTracks = [String] ()
    var backLegendLines = [String] ()
    var frontLegendLines = [String] ()
    var vias = [String] ()
    var pads = [NSDictionary] ()
    for board in self.rootObject.boardInstances_property.propval {
      let myModel : BoardModel? = board.myModel_property.propval
      myModel?.backComponentNameSegments?.add (toArchiveArray: &backComponentNames, dx: board.x, dy: board.y)
      myModel?.frontComponentNameSegments?.add (toArchiveArray: &frontComponentNames, dx: board.x, dy: board.y)
      myModel?.backComponentValueSegments?.add (toArchiveArray: &backComponentValues, dx: board.x, dy: board.y)
      myModel?.frontComponentValueSegments?.add (toArchiveArray: &frontComponentValues, dx: board.x, dy: board.y)
      myModel?.backPackagesSegments?.add (toArchiveArray: &backPackages, dx: board.x, dy: board.y)
      myModel?.frontPackagesSegments?.add (toArchiveArray: &frontPackages, dx: board.x, dy: board.y)
      myModel?.backLayoutTextsSegments?.add (toArchiveArray: &backLayoutTexts, dx: board.x, dy: board.y)
      myModel?.frontLayoutTextsSegments?.add (toArchiveArray: &frontLayoutTexts, dx: board.x, dy: board.y)
      myModel?.backLegendTextsSegments?.add (toArchiveArray: &backLegendTexts, dx: board.x, dy: board.y)
      myModel?.frontLegendTextsSegments?.add (toArchiveArray: &frontLegendTexts, dx: board.x, dy: board.y)
      myModel?.backTrackSegments?.add (toArchiveArray: &backTracks, dx: board.x, dy: board.y)
      myModel?.frontTrackSegments?.add (toArchiveArray: &frontTracks, dx: board.x, dy: board.y)
      myModel?.backLegendLinesSegments?.add (toArchiveArray: &backLegendLines, dx: board.x, dy: board.y)
      myModel?.frontLegendLinesSegments?.add (toArchiveArray: &frontLegendLines, dx: board.x, dy: board.y)
      for via in myModel?.vias_property.propval ?? [] {
        vias.append ("\(via.x) \(via.y) \(via.padDiameter) \(via.holeDiameter)")
      }
      for pad in myModel?.pads_property.propval ?? [] {
        let d = NSMutableDictionary ()
        d ["HEIGHT"] = pad.height
        d ["HOLE-DIAMETER"] = pad.holeDiameter
        d ["QUALIFIED-NAME"] = pad.qualifiedName
        d ["ROTATION"] = pad.rotation
        switch pad.shape {
        case .rectangular :
          d ["SHAPE"] = "RECT"
        case .round :
          d ["SHAPE"] = "ROUND"
        }
        switch pad.side {
        case .traversing :
          d ["SIDE"] = "TRAVERSING"
        case .front :
          d ["SIDE"] = "FRONT"
        case .back :
          d ["SIDE"] = "BACK"
        }
        d ["WIDTH"] = pad.width
        d ["X"] = pad.x
        d ["Y"] = pad.y
        pads.append (d)
      }
    }
    archiveDict ["COMPONENT-NAMES-BACK"] = backComponentNames
    archiveDict ["COMPONENT-NAMES-FRONT"] = frontComponentNames
    archiveDict ["COMPONENT-VALUES-BACK"] = backComponentValues
    archiveDict ["COMPONENT-VALUES-FRONT"] = frontComponentValues
    archiveDict ["PACKAGES-BACK"] = backPackages
    archiveDict ["PACKAGES-FRONT"] = frontPackages
    archiveDict ["LINES-BACK"] = backLegendLines
    archiveDict ["LINES-FRONT"] = frontLegendLines
    archiveDict ["PADS"] = pads
    archiveDict ["TEXTS-LAYOUT-BACK"] = backLayoutTexts
    archiveDict ["TEXTS-LAYOUT-FRONT"] = frontLayoutTexts
    archiveDict ["TEXTS-LEGEND-BACK"] = backLegendTexts
    archiveDict ["TEXTS-LEGEND-FRONT"] = frontLegendTexts
    archiveDict ["TRACKS-BACK"] = backTracks
    archiveDict ["TRACKS-FRONT"] = frontTracks
    archiveDict ["VIAS"] = vias
    // NSLog ("ARCHIVE \(archiveDict)")
  //--- Write file
    let data : Data = try PropertyListSerialization.data (
      fromPropertyList: archiveDict,
      format: (self.rootObject.generatedBoardArchiveFormat == .xml) ? .xml : .binary,
      options: 0
    )
    try data.write(to: URL (fileURLWithPath: inFilePath), options: .atomic)
  }

  //····················································································································

  fileprivate func generatePDFfiles (atPath inFilePath : String) throws {
    if let cocoaBoardRect : NSRect = self.rootObject.boardRect?.cocoaRect () {
      let boardWidth = self.rootObject.boardWidth ?? 0
      for product in self.rootObject.artwork_property.propval?.fileGenerationParameterArray_property.propval ?? [] {
        let horizontalMirror = product.horizontalMirror
        let filePath = inFilePath + "." + product.fileExtension + ".pdf"
        mLogTextView?.appendMessageString ("Generating \(filePath.lastPathComponent)…")
        var strokeBezierPaths = [NSBezierPath] ()
        var filledBezierPaths = [NSBezierPath] ()
        if product.drawBoardLimits {
          let boardLineWidth = canariUnitToCocoa (self.rootObject.boardLimitWidth)
          let r = cocoaBoardRect.insetBy (dx: boardLineWidth / 2.0, dy: boardLineWidth / 2.0)
          let bp = NSBezierPath (rect:r)
          bp.lineWidth = boardLineWidth
          strokeBezierPaths.append (bp)
        }
        if product.drawComponentNamesTopSide {
          for board in self.rootObject.boardInstances_property.propval {
            let myModel : BoardModel? = board.myModel_property.propval
            myModel?.frontComponentNameSegments?.add (toStrokeBezierPaths: &strokeBezierPaths, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
          }
        }
        if product.drawComponentNamesBottomSide {
          for board in self.rootObject.boardInstances_property.propval {
            let myModel : BoardModel? = board.myModel_property.propval
            myModel?.backComponentNameSegments?.add (toStrokeBezierPaths: &strokeBezierPaths, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
          }
        }
        if product.drawComponentValuesTopSide {
          for board in self.rootObject.boardInstances_property.propval {
            let myModel : BoardModel? = board.myModel_property.propval
            myModel?.frontComponentValueSegments?.add (toStrokeBezierPaths: &strokeBezierPaths, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
          }
        }
        if product.drawComponentValuesBottomSide {
          for board in self.rootObject.boardInstances_property.propval {
            let myModel : BoardModel? = board.myModel_property.propval
            myModel?.backComponentValueSegments?.add (toStrokeBezierPaths: &strokeBezierPaths, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
          }
        }
        if product.drawPackageLegendTopSide {
          for board in self.rootObject.boardInstances_property.propval {
            let myModel : BoardModel? = board.myModel_property.propval
            myModel?.frontPackagesSegments?.add (toStrokeBezierPaths: &strokeBezierPaths, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
          }
        }
        if product.drawPackageLegendBottomSide {
          for board in self.rootObject.boardInstances_property.propval {
            let myModel : BoardModel? = board.myModel_property.propval
            myModel?.backPackagesSegments?.add (toStrokeBezierPaths: &strokeBezierPaths, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
          }
        }
        if product.drawPadsTopSide {
          for board in self.rootObject.boardInstances_property.propval {
            let myModel : BoardModel? = board.myModel_property.propval
            myModel?.frontPads?.addPads (toFilledBezierPaths: &filledBezierPaths, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
          }
        }
        if product.drawPadsBottomSide {
          for board in self.rootObject.boardInstances_property.propval {
            let myModel : BoardModel? = board.myModel_property.propval
            myModel?.backPads?.addPads (toFilledBezierPaths: &filledBezierPaths, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
          }
        }
        if product.drawTextsLayoutTopSide {
          for board in self.rootObject.boardInstances_property.propval {
            let myModel : BoardModel? = board.myModel_property.propval
            myModel?.frontLayoutTextsSegments?.add (toStrokeBezierPaths: &strokeBezierPaths, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
          }
        }
        if product.drawTextsLayoutBottomSide {
          for board in self.rootObject.boardInstances_property.propval {
            let myModel : BoardModel? = board.myModel_property.propval
            myModel?.backLayoutTextsSegments?.add (toStrokeBezierPaths: &strokeBezierPaths, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
          }
        }
        if product.drawTextsLegendTopSide {
          for board in self.rootObject.boardInstances_property.propval {
            let myModel : BoardModel? = board.myModel_property.propval
            myModel?.frontLegendTextsSegments?.add (toStrokeBezierPaths: &strokeBezierPaths, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
            myModel?.frontLegendLinesSegments?.add (toStrokeBezierPaths: &strokeBezierPaths, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
          }
        }
        if product.drawTextsLegendBottomSide {
          for board in self.rootObject.boardInstances_property.propval {
            let myModel : BoardModel? = board.myModel_property.propval
            myModel?.backLegendTextsSegments?.add (toStrokeBezierPaths: &strokeBezierPaths, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
            myModel?.backLegendLinesSegments?.add (toStrokeBezierPaths: &strokeBezierPaths, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
          }
        }
        if product.drawTracksTopSide {
          for board in self.rootObject.boardInstances_property.propval {
            let myModel : BoardModel? = board.myModel_property.propval
            myModel?.frontTrackSegments?.add (toStrokeBezierPaths: &strokeBezierPaths, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
          }
        }
        if product.drawTracksBottomSide {
          for board in self.rootObject.boardInstances_property.propval {
            let myModel : BoardModel? = board.myModel_property.propval
            myModel?.backTrackSegments?.add (toStrokeBezierPaths: &strokeBezierPaths, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
          }
        }
        if product.drawVias {
          for board in self.rootObject.boardInstances_property.propval {
            let myModel : BoardModel? = board.myModel_property.propval
            myModel?.viaShapes?.addPad (toFilledBezierPaths: &filledBezierPaths, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
          }
        }
        var holeBezierPaths = [NSBezierPath] ()
        if product.drawPadHolesInPDF {
          let pdfHoleDiameter : CGFloat = canariUnitToCocoa (product.padHoleDiameterInPDF)
          for board in self.rootObject.boardInstances_property.propval {
            let myModel : BoardModel? = board.myModel_property.propval
            if product.drawVias {
              myModel?.viaShapes?.addHole (
                toFilledBezierPaths: &holeBezierPaths,
                dx: board.x,
                dy: board.y,
                pdfHoleDiameter: pdfHoleDiameter,
                horizontalMirror: horizontalMirror,
                boardWidth: boardWidth
              )
            }
            if product.drawPadsTopSide {
              for board in self.rootObject.boardInstances_property.propval {
                let myModel : BoardModel? = board.myModel_property.propval
                myModel?.frontPads?.addHoles (
                  toFilledBezierPaths: &holeBezierPaths,
                  dx: board.x,
                  dy: board.y,
                  pdfHoleDiameter: pdfHoleDiameter,
                  horizontalMirror:horizontalMirror,
                  boardWidth:boardWidth
                )
              }
            }
            if product.drawPadsBottomSide {
              for board in self.rootObject.boardInstances_property.propval {
                let myModel : BoardModel? = board.myModel_property.propval
                myModel?.backPads?.addHoles (
                  toFilledBezierPaths: &holeBezierPaths,
                  dx: board.x,
                  dy: board.y,
                  pdfHoleDiameter: pdfHoleDiameter,
                  horizontalMirror:horizontalMirror,
                  boardWidth:boardWidth
                )
              }
            }
          }
        }
        let view = CanariOffscreenView (frame: cocoaBoardRect)
        let paths : [([NSBezierPath], NSColor, StrokeOrFill)] = [
          (strokeBezierPaths, NSColor.black, .stroke),
          (filledBezierPaths, NSColor.black, .fill),
          (holeBezierPaths, NSColor.white, .fill)
        ]
        view.setPaths (paths)
        let pdfData : Data = view.dataWithPDF (inside: cocoaBoardRect)
        try pdfData.write (to: URL (fileURLWithPath: filePath), options: .atomic)
        mLogTextView?.appendSuccessString (" Ok\n")
      }
    }
  }

  //····················································································································

  fileprivate func generateGerberFiles (atPath inFilePath : String) throws {
    let boardWidth = self.rootObject.boardWidth!
    for product in self.rootObject.artwork_property.propval?.fileGenerationParameterArray_property.propval ?? [] {
      let horizontalMirror = product.horizontalMirror
      let filePath = inFilePath + "." + product.fileExtension
      mLogTextView?.appendMessageString ("Generating \(filePath.lastPathComponent)…")
      // var s = "G70*\n" // length unit is inch [OBSOLETE]
      //s += "%FSAX24Y24*%\n" // [missing L] A = Absolute coordinates, 24 = all data are in 2.4 form
      var s = "%FSLAX24Y24*%\n" // A = Absolute coordinates, 24 = all data are in 2.4 form
      s += "%MOIN*%\n" // length unit is inch
      var apertureDictionary = [String : [String]] ()
      var polygons = [[String]] ()
      let minimumApertureMilTenth = canariUnitToMilTenth (self.rootObject.artwork_property.propval!.minPP_TP_TT_TW_inEBUnit)
      if product.drawBoardLimits {
        let boardLineWidthMilTenth = canariUnitToMilTenth (self.rootObject.boardLimitWidth)
        let left = boardLineWidthMilTenth / 2
        let right = canariUnitToMilTenth (boardWidth - boardLineWidthMilTenth / 2)
        let bottom = boardLineWidthMilTenth / 2
        let top = canariUnitToMilTenth (self.rootObject.boardHeight! - boardLineWidthMilTenth / 2)
        var drawings = [String] ()
        drawings.append ("X\(String(format: "%06d",  left))Y\(String(format: "%06d", bottom))D02") // Move to
        drawings.append ("X\(String(format: "%06d",  left))Y\(String(format: "%06d",    top))D01") // Line to
        drawings.append ("X\(String(format: "%06d", right))Y\(String(format: "%06d",    top))D01") // Line to
        drawings.append ("X\(String(format: "%06d", right))Y\(String(format: "%06d", bottom))D01") // Line to
        drawings.append ("X\(String(format: "%06d",  left))Y\(String(format: "%06d", bottom))D01") // Line to
        let apertureString = "C,\(String(format: "%.4f", CGFloat (boardLineWidthMilTenth) / 10_000.0)))"
        if let array = apertureDictionary [apertureString] {
          apertureDictionary [apertureString] = array + drawings
        }else{
          apertureDictionary [apertureString] = drawings
        }
      }
      if product.drawComponentNamesTopSide {
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          myModel?.frontComponentNameSegments?.add (toApertures: &apertureDictionary, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
        }
      }
      if product.drawComponentNamesBottomSide {
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          myModel?.backComponentNameSegments?.add (toApertures: &apertureDictionary, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
        }
      }
      if product.drawComponentValuesTopSide {
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          myModel?.frontComponentValueSegments?.add (toApertures: &apertureDictionary, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
        }
      }
      if product.drawComponentValuesBottomSide {
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          myModel?.backComponentValueSegments?.add (toApertures: &apertureDictionary, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
        }
      }
      if product.drawPackageLegendTopSide {
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          myModel?.frontPackagesSegments?.add (toApertures: &apertureDictionary, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
        }
      }
      if product.drawPackageLegendBottomSide {
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          myModel?.backPackagesSegments?.add (toApertures: &apertureDictionary, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
        }
      }
      if product.drawPadsTopSide {
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          myModel?.frontPads?.addPads (
            toApertures: &apertureDictionary,
            toPolygones: &polygons,
            dx: board.x,
            dy: board.y,
            horizontalMirror: horizontalMirror,
            minimumAperture: minimumApertureMilTenth,
            boardWidth: boardWidth
          )
        }
      }
      if product.drawPadsBottomSide {
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          myModel?.backPads?.addPads (
            toApertures: &apertureDictionary,
            toPolygones: &polygons,
            dx: board.x,
            dy: board.y,
            horizontalMirror:horizontalMirror,
            minimumAperture: minimumApertureMilTenth,
            boardWidth:boardWidth
          )
        }
      }
      if product.drawTextsLayoutTopSide {
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          myModel?.frontLayoutTextsSegments?.add (toApertures: &apertureDictionary, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
        }
      }
      if product.drawTextsLayoutBottomSide {
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          myModel?.backLayoutTextsSegments?.add (toApertures: &apertureDictionary, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
        }
      }
      if product.drawTextsLegendTopSide {
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          myModel?.frontLegendTextsSegments?.add (toApertures: &apertureDictionary, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
          myModel?.frontLegendLinesSegments?.add (toApertures: &apertureDictionary, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
        }
      }
      if product.drawTextsLegendBottomSide {
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          myModel?.backLegendTextsSegments?.add (toApertures: &apertureDictionary, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
          myModel?.backLegendLinesSegments?.add (toApertures: &apertureDictionary, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
        }
      }
      if product.drawTracksTopSide {
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          myModel?.frontTrackSegments?.add (toApertures: &apertureDictionary, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
        }
      }
      if product.drawTracksBottomSide {
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          myModel?.backTrackSegments?.add (toApertures: &apertureDictionary, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
        }
      }
      if product.drawVias {
        for board in self.rootObject.boardInstances_property.propval {
          let myModel : BoardModel? = board.myModel_property.propval
          myModel?.viaShapes?.addPad (toApertures: &apertureDictionary, dx: board.x, dy: board.y, horizontalMirror:horizontalMirror, boardWidth:boardWidth)
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
      mLogTextView?.appendSuccessString (" Ok\n")
    }
//------------------------------------- Generate hole file
    let filePath = inFilePath + "." + (self.rootObject.artwork_property.propval?.drillDataFileExtension ?? "??")
    mLogTextView?.appendMessageString ("Generating \(filePath.lastPathComponent)…")
    var s = "M48\n"
    s += "INCH\n"
 //--- Array of hole diameters
    var holeDictionary = [Int : [(Int, Int)]] ()
    for board in self.rootObject.boardInstances_property.propval {
      let myModel : BoardModel? = board.myModel_property.propval
      myModel?.holes?.enterHolesIn (array: &holeDictionary)
    }
    let keys = holeDictionary.keys.sorted ()
 //--- Write hole diameters
    var idx = 0
    for diameter in keys {
      idx += 1
      s += "T\(idx)C\(String(format: "%.3f", canariUnitToInch (diameter)))\n"
    }
 //--- Write holes
    s += "%\n"
    s += "G05\n"
    s += "M72\n"
    idx = 0
    for diameter in keys {
      idx += 1
      s += "T\(idx)\n"
      for (x, y) in holeDictionary [diameter]! {
        s += "X\(String(format: "%.3f", canariUnitToInch (x)))Y\(String(format: "%.3f", canariUnitToInch (y)))\n"
      }
    }
 //--- End of file
    s += "T0\n"
    s += "30\n"
 //--- Write file
    let data : Data? = s.data (using: .ascii, allowLossyConversion:false)
    try data?.write (to: URL (fileURLWithPath: filePath), options: .atomic)
    mLogTextView?.appendSuccessString (" Ok\n")
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
