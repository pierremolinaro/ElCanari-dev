//
//  ProjectDocument-utilities.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SCHEMATICS_GRID_IN_MILS = 50
let SCHEMATICS_GRID_IN_CANARI_UNIT = milsToCanariUnit (SCHEMATICS_GRID_IN_MILS)

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct SymbolInProjectIdentifier : Hashable {
  let symbolInstanceName : String
  let symbolTypeName : String
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct PinDescriptor : Hashable {
  let symbolIdentifier : SymbolInProjectIdentifier
  let pinName : String
  let pinLocation : NSPoint
  let shape : EBShape
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct ComponentSymbolInfo : Hashable {
  let filledBezierPath : NSBezierPath
  let strokeBezierPath : NSBezierPath
  let center : CanariPoint
  let pins : [PinDescriptor]
  let componentName : String
  let componentValue : String
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct DeviceSymbolInfo {
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

