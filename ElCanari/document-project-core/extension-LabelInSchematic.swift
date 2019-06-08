//
//  extension-LabelInSchematic.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION LabelInSchematic
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension LabelInSchematic {

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    let possibleSymbol = self.mPoint?.mSymbol
    return possibleSymbol == nil
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : OCObjectSet) {
    if let point = self.mPoint, point.mSymbol == nil, !ioSet.objects.contains (point) {
      ioSet.objects.insert (point)
      point.mX += inDx
      point.mY += inDy
    }
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int, newX inNewX : Int, newY inNewY : Int) {
    if let point = self.mPoint, point.mSymbol == nil {
      point.mX += inDx
      point.mY += inDy
    }
  }

  //····················································································································
  //  ROTATE 90 CLOCKWISE
  //····················································································································

  override func rotate90Clockwise () {
    switch self.mOrientation {
    case .rotation0 :
      self.mOrientation = .rotation270
    case .rotation90 :
      self.mOrientation = .rotation0
    case .rotation180 :
      self.mOrientation = .rotation90
    case .rotation270 :
      self.mOrientation = .rotation180
    }
  }

  //····················································································································

  override func canRotate90Clockwise () -> Bool {
    return true
  }

  //····················································································································
  //  ROTATE 90 COUNTER CLOCKWISE
  //····················································································································

  override func rotate90CounterClockwise () {
    switch self.mOrientation {
    case .rotation0 :
      self.mOrientation = .rotation90
    case .rotation90 :
      self.mOrientation = .rotation180
    case .rotation180 :
      self.mOrientation = .rotation270
    case .rotation270 :
      self.mOrientation = .rotation0
    }
  }

  //····················································································································

  override func canRotate90CounterClockwise () -> Bool {
    return true
  }

  //····················································································································

  override func operationBeforeRemoving () {
    self.mPoint = nil // Detach from point
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
