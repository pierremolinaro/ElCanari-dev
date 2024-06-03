//
//  ProjectDocument-generate-board-archive.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 01/08/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //································································································

  func writeBoardArchiveFile (atPath inPath : String, _ inProductData : ProductData) throws {
    self.mProductFileGenerationLogTextView?.appendMessage ("Generating \(inPath.lastPathComponent)…")
    var boardArchive = [String : Any] ()
  //--- Add artwork name
    boardArchive [ARCHIVE_ARTWORK_KEY] = self.rootObject.mArtworkName
  //--- Add version
    boardArchive [ARCHIVE_VERSION_KEY] = MERGER_ARCHIVE_VERSION
  //--- Add Board limits
    let af = self.addBoardLimits (&boardArchive, inProductData)
    addBoardLimitPathToArchive (&boardArchive, inProductData.boardLimitPath, self.rootObject.mBoardLimitsWidth, af)
    addLinePathes (&boardArchive, inProductData.backComponentNames, ARCHIVE_COMPONENT_NAMES_BACK_KEY, af)
    addLinePathes (&boardArchive, inProductData.frontComponentNames, ARCHIVE_COMPONENT_NAMES_FRONT_KEY, af)
    addLinePathes (&boardArchive, inProductData.backComponentValues, ARCHIVE_COMPONENT_VALUES_BACK_KEY, af)
    addLinePathes (&boardArchive, inProductData.frontComponentValues, ARCHIVE_COMPONENT_VALUES_FRONT_KEY, af)
    addOblongs (&boardArchive, inProductData.backLines, ARCHIVE_LINES_BACK_KEY, af)
    addOblongs (&boardArchive, inProductData.frontLines, ARCHIVE_LINES_FRONT_KEY, af)
    addLinePathes (&boardArchive, inProductData.backPackageLegend, ARCHIVE_PACKAGES_BACK_KEY, af)
    addLinePathes (&boardArchive, inProductData.frontPackageLegend, ARCHIVE_PACKAGES_FRONT_KEY, af)
    addDrills (&boardArchive, inProductData.holeDictionary, af)
    self.addPadsToArchive (&boardArchive, af)
    addTracks (&boardArchive, inProductData.frontTracksWithNoSilkScreen, ARCHIVE_FRONT_TRACKS_WITH_NO_SILK_SCREEN_KEY, af)
    addTracks (&boardArchive, inProductData.backTracksWithNoSilkScreen, ARCHIVE_BACK_TRACKS_WITH_NO_SILK_SCREEN_KEY, af)
    addLinePathes (&boardArchive, inProductData.layoutBackTexts, ARCHIVE_TEXTS_LAYOUT_BACK_KEY, af)
    addLinePathes (&boardArchive, inProductData.layoutFrontTexts, ARCHIVE_TEXTS_LAYOUT_FRONT_KEY, af)
    addLinePathes (&boardArchive, inProductData.legendBackTexts, ARCHIVE_TEXTS_LEGEND_BACK_KEY, af)
    addLinePathes (&boardArchive, inProductData.legendFrontTexts, ARCHIVE_TEXTS_LEGEND_FRONT_KEY, af)
    addTracks (&boardArchive, inProductData.tracks [.back, default: []], ARCHIVE_TRACKS_BACK_KEY, af)
    addTracks (&boardArchive, inProductData.tracks [.front, default: []], ARCHIVE_TRACKS_FRONT_KEY, af)
    addCircles (&boardArchive, inProductData.viaPads, ARCHIVE_VIAS_KEY, af)
    addRectangles (&boardArchive, inProductData.legendFrontQRCodes, ARCHIVE_QRCODES_LEGEND_FRONT_KEY, af)
    addRectangles (&boardArchive, inProductData.legendBackQRCodes, ARCHIVE_QRCODES_LEGEND_BACK_KEY, af)
    addRectangles (&boardArchive, inProductData.legendFrontImages, ARCHIVE_IMAGES_LEGEND_FRONT_KEY, af)
    addRectangles (&boardArchive, inProductData.legendBackImages, ARCHIVE_IMAGES_LEGEND_BACK_KEY, af)
  //--- Add inner objects ?
    switch self.rootObject.mLayerConfiguration {
    case .twoLayers :
      ()
    case .fourLayers :
      addOblongs (&boardArchive, inProductData.tracks [.inner1, default: []], ARCHIVE_TRACKS_INNER1_KEY, af)
      addOblongs (&boardArchive, inProductData.tracks [.inner2, default: []], ARCHIVE_TRACKS_INNER2_KEY, af)
    case .sixLayers :
      addOblongs (&boardArchive, inProductData.tracks [.inner1, default: []], ARCHIVE_TRACKS_INNER1_KEY, af)
      addOblongs (&boardArchive, inProductData.tracks [.inner2, default: []], ARCHIVE_TRACKS_INNER2_KEY, af)
      addOblongs (&boardArchive, inProductData.tracks [.inner3, default: []], ARCHIVE_TRACKS_INNER3_KEY, af)
      addOblongs (&boardArchive, inProductData.tracks [.inner4, default: []], ARCHIVE_TRACKS_INNER4_KEY, af)
    }
  //--- Write file
    let data = try PropertyListSerialization.data (fromPropertyList: boardArchive, format: .xml, options: 0)
    try data.write (to: URL (fileURLWithPath: inPath))
    self.mProductFileGenerationLogTextView?.appendSuccess (" Ok\n")
  }

  //································································································

  private func addBoardLimits (_ ioBoardArchive : inout [String : Any], _ inProductData : ProductData) -> AffineTransform {
    let boardBoundBox = inProductData.boardBoundBox
    ioBoardArchive [ARCHIVE_BOARD_HEIGHT_KEY] = cocoaToCanariUnit (boardBoundBox.size.height)
    ioBoardArchive [ARCHIVE_BOARD_HEIGHT_UNIT_KEY] = self.rootObject.mBoardLimitsWidthUnit
    ioBoardArchive [ARCHIVE_BOARD_LINE_WIDTH_KEY] = self.rootObject.mBoardLimitsWidth
    ioBoardArchive [ARCHIVE_BOARD_LINE_WIDTH_UNIT_KEY] = self.rootObject.mBoardLimitsWidthUnit
    ioBoardArchive [ARCHIVE_BOARD_WIDTH_KEY]  = cocoaToCanariUnit (boardBoundBox.size.width)
    ioBoardArchive [ARCHIVE_BOARD_WIDTH_UNIT_KEY] = self.rootObject.mBoardLimitsWidthUnit
  //--- Transformation for translating origin to (0, 0)
    var af = AffineTransform ()
    af.translate (x: -boardBoundBox.origin.x, y: -boardBoundBox.origin.y)
    return af
  }

  //································································································

  private func addPadsToArchive (_ ioBoardArchive : inout [String : Any], _ inAffineTransform : AffineTransform) {
    var frontPads = [[String : Any]] ()
    var backPads = [[String : Any]] ()
    var traversingPads = [[String : Any]] ()
    for object in self.rootObject.mBoardObjects_property.propval.values {
      if let component = object as? ComponentInProject {
        var af = component.packageToComponentAffineTransform ()
        af.append (inAffineTransform)
        for (_, masterPad) in component.packagePadDictionary! {
          let masterPadDict = padDictionary (masterPad.center, masterPad.padSize, masterPad.shape, component.mRotation, af)
          switch masterPad.style {
          case .traversing :
            frontPads.append (masterPadDict)
            backPads.append (masterPadDict)
            traversingPads.append (masterPadDict)
          case .surface :
            switch component.mSide {
            case .back :
              backPads.append (masterPadDict)
            case .front :
              frontPads.append (masterPadDict)
            }
          }
          for slavePad in masterPad.slavePads {
            let slavePadDict = padDictionary (slavePad.center, slavePad.padSize, slavePad.shape, component.mRotation, af)
            switch slavePad.style {
            case .traversing :
              frontPads.append (slavePadDict)
              backPads.append (slavePadDict)
              traversingPads.append (masterPadDict)
            case .componentSide :
              switch component.mSide {
              case .back :
                backPads.append (slavePadDict)
              case .front :
                frontPads.append (slavePadDict)
              }
            case .oppositeSide :
              switch component.mSide {
              case .front :
                backPads.append (slavePadDict)
              case .back :
                frontPads.append (slavePadDict)
              }
            }
          }
        }
      }
    }
    ioBoardArchive [ARCHIVE_PADS_BACK_KEY] = backPads
    ioBoardArchive [ARCHIVE_PADS_FRONT_KEY] = frontPads
    if self.rootObject.mLayerConfiguration != .twoLayers {
      ioBoardArchive [ARCHIVE_PADS_TRAVERSING_KEY] = traversingPads
    }
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addBoardLimitPathToArchive (_ ioBoardArchive : inout [String : Any],
                                             _ inPath : EBLinePath,
                                             _ inWidth : Int,
                                             _ inAffineTransform : AffineTransform) {
   var stringArray = [String] ()
   var p0 = inAffineTransform.transform (inPath.origin).canariPoint
   let firstPoint = p0
   for p in inPath.lines {
     let pp = inAffineTransform.transform (p).canariPoint
     stringArray.append ("\(p0.x) \(p0.y) \(pp.x) \(pp.y) \(inWidth)")
     p0 = pp
   }
   stringArray.append ("\(p0.x) \(p0.y) \(firstPoint.x) \(firstPoint.y) \(inWidth)")
   ioBoardArchive [ARCHIVE_INTERNAL_BOARDS_LIMITS_KEY] = stringArray  // DO NOT SORT
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addLinePathes (_ ioBoardArchive : inout [String : Any],
                                _ inDictionary : [CGFloat : [EBLinePath]],
                                _ inKey : String,
                                _ inAffineTransform : AffineTransform) {
   var stringArray = [String] ()
   for (aperture, linePathes) in inDictionary {
     let width = cocoaToCanariUnit (aperture)
     for path in linePathes {
       let p0 = inAffineTransform.transform (path.origin).canariPoint
       var cp = p0
       for p in path.lines {
         let pp = inAffineTransform.transform (p).canariPoint
         stringArray.append ("\(cp.x) \(cp.y) \(pp.x) \(pp.y) \(width)")
         cp = pp
       }
       if path.closed {
         stringArray.append ("\(cp.x) \(cp.y) \(p0.x) \(p0.y) \(width)")
       }
     }
   }
   ioBoardArchive [inKey] = stringArray.sorted ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addOblongs (_ ioBoardArchive : inout [String : Any],
                             _ inOblongArray : [ProductLine],
                             _ inKey : String,
                             _ inAffineTransform : AffineTransform) {
   var stringArray = [String] ()
   for oblong in inOblongArray {
     let width = cocoaToCanariUnit (oblong.width)
     let p1 = inAffineTransform.transform (oblong.p1).canariPoint
     let p2 = inAffineTransform.transform (oblong.p2).canariPoint
     stringArray.append ("\(p1.x) \(p1.y) \(p2.x) \(p2.y) \(width) \(oblong.endStyleIntValue)")
   }
   ioBoardArchive [inKey] = stringArray.sorted ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addTracks (_ ioBoardArchive : inout [String : Any],
                            _ inTrackArray : [ProductLine],
                            _ inKey : String,
                            _ inAffineTransform : AffineTransform) {
   var stringArray = [String] ()
   for track in inTrackArray {
     let width = cocoaToCanariUnit (track.width)
     let p1 = inAffineTransform.transform (track.p1).canariPoint
     let p2 = inAffineTransform.transform (track.p2).canariPoint
     stringArray.append ("\(p1.x) \(p1.y) \(p2.x) \(p2.y) \(width) \(track.endStyleIntValue)")
   }
   ioBoardArchive [inKey] = stringArray.sorted ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addCircles (_ ioBoardArchive : inout [String : Any],
                             _ inCircleArray : [ProductCircle],
                             _ inKey : String,
                             _ inAffineTransform : AffineTransform) {
   var stringArray = [String] ()
   for circle in inCircleArray {
     let diameter = cocoaToCanariUnit (circle.diameter)
     let center = inAffineTransform.transform (circle.center).canariPoint
     stringArray.append ("\(center.x) \(center.y) \(diameter)")
   }
   ioBoardArchive [inKey] = stringArray.sorted ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addDrills (_ ioBoardArchive : inout [String : Any],
                            _ inDrillDictionary : [CGFloat : [(NSPoint, NSPoint)]],
                            _ inAffineTransform : AffineTransform) {
   var stringArray = [String] ()
   for (aperture, segmentArray) in inDrillDictionary {
     let width = cocoaToCanariUnit (aperture)
     for (pp1, pp2) in segmentArray {
       let p1 = inAffineTransform.transform (pp1).canariPoint
       let p2 = inAffineTransform.transform (pp2).canariPoint
       stringArray.append ("\(p1.x) \(p1.y) \(p2.x) \(p2.y) \(width)")
     }
   }
   ioBoardArchive [ARCHIVE_DRILLS_KEY] = stringArray.sorted ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func padDictionary (_ inCenter : CanariPoint,
                                _ inPadSize : CanariSize,
                                _ inShape : PadShape,
                                _ inRotation : Int,
                                _ inAffineTransform : AffineTransform) -> [String : Any] {
  let shapeString : String
  switch inShape {
  case .octo : shapeString = "OCTO"
  case .rect : shapeString = "RECT"
  case .round : shapeString = "ROUND"
  }
  let center = inAffineTransform.transform (inCenter.cocoaPoint).canariPoint
  let padDict : [String : Any] = [
    "HEIGHT" : inPadSize.height,
    "ROTATION" : inRotation,
    "SHAPE" : shapeString,
    "WIDTH" : inPadSize.width,
    "X" : center.x,
    "Y" : center.y
  ]
  return padDict
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addRectangles (_ ioBoardArchive : inout [String : Any],
                                _ inRectArray : [ProductRectangle],
                                _ inKey : String,
                                _ inAffineTransform : AffineTransform) {
   var stringArray = [String] ()
   for rect in inRectArray {
     let p0 = inAffineTransform.transform (rect.p0).canariPoint
     let p1 = inAffineTransform.transform (rect.p1).canariPoint
     let p2 = inAffineTransform.transform (rect.p2).canariPoint
     let p3 = inAffineTransform.transform (rect.p3).canariPoint

     let s = "\(p0.x):\(p0.y):\(p1.x):\(p1.y):\(p2.x):\(p2.y):\(p3.x):\(p3.y)"
     stringArray.append (s)
   }
   ioBoardArchive [inKey] = stringArray.sorted ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

