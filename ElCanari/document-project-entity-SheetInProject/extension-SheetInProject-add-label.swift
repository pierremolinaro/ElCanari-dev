//
//  extension-SheetInProject-add-label.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/05/2019.
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension SheetInProject {

  //································································································

  func addLabelInSchematics (at inLocation : CanariPoint,
                             orientation inOrientation : QuadrantRotation,
                             newNetCreator inNewNetCreator : @MainActor () -> NetInProject) -> LabelInSchematic? {
    let canariAlignedMouseDownLocation = inLocation.point (alignedOnGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
    let points = self.pointsInSchematics (at: canariAlignedMouseDownLocation)
    var possiblePoint : PointInSchematic? = nil
    if points.count == 1 {
      possiblePoint = points [0]
    }else if points.count == 0 {
      let point = PointInSchematic (self.undoManager)
      point.mX = canariAlignedMouseDownLocation.x
      point.mY = canariAlignedMouseDownLocation.y
      point.mNet = inNewNetCreator ()
      self.mPoints.append (point)
      possiblePoint = point
    }
    if let point = possiblePoint {
      let label = LabelInSchematic (self.undoManager)
      label.mPoint = point
      label.mOrientation = inOrientation
      self.mObjects.append (label)
      if point.mNet == nil {
        point.mNet = inNewNetCreator ()
      }
      point.propagateNetToAccessiblePointsThroughtWires ()
      return label
    }else{
      return nil
    }
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
