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
        let baseName = productDirectory.lastPathComponent
        let fm = FileManager ()
      //--- Library directory
        if !fm.fileExists (atPath: productDirectory) {
          try fm.createDirectory (atPath: productDirectory, withIntermediateDirectories:true, attributes:nil)
        }
      //--- Generate board archive
        if self.rootObject.generatedBoardArchiveFormat != .noGeneration {
          let boardArchivePath = productDirectory + "/" + baseName + ".ElCanariBoardArchive"
          try generateBoardArchive (atPath:boardArchivePath)
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
//    archiveDict ["BOARD-LINE-WIDTH"] = self.rootObject.board
//    archiveDict ["BOARD-LINE-UNIT"] = self.rootObject.boardHeightUnit
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
      for via in myModel?.vias_property.propval ?? [] {
        vias.append ("\(via.x), \(via.y) \(via.padDiameter) \(via.holeDiameter)")
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



//      myModel?.viaShapes?.add (toArchiveArray: &vias, dx: board.x, dy: board.y)
//      myModel?.pads?.add (toArchiveArray: &pads, dx: board.x, dy: board.y)
    }
    archiveDict ["COMPONENT-NAMES-BACK"] = backComponentNames
    archiveDict ["COMPONENT-NAMES-FRONT"] = frontComponentNames
    archiveDict ["COMPONENT-VALUES-BACK"] = backComponentValues
    archiveDict ["COMPONENT-VALUES-FRONT"] = frontComponentValues
    archiveDict ["PACKAGES-BACK"] = backPackages
    archiveDict ["PACKAGES-FRONT"] = frontPackages
    archiveDict ["PADS"] = pads
    archiveDict ["TEXTS-LAYOUT-BACK"] = backLayoutTexts
    archiveDict ["TEXTS-LAYOUT-FRONT"] = frontLayoutTexts
    archiveDict ["TEXTS-LEGEND-BACK"] = backLegendTexts
    archiveDict ["TEXTS-LEGEND-FRONT"] = frontLegendTexts
    archiveDict ["TRACKS-BACK"] = backTracks
    archiveDict ["TRACKS-FRONT"] = frontTracks
    archiveDict ["VIAS"] = vias
  //--- Write file
    let data : Data = try PropertyListSerialization.data (
      fromPropertyList: archiveDict,
      format: (self.rootObject.generatedBoardArchiveFormat == .xml) ? .xml : .binary,
      options: 0
    )
    try data.write(to: URL (fileURLWithPath: inFilePath), options: .atomic)
//      NSData * data = [NSPropertyListSerialization
//        dataFromPropertyList:boardArchiveDictionary
//        format:(mRootObject.artworkGeneratesBoardArchive == 1) ? NSPropertyListBinaryFormat_v1_0 : NSPropertyListXMLFormat_v1_0
//        errorDescription:nil
//      ] ;
//      if (data != nil) {
//        const BOOL ok = [data writeToFile:archivefileName atomically:YES] ;
//        if (ok) {
//          [mGenerationLogTextView appendMessageString:@" ok\n"] ;
//        }else{
//          [mGenerationLogTextView appendErrorString:@" error\n"] ;
//        }
//      }else{
//        [mGenerationLogTextView appendErrorString:@" Serialization error\n"] ;
//      }
//    }


  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
