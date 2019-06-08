//
//  extension-NCInSchematic.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION NCInSchematic
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension NCInSchematic {

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
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
