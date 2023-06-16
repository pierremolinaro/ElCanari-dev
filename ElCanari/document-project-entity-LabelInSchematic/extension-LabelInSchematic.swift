//
//  extension-LabelInSchematic.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let LABEL_IN_SCHEMATICS_TRANSLATION_KNOB = 0
let LABEL_IN_SCHEMATICS_ROTATION_KNOB = 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION LabelInSchematic
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension LabelInSchematic {

  //····················································································································

  func cursorForKnob_LabelInSchematic (knob inKnobIndex: Int) -> NSCursor? {
    if inKnobIndex == LABEL_IN_SCHEMATICS_TRANSLATION_KNOB {
      return NSCursor.upDownRightLeftCursor
    }else if inKnobIndex == LABEL_IN_SCHEMATICS_ROTATION_KNOB {
      return NSCursor.rotationCursor
    }else{
      return nil
    }
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_LabelInSchematic  (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //····················································································································

  func acceptToTranslate_LabelInSchematic (xBy _ : Int, yBy _ : Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_LabelInSchematic (xBy inDx: Int, yBy inDy: Int, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    if let point = self.mPoint, point.mSymbol == nil, !ioSet.contains (point) {
      ioSet.insert (point)
      point.mX += inDx
      point.mY += inDy
    }
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_LabelInSchematic (additionalDictionary _ : [String : Any],
                                               optionalDocument _ : EBAutoLayoutManagedDocument?,
                                               objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  HORIZONTAL FLIP
  //····················································································································

  func flipHorizontally_LabelInSchematic () {
  }

  //····················································································································

  func canFlipHorizontally_LabelInSchematic () -> Bool {
    return false
  }

  //····················································································································
  //  VERTICAL FLIP
  //····················································································································

  func flipVertically_LabelInSchematic () {
  }

  //····················································································································

  func canFlipVertically_LabelInSchematic () -> Bool {
    return false
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_LabelInSchematic (_ _ : inout [String : Any]) {
  }

  //····················································································································
  //  Move
  //····················································································································

  func canMove_LabelInSchematic (knob _ : Int,
                                 proposedUnalignedAlignedTranslation _ : CanariPoint,
                                 proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                                 unalignedMouseDraggedLocation _ : CanariPoint,
                                 shift _ : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  //····················································································································

  func move_LabelInSchematic (knob inKnobIndex: Int,
                              proposedDx inDx: Int,
                              proposedDy inDy: Int,
                              unalignedMouseLocationX _ : Int,
                              unalignedMouseLocationY _ : Int,
                              alignedMouseLocationX inAlignedMouseLocationX : Int,
                              alignedMouseLocationY inAlignedMouseLocationY : Int,
                              shift _ : Bool) {
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
  //  Snap to grid
  //····················································································································

  func snapToGrid_LabelInSchematic (_ _ : Int) {
  }

  //····················································································································

  func canSnapToGrid_LabelInSchematic (_ _ : Int) -> Bool {
    return false
  }

  //····················································································································
  //  Alignment Points
  //····················································································································

  func alignmentPoints_LabelInSchematic () -> Set <CanariPoint> {
    var s = Set <CanariPoint> ()
    if let point = self.mPoint {
      s.insertCanariPoint (x: point.mX, y: point.mY)
    }
    return s
  }

  //····················································································································
  //  ROTATE 90
  //····················································································································

  func canRotate90_LabelInSchematic (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insertCanariPoint (x: self.mPoint!.mX, y: self.mPoint!.mY)
    return true
  }

  //····················································································································

  func rotate90Clockwise_LabelInSchematic (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
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

  func rotate90CounterClockwise_LabelInSchematic (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
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

  func operationBeforeRemoving_LabelInSchematic () {
    self.mPoint = nil // Detach from point
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
