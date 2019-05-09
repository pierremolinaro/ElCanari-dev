//
//  extension-SheetInProject-add-label.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/05/2019.
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SheetInProject {

  //····················································································································

  func addLabelInSchematics (at inLocation : CanariPoint,
                             orientation inOrientation : QuadrantRotation,
                             newNetCreator inNewNetCreator : () -> NetInProject) -> LabelInSchematics? {
    let canariAlignedMouseDownLocation = inLocation.point (alignedOnGrid: SCHEMATICS_GRID_IN_CANARI_UNIT)
    let points = self.pointsInSchematics (at: canariAlignedMouseDownLocation)
    var possiblePoint : PointInSchematics? = nil
    if points.count == 1 {
      possiblePoint = points [0]
    }else if points.count == 0 {
      let point = PointInSchematics (self.ebUndoManager)
      point.mX = canariAlignedMouseDownLocation.x
      point.mY = canariAlignedMouseDownLocation.y
      point.mNet = inNewNetCreator ()
      self.mPoints.append (point)
      possiblePoint = point
    }
    if let point = possiblePoint {
      let label = LabelInSchematics (self.ebUndoManager)
      label.mPoint = point
      label.mOrientation = inOrientation
      self.mObjects.append (label)
      return label
    }else{
      return nil
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
