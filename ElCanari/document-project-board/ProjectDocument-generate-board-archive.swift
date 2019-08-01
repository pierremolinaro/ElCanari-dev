//
//  ProjectDocument-generate-board-archive.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 01/08/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectDocument {

  //····················································································································

  internal func writeBoardArchiveFile (atPath inPath : String, _ inProductData : ProductData) throws {
    self.mProductFileGenerationLogTextView?.appendMessageString ("Generating \(inPath.lastPathComponent)…")
    var boardArchive = [String : Any] ()
  //--- Add artwork name
    boardArchive ["ARTWORK"] = self.rootObject.mArtworkName
  //--- Add Board limits
    let af = self.addBoardLimits (&boardArchive, inProductData)
    addLinePathes (&boardArchive, inProductData.backComponentNames, "COMPONENT-NAMES-BACK", af)
    addLinePathes (&boardArchive, inProductData.frontComponentNames, "COMPONENT-NAMES-FRONT", af)
    addLinePathes (&boardArchive, inProductData.backComponentValues, "COMPONENT-VALUES-BACK", af)
    addLinePathes (&boardArchive, inProductData.frontComponentValues, "COMPONENT-VALUES-FRONT", af)
    addOblongs (&boardArchive, inProductData.backLines, "LINES-BACK", af)
    addOblongs (&boardArchive, inProductData.frontLines, "LINES-FRONT", af)
    addLinePathes (&boardArchive, inProductData.backPackageLegend, "PACKAGES-BACK", af)
    addLinePathes (&boardArchive, inProductData.frontPackageLegend, "PACKAGES-FRONT", af)
    addDrills (&boardArchive, inProductData.holeDictionary, af)
    self.addPadsToArchive (&boardArchive, af)
    addLinePathes (&boardArchive, inProductData.layoutBackTexts, "TEXTS-LAYOUT-BACK", af)
    addLinePathes (&boardArchive, inProductData.layoutFrontTexts, "TEXTS-LAYOUT-FRONT", af)
    addLinePathes (&boardArchive, inProductData.legendBackTexts, "TEXTS-LEGEND-BACK", af)
    addLinePathes (&boardArchive, inProductData.legendFrontTexts, "TEXTS-LEGEND-FRONT", af)
    addOblongs (&boardArchive, inProductData.backTracks, "TRACKS-BACK", af)
    addOblongs (&boardArchive, inProductData.frontTracks, "TRACKS-FRONT", af)
    addCircles (&boardArchive, inProductData.viaPads, "VIAS", af)
  //--- Write file
    let data = try PropertyListSerialization.data (fromPropertyList: boardArchive, format: .binary, options: 0)
    try data.write (to: URL (fileURLWithPath: inPath))
    self.mProductFileGenerationLogTextView?.appendSuccessString (" Ok\n")
  }

  //····················································································································

  private func addBoardLimits (_ ioBoardArchive : inout [String : Any], _ inProductData : ProductData) -> AffineTransform {
    let boardBoundBox = inProductData.boardBoundBox
    ioBoardArchive ["BOARD-HEIGHT"] = cocoaToCanariUnit (boardBoundBox.size.height)
    ioBoardArchive ["BOARD-HEIGHT-UNIT"] = self.rootObject.mBoardLimitsWidthUnit
    ioBoardArchive ["BOARD-LINE-WIDTH"] = self.rootObject.mBoardLimitsWidth
    ioBoardArchive ["BOARD-LINE-WIDTH-UNIT"] = self.rootObject.mBoardLimitsWidthUnit
    ioBoardArchive ["BOARD-WIDTH"]  = cocoaToCanariUnit (boardBoundBox.size.width)
    ioBoardArchive ["BOARD-WIDTH-UNIT"] = self.rootObject.mBoardLimitsWidthUnit
  //--- Transformation for translating origin to (0, 0)
    var af = AffineTransform ()
    af.translate (x: -boardBoundBox.origin.x, y: -boardBoundBox.origin.y)
    return af
  }

  //····················································································································

  private func addPadsToArchive (_ ioBoardArchive : inout [String : Any], _ inAffineTransform : AffineTransform) {
    var frontPads = [[String : Any]] ()
    var backPads = [[String : Any]] ()
    for object in self.rootObject.mBoardObjects {
      if let component = object as? ComponentInProject {
        var af = component.packageToComponentAffineTransform ()
        af.append (inAffineTransform)
        for (_, masterPad) in component.packagePadDictionary! {
          let masterPadDict = padDictionary (masterPad.center, masterPad.padSize, masterPad.shape, component.mRotation, af)
          switch masterPad.style {
          case .traversing :
            frontPads.append (masterPadDict)
            backPads.append (masterPadDict)
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


    ioBoardArchive ["PADS-BACK"] = backPads
    ioBoardArchive ["PADS-FRONT"] = frontPads
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

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
   ioBoardArchive [inKey] = stringArray
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func addOblongs (_ ioBoardArchive : inout [String : Any],
                             _ inOblongArray : [ProductOblong],
                             _ inKey : String,
                             _ inAffineTransform : AffineTransform) {
   var stringArray = [String] ()
   for oblong in inOblongArray {
     let width = cocoaToCanariUnit (oblong.width)
     let p1 = inAffineTransform.transform (oblong.p1).canariPoint
     let p2 = inAffineTransform.transform (oblong.p2).canariPoint
     stringArray.append ("\(p1.x) \(p1.y) \(p2.x) \(p2.y) \(width)")
   }
   ioBoardArchive [inKey] = stringArray
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

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
   ioBoardArchive [inKey] = stringArray
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

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
   ioBoardArchive ["DRILLS"] = stringArray
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

