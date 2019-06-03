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
    self.appendAddBoardLimitPoint (toMenu: menu, inUnalignedMouseDownPoint)
  //--- Remove Board limit Point ?
    self.appendRemoveBoardLimitPoint (toMenu: menu, inUnalignedMouseDownPoint)
  //---
    return menu
  }

  //····················································································································
  // Remove Point From Wire
  //····················································································································

  private func canRemovePointFromBoardLimits (_ inUnalignedMouseDownPoint : CanariPoint) -> BorderPoint? {
    if self.rootObject.mBorderPoints.count > 3 {
      let radius = Double (cocoaToCanariUnit (BOARD_LIMITS_KNOB_SIZE) / 2)
      let matchMaxSquareDistance = radius * radius
      for point in self.rootObject.mBorderPoints {
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
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      let menuItem = NSMenuItem (title: "Remove Point", action: #selector (CustomizedProjectDocument.removePointFromBorderAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = point
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func removePointFromBorderAction (_ inSender : NSMenuItem) {
    if let point = inSender.representedObject as? BorderPoint {
      let preservedCurve = point.mCurve2!
      let removedCurve = point.mCurve1!
      let preservedPoint = removedCurve.mP2
      removedCurve.mP1 = nil
      removedCurve.mP2 = nil
      preservedCurve.mP2 = preservedPoint
      self.rootObject.mBorderPoints_property.remove (point)
      removedCurve.mRoot = nil
    }
  }

  //····················································································································
  // Insert point into wire
  //····················································································································

  private func canCreateBoardLimitPoint (_ inUnalignedMouseDownPoint : CanariPoint) -> BoardLimit? {
    // Swift.print ("Mouse \(inUnalignedMouseDownPoint.x) \(inUnalignedMouseDownPoint.y)")
    for boardLimit in self.rootObject.mBoardLimits {
      let segment = CanariSegment (
        x1: boardLimit.mP1!.mX,
        y1: boardLimit.mP1!.mY,
        x2: boardLimit.mP2!.mX,
        y2: boardLimit.mP2!.mY,
        width: self.rootObject.mBoardLimitsWidth
      )
      // Swift.print ("x1 \(segment), y1 \(segment.y1) x2 \(segment.x2) y2 \(segment.y2) width \(segment.width)")
      if segment.strictlyContains (point: inUnalignedMouseDownPoint) {
        return boardLimit
      }
    }
    return nil
  }

  //····················································································································

  private func appendAddBoardLimitPoint (toMenu menu : NSMenu, _ inUnalignedMouseDownPoint : CanariPoint) {
    if let boardLimit = self.canCreateBoardLimitPoint (inUnalignedMouseDownPoint) {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      let menuItem = NSMenuItem (title: "Add Point…", action: #selector (CustomizedProjectDocument.addPointToBoardLimitAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = (boardLimit, inUnalignedMouseDownPoint)
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func addPointToBoardLimitAction (_ inSender : NSMenuItem) {
    if let (boardLimit, unalignedMouseDownPoint) = inSender.representedObject as? (BoardLimit, CanariPoint) {
      let alignedMouseDownPoint = unalignedMouseDownPoint.point (alignedOnGrid: self.rootObject.mBoardLimitsGridStep)
      let newPoint = BorderPoint (self.ebUndoManager)
      newPoint.mX = alignedMouseDownPoint.x
      newPoint.mY = alignedMouseDownPoint.y
      let newLimit = BoardLimit (self.ebUndoManager)
      let p = boardLimit.mP2
      boardLimit.mP2 = newPoint
      newLimit.mP1 = newPoint
      newLimit.mP2 = p
      self.rootObject.mBorderPoints.append (newPoint)
      self.rootObject.mBoardLimits.append (newLimit)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
