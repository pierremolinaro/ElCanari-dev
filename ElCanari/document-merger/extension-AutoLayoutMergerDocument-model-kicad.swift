//
//  ElCanari
//
//  Created by Pierre Molinaro on 21/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct TemporaryBoardModel {
  var mFrontPackagesEntities = EBReferenceArray <SegmentEntity> ()
  var mBackPackagesEntities = EBReferenceArray <SegmentEntity> ()

  var mDrillEntities = EBReferenceArray <SegmentEntity> ()
  var mViaEntities = EBReferenceArray <BoardModelVia> ()

  var mFrontPadEntities = EBReferenceArray <BoardModelPad> ()
  var mBackPadEntities = EBReferenceArray <BoardModelPad> ()

  var mFrontComponentNamesEntities = EBReferenceArray <SegmentEntity> ()
  var mBackComponentNamesEntities = EBReferenceArray <SegmentEntity> ()

  var mFrontComponentValuesEntities = EBReferenceArray <SegmentEntity> ()
  var mBackComponentValuesEntities = EBReferenceArray <SegmentEntity> ()

  var mFrontTrackEntities = EBReferenceArray <SegmentEntity> ()
  var mBackTrackEntities = EBReferenceArray <SegmentEntity> ()

  var mFrontLayoutTextEntities = EBReferenceArray <SegmentEntity> ()
  var mBackLayoutTextEntities = EBReferenceArray <SegmentEntity> ()

  let mBoardRect_mm : NSRect
  let mKicadFont : [UInt32 : BoardFontCharacter]
  let mLeftMM  : CGFloat
  let mBottomMM : CGFloat

  init (boardRectMM inBoardRect_mm : NSRect,
        kicadFont inKicadFont : [UInt32 : BoardFontCharacter],
        leftMM inLeftMM: CGFloat,
        bottomMM inBottomMM : CGFloat) {
    self.mBoardRect_mm = inBoardRect_mm
    self.mKicadFont = inKicadFont
    self.mLeftMM = inLeftMM
    self.mBottomMM = inBottomMM
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct KicadNetClass {
  let name : String
  let padDiameter : Int
  let drillDiameter : Int
  let netNames : [String]

  //····················································································································

  init (name inName : String,
        padDiameter inPadDiameter : Int,
        drillDiameter inDrillDiameter : Int,
        netNames inNetNames : [String]) {
    self.name = inName
    self.padDiameter = inPadDiameter
    self.drillDiameter = inDrillDiameter
    self.netNames = inNetNames
  }

  //····················································································································

  init () {
    self.name = "???"
    self.padDiameter = 0
    self.drillDiameter = 0
    self.netNames = []
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutMergerDocument {

  //····················································································································

  func loadBoardModel_kicad (filePath inFilePath : String, windowForSheet inWindow : NSWindow) {
  //--- Load file, as plist
    let optionalFileData : Data? = FileManager ().contents (atPath: inFilePath)
    if let fileData = optionalFileData {
      let s = inFilePath.lastPathComponent.deletingPathExtension
      let possibleBoardModel = self.parseBoardModel_kicad (fromData: fileData, named : s)
      if let boardModel = possibleBoardModel {
        self.rootObject.boardModels_property.add (boardModel)
        self.mBoardModelController.select (object:boardModel)
      }
    }else{ // Cannot read file
      let alert = NSAlert ()
      alert.messageText = "Cannot read file"
      alert.informativeText = "The file \(inFilePath) cannot be read."
      alert.beginSheetModal (for: inWindow) { (NSModalResponse) in }
    }
  }

  //····················································································································

  func parseBoardModel_kicad (fromData inData : Data, named inName : String) -> BoardModel? {
    var result : BoardModel? = nil
    if let contentString = String (data: inData, encoding: .utf8) {
    //--- Parse
      var index = 0
      let possibleContents : KicadItem? = parseKicadString (contentString.unicodeArray, &index)
    //--- Display
//      var str = ""
//      possibleContents?.display ("", &str)
//      Swift.print (str)
    //--- Get first level items
      if let contents = possibleContents, contents.key == "kicad_pcb" {
        let font : [UInt32 : BoardFontCharacter] = kicadFont ()
        let boardModel = BoardModel (self.undoManager)
        boardModel.name = inName
        var errorArray = [(String, Int)] ()
        self.extractContents (contents.items, boardModel, font, &errorArray)
        if errorArray.count == 0 {
          result = boardModel
        }else{
          var s = ""
          for anError in errorArray {
            if s != "" {
              s += "\n"
            }
            s += anError.0 + " (line \(anError.1))"
          }
          let alert = NSAlert ()
          alert.messageText = "Cannot Analyse file contents"
          alert.informativeText = s
          alert.beginSheetModal (for: self.windowForSheet!) { (NSModalResponse) in }
        }
      }else{
        let alert = NSAlert ()
        alert.messageText = "Invalid file contents"
        alert.informativeText = "No 'kicad_pcb' key"
        alert.beginSheetModal (for: self.windowForSheet!) { (NSModalResponse) in }
      }
    }
  //--- Return
    return result
  }

  //····················································································································

  fileprivate func extractContents (_ inContentArray : [KicadItem],
                                    _ boardModel : BoardModel,
                                    _ inKicadFont : [UInt32 : BoardFontCharacter],
                                    _ ioErrorArray : inout [(String, Int)]) {
  //--- Extract board bounding box
    var left   =  Int.max ; var right  = -Int.max
    var bottom = -Int.max ; var top = Int.max // in Kicad, the Y-axis is pointing down
    var boardModelWidth = -Int.max
    self.collectBoardLimits (inContentArray, &left, &right, &top, &bottom, &boardModelWidth, &ioErrorArray)
    if (left >= right) || (top >= bottom) {
      let alert = NSAlert ()
      alert.messageText = "Cannot extract board bounding box"
      alert.informativeText = ""
      alert.beginSheetModal (for: self.windowForSheet!) { (NSModalResponse) in }
    }else{
      let leftMM = canariUnitToMillimeter (left)
      let rightMM = canariUnitToMillimeter (right)
      let topMM = canariUnitToMillimeter (top)
      let bottomMM = canariUnitToMillimeter (bottom)
      let modelWidthMM = rightMM - leftMM
      let modelHeightMM = bottomMM - topMM // in Kicad, the Y-axis is pointing down
      let boardRect_mm = NSRect (x: 0.0, y: 0.0, width: canariUnitToMillimeter (right - left), height: canariUnitToMillimeter (bottom - top))
      // Swift.print ("Board size \(modelWidth) mm • \(modelHeight) mm")
      boardModel.modelWidth  = millimeterToCanariUnit (modelWidthMM)
      boardModel.modelWidthUnit = CANARI_UNITS_PER_MM
      boardModel.modelHeight = millimeterToCanariUnit (modelHeightMM)
      boardModel.modelHeightUnit = CANARI_UNITS_PER_MM
      boardModel.modelLimitWidth = boardModelWidth
      boardModel.modelLimitWidthUnit = CANARI_UNITS_PER_MM
    //--- Collect datas
      var temporaryBoardModel = TemporaryBoardModel (
        boardRectMM: boardRect_mm,
        kicadFont: inKicadFont,
        leftMM: leftMM,
        bottomMM: bottomMM
      )
      self.collectDatas (inContentArray, &temporaryBoardModel, &ioErrorArray)
    //--- Enter collected datas
      boardModel.backTracks_property.setProp (temporaryBoardModel.mBackTrackEntities)
      boardModel.frontTracks_property.setProp (temporaryBoardModel.mFrontTrackEntities)
      boardModel.vias_property.setProp (temporaryBoardModel.mViaEntities)
      boardModel.frontPackages_property.setProp (temporaryBoardModel.mFrontPackagesEntities)
      boardModel.backPackages_property.setProp (temporaryBoardModel.mBackPackagesEntities)
      boardModel.frontPads_property.setProp (temporaryBoardModel.mFrontPadEntities)
      boardModel.backPads_property.setProp (temporaryBoardModel.mBackPadEntities)
      boardModel.backComponentNames_property.setProp (temporaryBoardModel.mBackComponentNamesEntities)
      boardModel.frontComponentNames_property.setProp (temporaryBoardModel.mFrontComponentNamesEntities)
      boardModel.frontComponentValues_property.setProp (temporaryBoardModel.mFrontComponentValuesEntities)
      boardModel.backComponentValues_property.setProp (temporaryBoardModel.mBackComponentValuesEntities)
      boardModel.drills_property.setProp (temporaryBoardModel.mDrillEntities)
      boardModel.frontLayoutTexts_property.setProp (temporaryBoardModel.mFrontLayoutTextEntities)
      boardModel.backLayoutTexts_property.setProp (temporaryBoardModel.mBackLayoutTextEntities)
    }
  }

  //····················································································································

  fileprivate func collectDatas (_ inContentArray : [KicadItem],
                                 _ ioTemporaryBoardModel : inout TemporaryBoardModel,
                                 _ ioErrorArray : inout [(String, Int)]) {
  //--- Collect net name array, net class array
    var netNameArray = [String] ()
    var netClassArray = [KicadNetClass] ()
    self.collectNetNameArray (inContentArray, &netNameArray, &netClassArray, &ioErrorArray)
  //--- Build dictionary of net class, key by net name
    var netDictionary = [String : KicadNetClass] ()
    for netClass in netClassArray {
      for netName in netClass.netNames {
        netDictionary [netName] = netClass
      }
    }
  //--- Build array of net class, index by net index
  //    Note that net #0 has an empty name and is never used
    var netArray = [KicadNetClass] ()
    netArray.append (KicadNetClass ()) // Pseudo net #0
    for netName in netNameArray.dropFirst () {
      if let netClass = netDictionary [netName] {
        netArray.append (netClass)
      }else{
        ioErrorArray.append (("no net named \(netName)", #line))
      }
    }
  //--- collect other items
    for item in inContentArray {
      if item.key == "segment" {
        self.collectTracks (item, &ioTemporaryBoardModel, &ioErrorArray)
      }else if item.key == "via" {
        self.collectVia (item,  &ioTemporaryBoardModel, netArray, &ioErrorArray)
      }else if item.key == "gr_text" {
        self.collectText (item, &ioTemporaryBoardModel, &ioErrorArray)
      }else if item.key == "module" {
        self.collectModule (item, &ioTemporaryBoardModel, &ioErrorArray)
      }else{

      }
    }
  }

  //····················································································································

  fileprivate func collectTracks (_ inKicadItem : KicadItem,
                                  _ ioTemporaryBoardModel : inout TemporaryBoardModel,
                                  _ ioErrorArray : inout [(String, Int)]) {
    if let startX = inKicadItem.getFloat (["segment", "start"], 0, &ioErrorArray, #line),
       let startY = inKicadItem.getFloat (["segment", "start"], 1, &ioErrorArray, #line),
       let endX = inKicadItem.getFloat (["segment", "end"], 0, &ioErrorArray, #line),
       let endY = inKicadItem.getFloat (["segment", "end"], 1, &ioErrorArray, #line),
       let width = inKicadItem.getFloat (["segment", "width"], 0, &ioErrorArray, #line),
       let layer = inKicadItem.getString (["segment", "layer"], 0, &ioErrorArray, #line) {
      let segment = SegmentEntity (self.undoManager)
      segment.x1 = millimeterToCanariUnit (startX - ioTemporaryBoardModel.mLeftMM)
      segment.y1 = millimeterToCanariUnit (ioTemporaryBoardModel.mBottomMM - startY)
      segment.x2 = millimeterToCanariUnit (endX - ioTemporaryBoardModel.mLeftMM)
      segment.y2 = millimeterToCanariUnit (ioTemporaryBoardModel.mBottomMM - endY)
      segment.width = millimeterToCanariUnit (width)
      if layer == "F.Cu" {
        ioTemporaryBoardModel.mFrontTrackEntities.append (segment)
      }else if layer == "B.Cu" {
        ioTemporaryBoardModel.mBackTrackEntities.append (segment)
      }else{
        ioErrorArray.append (("Invalid segment layer \(layer)", #line))
      }
    }
  }

  //····················································································································

  fileprivate func collectNetNameArray (_ inContentArray : [KicadItem],
                                        _ ioNetNameArray : inout [String],
                                        _ ioNetClassArray : inout [KicadNetClass],
                                        _ ioErrorArray : inout [(String, Int)]) {
    var idx = 0
    for item in inContentArray {
      if item.key == "net" {
        if let index = item.getInt (["net"], 0, &ioErrorArray, #line),
           let name = item.getString (["net"], 1, &ioErrorArray, #line) {
          if index != idx {
            ioErrorArray.append (("Invalid net index: \(index) instead of \(idx)", #line))
          }
          ioNetNameArray.append (name)
          idx += 1
        }
      }else if item.key == "net_class" {
        if let padDiameter = item.getFloat (["net_class", "via_dia"], 0, &ioErrorArray, #line),
           let holeDiameter = item.getFloat (["net_class", "via_drill"], 0, &ioErrorArray, #line),
           let name = item.getString (["net_class"], 0, &ioErrorArray, #line) {
          var netNameArray = [String] ()
          for netClassItem in item.items {
            if netClassItem.key == "add_net", let netName = netClassItem.getString (["add_net"], 0, &ioErrorArray, #line) {
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

  fileprivate func collectVia (_ inKicadItem : KicadItem,
                               _ ioTemporaryBoardModel : inout TemporaryBoardModel,
                               _ inNetArray : [KicadNetClass],
                               _ ioErrorArray : inout [(String, Int)]) {
    if let x = inKicadItem.getFloat (["via", "at"], 0, &ioErrorArray, #line),
       let y = inKicadItem.getFloat (["via", "at"], 1, &ioErrorArray, #line),
       let diameter = inKicadItem.getFloat (["via", "size"], 0, &ioErrorArray, #line),
       let netIndex = inKicadItem.getInt (["via", "net"], 0, &ioErrorArray, #line) {
    //--- Add via
      let via = BoardModelVia (self.undoManager)
      via.x = millimeterToCanariUnit (x - ioTemporaryBoardModel.mLeftMM)
      via.y = millimeterToCanariUnit (ioTemporaryBoardModel.mBottomMM - y)
      via.padDiameter = millimeterToCanariUnit (diameter)
      let netClass = inNetArray [netIndex]
      ioTemporaryBoardModel.mViaEntities.append (via)
    //--- Add drill
      let segment = SegmentEntity (self.undoManager)
      segment.x1 = via.x
      segment.y1 = via.y
      segment.x2 = via.x
      segment.y2 = via.y
      segment.width = netClass.drillDiameter
      ioTemporaryBoardModel.mDrillEntities.append (segment)
    }
  }

  //····················································································································

  fileprivate func collectText (_ inKicadItem : KicadItem,
                                _ ioTemporaryBoardModel : inout TemporaryBoardModel,
                                _ ioErrorArray : inout [(String, Int)]) {
    if let stringValue = inKicadItem.getString (["gr_text"], 0, &ioErrorArray, #line),
            let textLayer = inKicadItem.getString (["gr_text", "layer"], 0, &ioErrorArray, #line),
            let startX = inKicadItem.getFloat (["gr_text", "at"], 0, &ioErrorArray, #line),
            let startY = inKicadItem.getFloat (["gr_text", "at"], 1, &ioErrorArray, #line),
            let thickness = inKicadItem.getOptionalFloat (["gr_text", "effects", "font", "thickness"], 0, &ioErrorArray, #line),
            let fontSize = inKicadItem.getOptionalFloat (["gr_text", "effects", "font", "size"], 0, &ioErrorArray, #line) {
      let textTransform = NSAffineTransform ()
      textTransform.scaleX (by: 1.0, yBy: -1.0)
      textTransform.translateX (
        by: CGFloat (startX - ioTemporaryBoardModel.mLeftMM),
        yBy: CGFloat (startY - ioTemporaryBoardModel.mBottomMM)
      )
    //--- Justify
      let effectItem = inKicadItem.getItem ("effects", &ioErrorArray, #line)
      let justifyArray = effectItem.getOptionalItemContents ("justify")
      var mirror = false
      var justification = KicadStringJustification.center
      for option in justifyArray {
        if option.key == "mirror" {
          mirror = true
        }else if option.key == "right" {
          justification = .right
        }else if option.key == "left" {
          justification = .left
        }else{
          ioErrorArray.append (("Invalid justification: \(option.key)", #line))
        }
      }
    //--- Draw
      let segments = drawKicadString (
        str: stringValue,
        transform: textTransform,
        mirror: mirror,
        justification: justification,
        fontSize: fontSize,
        thickness: thickness,
        font: ioTemporaryBoardModel.mKicadFont,
        leftMM: ioTemporaryBoardModel.mLeftMM,
        bottomMM: ioTemporaryBoardModel.mBottomMM,
        boardRect: ioTemporaryBoardModel.mBoardRect_mm,
        self.undoManager
      )
      if textLayer == "F.Cu" {
        ioTemporaryBoardModel.mFrontLayoutTextEntities.append (objects: segments)
      }else if textLayer == "B.Cu" {
        ioTemporaryBoardModel.mBackLayoutTextEntities.append (objects: segments)
      }
    }
  }

  //····················································································································

  fileprivate func collectModule (_ inKicadItem : KicadItem,
                                  _ ioTemporaryBoardModel : inout TemporaryBoardModel,
                                  _ ioErrorArray : inout [(String, Int)]) {
    if let moduleX = inKicadItem.getFloat (["module", "at"], 0, &ioErrorArray, #line),
       let moduleY = inKicadItem.getFloat (["module", "at"], 1, &ioErrorArray, #line),
       let layer = inKicadItem.getString (["module", "layer"], 0, &ioErrorArray, #line) { // F.Cu, B.Cu
      let moduleRotationInDegrees = inKicadItem.getOptionalFloat (["module", "at"], 2, &ioErrorArray, #line) ?? 0.0
      let moduleTransform = NSAffineTransform ()
      moduleTransform.scaleX (by: 1.0, yBy: -1.0)
      moduleTransform.translateX (
        by: CGFloat (moduleX - ioTemporaryBoardModel.mLeftMM),
        yBy: CGFloat (moduleY - ioTemporaryBoardModel.mBottomMM)
      )
      moduleTransform.rotate (byDegrees: -moduleRotationInDegrees)
      for item in inKicadItem.items {
        if item.key == "fp_text",
              let kind = item.getString (["fp_text"], 0, &ioErrorArray, #line), // reference, value, user
              let stringValue = item.getString (["fp_text"], 1, &ioErrorArray, #line),
              let textLayer = item.getString (["fp_text", "layer"], 0, &ioErrorArray, #line),
              let startX = item.getFloat (["fp_text", "at"], 0, &ioErrorArray, #line),
              let startY = item.getFloat (["fp_text", "at"], 1, &ioErrorArray, #line),
              let thickness = item.getOptionalFloat (["fp_text", "effects", "font", "thickness"], 0, &ioErrorArray, #line),
              let fontSize = item.getOptionalFloat (["fp_text", "effects", "font", "size"], 0, &ioErrorArray, #line) {
        //--- Justify
          let effectItem = inKicadItem.getOptionalItem ("effects")
          let justifyArray = effectItem.getOptionalItemContents ("justify")
          var mirror = false
          var justification = KicadStringJustification.center
          for option in justifyArray {
            if option.key == "mirror" {
              mirror = true
            }else if option.key == "right" {
              justification = .right
            }else if option.key == "left" {
              justification = .left
            }else{
              ioErrorArray.append (("Invalid justification: \(option.key)", #line))
            }
          }
          let textTransform = NSAffineTransform ()
          textTransform.scaleX (by: 1.0, yBy: -1.0)
          textTransform.translateX (
            by: CGFloat (moduleX - ioTemporaryBoardModel.mLeftMM),
            yBy: CGFloat (moduleY - ioTemporaryBoardModel.mBottomMM)
          )
          textTransform.rotate (byDegrees: -moduleRotationInDegrees)
          textTransform.translateX (by: startX, yBy: startY)
        //  textTransform.rotate (byDegrees: moduleRotationInDegrees)
//          if let textRotationInDegrees = item.getOptionalFloat (["fp_text", "at"], 2, &ioErrorArray, #line) {
//            textTransform.rotate (byDegrees: -textRotationInDegrees)
//          }
          let segments = drawKicadString (
            str: stringValue,
            transform: textTransform,
            mirror: mirror,
            justification: justification,
            fontSize: fontSize,
            thickness: thickness,
            font: ioTemporaryBoardModel.mKicadFont,
            leftMM: ioTemporaryBoardModel.mLeftMM,
            bottomMM: ioTemporaryBoardModel.mBottomMM,
            boardRect: ioTemporaryBoardModel.mBoardRect_mm,
            self.undoManager
          )
          if (kind == "reference") && (textLayer == "F.SilkS") {
            ioTemporaryBoardModel.mFrontComponentNamesEntities.append (objects: segments)
          }else if (kind == "reference") && (textLayer == "B.SilkS") {
            ioTemporaryBoardModel.mBackComponentNamesEntities.append (objects: segments)
          }else if (kind == "value") && (textLayer == "F.Fab") {
            ioTemporaryBoardModel.mFrontComponentValuesEntities.append (objects: segments)
          }else if (kind == "value") && (textLayer == "B.Fab") {
            ioTemporaryBoardModel.mBackComponentValuesEntities.append (objects: segments)
          }
        }else if item.key == "fp_line",
              let startX = item.getFloat (["fp_line", "start"], 0, &ioErrorArray, #line),
              let startY = item.getFloat (["fp_line", "start"], 1, &ioErrorArray, #line),
              let endX = item.getFloat (["fp_line", "end"], 0, &ioErrorArray, #line),
              let endY = item.getFloat (["fp_line", "end"], 1, &ioErrorArray, #line),
              let widthMM = item.getFloat (["fp_line", "width"], 0, &ioErrorArray, #line),
              let lineLayer = item.getString (["fp_line", "layer"], 0, &ioErrorArray, #line) {
          let start = moduleTransform.transform (NSPoint (x: startX, y: startY))
          let end = moduleTransform.transform (NSPoint (x: endX, y: endY))
          if let packageLine = clippedSegmentEntity (
            p1_mm: NSPoint (x: start.x, y: start.y),
            p2_mm: NSPoint (x: end.x, y: end.y),
            width_mm: widthMM,
            clipRect_mm: ioTemporaryBoardModel.mBoardRect_mm,
            self.undoManager,
            file: #file, #line
          ) {
            if layer == "F.Cu" {
              if lineLayer == "F.SilkS" {
                ioTemporaryBoardModel.mFrontPackagesEntities.append (packageLine)
              }
            }else if layer == "B.Cu" {
              if lineLayer == "B.SilkS" {
                ioTemporaryBoardModel.mBackPackagesEntities.append (packageLine)
              }
            }else{
              ioErrorArray.append (("Invalid module layer: \(layer)", #line))
            }
          }
        }else if item.key == "fp_arc",
              let centerX = item.getFloat (["fp_arc", "start"], 0, &ioErrorArray, #line),
              let centerY = item.getFloat (["fp_arc", "start"], 1, &ioErrorArray, #line),
              let startX = item.getFloat (["fp_arc", "end"], 0, &ioErrorArray, #line),
              let startY = item.getFloat (["fp_arc", "end"], 1, &ioErrorArray, #line),
              let angle = item.getFloat (["fp_arc", "angle"], 0, &ioErrorArray, #line),
              let widthMM = item.getFloat (["fp_arc", "width"], 0, &ioErrorArray, #line),
              let lineLayer = item.getString (["fp_arc", "layer"], 0, &ioErrorArray, #line) {
          let start = moduleTransform.transform (NSPoint (x: startX, y: startY))
          let center = moduleTransform.transform (NSPoint (x: centerX, y: centerY))
          let bp = NSBezierPath ()
          let dx = start.x - center.x
          let dy = start.y - center.y
          let radius = sqrt (dx * dx + dy * dy)
          let startAngle = angleInDegreesBetweenNSPoints (center, start)
          bp.appendArc (
            withCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: startAngle + CGFloat(angle),
            clockwise: angle > 0.0
          )
          bp.lineWidth = CGFloat (widthMM)
          NSBezierPath.defaultFlatness = CGFloat (widthMM) / 10.0
          let flattenedBP = bp.flattened
          var currentPoint = NSPoint ()
          for idx in 0 ..< flattenedBP.elementCount {
            var pointArray = [NSPoint (), NSPoint (), NSPoint ()] // 3-point array
            let element : NSBezierPath.ElementType = flattenedBP.element (at:idx, associatedPoints: &pointArray)
            switch element {
            case .moveTo :
              currentPoint = pointArray [0]
            case .lineTo :
              let packageLine = SegmentEntity (self.undoManager)
              packageLine.x1 = millimeterToCanariUnit (CGFloat (currentPoint.x))
              packageLine.y1 = millimeterToCanariUnit (CGFloat (currentPoint.y))
              packageLine.x2 = millimeterToCanariUnit (CGFloat (pointArray [0].x))
              packageLine.y2 = millimeterToCanariUnit (CGFloat (pointArray [0].y))
              currentPoint = pointArray [0]
              packageLine.width = millimeterToCanariUnit (widthMM)
              if layer == "F.Cu" {
                if lineLayer == "F.SilkS" {
                  ioTemporaryBoardModel.mFrontPackagesEntities.append (packageLine)
                }
              }else if layer == "B.Cu" {
                if lineLayer == "B.SilkS" {
                  ioTemporaryBoardModel.mBackPackagesEntities.append (packageLine)
                }
              }else{
                ioErrorArray.append (("Invalid module layer: \(layer)", #line))
              }
            case .curveTo :
              ioErrorArray.append (("Invalid curveToBezierPathElement", #line))
            case .closePath :
              ioErrorArray.append (("Invalid closePathBezierPathElement", #line))
            case .cubicCurveTo:
              ()
            case .quadraticCurveTo:
              ()
            @unknown default:
              ()
            }
          }
        }else if item.key == "pad",
              let padSideString = item.getString (["pad"], 1, &ioErrorArray, #line), // thru_hole, smd, np_thru_hole
              let padShapeString = item.getString (["pad"], 2, &ioErrorArray, #line), // oval, rect, circle
              let atX = item.getFloat (["pad", "at"], 0, &ioErrorArray, #line),
              let atY = item.getFloat (["pad", "at"], 1, &ioErrorArray, #line),
              let widthMM = item.getFloat (["pad", "size"], 0, &ioErrorArray, #line),
              let heightMM = item.getFloat (["pad", "size"], 1, &ioErrorArray, #line) {
          let pad = BoardModelPad (self.undoManager)
          let padXY = moduleTransform.transform (NSPoint (x: atX, y: atY))
          pad.x = millimeterToCanariUnit (CGFloat (padXY.x))
          pad.y = millimeterToCanariUnit (CGFloat (padXY.y))
          pad.width = millimeterToCanariUnit (widthMM)
          pad.height = millimeterToCanariUnit (heightMM)
          let padRotationInDegrees = item.getOptionalFloat (["pad", "at"], 2, &ioErrorArray, #line) ?? 0.0
          pad.rotation = degreesToCanariRotation (padRotationInDegrees)
          if padShapeString == "rect" {
            pad.shape = .rect
          }else if padShapeString == "oval" {
            pad.shape = .round
          }else if padShapeString == "roundrect" {
            pad.shape = .round
          }else if padShapeString == "circle" {
            pad.shape = .round
            if widthMM != heightMM {
              ioErrorArray.append (("Invalid circle pad: width \"\(widthMM)\".", #line))
            }
          }else{
            ioErrorArray.append (("Invalid pad shape \(padShapeString)", #line))
          }
          if (padSideString == "thru_hole") || (padSideString == "np_thru_hole") {
            ioTemporaryBoardModel.mFrontPadEntities.append (pad)
            ioTemporaryBoardModel.mBackPadEntities.append (pad)
            if let holeSpecification = item.getString (["pad", "drill"], 0, &ioErrorArray, #line) {
              if let holeDiameter = Double (holeSpecification) {
                let drillDiameter = millimeterToCanariUnit (CGFloat (holeDiameter))
                let x1 = pad.x
                let y1 = pad.y
                let drill = SegmentEntity (self.undoManager)
                drill.x1 = x1
                drill.y1 = y1
                drill.x2 = x1
                drill.y2 = y1
                drill.width = drillDiameter
                ioTemporaryBoardModel.mDrillEntities.append (drill)
              }else if holeSpecification == "oval" {
                if let drillDiameterMM = item.getFloat (["pad", "drill"], 1, &ioErrorArray, #line),
                   let ovalMM = item.getFloat (["pad", "drill"], 2, &ioErrorArray, #line) {
                  let drillDiameter = millimeterToCanariUnit (drillDiameterMM)
                  let padTransform = NSAffineTransform ()
                  padTransform.scaleX (by: 1.0, yBy: -1.0)
                  padTransform.rotate (byDegrees: CGFloat (-moduleRotationInDegrees))
                  let p = padTransform.transform (NSPoint (x: (ovalMM - drillDiameterMM) / 2.0, y:0))
                  let dx = millimeterToCanariUnit (CGFloat (p.x))
                  let dy = millimeterToCanariUnit (CGFloat (p.y))
                  let drill = SegmentEntity (self.undoManager)
                  drill.x1 = pad.x - dx
                  drill.y1 = pad.y - dy
                  drill.x2 = pad.x + dx
                  drill.y2 = pad.y + dy
                  drill.width = drillDiameter
                  ioTemporaryBoardModel.mDrillEntities.append (drill)
                }else{
                  ioErrorArray.append (("Invalid pad drill oval width or height", #line))
                }
              }else{
                ioErrorArray.append (("Invalid pad drill \"\(holeSpecification)\".", #line))
              }
            }
          }else if padSideString == "smd" {
            if layer == "F.Cu" {
              ioTemporaryBoardModel.mFrontPadEntities.append (pad)
            }else{
              ioTemporaryBoardModel.mBackPadEntities.append (pad)
            }
          }else{
            ioErrorArray.append (("Invalid pad side \"\(padSideString)\".", #line))
          }
        }
      }
    }
  }

  //····················································································································

  fileprivate func collectBoardLimits (_ inContentArray : [KicadItem],
                                       _ ioLeft : inout Int,
                                       _ ioRight : inout Int,
                                       _ ioTop : inout Int,
                                       _ ioBottom : inout Int,
                                       _ ioLineWidth : inout Int,
                                       _ ioErrorArray : inout [(String, Int)]) {
    for item in inContentArray {
      if item.key == "gr_line" {
        if let startX = item.getFloat (["gr_line", "start"], 0, &ioErrorArray, #line),
           let startY = item.getFloat (["gr_line", "start"], 1, &ioErrorArray, #line),
           let endX = item.getFloat (["gr_line", "end"], 0, &ioErrorArray, #line),
           let endY = item.getFloat (["gr_line", "end"], 1, &ioErrorArray, #line),
           let width = item.getFloat (["gr_line", "width"], 0, &ioErrorArray, #line),
  //         let angle = item.getFloat (["gr_line", "angle"], 0, &ioErrorArray, #line),
           let layer = item.getString (["gr_line", "layer"], 0, &ioErrorArray, #line) {
          if layer == "Edge.Cuts" {
            let x1 = millimeterToCanariUnit (startX)
            let y1 = millimeterToCanariUnit (startY)
            let x2 = millimeterToCanariUnit (endX)
            let y2 = millimeterToCanariUnit (endY)
            let lineWidth = millimeterToCanariUnit (width)
            if ioLeft > x1 {
              ioLeft = x1
            }
            if ioRight < x1 {
              ioRight = x1
            }
            if ioBottom < y1 {
              ioBottom = y1
            }
            if ioTop > y1 {
              ioTop = y1
            }
            if ioLeft > x2 {
              ioLeft = x2
            }
            if ioRight < x2 {
              ioRight = x2
            }
            if ioBottom < y2 {
              ioBottom = y2
            }
            if ioTop > y2 {
              ioTop = y2
            }
            if ioLineWidth < lineWidth {
              ioLineWidth = lineWidth
            }
          }
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
