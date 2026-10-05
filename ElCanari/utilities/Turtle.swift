//
//  Turtle.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation
import CanariGeometry

//--------------------------------------------------------------------------------------------------

struct Turtle {

  // - - Properties  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var x : CanariLength
  private var y : CanariLength
  private var angle : CanariAngle

  // -  Initializers - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    self.x = .zero
    self.y = .zero
    self.angle = .zero
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (p inPoint : CanariPoint, angle inAngle : CanariAngle) {
    self.x = inPoint.x
    self.y = inPoint.y
    self.angle = inAngle
  }
  
  //··· Rotate ·····················································································

  mutating func rotate (by inAngle : CanariAngle) {
    self.angle += inAngle
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func rotate90 () {
    self.angle += .degrees90
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func rotate180 () {
    self.angle += .degrees180
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func rotate270 () {
    self.angle += .degrees270
  }

  //··· Forward ···················································································

  mutating func forward (_ inLength : CanariLength) {
    self.x += inLength * cos (self.angle)
    self.y += inLength * sin (self.angle)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var location : CanariPoint { CanariPoint (x: self.x, y: self.y) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
