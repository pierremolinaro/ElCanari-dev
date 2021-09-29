//
//  extension-BoardConnector.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let BOARD_CONNECTOR_KNOB  = 0

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION BoardConnector
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension BoardConnector {

  //····················································································································
  //  Cursor
  //····················································································································

  func cursorForKnob_BoardConnector (knob inKnobIndex: Int) -> NSCursor? {
    return nil // Uses default cursor
  }

  //····················································································································
  //  ROTATE 90
  //····················································································································

  func canRotate90_BoardConnector (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    return false
  }

  //····················································································································

  func rotate90Clockwise_BoardConnector (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <AnyObject>) {
  }

  //····················································································································

  func rotate90CounterClockwise_BoardConnector (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <AnyObject>) {
  }

  //····················································································································
  //  Alignment Points
  //····················································································································

  func alignmentPoints_BoardConnector () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  //····················································································································
  //  operationBeforeRemoving
  //····················································································································

  func operationBeforeRemoving_BoardConnector () {
  }

  //····················································································································

  func acceptToTranslate_BoardConnector (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_BoardConnector (xBy inDx : Int, yBy inDy : Int, userSet ioSet : inout EBReferenceSet <AnyObject>) {
    if !ioSet.contains (self) {
      ioSet.insert (self)
      self.mX += inDx
      self.mY += inDy
    }
  }

  //····················································································································
  //  Knob
  //····················································································································

  func canMove_BoardConnector (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                         shift inShift : Bool) -> CanariPoint {
    if (inKnobIndex == BOARD_CONNECTOR_KNOB) && !(self.connectedToComponent ?? true) {
      return inProposedAlignedTranslation
    }else{
      return CanariPoint (x: 0, y: 0)
    }
  }

  //····················································································································

  func move_BoardConnector (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
    if inKnobIndex == BOARD_CONNECTOR_KNOB {
      self.mX += inDx
      self.mY += inDy
    }
  }

  //····················································································································
  //   SNAP TO GRID
  //····················································································································

  func canSnapToGrid_BoardConnector (_ inGrid : Int) -> Bool {
    var isAligned = self.mX.isAlignedOnGrid (inGrid)
    if isAligned {
      isAligned = self.mY.isAlignedOnGrid (inGrid)
    }
    return !isAligned
  }

  //····················································································································

  func snapToGrid_BoardConnector (_ inGrid : Int) {
    self.mX.align (onGrid: inGrid)
    self.mY.align (onGrid: inGrid)
  }

  //····················································································································

  func connectedTracksNet () -> NetInProject? {
    var netSet = EBReferenceSet <NetInProject> ()
    for t in self.mTracksP1 {
      if let net = t.mNet {
        netSet.insert (net)
      }
    }
    for t in self.mTracksP2 {
      if let net = t.mNet {
        netSet.insert (net)
      }
    }
    if netSet.count == 1 {
      return netSet.first
    }else{
      return nil
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
