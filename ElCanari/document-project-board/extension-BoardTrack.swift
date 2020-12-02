//
//  extension-BoardTrack.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/07/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

let BOARD_TRACK_P1  = 0
let BOARD_TRACK_P2  = 1

//----------------------------------------------------------------------------------------------------------------------
//   EXTENSION BoardTrack
//----------------------------------------------------------------------------------------------------------------------

extension BoardTrack {

  //····················································································································

  override func cursorForKnob (knob inKnobIndex: Int) -> NSCursor? {
    return NSCursor.upDownRightLeftCursor
  }

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx : Int, yBy inDy : Int, userSet ioSet : OCObjectSet) {
    if let connectorP1 = self.mConnectorP1, !ioSet.contains (connectorP1) {
      ioSet.insert (connectorP1)
      connectorP1.mX += inDx
      connectorP1.mY += inDy
    }
    if let connectorP2 = self.mConnectorP2, !ioSet.contains (connectorP2) {
      ioSet.insert (connectorP2)
      connectorP2.mX += inDx
      connectorP2.mY += inDy
    }
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int,
                         proposedAlignedTranslation inProposedAlignedTranslation : OCCanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : OCCanariPoint) -> OCCanariPoint {
    if let connectorP1 = self.mConnectorP1, let connectorP2 = self.mConnectorP2 {
      let shift = NSApp.currentEvent?.modifierFlags.contains (.shift) ?? false
      if inKnobIndex == BOARD_TRACK_P1 {
        if shift {
          return inProposedAlignedTranslation
        }else{
          var p1 = inUnalignedMouseDraggedLocation.p
          p1.quadrantAligned (from: CanariPoint (x: connectorP2.mX, y: connectorP2.mY))
          return OCCanariPoint (x: p1.x - connectorP1.mX, y: p1.y - connectorP1.mY)
        }
      }else if inKnobIndex == BOARD_TRACK_P2 {
        if shift {
          return inProposedAlignedTranslation
        }else{
          var p2 = inUnalignedMouseDraggedLocation.p
          p2.quadrantAligned (from: CanariPoint (x: connectorP1.mX, y: connectorP1.mY))
          return OCCanariPoint (x: p2.x - connectorP2.mX, y: p2.y - connectorP2.mY)
        }
      }else{
        return OCCanariPoint (x: 0, y:0)
      }
    }else{
      return OCCanariPoint (x: 0, y:0)
    }
  }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int, newX inNewX : Int, newY inNewY : Int) {
    if inKnobIndex == BOARD_TRACK_P1 {
      self.mConnectorP1?.mX += inDx
      self.mConnectorP1?.mY += inDy
    }else if inKnobIndex == BOARD_TRACK_P2 {
      self.mConnectorP2?.mX += inDx
      self.mConnectorP2?.mY += inDy
    }
  }

  //····················································································································
  //  Rotate 90°
  //····················································································································

  override func canRotate90 (accumulatedPoints : OCCanariPointSet) -> Bool {
    if let p1 = self.mConnectorP1?.location, let p2 = self.mConnectorP2?.location {
      accumulatedPoints.insert (CanariPoint (x: p1.x, y: p1.y))
      accumulatedPoints.insert (CanariPoint (x: p2.x, y: p2.y))
      return true
    }else{
      return false
    }
  }

  //····················································································································

  override func rotate90Clockwise (from inRotationCenter : OCCanariPoint, userSet ioSet : OCObjectSet) {
    if let connectorP1 = self.mConnectorP1, let connectorP2 = self.mConnectorP2 {
      if !ioSet.contains (connectorP1) {
        let p = inRotationCenter.rotated90Clockwise (x: connectorP1.mX, y: connectorP1.mY)
        connectorP1.mX = p.x
        connectorP1.mY = p.y
        ioSet.insert (connectorP1)
      }
      if !ioSet.contains (connectorP2) {
        let p = inRotationCenter.rotated90Clockwise (x: connectorP2.mX, y: connectorP2.mY)
        connectorP2.mX = p.x
        connectorP2.mY = p.y
        ioSet.insert (connectorP2)
      }
    }
  }

  //····················································································································

  override func rotate90CounterClockwise (from inRotationCenter : OCCanariPoint, userSet ioSet : OCObjectSet) {
    if let connectorP1 = self.mConnectorP1, let connectorP2 = self.mConnectorP2 {
      if !ioSet.contains (connectorP1) {
        let p = inRotationCenter.rotated90CounterClockwise (x: connectorP1.mX, y: connectorP1.mY)
        connectorP1.mX = p.x
        connectorP1.mY = p.y
        ioSet.insert (connectorP1)
      }
      if !ioSet.contains (connectorP2) {
        let p = inRotationCenter.rotated90CounterClockwise (x: connectorP2.mX, y: connectorP2.mY)
        connectorP2.mX = p.x
        connectorP2.mY = p.y
        ioSet.insert (connectorP2)
      }
    }
  }

  //····················································································································
  //   SNAP TO GRID
  //····················································································································

  override func canSnapToGrid (_ inGrid : Int) -> Bool {
    var isAligned = self.mConnectorP1?.mX.isAlignedOnGrid (inGrid) ?? true
    if isAligned, let connectorP1 = self.mConnectorP1 {
      isAligned = connectorP1.mY.isAlignedOnGrid (inGrid)
    }
    if isAligned, let connectorP2 = self.mConnectorP2 {
      isAligned = connectorP2.mX.isAlignedOnGrid (inGrid)
    }
    if isAligned, let connectorP2 = self.mConnectorP2 {
      isAligned = connectorP2.mY.isAlignedOnGrid (inGrid)
    }
    return !isAligned
  }

  //····················································································································

  override func snapToGrid (_ inGrid : Int) {
    self.mConnectorP1?.mX.align (onGrid: inGrid)
    self.mConnectorP1?.mY.align (onGrid: inGrid)
    self.mConnectorP2?.mX.align (onGrid: inGrid)
    self.mConnectorP2?.mY.align (onGrid: inGrid)
  }

  //····················································································································
  //  REMOVING
  //····················································································································

  override func operationBeforeRemoving () {
    let optionalNet = self.mNet
    self.mConnectorP1 = nil
    self.mConnectorP2 = nil
    self.mNet = nil
    if let net = optionalNet, net.mPoints.count == 0, net.mTracks.count == 0 {
      net.mNetClass = nil // Remove net
    }
  }
  
  //····················································································································
  //  Bezier path
  //····················································································································

  func bezierPath (extraWidth inExtraWidth : Int) -> EBBezierPath {
    var bp = EBBezierPath ()
    bp.lineWidth = canariUnitToCocoa (self.actualTrackWidth! + inExtraWidth)
    bp.lineCapStyle = .round
    bp.lineJoinStyle = .round
    bp.move (to: self.mConnectorP1!.location!.cocoaPoint)
    bp.line (to: self.mConnectorP2!.location!.cocoaPoint)
    return bp.pathByStroking
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
