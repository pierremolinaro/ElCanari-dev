//
//  extension-WireInSchematics.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let WIRE_P1_KNOB = 0
let WIRE_P2_KNOB = 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION WireInSchematics
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension WireInSchematics {

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    if let p1 = self.mP1, p1.mSymbol == nil, let p2 = self.mP2, p2.mSymbol == nil {
      return true
    }else{
      return false
    }
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int) {
    if let p1 = self.mP1, p1.mSymbol == nil, let p2 = self.mP2, p2.mSymbol == nil {
      p1.mX += inDx
      p1.mY += inDy
      p2.mX += inDx
      p2.mY += inDy
    }
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int, newX inNewX : Int, newY inNewY : Int) {
    if inKnobIndex == WIRE_P1_KNOB, let point = self.mP1, point.mSymbol == nil {
      point.mX += inDx
      point.mY += inDy
    }else if inKnobIndex == WIRE_P2_KNOB, let point = self.mP2, point.mSymbol == nil {
      point.mX += inDx
      point.mY += inDy
    }
  }

  //····················································································································
  //  ROTATE 90 CLOCKWISE
  //····················································································································

//  override func rotate90Clockwise () {
//    switch self.mOrientation {
//    case .rotation0 :
//      self.mOrientation = .rotation270
//    case .rotation90 :
//      self.mOrientation = .rotation0
//    case .rotation180 :
//      self.mOrientation = .rotation90
//    case .rotation270 :
//      self.mOrientation = .rotation180
//    }
//  }

  //····················································································································

//  override func canRotate90Clockwise () -> Bool {
//    return true
//  }

  //····················································································································
  //  ROTATE 90 COUNTER CLOCKWISE
  //····················································································································

//  override func rotate90CounterClockwise () {
//    switch self.mOrientation {
//    case .rotation0 :
//      self.mOrientation = .rotation90
//    case .rotation90 :
//      self.mOrientation = .rotation180
//    case .rotation180 :
//      self.mOrientation = .rotation270
//    case .rotation270 :
//      self.mOrientation = .rotation0
//    }
//  }

  //····················································································································

//  override func canRotate90CounterClockwise () -> Bool {
//    return true
//  }

  //····················································································································

  override func operationBeforeRemoving () {
    self.mP1 = nil // Detach from point
    self.mP2 = nil // Detach from point
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
