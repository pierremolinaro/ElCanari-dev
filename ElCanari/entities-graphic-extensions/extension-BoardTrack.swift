//
//  extension-BoardTrack.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/07/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let BOARD_TRACK_P1  = 0
let BOARD_TRACK_P2  = 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION BoardTrack
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension BoardTrack {

  //····················································································································

  func cursorForKnob_BoardTrack (knob inKnobIndex: Int) -> NSCursor? {
    return NSCursor.upDownRightLeftCursor
  }

  //····················································································································

  func acceptToTranslate_BoardTrack (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_BoardTrack (xBy inDx : Int, yBy inDy : Int, userSet ioSet : ObjcObjectSet) {
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

  func canMove_BoardTrack (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                         shift inShift : Bool) -> CanariPoint {
    return inProposedUnalignedTranslation
//    if let p1 = self.mConnectorP1?.location, let p2 = self.mConnectorP2?.location {
//      if inKnobIndex == BOARD_TRACK_P1 {
//        if inShift {
//          return inProposedUnalignedTranslation
//        }else{
//          var p = inUnalignedMouseDraggedLocation.p
//          p.quadrantAligned (from: p2)
//          return CanariPoint (x: p.x - p1.x, y: p.y - p1.y)
//        }
//      }else if inKnobIndex == BOARD_TRACK_P2 {
//        if inShift {
//          return inProposedUnalignedTranslation
//        }else{
//          var p = inUnalignedMouseDraggedLocation.p
//          p.quadrantAligned (from: p1)
//          return CanariPoint (x: p.x - p2.x, y: p.y - p2.y)
//        }
//      }else{
//        return CanariPoint ()
//      }
//    }else{
//      return CanariPoint ()
//    }
  }

  //····················································································································

  func move_BoardTrack (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnalignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnalignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
    if inKnobIndex == BOARD_TRACK_P1 {
      switch self.mDirectionLockOnKnobDragging {
      case .unlocked :
        self.mConnectorP1?.mX = inUnalignedMouseLocationX
        self.mConnectorP1?.mY = inUnalignedMouseLocationY
      case .locked :
        let p1 = self.mConnectorP1!.location!
        let p2 = self.mConnectorP2!.location!
        let angle = Double (CanariPoint.angleInRadian (p1, p2))
        let newLength : Double = Double (inUnalignedMouseLocationX - p2.x) * cos (angle) + Double (inUnalignedMouseLocationY - p2.y) * sin (angle)
        let newP1X = p2.x + Int ((newLength * cos (angle)).rounded ())
        let newP1Y = p2.y + Int ((newLength * sin (angle)).rounded ())
        self.mConnectorP1?.mX = newP1X
        self.mConnectorP1?.mY = newP1Y
      case .octolinear :
        let p2 = self.mConnectorP2!.location!
        let inUnalignedMouseLocation = CanariPoint (x: inUnalignedMouseLocationX, y: inUnalignedMouseLocationY)
        let angle = Double (CanariPoint.octolinearNearestAngleInDegrees (inUnalignedMouseLocation, p2)) * .pi / 180.0
        let newLength : Double = Double (inUnalignedMouseLocationX - p2.x) * cos (angle) + Double (inUnalignedMouseLocationY - p2.y) * sin (angle)
        let newP1X = p2.x + Int ((newLength * cos (angle)).rounded ())
        let newP1Y = p2.y + Int ((newLength * sin (angle)).rounded ())
        self.mConnectorP1?.mX = newP1X
        self.mConnectorP1?.mY = newP1Y
      case .rectilinear :
        let p2 = self.mConnectorP2!.location!
        let inUnalignedMouseLocation = CanariPoint (x: inUnalignedMouseLocationX, y: inUnalignedMouseLocationY)
        let angle = Double (CanariPoint.rectilinearNearestAngleInDegrees (inUnalignedMouseLocation, p2)) * .pi / 180.0
        let newLength : Double = Double (inUnalignedMouseLocationX - p2.x) * cos (angle) + Double (inUnalignedMouseLocationY - p2.y) * sin (angle)
        let newP1X = p2.x + Int ((newLength * cos (angle)).rounded ())
        let newP1Y = p2.y + Int ((newLength * sin (angle)).rounded ())
        self.mConnectorP1?.mX = newP1X
        self.mConnectorP1?.mY = newP1Y      }
    }else if inKnobIndex == BOARD_TRACK_P2 {
      switch self.mDirectionLockOnKnobDragging {
      case .unlocked :
        self.mConnectorP2?.mX = inUnalignedMouseLocationX
        self.mConnectorP2?.mY = inUnalignedMouseLocationY
      case .locked :
        let p1 = self.mConnectorP1!.location!
        let p2 = self.mConnectorP2!.location!
        let angle = Double (CanariPoint.angleInRadian (p1, p2))
        let newLength : Double = Double (inUnalignedMouseLocationX - p1.x) * cos (angle) + Double (inUnalignedMouseLocationY - p1.y) * sin (angle)
        let newP2X = p1.x + Int ((newLength * cos (angle)).rounded ())
        let newP2Y = p1.y + Int ((newLength * sin (angle)).rounded ())
        self.mConnectorP2?.mX = newP2X
        self.mConnectorP2?.mY = newP2Y
      case .octolinear :
        let p1 = self.mConnectorP1!.location!
        let inUnalignedMouseLocation = CanariPoint (x: inUnalignedMouseLocationX, y: inUnalignedMouseLocationY)
        let angle = Double (CanariPoint.octolinearNearestAngleInDegrees (p1, inUnalignedMouseLocation)) * .pi / 180.0
        let newLength : Double = Double (inUnalignedMouseLocationX - p1.x) * cos (angle) + Double (inUnalignedMouseLocationY - p1.y) * sin (angle)
        let newP2X = p1.x + Int ((newLength * cos (angle)).rounded ())
        let newP2Y = p1.y + Int ((newLength * sin (angle)).rounded ())
        self.mConnectorP2?.mX = newP2X
        self.mConnectorP2?.mY = newP2Y
      case .rectilinear :
        let p1 = self.mConnectorP1!.location!
        let inUnalignedMouseLocation = CanariPoint (x: inUnalignedMouseLocationX, y: inUnalignedMouseLocationY)
        let angle = Double (CanariPoint.rectilinearNearestAngleInDegrees (p1, inUnalignedMouseLocation)) * .pi / 180.0
        let newLength : Double = Double (inUnalignedMouseLocationX - p1.x) * cos (angle) + Double (inUnalignedMouseLocationY - p1.y) * sin (angle)
        let newP2X = p1.x + Int ((newLength * cos (angle)).rounded ())
        let newP2Y = p1.y + Int ((newLength * sin (angle)).rounded ())
        self.mConnectorP2?.mX = newP2X
        self.mConnectorP2?.mY = newP2Y
      }
    }
  }

  //····················································································································
  //  Rotate 90°
  //····················································································································

  func canRotate90_BoardTrack (accumulatedPoints : ObjcCanariPointSet) -> Bool {
    if let p1 = self.mConnectorP1?.location, let p2 = self.mConnectorP2?.location {
      accumulatedPoints.insert (CanariPoint (x: p1.x, y: p1.y))
      accumulatedPoints.insert (CanariPoint (x: p2.x, y: p2.y))
      return true
    }else{
      return false
    }
  }

  //····················································································································

  func rotate90Clockwise_BoardTrack (from inRotationCenter : CanariPoint, userSet ioSet : ObjcObjectSet) {
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

  func rotate90CounterClockwise_BoardTrack (from inRotationCenter : CanariPoint, userSet ioSet : ObjcObjectSet) {
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
  //  Alignment Points
  //····················································································································

  func alignmentPoints_BoardTrack () -> ObjcCanariPointSet {
    return ObjcCanariPointSet ()
  }

  //····················································································································
  //   SNAP TO GRID
  //····················································································································

  func canSnapToGrid_BoardTrack (_ inGrid : Int) -> Bool {
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

  func snapToGrid_BoardTrack (_ inGrid : Int) {
    self.mConnectorP1?.mX.align (onGrid: inGrid)
    self.mConnectorP1?.mY.align (onGrid: inGrid)
    self.mConnectorP2?.mX.align (onGrid: inGrid)
    self.mConnectorP2?.mY.align (onGrid: inGrid)
  }

  //····················································································································
  //  REMOVING
  //····················································································································

  func operationBeforeRemoving_BoardTrack () {
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
