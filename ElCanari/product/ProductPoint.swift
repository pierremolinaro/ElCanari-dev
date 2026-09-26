//
//  ProductPoint.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

struct ProductPoint : Codable, Equatable, CustomStringConvertible {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let x : ProductLength
  let y : ProductLength

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static var zero : ProductPoint { ProductPoint (x: .zero, y: .zero) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (x inX : ProductLength, y inY : ProductLength) {
    self.x = inX
    self.y = inY
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (x inX : Double, _ inXUnit : ProductLength.Unit,
        y inY : Double, _ inYUnit : ProductLength.Unit) {
    self.x = ProductLength (inX, inXUnit)
    self.y = ProductLength (inY, inYUnit)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (canariPoint inCanariPoint : CanariPoint) {
    self.x = ProductLength (valueInCanariUnit: inCanariPoint.x)
    self.y = ProductLength (valueInCanariUnit: inCanariPoint.y)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (cocoaPoint inPoint : NSPoint) {
    self.x = ProductLength (inPoint.x, .pt)
    self.y = ProductLength (inPoint.y, .pt)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var cocoaPoint : NSPoint { NSPoint (x: self.x.value (in: .pt), y: self.y.value (in: .pt)) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var description : String {
    "(\(self.x), \(self.y))"
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
