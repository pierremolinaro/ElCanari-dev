//
//  extension-PackageSlavePad.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/12/2018.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   EXTENSION PackagePad
//----------------------------------------------------------------------------------------------------------------------

extension PackageSlavePad {

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : ObjcObjectSet) {
    self.xCenter += inDx
    self.yCenter += inDy
  }

  //····················································································································
  //  Rotate 90°
  //····················································································································

  override func canRotate90 (accumulatedPoints : ObjcCanariPointSet) -> Bool {
    accumulatedPoints.insert (x: self.xCenter, y: self.yCenter)
    return true
  }

  //····················································································································

  override func rotate90Clockwise (from inRotationCenter : ObjcCanariPoint, userSet ioSet : ObjcObjectSet) {
    let newCenter = inRotationCenter.rotated90Clockwise (x: self.xCenter, y: self.yCenter)
    self.xCenter = newCenter.x
    self.yCenter = newCenter.y
    (self.width, self.height) = (self.height, self.width)
    (self.holeWidth, self.holeHeight) = (self.holeHeight, self.holeWidth)
  }

  //····················································································································

  override func rotate90CounterClockwise (from inRotationCenter : ObjcCanariPoint, userSet ioSet : ObjcObjectSet) {
    let newCenter = inRotationCenter.rotated90CounterClockwise (x: self.xCenter, y: self.yCenter)
    self.xCenter = newCenter.x
    self.yCenter = newCenter.y
    (self.width, self.height) = (self.height, self.width)
    (self.holeWidth, self.holeHeight) = (self.holeHeight, self.holeWidth)
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : ObjcCanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : ObjcCanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : ObjcCanariPoint,
                         shift inShift : Bool) -> ObjcCanariPoint {
    return inProposedAlignedTranslation
  }

  //····················································································································
  //  COPY AND PASTE
  //····················································································································

  override func canCopyAndPaste () -> Bool {
    return true
  }

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  override func canSnapToGrid (_ inGrid : Int) -> Bool {
    var result = (self.xCenter % inGrid) != 0
    if !result {
      result = (self.yCenter % inGrid) != 0
    }
    return result
  }

  //····················································································································

  override func snapToGrid (_ inGrid : Int) {
    self.xCenter = ((self.xCenter + inGrid / 2) / inGrid) * inGrid
    self.yCenter = ((self.yCenter + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  override func alignmentPoints () -> ObjcCanariPointSet {
    let result = ObjcCanariPointSet ()
    result.insert (CanariPoint (x: self.xCenter, y: self.yCenter))
    return result
  }

  //····················································································································

  override func operationBeforeRemoving () {
    super.operationBeforeRemoving ()
    self.master_property.setProp (nil)
  }

  //····················································································································
  //
  //····················································································································

  func angle (from inCanariPoint : CanariPoint) -> CGFloat {
    return CanariPoint.angleInRadian (CanariPoint (x: self.xCenter, y: self.yCenter), inCanariPoint)
  }

  //····················································································································

  override func program () -> String {
    var s = "slave "
    s += stringFrom (valueInCanariUnit: self.xCenter, displayUnit : self.xCenterUnit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.yCenter, displayUnit : self.yCenterUnit)
    s += " size "
    s += stringFrom (valueInCanariUnit: self.width, displayUnit : self.widthUnit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.height, displayUnit : self.heightUnit)
    s += " shape "
    s += self.padShape.descriptionForExplorer ()
    s += " style "
    s += self.padStyle.descriptionForExplorer ()
    s += " hole "
    s += stringFrom (valueInCanariUnit: self.holeWidth, displayUnit : self.holeWidthUnit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.holeHeight, displayUnit : self.holeHeightUnit)
    s += " id "
    s += "\(self.master_property.propval!.ebObjectIndex)"
    s += ";\n"
    return s
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
