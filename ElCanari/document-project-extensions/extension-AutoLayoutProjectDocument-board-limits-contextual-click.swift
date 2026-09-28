//
//  ProjectDocument-board-limits-contextual-click.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/06/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func populateContextualClickOnBoardLimits (_ inUnalignedMouseDownPoint : CanariPoint) -> NSMenu {
    let menu = NSMenu ()
    switch self.rootObject.mBoardShape {
    case .rectangular :
      let menuItem = NSMenuItem (title: "Rectangular board limit: no contextual action", action: nil, keyEquivalent: "")
      menu.addItem (menuItem)
    case .bezierPathes :
    //--- Add Board limit Point ?
      self.appendAddBoardLimitCurvePoint (toMenu: menu, inUnalignedMouseDownPoint)
    //--- Remove Board limit Point ?
      self.appendRemoveBoardLimitPoint (toMenu: menu, inUnalignedMouseDownPoint)
    }
    return menu
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Remove Point From Wire
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func curve (at inUnalignedMouseDownPoint : CanariPoint) -> BorderCurve? {
    let alignedMouseDownPoint = inUnalignedMouseDownPoint.point (alignedOnGrid: .cu (self.rootObject.mBoardLimitsGridStep))
    for borderCurve in self.rootObject.mBorderCurves.values {
      let p1  = CanariPoint (x: .cu (borderCurve.mX), y: .cu (borderCurve.mY))
      let p2  = CanariPoint (x: .cu (borderCurve.mNext!.mX), y: .cu (borderCurve.mNext!.mY))
      if (p1 != alignedMouseDownPoint) && (p2 != alignedMouseDownPoint) {
        switch borderCurve.mShape {
        case .line :
          let segment = CanariSegment (
            x1: p1.x.cuValue,
            y1: p1.y.cuValue,
            x2: p2.x.cuValue,
            y2: p2.y.cuValue,
        //    width: 2 * (self.rootObject.mBoardLimitsWidth + self.rootObject.mBoardClearance), §
            width: 2 * self.rootObject.mBoardClearance,
            endStyle: .round
          )
          if segment.strictlyContains (point: inUnalignedMouseDownPoint) {
            return borderCurve
          }
        case .bezier :
          let cp1 = CanariPoint (x: .cu (borderCurve.mCPX1), y: .cu (borderCurve.mCPY1)).ptValue
          let cp2 = CanariPoint (x: .cu (borderCurve.mCPX2), y: .cu (borderCurve.mCPY2)).ptValue
          var bp = BezierPath ()
          bp.move (to: p1.ptValue)
          bp.curve (to: p2.ptValue, controlPoint1: cp1, controlPoint2: cp2)
     //     bp.lineWidth = 2.0 * canariUnitToCocoa (self.rootObject.mBoardLimitsWidth + self.rootObject.mBoardClearance)
          bp.lineWidth = 2.0 * canariUnitToCocoa (self.rootObject.mBoardClearance)
          bp = bp.pathToFillByStroking
          if bp.contains (inUnalignedMouseDownPoint.ptValue) {
            return borderCurve
          }
        }
      }
    }
    return nil
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Remove Point From Wire
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func canRemovePointFromBoardLimits (_ inUnalignedMouseDownPoint : CanariPoint) -> BorderCurve? {
    if self.rootObject.mBorderCurves.count > 3, let curve = self.curve (at: inUnalignedMouseDownPoint) {
      return curve
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendRemoveBoardLimitPoint (toMenu menu : NSMenu, _ inUnalignedMouseDownPoint : CanariPoint) {
    if let borderCurve = self.canRemovePointFromBoardLimits (inUnalignedMouseDownPoint) {
      let menuItem = NSMenuItem (title: "Remove Curve and nearest Point", action: #selector (Self.removePointFromBorderAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = (borderCurve, inUnalignedMouseDownPoint)
      menu.addItem (menuItem)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func removePointFromBorderAction (_ inSender : NSMenuItem) {
    if let (removedBorderCurve, unalignedMouseDownPoint) = inSender.representedObject as? (BorderCurve, CanariPoint) {
      let p1  = CanariPoint (x: .cu (removedBorderCurve.mX), y: .cu (removedBorderCurve.mY))
      let p2  = CanariPoint (x: .cu (removedBorderCurve.mNext!.mX), y: .cu (removedBorderCurve.mNext!.mY))
      if CanariPoint.distanceSquare (p1, unalignedMouseDownPoint) < CanariPoint.distanceSquare (p2, unalignedMouseDownPoint) {
        let nextBorderCurve = removedBorderCurve.mNext!
        let previousBorderCurve = removedBorderCurve.mPrevious!
        removedBorderCurve.mNext = nil
        removedBorderCurve.mPrevious = nil
        previousBorderCurve.mNext = nextBorderCurve
        previousBorderCurve.setControlPointsDefaultValuesForLine ()
        nextBorderCurve.setControlPointsDefaultValuesForLine ()
        removedBorderCurve.mRoot = nil
//        Swift.print ("COUNT \(self.rootObject.mBorderCurves.count)")
      }else{
        let nextBorderCurve = removedBorderCurve.mNext!
        let previousBorderCurve = removedBorderCurve.mPrevious!
        nextBorderCurve.mX = removedBorderCurve.mX
        nextBorderCurve.mY = removedBorderCurve.mY
        removedBorderCurve.mNext = nil
        removedBorderCurve.mPrevious = nil
        previousBorderCurve.mNext = nextBorderCurve
        previousBorderCurve.setControlPointsDefaultValuesForLine ()
        nextBorderCurve.setControlPointsDefaultValuesForLine ()
        removedBorderCurve.mRoot = nil
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Insert point into wire
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendAddBoardLimitCurvePoint (toMenu menu : NSMenu, _ inUnalignedMouseDownPoint : CanariPoint) {
    if let curve = self.curve (at: inUnalignedMouseDownPoint) {
      if curve.mShape == .line {
        let menuItem = NSMenuItem (title: "Add Point", action: #selector (Self.addPointToBoardLimitAction (_:)), keyEquivalent: "")
        menuItem.target = self
        menuItem.representedObject = (curve, inUnalignedMouseDownPoint)
        menu.addItem (menuItem)
      }
      let menuItem = NSMenuItem (title: "Split Curve", action: #selector (Self.splitCurveLimitAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = curve
      menu.addItem (menuItem)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func addPointToBoardLimitAction (_ inSender : NSMenuItem) {
    if let (curve, unalignedMouseDownPoint) = inSender.representedObject as? (BorderCurve, CanariPoint) {
      let alignedMouseDownPoint = unalignedMouseDownPoint.point (alignedOnGrid: .cu (self.rootObject.mBoardLimitsGridStep))
      let newCurve = BorderCurve (self.undoManager)
      newCurve.mX = alignedMouseDownPoint.x.cuValue
      newCurve.mY = alignedMouseDownPoint.y.cuValue
      let nextCurve = curve.mNext!
      curve.mNext = nil
      curve.mNext = newCurve
      newCurve.mNext = nextCurve
      self.rootObject.mBorderCurves.append (newCurve)
      curve.setControlPointsDefaultValuesForLine ()
      newCurve.setControlPointsDefaultValuesForLine ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func splitCurveLimitAction (_ inSender : NSMenuItem) {
    if let curve = inSender.representedObject as? BorderCurve {
      switch curve.mShape {
      case .line :
        let unalignedMouseDownPoint = CanariPoint (
          x: .cu (curve.mX + curve.mNext!.mX) / 2,
          y: .cu (curve.mY + curve.mNext!.mY) / 2
        )
        let alignedMouseDownPoint = unalignedMouseDownPoint.point (alignedOnGrid: .cu (self.rootObject.mBoardLimitsGridStep))
        let newCurve = BorderCurve (self.undoManager)
        newCurve.mX = alignedMouseDownPoint.x.cuValue
        newCurve.mY = alignedMouseDownPoint.y.cuValue
        let nextCurve = curve.mNext!
        curve.mNext = nil
        curve.mNext = newCurve
        newCurve.mNext = nextCurve
        self.rootObject.mBorderCurves.append (newCurve)
        curve.setControlPointsDefaultValuesForLine ()
        newCurve.setControlPointsDefaultValuesForLine ()
      case .bezier :
        let p1 = CanariPoint (x: .cu (curve.mX), y: .cu (curve.mY))
        let p2 = CanariPoint (x: .cu (curve.mNext!.mX), y: .cu (curve.mNext!.mY))
        let cp1 = CanariPoint (x: .cu (curve.mCPX1), y: .cu (curve.mCPY1))
        let cp2 = CanariPoint (x: .cu (curve.mCPX2), y: .cu (curve.mCPY2))
        let mid_P1_CP1 = CanariPoint.center (p1, cp1)
        let mid_P2_CP2 = CanariPoint.center (p2, cp2)
        let mid_CP1_CP2 = CanariPoint.center (cp1, cp2)
        let newCP1 = CanariPoint.center (mid_P1_CP1, mid_CP1_CP2)
        let newCP2 = CanariPoint.center (mid_P2_CP2, mid_CP1_CP2)
        let newP = CanariPoint.center (newCP1, newCP2)
      //---
        let newCurve = BorderCurve (self.undoManager)
        newCurve.mShape = .bezier
        newCurve.mX = newP.x.cuValue.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
        newCurve.mY = newP.y.cuValue.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
        let nextCurve = curve.mNext!
        curve.mNext = nil
        curve.mNext = newCurve
        newCurve.mNext = nextCurve
      //---
        curve.mCPX2 = newCP1.x.cuValue.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
        curve.mCPY2 = newCP1.y.cuValue.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
        curve.mCPX1 = mid_P1_CP1.x.cuValue.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
        curve.mCPY1 = mid_P1_CP1.y.cuValue.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
        newCurve.mCPX1 = newCP2.x.cuValue.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
        newCurve.mCPY1 = newCP2.y.cuValue.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
        newCurve.mCPX2 = mid_P2_CP2.x.cuValue.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
        newCurve.mCPY2 = mid_P2_CP2.y.cuValue.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
        self.rootObject.mBorderCurves.append (newCurve)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
