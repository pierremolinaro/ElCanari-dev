//
//  ProductLength.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

struct ProductLength : Codable, Hashable, Comparable {

  //································································································
  //  Property
  //································································································

  let valueInCanariUnit : Int

  //································································································
  //  Initializer
  //································································································

  static var zero : ProductLength { ProductLength (valueInCanariUnit: 0) }

  //································································································

  init (valueInCanariUnit inValue : Int) {
    self.valueInCanariUnit = inValue
  }

  //································································································

  init (_ inValue : Double, _ inUnit : Unit) {
    self.valueInCanariUnit = Int (inValue * inUnit.canariUnits)
  }

  //································································································
  //  Comparable protocol
  //································································································

  static func < (lhs: ProductLength, rhs: ProductLength) -> Bool {
    return lhs.valueInCanariUnit < rhs.valueInCanariUnit
  }

  //································································································
  //  Codable protocol
  //································································································

  func encode (to encoder : any Encoder) throws {
    try valueInCanariUnit.encode (to: encoder)
  }

  //································································································
  //  Decodable protocol
  //································································································

  init (from encoder : any Decoder) throws {
    self.valueInCanariUnit = try Int (from: encoder)
  }

  //································································································

  func value (in inUnit : ProductLength.Unit) -> Double {
    return Double (self.valueInCanariUnit) / inUnit.canariUnits
  }

  //································································································
  //   Enumeration
  //································································································

  enum Unit {
    case mm
    case cm
    case inch
    case mil
    case µm
    case cocoa // Cocoa point, Cocoa Pixel, 1/72 inch

    var canariUnits : Double {
      switch self {
        case .mm   : return Double (CANARI_UNITS_PER_MM)
        case .cm   : return Double (CANARI_UNITS_PER_CM)
        case .inch : return Double (CANARI_UNITS_PER_INCH)
        case .mil  : return Double (CANARI_UNITS_PER_MIL)
        case .µm  : return Double (CANARI_UNITS_PER_µM)
        case .cocoa  : return Double (CANARI_UNITS_PER_PIXEL)
      }
    }

//    var unitString : String {
//      switch self {
//        case .mm   : return "mm"
//        case .cm   : return "cm"
//        case .inch : return "inch"
//        case .mil  : return "mil"
//        case .µm  : return "µm"
//        case .cocoa  : return "px"
//      }
//    }

  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
