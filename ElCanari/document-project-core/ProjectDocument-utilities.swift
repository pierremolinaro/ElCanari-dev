//
//  ProjectDocument-utilities.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SCHEMATIC_GRID_IN_MILS = 50
let SCHEMATIC_GRID_IN_CANARI_UNIT = milsToCanariUnit (SCHEMATIC_GRID_IN_MILS)
let SCHEMATIC_GRID_IN_COCOA_UNIT = milsToCocoaUnit (CGFloat (SCHEMATIC_GRID_IN_MILS))

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let NC_DISTANCE_IN_COCOA_UNIT = milsToCocoaUnit (50.0)
let NC_TITLE = "nc"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let CONNECTED_POINT_DIAMETER = milsToCocoaUnit (50.0)

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SCHEMATIC_KNOB_SIZE : CGFloat = 4.0
let SCHEMATIC_HILITE_WIDTH : CGFloat = 0.5

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let BOARD_KNOB_SIZE : CGFloat = 4.0
let BOARD_HILITE_WIDTH : CGFloat = 0.5

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SCHEMATIC_LABEL_SIZE : CGFloat = 3.6

let WIRE_DEFAULT_SIZE_ON_DRAG_AND_DROP = milsToCanariUnit (400)

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
  let points : NetInfoPointArray
  let subnets : StatusStringArray
  let subnetsHaveWarning : Bool
  let pinCount : Int
  let labelCount : Int
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct NetInfoPoint : Hashable {
  let pin : String?
  let labels : StringArray
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

struct SchematicSheetDescriptor : Hashable {
  let size : CanariSize // Canari Unit
  let horizontalDivisions : Int
  let verticalDivisions : Int
  let sheetIndex : Int

  func coordinates (ofPoint inPoint : CanariPoint) -> String {
    return ""
  }
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
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias BoardFontDictionary = [UInt32 : BoardFontCharacter]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct BoardFontDescriptor : Hashable {
  let nominalSize : Int
  let dictionary :  BoardFontDictionary
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias PackageMasterPadDictionary = [String : MasterPadDescriptor]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Dictionary where Key == String, Value == MasterPadDescriptor {

  var masterPadsRect : CanariRect {
    var points = [CanariPoint] ()
    for (_, masterPadDescriptor) in self {
      points.append (masterPadDescriptor.center)
      for slavePadDescriptor in masterPadDescriptor.slavePads {
        points.append (slavePadDescriptor.center)
      }
    }
    return CanariRect (points: points)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct MasterPadDescriptor : Hashable {
  let name : String
  let center : CanariPoint
  let padSize : CanariSize
  let holeSize : CanariSize
  let shape : PadShape
  let style : PadStyle
  let slavePads : [SlavePadDescriptor]

  func accumulatePadBezierPathes (into ioShape : EBShape,
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
      let holeSize = self.holeSize.cocoaSize
      let rHole = NSRect (x: center.x - holeSize.width / 2.0, y: center.y - holeSize.height / 2.0, width: holeSize.width, height: holeSize.height)
      bp.appendOblong (in: rHole)
      bp.windingRule = .evenOdd
      if let color = frontPadColor {
        ioShape.append (EBFilledBezierPathShape ([bp], color))
      }else if let color = backPadColor {
        ioShape.append (EBFilledBezierPathShape ([bp], color))
      }
    case .surface :
      switch side {
      case .front :
        if let color = frontPadColor {
          ioShape.append (EBFilledBezierPathShape ([bp], color))
        }
      case .back :
        if let color = backPadColor {
          ioShape.append (EBFilledBezierPathShape ([bp], color))
        }
      }
    }
  //--- Pad names
    if let textAttributes = padDisplayAttributes {
      var af = AffineTransform ()
      af.translate (x: center.x, y: center.y)
      af.prepend (padNumberAF)
      ioShape.append (EBTextShape (self.name, NSPoint (), textAttributes, .center, .center).transformed (by: af))
    }
  //--- Tool tip
    ioShape.addToolTip (rPad, inPadNetDictionary [self.name] ?? "No net")
  //--- Slave pads
    for pad in slavePads {
      pad.accumulatePadBezierPathes (
        into: ioShape,
        side: side,
        name: "(" + self.name + ")",
        padDisplayAttributes: padDisplayAttributes,
        padNumberAF: padNumberAF,
        frontPadColor: frontPadColor,
        backPadColor: backPadColor
      )
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct SlavePadDescriptor : Hashable {
  let center : CanariPoint
  let padSize : CanariSize
  let holeSize : CanariSize
  let shape : PadShape
  let style : SlavePadStyle

  func accumulatePadBezierPathes (into ioShape : EBShape,
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
        ioShape.append (EBFilledBezierPathShape ([bp], color))
      }else if let color = backPadColor {
        ioShape.append (EBFilledBezierPathShape ([bp], color))
      }
    case .topSide :
      switch side {
      case .front :
        if let color = frontPadColor {
          ioShape.append (EBFilledBezierPathShape ([bp], color))
        }
      case .back :
        if let color = backPadColor {
          ioShape.append (EBFilledBezierPathShape ([bp], color))
        }
      }
    case .bottomSide :
      switch side {
      case .front :
        if let color = backPadColor {
          ioShape.append (EBFilledBezierPathShape ([bp], color))
        }
      case .back :
        if let color = frontPadColor {
          ioShape.append (EBFilledBezierPathShape ([bp], color))
        }
      }
    }
  //--- Pad name
    if let textAttributes = padDisplayAttributes {
      var af = AffineTransform ()
      af.translate (x: center.x, y: center.y)
      af.prepend (padNumberAF)
      ioShape.append (EBTextShape (name, NSPoint (), textAttributes, .center, .center).transformed (by: af))
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct ComponentPadDescriptor : Hashable {
   let padName : String
   let padLocation : NSPoint
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

typealias ComponentPadDescriptorDictionary = [String : ComponentPadDescriptor]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
