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
    archiveDict ["BOARD-HEIGHT"] = self.rootObject.boardHeight_value
    archiveDict ["BOARD-HEIGHT-UNIT"] = self.rootObject.boardHeightUnit
//    archiveDict ["BOARD-LINE-WIDTH"] = self.rootObject.board
//    archiveDict ["BOARD-LINE-UNIT"] = self.rootObject.boardHeightUnit
    archiveDict ["BOARD-WIDTH"] = self.rootObject.boardWidth_value
    archiveDict ["BOARD-WIDTH-UNIT"] = self.rootObject.boardWidthUnit
    var backComponentNames = [String] ()
    for board in self.rootObject.boardInstances_property.propval {
      let myModel : BoardModel? = board.myModel_property.propval
      myModel?.backComponentNameSegments_value.add (toArchiveArray: &backComponentNames, dx: board.x, dy: board.y)
    }
    archiveDict ["COMPONENT-NAMES-BACK"] = backComponentNames

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

extension BoardModel {

  var backComponentNameSegments_value : MergerSegmentArray {
    switch self.backComponentNameSegments_property_selection {
    case .empty :
      return MergerSegmentArray ([])
    case .multiple :
      return MergerSegmentArray ([])
    case .single (let v) :
      return v
    }
  }

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension MergerRoot {

  var boardWidth_value : Int {
    switch self.boardWidth {
    case .empty :
      return Int ()
    case .multiple :
      return Int ()
    case .single (let v) :
      return v
    }
  }

  var boardHeight_value : Int {
    switch self.boardHeight {
    case .empty :
      return Int ()
    case .multiple :
      return Int ()
    case .single (let v) :
      return v
    }
  }
}
