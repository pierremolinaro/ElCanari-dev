//
//  Turtle.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

struct Turtle {

  //··· Properties ·················································································

  private(set) var x : Double
  private(set) var y : Double
  private(set) var angleRadian : Double

  //··· Initializers ···············································································

  init () {
    self.x = 0.0
    self.y = 0.0
    self.angleRadian = 0.0
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (p inPoint : NSPoint, angleInRadian inAngle : Double) {
    self.x = inPoint.x
    self.y = inPoint.y
    self.angleRadian = inAngle
  }
  
  //··· Rotate ·····················································································

  mutating func rotate (radians inAngle : Double) {
    self.angleRadian += inAngle
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func rotate90 () {
    self.angleRadian += .pi / 2.0
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func rotate180 () {
    self.angleRadian += .pi
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func rotate270 () {
    self.angleRadian += 3.0 * .pi / 2.0
  }

  //··· Forward ···················································································

  mutating func forward (_ inLength : Double) {
    self.x += inLength * cos (self.angleRadian)
    self.y += inLength * sin (self.angleRadian)
  }

  //··· Left arc ···················································································

//  mutating func leftArc (radius inRadius : Length, angle inAngle : Angle) {
//    self.x -= inRadius.multipliedBy (sinOf: self.angle)
//    self.y += inRadius.multipliedBy (cosOf: self.angle)
//    let aa = self.angle - .degrees90 + inAngle
//    self.x += inRadius.multipliedBy (cosOf: aa)
//    self.y += inRadius.multipliedBy (sinOf: aa)
//    self.angle += inAngle
//  }

  //··· Right arc ··················································································

//  mutating func rightArc (radius inRadius : Length, angle inAngle : Angle) {
//    self.x += inRadius.multipliedBy (sinOf: self.angle)
//    self.y -= inRadius.multipliedBy (cosOf: self.angle)
//    let aa = self.angle + .degrees90 - inAngle
//    self.x += inRadius.multipliedBy (cosOf: aa)
//    self.y += inRadius.multipliedBy (sinOf: aa)
//    self.angle -= inAngle
//  }

  //··· Move ·······················································································

//  mutating func move (fromTurtle inTurtle : Turtle) {
//    self.x += inTurtle.x.multipliedBy (cosOf: self.angle)
//    self.y += inTurtle.x.multipliedBy (sinOf: self.angle)
//    self.x -= inTurtle.y.multipliedBy (sinOf: self.angle)
//    self.y += inTurtle.y.multipliedBy (cosOf: self.angle)
//    self.angle += inTurtle.angle
//  }

  //··· Current ····················································································

  var location : NSPoint { NSPoint (x: self.x, y: self.y) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  var isZero : Bool {
//    return self.x.isZero && self.y.isZero && self.angle.isZero
//  }

  //··· Print ······················································································

//  func print () {
//    Swift.print ("  x = \(self.x.string (in: .mm)), y = \(self.y.string (in: .mm)), a = \(self.angle.string (in: .degree))")
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
