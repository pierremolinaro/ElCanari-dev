//
//  extension-LabelInSchematic.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/05/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

let LABEL_IN_SCHEMATICS_TRANSLATION_KNOB = 0
let LABEL_IN_SCHEMATICS_ROTATION_KNOB = 1

//----------------------------------------------------------------------------------------------------------------------
//   EXTENSION LabelInSchematic
//----------------------------------------------------------------------------------------------------------------------

extension LabelInSchematic {

  //····················································································································

  override func cursorForKnob (knob inKnobIndex: Int) -> NSCursor? {
    if inKnobIndex == LABEL_IN_SCHEMATICS_TRANSLATION_KNOB {
      return NSCursor.upDownRightLeftCursor
    }else if inKnobIndex == LABEL_IN_SCHEMATICS_ROTATION_KNOB {
      return NSCursor.rotationCursor
    }else{
      return nil
    }
  }

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : ObjcObjectSet) {
    if let point = self.mPoint, point.mSymbol == nil, !ioSet.contains (point) {
      ioSet.insert (point)
      point.mX += inDx
      point.mY += inDy
    }
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func move (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
    if let point = self.mPoint, point.mSymbol == nil {
      if inKnobIndex == LABEL_IN_SCHEMATICS_TRANSLATION_KNOB {
        point.mX += inDx
        point.mY += inDy
      }else if inKnobIndex == LABEL_IN_SCHEMATICS_ROTATION_KNOB {
        let newKnobLocation = CanariPoint (x: inAlignedMouseLocationX, y: inAlignedMouseLocationY)
        let p = CanariPoint (x: point.mX, y: point.mY)
        let angleInDegrees = CanariPoint.angleInRadian (p, newKnobLocation) * 180.0 / .pi
        if angleInDegrees <= 45.0 {
          self.mOrientation = .rotation0
        }else if angleInDegrees <= 135.0 {
          self.mOrientation = .rotation90
        }else if angleInDegrees <= 225.0 {
          self.mOrientation = .rotation180
        }else if angleInDegrees <= 315.0 {
          self.mOrientation = .rotation270
        }else{
          self.mOrientation = .rotation0
        }
      }
    }
  }

  //····················································································································
  //  ROTATE 90
  //····················································································································

  override func canRotate90 (accumulatedPoints : ObjcCanariPointSet) -> Bool {
    let p = CanariPoint (x: self.mPoint!.mX, y: self.mPoint!.mY)
    accumulatedPoints.insert (p)
    return true
  }

  //····················································································································

  override func rotate90Clockwise (from inRotationCenter : ObjcCanariPoint, userSet ioSet : ObjcObjectSet) {
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

  override func rotate90CounterClockwise (from inRotationCenter : ObjcCanariPoint, userSet ioSet : ObjcObjectSet) {
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

  override func operationBeforeRemoving () {
    self.mPoint = nil // Detach from point
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
