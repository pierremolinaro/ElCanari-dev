//
//  extension-MergerBoardInstance-graphic.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION MergerBoardInstance
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension MergerBoardInstance {

  //····················································································································

  func acceptedTranslation_MergerBoardInstance (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    var acceptedX = inDx
    let newX = self.x + acceptedX
    if newX < 0 {
      acceptedX = -self.x
    }
    var acceptedY = inDy
    let newY = self.y + acceptedY
    if newY < 0 {
      acceptedY = -self.y
    }
    return CanariPoint (x: acceptedX, y: acceptedY)
  }

  //····················································································································

  func acceptToTranslate_MergerBoardInstance (xBy inDx: Int, yBy inDy: Int) -> Bool {
    let newX = self.x + inDx
    let newY = self.y + inDy
    return (newX >= 0) && (newY >= 0)
  }

  //····················································································································

  func translate_MergerBoardInstance (xBy inDx: Int, yBy inDy: Int, userSet ioSet : ObjcObjectSet) {
    self.x += inDx
    self.y += inDy
  }

  //····················································································································

  func operationBeforeRemoving_MergerBoardInstance () {
    super.operationBeforeRemoving ()
    self.myRoot_property.setProp (nil)
    self.myModel_property.setProp (nil)
  }

  //····················································································································
  //  Alignment Points
  //····················································································································

  func alignmentPoints_MergerBoardInstance () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
