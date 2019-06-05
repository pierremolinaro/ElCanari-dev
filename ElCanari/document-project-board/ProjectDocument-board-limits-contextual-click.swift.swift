//
//  ProjectDocument-board-limits-contextual-click.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/06/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  internal func populateContextualClickOnBoardLimits (_ inUnalignedMouseDownPoint : CanariPoint) -> NSMenu {
    let menu = NSMenu ()
  //--- Add Board limit Point ?
    self.appendAddBoardLimitCurvePoint (toMenu: menu, inUnalignedMouseDownPoint)
  //--- Remove Board limit Point ?
    self.appendRemoveBoardLimitPoint (toMenu: menu, inUnalignedMouseDownPoint)
  //---
    return menu
  }

  //····················································································································
  // Remove Point From Wire
  //····················································································································

  private func canRemovePointFromBoardLimits (_ inUnalignedMouseDownPoint : CanariPoint) -> BorderCurve? {
    if self.rootObject.mBorderCurves.count > 3 {
      let radius = Double (cocoaToCanariUnit (BOARD_LIMITS_KNOB_SIZE) / 2)
      let matchMaxSquareDistance = radius * radius
      for point in self.rootObject.mBorderCurves {
        let dx = Double (inUnalignedMouseDownPoint.x - point.mX)
        let dy = Double (inUnalignedMouseDownPoint.y - point.mY)
        let squareDistance = dx * dx + dy * dy
        if squareDistance < matchMaxSquareDistance {
          return point
        }
      }
    }
    return nil
  }

  //····················································································································

  private func appendRemoveBoardLimitPoint (toMenu menu : NSMenu, _ inUnalignedMouseDownPoint : CanariPoint) {
    if let point = self.canRemovePointFromBoardLimits (inUnalignedMouseDownPoint) {
      let menuItem = NSMenuItem (title: "Remove Point", action: #selector (CustomizedProjectDocument.removePointFromBorderAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = point
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func removePointFromBorderAction (_ inSender : NSMenuItem) {
    if let point = inSender.representedObject as? BorderCurve {
//      let preservedCurve = point.mCurve2! §
//      let removedCurve = point.mCurve1!
//      let preservedPoint = removedCurve.mP2
//      removedCurve.mP1 = nil
//      removedCurve.mP2 = nil
//      preservedCurve.mP2 = preservedPoint
//      self.rootObject.mBorderPoints_property.remove (point)
//      removedCurve.mRoot = nil
//      preservedCurve.setControlPointsDefaultValuesForLine ()
    }
  }

  //····················································································································
  // Insert point into wire
  //····················································································································

  private func canCreateBoardLimitPoint (_ inUnalignedMouseDownPoint : CanariPoint) -> BorderCurve? {
    let alignedMouseDownPoint = inUnalignedMouseDownPoint.point (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
    for borderCurve in self.rootObject.mBorderCurves {
//      let p1  = CanariPoint (x: boardLimit.mP1!.mX, y: boardLimit.mP1!.mY)
//      let p2  = CanariPoint (x: boardLimit.mP2!.mX, y: boardLimit.mP2!.mY) §
//      if (p1 != alignedMouseDownPoint) && (p2 != alignedMouseDownPoint) {
//        switch boardLimit.mShape {
//        case .line :
//          let segment = CanariSegment (
//            x1: p1.x,
//            y1: p1.y,
//            x2: p2.x,
//            y2: p2.y,
//            width: self.rootObject.mBoardLimitsWidth
//          )
//          // Swift.print ("x1 \(segment), y1 \(segment.y1) x2 \(segment.x2) y2 \(segment.y2) width \(segment.width)")
//          if (segment.p1 != alignedMouseDownPoint) && (segment.p2 != alignedMouseDownPoint) && segment.strictlyContains (point: inUnalignedMouseDownPoint) {
//            return boardLimit
//          }
//        case .bezier :
//          let cp1 = CanariPoint (x: boardLimit.mCPX1, y: boardLimit.mCPY1).cocoaPoint
//          let cp2 = CanariPoint (x: boardLimit.mCPX2, y: boardLimit.mCPY2).cocoaPoint
//          var bp = NSBezierPath ()
//          bp.move (to: p1.cocoaPoint)
//          bp.curve (to: p2.cocoaPoint, controlPoint1: cp1, controlPoint2: cp2)
//          bp.lineWidth = canariUnitToCocoa (self.rootObject.mBoardLimitsWidth)
//          bp = bp.pathByStroking.bezierPath
//          if bp.contains (inUnalignedMouseDownPoint.cocoaPoint) {
//            return boardLimit
//          }
//        }
//      }
    }
    return nil
  }

  //····················································································································

  private func appendAddBoardLimitCurvePoint (toMenu menu : NSMenu, _ inUnalignedMouseDownPoint : CanariPoint) {
    if let boardLimit = self.canCreateBoardLimitPoint (inUnalignedMouseDownPoint) {
      if boardLimit.mShape == .line {
        let menuItem = NSMenuItem (title: "Add Point", action: #selector (CustomizedProjectDocument.addPointToBoardLimitAction (_:)), keyEquivalent: "")
        menuItem.target = self
        menuItem.representedObject = (boardLimit, inUnalignedMouseDownPoint)
        menu.addItem (menuItem)
      }
      let menuItem = NSMenuItem (title: "Split Curve", action: #selector (CustomizedProjectDocument.splitCurveLimitAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = boardLimit
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func addPointToBoardLimitAction (_ inSender : NSMenuItem) {
    if let (boardLimit, unalignedMouseDownPoint) = inSender.representedObject as? (BorderCurve, CanariPoint) {
//      let alignedMouseDownPoint = unalignedMouseDownPoint.point (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
//      let newPoint = BorderCurve (self.ebUndoManager)
//      newPoint.mX = alignedMouseDownPoint.x
//      newPoint.mY = alignedMouseDownPoint.y §
//      let newLimit = BorderCurve (self.ebUndoManager)
//      let p = boardLimit.mP2
//      boardLimit.mP2 = newPoint
//      newLimit.mP1 = newPoint
//      newLimit.mP2 = p
//      self.rootObject.mBorderCurves.append (newPoint)
//      self.rootObject.mBoardLimits.append (newLimit)
//      boardLimit.setControlPointsDefaultValuesForLine ()
//      newLimit.setControlPointsDefaultValuesForLine ()
    }
  }

  //····················································································································

  @objc private func splitCurveLimitAction (_ inSender : NSMenuItem) {
    if let boardLimit = inSender.representedObject as? BorderCurve {
//      switch boardLimit.mShape { §
//      case .line :
//        let unalignedMouseDownPoint = CanariPoint (
//          x: (boardLimit.mP1!.mX + boardLimit.mP2!.mX) / 2,
//          y: (boardLimit.mP1!.mY + boardLimit.mP2!.mY) / 2
//        )
//        let alignedMouseDownPoint = unalignedMouseDownPoint.point (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
//        let newPoint = BorderCurve (self.ebUndoManager)
//        newPoint.mX = alignedMouseDownPoint.x
//        newPoint.mY = alignedMouseDownPoint.y
//        let newLimit = BorderCurve (self.ebUndoManager)
//        let p = boardLimit.mP2
//        boardLimit.mP2 = newPoint
//        newLimit.mP1 = newPoint
//        newLimit.mP2 = p
//        self.rootObject.mBorderCurves.append (newPoint)
//        self.rootObject.mBoardLimits.append (newLimit)
//      case .bezier :
//        let p1 = CanariPoint (x: boardLimit.mP1!.mX, y: boardLimit.mP1!.mY)
//        let p2 = CanariPoint (x: boardLimit.mP2!.mX, y: boardLimit.mP2!.mY)
//        let cp1 = CanariPoint (x: boardLimit.mCPX1, y: boardLimit.mCPY1)
//        let cp2 = CanariPoint (x: boardLimit.mCPX2, y: boardLimit.mCPY2)
//        let mid_P1_CP1 = CanariPoint.center (p1, cp1)
//        let mid_P2_CP2 = CanariPoint.center (p2, cp2)
//        let mid_CP1_CP2 = CanariPoint.center (cp1, cp2)
//        let newCP1 = CanariPoint.center (mid_P1_CP1, mid_CP1_CP2)
//        let newCP2 = CanariPoint.center (mid_P2_CP2, mid_CP1_CP2)
//        let newP = CanariPoint.center (newCP1, newCP2)
//      //---
//        let newPoint = BorderCurve (self.ebUndoManager)
//        newPoint.mX = newP.x.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
//        newPoint.mY = newP.y.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
//        let newLimit = BorderCurve (self.ebUndoManager)
//        let p = boardLimit.mP2
//        boardLimit.mP2 = newPoint
//        boardLimit.mCPX2 = newCP1.x.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
//        boardLimit.mCPY2 = newCP1.y.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
//        boardLimit.mCPX1 = mid_P1_CP1.x.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
//        boardLimit.mCPY1 = mid_P1_CP1.y.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
//        newLimit.mP1 = newPoint
//        newLimit.mP2 = p
//        newLimit.mShape = .bezier
//        newLimit.mCPX1 = newCP2.x.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
//        newLimit.mCPY1 = newCP2.y.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
//        newLimit.mCPX2 = mid_P2_CP2.x.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
//        newLimit.mCPY2 = mid_P2_CP2.y.value (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
//        self.rootObject.mBorderCurves.append (newPoint)
//        self.rootObject.mBoardLimits.append (newLimit)
//      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
