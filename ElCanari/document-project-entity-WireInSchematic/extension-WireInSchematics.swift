//
//  extension-WireInSchematic.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let WIRE_CENTER_KNOB = 0
let WIRE_P1_KNOB = 1
let WIRE_P2_KNOB = 2

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION WireInSchematic
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension WireInSchematic {

  //····················································································································

  func cursorForKnob_WireInSchematic (knob inKnobIndex: Int) -> NSCursor? {
    return NSCursor.upDownRightLeftCursor
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_WireInSchematic (additionalDictionary inDictionary : NSDictionary,
                                             optionalDocument inOptionalDocument : EBAutoLayoutManagedDocument?,
                                             objectArray inObjectArray : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  HORIZONTAL FLIP
  //····················································································································

  func flipHorizontally_WireInSchematic () {
  }

  //····················································································································

  func canFlipHorizontally_WireInSchematic () -> Bool {
    return false
  }

  //····················································································································
  //  VERTICAL FLIP
  //····················································································································

  func flipVertically_WireInSchematic () {
  }

  //····················································································································

  func canFlipVertically_WireInSchematic () -> Bool {
    return false
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_WireInSchematic (_ ioDictionary : NSMutableDictionary) {
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_WireInSchematic (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }
  //····················································································································

  func acceptToTranslate_WireInSchematic (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_WireInSchematic (xBy inDx: Int, yBy inDy: Int, userSet ioSet : inout EBReferenceSet <AnyObject>) {
    if let p1 = self.mP1, !ioSet.contains (p1) {
      ioSet.insert (p1)
      p1.mX += inDx
      p1.mY += inDy
    }
    if let p2 = self.mP2, !ioSet.contains (p2) {
      ioSet.insert (p2)
      p2.mX += inDx
      p2.mY += inDy
    }
  }

  //····················································································································
  //  ROTATE 90
  //····················································································································

  func canRotate90_WireInSchematic (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    return false
  }

  //····················································································································

  func rotate90Clockwise_WireInSchematic (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <AnyObject>) {
  }

  //····················································································································

  func rotate90CounterClockwise_WireInSchematic (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <AnyObject>) {
  }

  //····················································································································
  //  Snap to grid
  //····················································································································

  func snapToGrid_WireInSchematic (_ inGrid : Int) {
  }

  //····················································································································

  func canSnapToGrid_WireInSchematic (_ inGrid : Int) -> Bool {
    return false
  }

  //····················································································································
  //  Alignment Points
  //····················································································································

  func alignmentPoints_WireInSchematic () -> Set <CanariPoint> {
    var s = Set <CanariPoint> ()
    if let point = self.mP1 {
      s.insertCanariPoint (x: point.mX, y: point.mY)
    }
    if let point = self.mP2 {
      s.insertCanariPoint (x: point.mX, y: point.mY)
    }
    return s
  }

  //····················································································································
  //  Knob
  //····················································································································

  func canMove_WireInSchematic (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                         shift inShift : Bool) -> CanariPoint {
    if inKnobIndex == WIRE_CENTER_KNOB, self.mP1?.mSymbol == nil, self.mP2?.mSymbol == nil {
      return CanariPoint (x: inProposedAlignedTranslation.x, y: inProposedAlignedTranslation.y)
    }else if inKnobIndex == WIRE_P1_KNOB, let point = self.mP1, point.mSymbol == nil, let other = self.mP2 {
      if ((point.mX + inProposedAlignedTranslation.x) == other.mX) && ((point.mY + inProposedAlignedTranslation.y) == other.mY) {
        return CanariPoint (x: 0, y: 0)
      }else{
        return inProposedAlignedTranslation
      }
    }else if inKnobIndex == WIRE_P2_KNOB, let point = self.mP2, point.mSymbol == nil, let other = self.mP1 {
      if ((point.mX + inProposedAlignedTranslation.x) == other.mX) && ((point.mY + inProposedAlignedTranslation.y) == other.mY) {
        return CanariPoint (x: 0, y: 0)
      }else{
        return inProposedAlignedTranslation
      }
    }else{
      return CanariPoint (x: 0, y: 0)
    }
  }

  //····················································································································

  func move_WireInSchematic (knob inKnobIndex: Int,
                             proposedDx inDx: Int,
                             proposedDy inDy: Int,
                             unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                             unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                             alignedMouseLocationX inAlignedMouseLocationX : Int,
                             alignedMouseLocationY inAlignedMouseLocationY : Int,
                             shift inShift : Bool) {
    if inKnobIndex == WIRE_CENTER_KNOB, let p1 = self.mP1, p1.mSymbol == nil, let p2 = self.mP2, p2.mSymbol == nil {
      p1.mX += inDx
      p1.mY += inDy
      p2.mX += inDx
      p2.mY += inDy
    }else if inKnobIndex == WIRE_P1_KNOB, let point = self.mP1, point.mSymbol == nil {
      point.mX += inDx
      point.mY += inDy
    }else if inKnobIndex == WIRE_P2_KNOB, let point = self.mP2, point.mSymbol == nil {
      point.mX += inDx
      point.mY += inDy
    }
  }

  //····················································································································
  //  REMOVING
  //····················································································································

  func operationBeforeRemoving_WireInSchematic () {
    var pointSet = EBReferenceSet <PointInSchematic> ()
    if let p1 = self.mP1 {
      pointSet.insert (p1)
      self.mP1 = nil // Detach from point
    }
    if let p2 = self.mP2 {
      pointSet.insert (p2)
      self.mP2 = nil // Detach from point
    }
    self.mSheet?.updateConnections (pointSet : pointSet)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
