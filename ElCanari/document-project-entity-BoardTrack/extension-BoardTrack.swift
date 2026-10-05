//
//  extension-BoardTrack.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/07/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let BOARD_TRACK_P1  = 0
let BOARD_TRACK_P2  = 1

//--------------------------------------------------------------------------------------------------
//   EXTENSION BoardTrack
//--------------------------------------------------------------------------------------------------

extension BoardTrack {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func cursorForKnob_BoardTrack (knob _ : Int) -> NSCursor? {
    return NSCursor.upDownRightLeftCursor
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationAfterPasting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_BoardTrack (additionalDictionary _ : [String : Any],
                                         optionalDocument _ : EBAutoLayoutManagedDocument?,
                                         objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  HORIZONTAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_BoardTrack () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_BoardTrack () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  VERTICAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_BoardTrack () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_BoardTrack () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_BoardTrack (_ _ : inout [String : Any]) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Translation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_BoardTrack (xBy inDx: CanariLength, yBy inDy: CanariLength) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_BoardTrack (xBy _ : CanariLength, yBy _ : CanariLength) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_BoardTrack (xBy inDx : CanariLength,
                             yBy inDy : CanariLength,
                             userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Knob
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_BoardTrack (knob _ : Int,
                           proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                           proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                           unalignedMouseDraggedLocation _ : CanariPoint,
                           shift inShiftKeyOn : Bool) -> CanariPoint {
    return inProposedUnalignedTranslation
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_BoardTrack (knob inKnobIndex : Int,
                        proposedDx _ : CanariLength,
                        proposedDy _ : CanariLength,
                        unalignedMouseLocationX inUnalignedMouseCanariLocationX : CanariLength,
                        unalignedMouseLocationY inUnalignedMouseCanariLocationY : CanariLength,
                        alignedMouseLocationX inAlignedMouseCanariLocationX : CanariLength,
                        alignedMouseLocationY inAlignedMouseCanariLocationY : CanariLength,
                        shift inShiftKey : Bool) {
    let mouseCanariLocationX = inShiftKey ? inAlignedMouseCanariLocationX : inUnalignedMouseCanariLocationX
    let mouseCanariLocationY = inShiftKey ? inAlignedMouseCanariLocationY : inUnalignedMouseCanariLocationY
    if inKnobIndex == BOARD_TRACK_P1 {
      switch self.mDirectionLockOnKnobDragging {
      case .unlocked :
        self.mConnectorP1?.mX = mouseCanariLocationX
        self.mConnectorP1?.mY = mouseCanariLocationY
      case .locked :
        let p1 = self.mConnectorP1!.location!
        let p2 = self.mConnectorP2!.location!
        let angle = p1.angle (to: p2)
        let newLength : Double = Double (mouseCanariLocationX.cuValue - p2.x.cuValue) * cos (angle) + Double (mouseCanariLocationY.cuValue - p2.y.cuValue) * sin (angle)
        let newP1X = p2.x + .cu (Int ((newLength * cos (angle)).rounded ()))
        let newP1Y = p2.y + .cu (Int ((newLength * sin (angle)).rounded ()))
        self.mConnectorP1?.mX = newP1X
        self.mConnectorP1?.mY = newP1Y
      case .octolinear :
        let p2 = self.mConnectorP2!.location!
        let inUnalignedMouseLocation = CanariPoint (x: mouseCanariLocationX, y: mouseCanariLocationY)
        let angle = Double (CanariPoint.octolinearNearestAngleInDegrees (inUnalignedMouseLocation, p2)) * .pi / 180.0
        let newLength : Double = Double (mouseCanariLocationX.cuValue - p2.x.cuValue) * cos (angle) + Double (mouseCanariLocationY.cuValue - p2.y.cuValue) * sin (angle)
        let newP1X = p2.x + .cu (Int ((newLength * cos (angle)).rounded ()))
        let newP1Y = p2.y + .cu (Int ((newLength * sin (angle)).rounded ()))
        self.mConnectorP1?.mX = newP1X
        self.mConnectorP1?.mY = newP1Y
      case .rectilinear :
        let p2 = self.mConnectorP2!.location!
        let inUnalignedMouseLocation = CanariPoint (x: mouseCanariLocationX, y: mouseCanariLocationY)
        let angle = Double (CanariPoint.rectilinearNearestAngleInDegrees (inUnalignedMouseLocation, p2)) * .pi / 180.0
        let newLength : Double = Double (mouseCanariLocationX.cuValue - p2.x.cuValue) * cos (angle) + Double (mouseCanariLocationY.cuValue - p2.y.cuValue) * sin (angle)
        let newP1X = p2.x + .cu (Int ((newLength * cos (angle)).rounded ()))
        let newP1Y = p2.y + .cu (Int ((newLength * sin (angle)).rounded ()))
        self.mConnectorP1?.mX = newP1X
        self.mConnectorP1?.mY = newP1Y
      }
    }else if inKnobIndex == BOARD_TRACK_P2 {
      switch self.mDirectionLockOnKnobDragging {
      case .unlocked :
        self.mConnectorP2?.mX = mouseCanariLocationX
        self.mConnectorP2?.mY = mouseCanariLocationY
      case .locked :
        let p1 = self.mConnectorP1!.location!
        let p2 = self.mConnectorP2!.location!
        let angle = p1.angle (to: p2)
        let newLength : Double = Double (mouseCanariLocationX.cuValue - p1.x.cuValue) * cos (angle) + Double (mouseCanariLocationY.cuValue - p1.y.cuValue) * sin (angle)
        let newP2X = p1.x + .cu (Int ((newLength * cos (angle)).rounded ()))
        let newP2Y = p1.y + .cu (Int ((newLength * sin (angle)).rounded ()))
        self.mConnectorP2?.mX = newP2X
        self.mConnectorP2?.mY = newP2Y
      case .octolinear :
        let p1 = self.mConnectorP1!.location!
        let inUnalignedMouseLocation = CanariPoint (x: mouseCanariLocationX, y: mouseCanariLocationY)
        let angle = Double (CanariPoint.octolinearNearestAngleInDegrees (p1, inUnalignedMouseLocation)) * .pi / 180.0
        let newLength : Double = Double (mouseCanariLocationX.cuValue - p1.x.cuValue) * cos (angle) + Double (mouseCanariLocationY.cuValue - p1.y.cuValue) * sin (angle)
        let newP2X = p1.x + .cu (Int ((newLength * cos (angle)).rounded ()))
        let newP2Y = p1.y + .cu (Int ((newLength * sin (angle)).rounded ()))
        self.mConnectorP2?.mX = newP2X
        self.mConnectorP2?.mY = newP2Y
      case .rectilinear :
        let p1 = self.mConnectorP1!.location!
        let inUnalignedMouseLocation = CanariPoint (x: mouseCanariLocationX, y: mouseCanariLocationY)
        let angle = Double (CanariPoint.rectilinearNearestAngleInDegrees (p1, inUnalignedMouseLocation)) * .pi / 180.0
        let newLength : Double = Double (mouseCanariLocationX.cuValue - p1.x.cuValue) * cos (angle) + Double (mouseCanariLocationY.cuValue - p1.y.cuValue) * sin (angle)
        let newP2X = p1.x + .cu (Int ((newLength * cos (angle)).rounded ()))
        let newP2Y = p1.y + .cu (Int ((newLength * sin (angle)).rounded ()))
        self.mConnectorP2?.mX = newP2X
        self.mConnectorP2?.mY = newP2Y
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Rotate 90°
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_BoardTrack (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    if let p1 = self.mConnectorP1?.location, let p2 = self.mConnectorP2?.location {
      accumulatedPoints.insert (p1)
      accumulatedPoints.insert (p2)
      return true
    }else{
      return false
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90Clockwise_BoardTrack (from inRotationCenter : CanariPoint,
                                     userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90CounterClockwise_BoardTrack (from inRotationCenter : CanariPoint,
                                            userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Alignment Points
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_BoardTrack () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_BoardTrack (_ inGrid : CanariLength) -> Bool {
    var isAligned = self.mConnectorP1?.mX.isAligned (on: inGrid) ?? true
    if isAligned, let connectorP1 = self.mConnectorP1 {
      isAligned = connectorP1.mY.isAligned (on: inGrid)
    }
    if isAligned, let connectorP2 = self.mConnectorP2 {
      isAligned = connectorP2.mX.isAligned (on: inGrid)
    }
    if isAligned, let connectorP2 = self.mConnectorP2 {
      isAligned = connectorP2.mY.isAligned (on: inGrid)
    }
    return !isAligned
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_BoardTrack (_ inGrid : CanariLength) {
    self.mConnectorP1?.mX.align (on: inGrid)
    self.mConnectorP1?.mY.align (on: inGrid)
    self.mConnectorP2?.mX.align (on: inGrid)
    self.mConnectorP2?.mY.align (on: inGrid)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  REMOVING
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_BoardTrack () {
    let optionalNet = self.mNet
    self.mConnectorP1 = nil
    self.mConnectorP2 = nil
    self.mNet = nil
    if let net = optionalNet, net.mPoints.count == 0, net.mTracks.count == 0 {
      net.mNetClass = nil // Remove net
    }
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Bezier path
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func bezierPath (extraWidth inExtraWidth : CanariLength) -> BezierPath {
    var bp = BezierPath ()
    bp.lineWidth = (self.actualTrackWidth! + inExtraWidth)
    switch self.mEndStyle {
    case .round :
      bp.lineCapStyle = .round
    case .square :
      bp.lineCapStyle = .square
    }
    bp.lineJoinStyle = .round
    bp.move (to: self.mConnectorP1!.location!.ptValue)
    bp.line (to: self.mConnectorP2!.location!.ptValue)
    return bp.pathToFillByStroking
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
