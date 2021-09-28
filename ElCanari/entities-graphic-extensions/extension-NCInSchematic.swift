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
  //  Translation
  //····················································································································

  func acceptedTranslation_NCInSchematic (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //····················································································································

  func acceptToTranslate_NCInSchematic (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_NCInSchematic (xBy inDx: Int, yBy inDy: Int, userSet ioSet : ObjcObjectSet) {
  }

  //····················································································································
  //  Alignment Points
  //····················································································································

  func alignmentPoints_NCInSchematic () -> ObjcCanariPointSet {
    return ObjcCanariPointSet ()
  }

  //····················································································································
  //  ROTATE 90
  //····················································································································

  func canRotate90_NCInSchematic (accumulatedPoints : ObjcCanariPointSet) -> Bool {
    let p = self.mPoint!.location!
    accumulatedPoints.insert (p)
    return true
  }

  //····················································································································

  func rotate90Clockwise_NCInSchematic (from inRotationCenter : CanariPoint, userSet ioSet : ObjcObjectSet) {
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

  func rotate90CounterClockwise_NCInSchematic (from inRotationCenter : CanariPoint, userSet ioSet : ObjcObjectSet) {
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

  func operationBeforeRemoving_NCInSchematic () {
    self.mPoint = nil // Detach from point
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
