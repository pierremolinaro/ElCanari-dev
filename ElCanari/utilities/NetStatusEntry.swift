//——————————————————————————————————————————————————————————————————————————————————————————————————
//
//  view-StatusStringArrayTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   Status
//——————————————————————————————————————————————————————————————————————————————————————————————————

enum Status : UInt, Hashable {
  case ok
  case warning
  case error
}

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   SubnetDescriptor
//——————————————————————————————————————————————————————————————————————————————————————————————————

struct SubnetDescriptor : Hashable {
  let status : Status
  let showExactlyOneLabelMessage : Bool
  let pins : [NetPinInSchematics]
  let labels : [NetLabelInSchematics]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   NetPinInSchematics
//——————————————————————————————————————————————————————————————————————————————————————————————————

struct NetPinInSchematics : Hashable {
  let pinName : String
  let sheetIndex : Int
  let locationInSheet : CanariPoint
  let location : SchematicSheetGeometry.PointLocationInfo // For example D1, H4, …
}

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   NetLabelInSchematics
//——————————————————————————————————————————————————————————————————————————————————————————————————

struct NetLabelInSchematics : Hashable {
  let labelName : String
  let sheetIndex : Int
  let locationInSheet : CanariPoint
  let location : SchematicSheetGeometry.PointLocationInfo // For example D1, H4, …
}

//——————————————————————————————————————————————————————————————————————————————————————————————————
