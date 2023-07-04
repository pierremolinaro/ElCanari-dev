//
//  ProjectDocument-utilities.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let kDragAndDropSymbol = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.schematic.symbol")
let kDragAndDropComment = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.schematic.comment")
let kDragAndDropWire = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.schematic.wire")

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SCHEMATIC_PASTEBOARD_TYPE = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.pasteboard.schematic")

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let kDragAndDropRestrictRectangle = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.restrict.rectangle")
let kDragAndDropBoardText = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.text")
let kDragAndDropBoardQRCode = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.qrcode")
let kDragAndDropBoardImage = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.image")
let kDragAndDropBoardPackage = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.package")
let kDragAndDropBoardLine = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.line")
let kDragAndDropBoardTrack = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.drag.and.drop.board.track")

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let TRACK_INITIAL_SIZE_IN_CANARI_UNIT = 500 * 2_286 // 500 mils

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SCHEMATIC_GRID_IN_MILS = 50
let SCHEMATIC_GRID_IN_CANARI_UNIT = milsToCanariUnit (fromInt: SCHEMATIC_GRID_IN_MILS)
let SCHEMATIC_GRID_IN_COCOA_UNIT  = milsToCocoaUnit (CGFloat (SCHEMATIC_GRID_IN_MILS))

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let NC_DISTANCE_IN_COCOA_UNIT = milsToCocoaUnit (50.0)
let NC_TITLE = "nc"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SCHEMATIC_CONNECTION_POINT_DIAMETER = milsToCocoaUnit (50.0)

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SCHEMATIC_KNOB_SIZE : CGFloat = 4.0
let SCHEMATIC_HILITE_WIDTH : CGFloat = 0.5

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let BOARD_KNOB_SIZE : CGFloat = 4.0

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let BOARD_PASTEBOARD_TYPE = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.pasteboard.board")

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SCHEMATIC_LABEL_SIZE : CGFloat = 3.6

let WIRE_DEFAULT_SIZE_ON_DRAG_AND_DROP = milsToCanariUnit (fromInt: 400)

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct SymbolInProjectIdentifier : Hashable {
  let symbolInstanceName : String
  let symbolTypeName : String
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct PinSymbolInProjectIdentifier : Hashable {
  let symbol : SymbolInProjectIdentifier
  let pinName : String
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct ComponentPinDescriptor : Hashable {
  let pinIdentifier : PinSymbolInProjectIdentifier
  let pinLocation : CanariPoint
  let shape : EBShape
  let netName : String // Empty string if no net
  let padName : String
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct ComponentSymbolInfo : Hashable {
  let filledBezierPath : NSBezierPath
  let strokeBezierPath : NSBezierPath
  let center : CanariPoint
  let pins : [ComponentPinDescriptor]
  let componentName : String
  let componentValue : String
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct DeviceSymbolInfo : Hashable {
  let filledBezierPath : NSBezierPath
  let strokeBezierPath : NSBezierPath
  let center : CanariPoint
  let assignments : [PinPadAssignmentInProject]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias CanariWireArray = [CanariWireDescription]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CanariWireDescription : Hashable {
  let p1 : CanariPoint
  let p2 : CanariPoint
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias SymbolInProjectIdentifierArray = [SymbolInProjectIdentifier]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias DeviceSymbolDictionary = [SymbolInProjectIdentifier : DeviceSymbolInfo]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct PinInProjectDescriptor : Hashable {
  let pinName : String
  let symbol : SymbolInProjectIdentifier
  let pinXY : CanariPoint

  let nameXY : CanariPoint
  let nameHorizontalAlignment : HorizontalAlignment
  let pinNameIsDisplayedInSchematics : Bool

  let numberXY : CanariPoint
  let numberHorizontalAlignment : HorizontalAlignment
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct PinPadAssignmentInProject : Hashable {
  let padName : String
  let pin : PinInProjectDescriptor? // if nil, pad is nc
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias NetInfoArray = [NetInfo]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct NetInfo : Hashable {
  let netIdentifier : Int
  let netName : String
  let netClassName : String
  let points : [NetInfoPoint]
  let subnets : [SubnetDescriptor]
  let subnetsHaveWarning : Bool
  let pinCount : Int
  let labelCount : Int
  let trackCount : Int
  let warnsExactlyOneLabel : Bool
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct NetInfoPoint : Hashable {
  let pinName : String?
  let sheet : Int
  let locationInSheet : CanariPoint
  let locationString : String
  let row : Int
  let column : Int
  let labels : [SchematicSheetGeometry.PointLocationInfo]
  let wires : Set <Int>
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias NetInfoPointArray = [NetInfoPoint]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct SchematicPointStatus : Hashable {
  let location : CanariPoint
  let connected : Bool
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct SchematicSheetGeometry : Hashable {
  let size : CanariSize // Canari Unit
  let horizontalDivisions : Int
  let verticalDivisions : Int

  //····················································································································

  struct PointLocationInfo : Hashable {
    let row : Int
    let column : Int
    let string : String
  }

  //····················································································································

  func locationInfo (forPointInSheet inPoint : CanariPoint) -> PointLocationInfo {
    let gutterWidth = cocoaToCanariUnit (PAPER_GUTTER_WIDTH_COCOA_UNIT)
    let gutterHeight = cocoaToCanariUnit (PAPER_GUTTER_HEIGHT_COCOA_UNIT)
    var column = 0
    if inPoint.x >= gutterWidth {
      column = (inPoint.x - gutterWidth) * self.horizontalDivisions / (self.size.width - 2 * gutterWidth)
      if column >= self.horizontalDivisions {
        column = self.horizontalDivisions - 1
      }
    }
    var line = 0
    if inPoint.y >= gutterHeight {
      line = (inPoint.y - gutterHeight) * self.verticalDivisions / (self.size.height - 2 * gutterHeight)
      if line >= self.verticalDivisions {
        line = self.verticalDivisions - 1
      }
    }
    // Swift.print ("horizontalDivisions \(self.horizontalDivisions), verticalDivisions \(self.verticalDivisions)")
    let unicodeA = 0x41
    return PointLocationInfo (row: line, column: column, string: "\(UnicodeScalar (unicodeA + column)!)\(line)")
  }


  //····················································································································

  enum PointInRowOrColumnHeader {
    case inColumHeader (Int)
    case inRowHeader (Int)
    case inCorner
    case outsideRowOrColumnHeader
  }

  //····················································································································

  func pointInRowOrColumnHeader (_ inPoint : NSPoint) -> PointInRowOrColumnHeader {
    let cocoaSize = self.size.cocoaSize
    var result = PointInRowOrColumnHeader.outsideRowOrColumnHeader
    var pointInVerticalGutter = inPoint.y <= PAPER_GUTTER_HEIGHT_COCOA_UNIT // in bottom gutter
    if !pointInVerticalGutter {
      pointInVerticalGutter = (inPoint.y >= (cocoaSize.height - PAPER_GUTTER_HEIGHT_COCOA_UNIT)) && (inPoint.y < cocoaSize.height)
    }
    if pointInVerticalGutter {
      let column = (inPoint.x - PAPER_GUTTER_WIDTH_COCOA_UNIT) * CGFloat (self.horizontalDivisions) / (cocoaSize.width - 2.0 * PAPER_GUTTER_WIDTH_COCOA_UNIT)
      if column >= 0.0, column < CGFloat (self.horizontalDivisions) {
        result = .inColumHeader (Int (column))
      }else{
        result = .inCorner
      }
    }else{
      var pointInHorizontalGutter = inPoint.x <= PAPER_GUTTER_WIDTH_COCOA_UNIT // in left gutter
      if !pointInHorizontalGutter {
        pointInHorizontalGutter = (inPoint.x >= (cocoaSize.width - PAPER_GUTTER_WIDTH_COCOA_UNIT)) && (inPoint.x < cocoaSize.width)
      }
      if pointInHorizontalGutter {
        let row = (inPoint.y - PAPER_GUTTER_HEIGHT_COCOA_UNIT) * CGFloat (self.verticalDivisions) / (cocoaSize.height - 2.0 * PAPER_GUTTER_HEIGHT_COCOA_UNIT)
        if row >= 0.0, row < CGFloat (self.verticalDivisions) {
          result = .inRowHeader (Int (row))
        }
      }
    }
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct SchematicSheetDescriptor : Hashable {
  let geometry : SchematicSheetGeometry
  let sheetIndex : Int

  //····················································································································

  func sheetLocationInfo (forPointInSheet inPoint : CanariPoint) -> SchematicSheetGeometry.PointLocationInfo {
    return self.geometry.locationInfo (forPointInSheet: inPoint)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias IntArray = [Int]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func + (lhs : QuadrantRotation, rhs : QuadrantRotation) -> QuadrantRotation {
  let v = (lhs.rawValue + rhs.rawValue) % 4
  return QuadrantRotation (rawValue: v)!
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension QuadrantRotation {

  //····················································································································

  mutating func rotateClockwise () {
    switch self {
    case .rotation0 :
      self = .rotation270
    case .rotation90 :
      self = .rotation0
    case .rotation180 :
      self = .rotation90
    case .rotation270 :
      self = .rotation180
    }
  }

  //····················································································································

  mutating func rotateCounterClockwise () {
    switch self {
    case .rotation0 :
      self = .rotation90
    case .rotation90 :
      self = .rotation180
    case .rotation180 :
      self = .rotation270
    case .rotation270 :
      self = .rotation0
    }
  }
  
  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct BorderCurveDescriptor : Hashable {

  //····················································································································

  let p1 : CanariPoint
  let p2 : CanariPoint
  let cp1 : CanariPoint
  let cp2 : CanariPoint
  let shape : BorderCurveShape

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct BoardCharSegment : Hashable {
  let x1 : Int8
  let y1 : Int8
  let x2 : Int8
  let y2 : Int8
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct BoardFontCharacter : Hashable {

  let advancement : Int
  let segments : [BoardCharSegment]

  //····················································································································

  func ebHashValue () -> UInt32 {
    var crc : UInt32 = 0
    crc.accumulate (u32: advancement.ebHashValue ())
    for segment in segments {
      crc.accumulate (s8: segment.x1)
      crc.accumulate (s8: segment.y1)
      crc.accumulate (s8: segment.x2)
      crc.accumulate (s8: segment.y2)
    }
    return crc
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias BoardFontDictionary = [UInt32 : BoardFontCharacter]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct BoardFontDescriptor : Hashable {
  let nominalSize : Int
  let dictionary :  BoardFontDictionary

  //····················································································································

  func ebHashValue () -> UInt32 {
    var crc : UInt32 = 0
    crc.accumulate (u32: nominalSize.ebHashValue ())
    for key in dictionary.keys.sorted () {
      crc.accumulate (u32: key.ebHashValue ())
      crc.accumulate (u32: dictionary [key]!.ebHashValue ())
    }
    return crc
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias PackageMasterPadDictionary = [String : MasterPadDescriptor] // Pad name, descriptor

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Dictionary where Key == String, Value == MasterPadDescriptor {

  //····················································································································

  var padsRect : CanariRect {
    var points = [CanariPoint] ()
    for (_, masterPadDescriptor) in self {
      points.append (masterPadDescriptor.center)
      for slavePadDescriptor in masterPadDescriptor.slavePads {
        points.append (slavePadDescriptor.center)
      }
    }
    return CanariRect (points: points)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor struct MasterPadDescriptor : Hashable {

  //····················································································································

  let name : String
  let center : CanariPoint
  let padSize : CanariSize
  let holeSize : CanariSize
  let shape : PadShape
  let style : PadStyle
  let slavePads : [SlavePadDescriptor]

  //····················································································································

  func bezierPath (index inIndex : Int, extraWidth : Int = 0) -> EBBezierPath {
    if inIndex == 0 {
      return EBBezierPath.pad (
        centerX: self.center.x,
        centerY: self.center.y,
        width: self.padSize.width + extraWidth,
        height: self.padSize.height + extraWidth,
        shape: self.shape
      )
    }else{
      let slavePad = self.slavePads [inIndex - 1]
      return EBBezierPath.pad (
        centerX: slavePad.center.x,
        centerY: slavePad.center.y,
        width: slavePad.padSize.width + extraWidth,
        height: slavePad.padSize.height + extraWidth,
        shape: slavePad.shape
      )
    }
  }

  //····················································································································

  func accumulatePadBezierPathes (into ioShape : inout EBShape,
                                  side : ComponentSide,
                                  padDisplayAttributes : [NSAttributedString.Key : Any]?,
                                  padNumberAF : AffineTransform,
                                  frontPadColor : NSColor?,
                                  backPadColor : NSColor?,
                                  padNetDictionary inPadNetDictionary : [String : String]) {
    let center = self.center.cocoaPoint
    let padSize = self.padSize.cocoaSize
    let rPad = NSRect (x: center.x - padSize.width / 2.0, y: center.y - padSize.height / 2.0, width: padSize.width, height: padSize.height)
    var bp : EBBezierPath
    switch self.shape {
    case .rect :
      bp = EBBezierPath (rect: rPad)
    case .round :
      bp = EBBezierPath (oblongInRect: rPad)
    case .octo :
      bp = EBBezierPath (octogonInRect: rPad)
    }
    switch self.style {
    case .traversing :
      ioShape.add (filled: [bp], nil) // Append a transparent layer, but that intercepts clicks
      let holeSize = self.holeSize.cocoaSize
      let rHole = NSRect (x: center.x - holeSize.width / 2.0, y: center.y - holeSize.height / 2.0, width: holeSize.width, height: holeSize.height)
      bp.appendOblong (in: rHole)
      bp.windingRule = .evenOdd
      if let color = frontPadColor {
        ioShape.add (filled: [bp], color)
      }else if let color = backPadColor {
        ioShape.add (filled: [bp], color)
      }
    case .surface :
      switch side {
      case .front :
        if let color = frontPadColor {
          ioShape.add (filled: [bp], color)
        }
      case .back :
        if let color = backPadColor {
          ioShape.add (filled: [bp], color)
        }
      }
    }
  //--- Pad names
    if let textAttributes = padDisplayAttributes {
      var af = AffineTransform ()
      af.translate (x: center.x, y: center.y)
      af.prepend (padNumberAF)
      ioShape.add (EBShape (text: self.name, NSPoint (), textAttributes, .center, .center).transformed (by: af))
    }
  //--- Tool tip
    ioShape.appendToolTip (rPad, inPadNetDictionary [self.name] ?? "No net")
  //--- Slave pads
    for pad in slavePads {
      pad.accumulatePadBezierPathes (
        into: &ioShape,
        side: side,
        name: "(" + self.name + ")",
        padDisplayAttributes: padDisplayAttributes,
        padNumberAF: padNumberAF,
        frontPadColor: frontPadColor,
        backPadColor: backPadColor
      )
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor struct SlavePadDescriptor : Hashable {

  //····················································································································

  let center : CanariPoint
  let padSize : CanariSize
  let holeSize : CanariSize
  let shape : PadShape
  let style : SlavePadStyle

  //····················································································································

  func accumulatePadBezierPathes (into ioShape : inout EBShape,
                                  side : ComponentSide,
                                  name : String,
                                  padDisplayAttributes : [NSAttributedString.Key : Any]?,
                                  padNumberAF : AffineTransform,
                                  frontPadColor : NSColor?,
                                  backPadColor : NSColor?) {
    let center = self.center.cocoaPoint
    let padSize = self.padSize.cocoaSize
    let rPad = NSRect (x: center.x - padSize.width / 2.0, y: center.y - padSize.height / 2.0, width: padSize.width, height: padSize.height)
    var bp : EBBezierPath
    switch self.shape {
    case .rect :
      bp = EBBezierPath (rect: rPad)
    case .round :
      bp = EBBezierPath (oblongInRect: rPad)
    case .octo :
      bp = EBBezierPath (octogonInRect: rPad)
    }
    switch self.style {
    case .traversing :
      let holeSize = self.holeSize.cocoaSize
      let rHole = NSRect (x: center.x - holeSize.width / 2.0, y: center.y - holeSize.height / 2.0, width: holeSize.width, height: holeSize.height)
      bp.appendOblong (in: rHole)
      bp.windingRule = .evenOdd
      if let color = frontPadColor {
        ioShape.add (filled: [bp], color)
      }else if let color = backPadColor {
        ioShape.add (filled: [bp], color)
      }
    case .componentSide :
      switch side {
      case .front :
        if let color = frontPadColor {
          ioShape.add (filled: [bp], color)
        }
      case .back :
        if let color = backPadColor {
          ioShape.add (filled: [bp], color)
        }
      }
    case .oppositeSide :
      switch side {
      case .front :
        if let color = backPadColor {
          ioShape.add (filled: [bp], color)
        }
      case .back :
        if let color = frontPadColor {
          ioShape.add (filled: [bp], color)
        }
      }
    }
  //--- Pad name
    if let textAttributes = padDisplayAttributes {
      var af = AffineTransform ()
      af.translate (x: center.x, y: center.y)
      af.prepend (padNumberAF)
      ioShape.add (EBShape (text: name, NSPoint (), textAttributes, .center, .center).transformed (by: af))
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct PadLocationAndSide : Hashable {
  let location : NSPoint
  let side : ConnectorSide
//  let bp : EBBezierPath
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct ComponentPadDescriptor : Hashable {
  let padName : String
  let pads : [PadLocationAndSide] // Master pad (index 0), then slave pads (if any)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias ComponentPadDescriptorDictionary = [String : ComponentPadDescriptor] // Pad name

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias PadNetDictionary = [String : String] // Pad name, associated net

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct RastnetInfo : Equatable, Hashable {
  let netName : String
  let location : CanariPoint
  let componentName : String
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias RastnetInfoArray = [RastnetInfo]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

