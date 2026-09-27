//
//  ProductPoint.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation
import CanariGeometry

//--------------------------------------------------------------------------------------------------

struct ProductPoint : Codable, Equatable, CustomStringConvertible {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let x : CanariLength
  let y : CanariLength

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static var zero : ProductPoint { ProductPoint (x: .zero, y: .zero) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (x inX : CanariLength, y inY : CanariLength) {
    self.x = inX
    self.y = inY
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (x inX : Double, _ inXUnit : CanariLength.Unit,
        y inY : Double, _ inYUnit : CanariLength.Unit) {
    self.x = CanariLength (inX, in: inXUnit)
    self.y = CanariLength (inY, in: inYUnit)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (canariPoint inCanariPoint : CanariPoint) {
    self.x = CanariLength.cu (inCanariPoint.x)
    self.y = CanariLength.cu (inCanariPoint.y)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (cocoaPoint inPoint : NSPoint) {
    self.x = CanariLength.pt (inPoint.x)
    self.y = CanariLength.pt (inPoint.y)
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
