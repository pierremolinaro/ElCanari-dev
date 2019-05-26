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
  let netName : String
  let netClassName : String
  let pins : StringArray
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct SchematicPointStatus : Hashable {
  let location : CanariPoint
  let connected : Bool
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
