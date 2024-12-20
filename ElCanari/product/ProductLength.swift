//
//  ProductLength.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------
//  Operators
//--------------------------------------------------------------------------------------------------

prefix func - (_ inOperand : ProductLength) -> ProductLength {
  return inOperand.multipliedBy (-1.0)
}

//--------------------------------------------------------------------------------------------------

func - (_ inLeft : ProductLength, _ inRight : ProductLength) -> ProductLength {
  return ProductLength ([inLeft, -inRight])
}

//--------------------------------------------------------------------------------------------------

struct ProductLength : Codable, Hashable, Comparable, CustomStringConvertible {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Property
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let valueInCanariUnit : Int

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Initializer
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static var zero : ProductLength { ProductLength (valueInCanariUnit: 0) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inValueArray : [ProductLength]) {
    var v = 0
    for element in inValueArray {
      v += element.valueInCanariUnit
    }
    self.valueInCanariUnit = v
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (valueInCanariUnit inValue : Int) {
    self.valueInCanariUnit = inValue
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inValue : Double, _ inUnit : Unit) {
    self.valueInCanariUnit = Int (inValue * inUnit.canariUnits)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inValue : ProductLength, multipliedBy inOperand : Double) {
    self.valueInCanariUnit = Int (Double (inValue.valueInCanariUnit) * inOperand)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func multipliedBy (_ inValue : Double) -> ProductLength {
    return ProductLength (self, multipliedBy: inValue)
  }


  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Comparable protocol
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func < (lhs: ProductLength, rhs: ProductLength) -> Bool {
    return lhs.valueInCanariUnit < rhs.valueInCanariUnit
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Codable protocol
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func encode (to encoder : any Encoder) throws {
    try valueInCanariUnit.encode (to: encoder)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Decodable protocol
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (from encoder : any Decoder) throws {
    self.valueInCanariUnit = try Int (from: encoder)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func value (in inUnit : ProductLength.Unit) -> Double {
    return Double (self.valueInCanariUnit) / inUnit.canariUnits
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Enumeration
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var description : String {
    "\(self.value (in: .mm)) mm"
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
