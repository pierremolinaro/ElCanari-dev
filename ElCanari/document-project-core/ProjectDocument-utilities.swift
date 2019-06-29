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

struct PinDescriptor : Hashable {
  let symbolIdentifier : SymbolInProjectIdentifier
  let pinName : String
  let pinLocation : CanariPoint
  let shape : EBShape
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct ComponentSymbolInfo : Equatable, Hashable {
  let filledBezierPath : NSBezierPath
  let strokeBezierPath : NSBezierPath
  let center : CanariPoint
  let pins : [PinDescriptor]
  let componentName : String
  let componentValue : String
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct DeviceSymbolInfo : Equatable {
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

typealias PackagePadDictionary = [String : MasterPadDescriptor]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Dictionary where Key == String, Value == MasterPadDescriptor {

  var masterPadsRect : CanariRect {
    var minX = Int.max
    var maxX = Int.min
    var minY = Int.max
    var maxY = Int.min
    for (_, descriptor) in self {
      let x = descriptor.centerX
      let y = descriptor.centerY
      if minX > x {
        minX = x
      }
      if maxX < x {
        maxX = x
      }
      if minY > y {
        minY = y
      }
      if maxY < y {
        maxY = y
      }
    }
    return CanariRect (left: minX, bottom: minY, width: maxX - minX, height: maxY - minY)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct MasterPadDescriptor : Hashable {
  let name : String
  let centerX : Int
  let centerY : Int
  let width : Int
  let height : Int
  let holeWidth : Int
  let holeHeight : Int
  let shape : PadShape
  let style : PadStyle
  let slavePads : [SlavePadDescriptor]

  func accumulatePadBezierPathes (into ioShape : EBShape,
                                  frontPadColor : NSColor,
                                  displayFrontPads : Bool,
                                  backPadColor : NSColor,
                                  displayBackPads : Bool) {
    let xCenter = canariUnitToCocoa (self.centerX)
    let yCenter = canariUnitToCocoa (self.centerY)
    let width = canariUnitToCocoa (self.width)
    let height = canariUnitToCocoa (self.height)
    let rPad = NSRect (x: xCenter - width / 2.0, y: yCenter - height / 2.0, width: width, height: height)
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
      let holeWidth = canariUnitToCocoa (self.holeWidth)
      let holeHeight = canariUnitToCocoa (self.holeHeight)
      let rHole = NSRect (x: xCenter - holeWidth / 2.0, y: yCenter - holeHeight / 2.0, width: holeWidth, height: holeHeight)
      bp.appendOblong (in: rHole)
      bp.windingRule = .evenOdd
      if displayFrontPads {
        ioShape.append (EBFilledBezierPathShape ([bp], frontPadColor))
      }else if displayBackPads {
        ioShape.append (EBFilledBezierPathShape ([bp], backPadColor))
      }
    case .surface :
      if displayFrontPads {
        ioShape.append (EBFilledBezierPathShape ([bp], frontPadColor))
      }
    }
  //--- Slave pads
    for pad in slavePads {
      pad.accumulatePadBezierPathes (
        into: ioShape,
        frontPadColor: frontPadColor,
        displayFrontPads: displayFrontPads,
        backPadColor: backPadColor,
        displayBackPads: displayBackPads
      )
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct SlavePadDescriptor : Hashable {
  let centerX : Int
  let centerY : Int
  let width : Int
  let height : Int
  let holeWidth : Int
  let holeHeight : Int
  let shape : PadShape
  let style : SlavePadStyle

  func accumulatePadBezierPathes (into ioShape : EBShape,
                                  frontPadColor : NSColor,
                                  displayFrontPads : Bool,
                                  backPadColor : NSColor,
                                  displayBackPads : Bool) {
    let xCenter = canariUnitToCocoa (self.centerX)
    let yCenter = canariUnitToCocoa (self.centerY)
    let width = canariUnitToCocoa (self.width)
    let height = canariUnitToCocoa (self.height)
    let rPad = NSRect (x: xCenter - width / 2.0, y: yCenter - height / 2.0, width: width, height: height)
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
      let holeWidth = canariUnitToCocoa (self.holeWidth)
      let holeHeight = canariUnitToCocoa (self.holeHeight)
      let rHole = NSRect (x: xCenter - holeWidth / 2.0, y: yCenter - holeHeight / 2.0, width: holeWidth, height: holeHeight)
      bp.appendOblong (in: rHole)
      bp.windingRule = .evenOdd
      if displayFrontPads {
        ioShape.append (EBFilledBezierPathShape ([bp], frontPadColor))
      }else if displayBackPads {
        ioShape.append (EBFilledBezierPathShape ([bp], backPadColor))
      }
    case .topSide :
      if displayFrontPads {
        ioShape.append (EBFilledBezierPathShape ([bp], frontPadColor))
      }
    case .bottomSide :
      if displayBackPads {
        ioShape.append (EBFilledBezierPathShape ([bp], backPadColor))
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
