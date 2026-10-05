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
    let alignedMouseDownPoint = inUnalignedMouseDownPoint.aligning (on: self.rootObject.mBoardLimitsGridStep)
    for borderCurve in self.rootObject.mBorderCurves.values {
      let p1  = CanariPoint (x: borderCurve.mX, y: borderCurve.mY)
      let p2  = CanariPoint (x: borderCurve.mNext!.mX, y: borderCurve.mNext!.mY)
      if (p1 != alignedMouseDownPoint) && (p2 != alignedMouseDownPoint) {
        switch borderCurve.mShape {
        case .line :
          let segment = CanariSegment (
            x1: p1.x,
            y1: p1.y,
            x2: p2.x,
            y2: p2.y,
            width: 2 * self.rootObject.mBoardClearance,
            endStyle: .round
          )
          if segment.strictlyContains (point: inUnalignedMouseDownPoint) {
            return borderCurve
          }
        case .bezier :
          let cp1 = NSPoint (x: borderCurve.mCPX1, y: borderCurve.mCPY1)
          let cp2 = NSPoint (x: borderCurve.mCPX2, y: borderCurve.mCPY2)
          var bp = BezierPath ()
          bp.move (to: p1.ptValue)
          bp.cubic (to: p2.ptValue, controlPoint1: cp1, controlPoint2: cp2)
          bp.lineWidth = 2.0 * self.rootObject.mBoardClearance
          bp = bp.pathToFillByStroking
          if bp.contains (inUnalignedMouseDownPoint) {
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
      let p1  = CanariPoint (x: removedBorderCurve.mX, y: removedBorderCurve.mY)
      let p2  = CanariPoint (x: removedBorderCurve.mNext!.mX, y: removedBorderCurve.mNext!.mY)
      if p1.squareOfDistance (to: unalignedMouseDownPoint) < p2.squareOfDistance (to: unalignedMouseDownPoint) {
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
      let alignedMouseDownPoint = unalignedMouseDownPoint.aligning (on: self.rootObject.mBoardLimitsGridStep)
      let newCurve = BorderCurve (self.undoManager)
      newCurve.mX = alignedMouseDownPoint.x
      newCurve.mY = alignedMouseDownPoint.y
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
          x: (curve.mX + curve.mNext!.mX) / 2,
          y: (curve.mY + curve.mNext!.mY) / 2
        )
        let alignedMouseDownPoint = unalignedMouseDownPoint.aligning (on: self.rootObject.mBoardLimitsGridStep)
        let newCurve = BorderCurve (self.undoManager)
        newCurve.mX = alignedMouseDownPoint.x
        newCurve.mY = alignedMouseDownPoint.y
        let nextCurve = curve.mNext!
        curve.mNext = nil
        curve.mNext = newCurve
        newCurve.mNext = nextCurve
        self.rootObject.mBorderCurves.append (newCurve)
        curve.setControlPointsDefaultValuesForLine ()
        newCurve.setControlPointsDefaultValuesForLine ()
      case .bezier :
        let p1 = CanariPoint (x: curve.mX, y: curve.mY)
        let p2 = CanariPoint (x: curve.mNext!.mX, y: curve.mNext!.mY)
        let cp1 = CanariPoint (x: curve.mCPX1, y: curve.mCPY1)
        let cp2 = CanariPoint (x: curve.mCPX2, y: curve.mCPY2)
        let mid_P1_CP1 = p1.mid (with: cp1)
        let mid_P2_CP2 = p2.mid (with: cp2)
        let mid_CP1_CP2 = cp1.mid (with: cp2)
        let newCP1 = mid_P1_CP1.mid (with: mid_CP1_CP2)
        let newCP2 = mid_P2_CP2.mid (with: mid_CP1_CP2)
        let newP = newCP1.mid (with: newCP2)
      //---
        let newCurve = BorderCurve (self.undoManager)
        newCurve.mShape = .bezier
        newCurve.mX = newP.x.aligning (on: self.rootObject.mBoardLimitsGridStep)
        newCurve.mY = newP.y.aligning (on: self.rootObject.mBoardLimitsGridStep)
        let nextCurve = curve.mNext!
        curve.mNext = nil
        curve.mNext = newCurve
        newCurve.mNext = nextCurve
      //---
        curve.mCPX2 = newCP1.x.aligning (on: self.rootObject.mBoardLimitsGridStep)
        curve.mCPY2 = newCP1.y.aligning (on: self.rootObject.mBoardLimitsGridStep)
        curve.mCPX1 = mid_P1_CP1.x.aligning (on: self.rootObject.mBoardLimitsGridStep)
        curve.mCPY1 = mid_P1_CP1.y.aligning (on: self.rootObject.mBoardLimitsGridStep)
        newCurve.mCPX1 = newCP2.x.aligning (on: self.rootObject.mBoardLimitsGridStep)
        newCurve.mCPY1 = newCP2.y.aligning (on: self.rootObject.mBoardLimitsGridStep)
        newCurve.mCPX2 = mid_P2_CP2.x.aligning (on: self.rootObject.mBoardLimitsGridStep)
        newCurve.mCPY2 = mid_P2_CP2.y.aligning (on: self.rootObject.mBoardLimitsGridStep)
        self.rootObject.mBorderCurves.append (newCurve)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
