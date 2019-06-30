//
//  extension-ComponentInProject.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/06/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let COMPONENT_PACKAGE_CENTER_KNOB  = 0
let COMPONENT_PACKAGE_ROTATION_KNOB  = 1
let COMPONENT_PACKAGE_NAME_KNOB  = 2

let COMPONENT_PACKAGE_ROTATION_KNOB_DISTANCE : CGFloat = 30.0

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION ComponentInProject
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ComponentInProject {

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx : Int, yBy inDy : Int, userSet ioSet : OCObjectSet) {
    self.mX += inDx
    self.mY += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) -> OCCanariPoint {
    if inKnobIndex == COMPONENT_PACKAGE_CENTER_KNOB {
      return OCCanariPoint (x: inDx, y: inDy)
    }else if inKnobIndex == COMPONENT_PACKAGE_ROTATION_KNOB {
      return OCCanariPoint (x: inDx, y: inDy)
    }else if inKnobIndex == COMPONENT_PACKAGE_NAME_KNOB {
      return OCCanariPoint (x: inDx, y: inDy)
    }else{
      return OCCanariPoint (x: 0, y: 0)
    }
  }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int, newX inNewX : Int, newY inNewY : Int) {
    if inKnobIndex == COMPONENT_PACKAGE_CENTER_KNOB {
      self.mX += inDx
      self.mY += inDy
    }else if inKnobIndex == COMPONENT_PACKAGE_ROTATION_KNOB {
      let absoluteCenter = CanariPoint (x: self.mX, y: self.mY).cocoaPoint
      let newRotationKnobLocation = CanariPoint (x: inNewX, y: inNewY).cocoaPoint
      let newAngleInDegrees = angleInDegreesBetweenNSPoints (absoluteCenter, newRotationKnobLocation)
      self.mRotation = degreesToCanariRotation (newAngleInDegrees)
    }else if inKnobIndex == COMPONENT_PACKAGE_NAME_KNOB {
      self.mXName += inDx
      self.mYName += inDy
    }
  }

  //····················································································································
  //   SNAP TO GRID
  //····················································································································

  override func canSnapToGrid (_ inGrid : Int) -> Bool {
    var isAligned = self.mX.isAlignedOnGrid (inGrid)
    if isAligned {
      isAligned = self.mY.isAlignedOnGrid (inGrid)
    }
    return !isAligned
  }

  //····················································································································

  override func snapToGrid (_ inGrid : Int) {
    self.mX.align (onGrid: inGrid)
    self.mY.align (onGrid: inGrid)
  }

  //····················································································································
  //  REMOVING
  //····················································································································

  override func operationBeforeRemoving () {
//    self.mFont = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
