//
//  extension-PackageArc.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/12/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//let PACKAGE_ARC_CENTER = 1
//let PACKAGE_ARC_RADIUS = 2
//let PACKAGE_ARC_START_ANGLE = 3
//let PACKAGE_ARC_END_ANGLE = 4

let VERY_LARGE_PAD_NUMBER = 1_000_000

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION PackagePad
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackagePad {

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : OCObjectSet) {
    self.xCenter += inDx
    self.yCenter += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) -> OCCanariPoint {
    return OCCanariPoint (x: inDx, y: inDy)
 }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int, newX inNewX : Int, newY inNewY : Int) {
  }

  //····················································································································
  //  COPY AND PASTE
  //····················································································································

  override func canCopyAndPaste () -> Bool {
    return true
  }

  //····················································································································

  override func operationAfterPasting () {
    self.padNumber += VERY_LARGE_PAD_NUMBER // So it will be numbered by model observer CustomizedPackageDocument:handlePadNumbering
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

  override func alignmentPoints () -> OCCanariPointSet {
    let result = OCCanariPointSet ()
    result.points.insert (CanariPoint (x: self.xCenter, y: self.yCenter))
    return result
  }

  //····················································································································
  //
  //····················································································································

  func angle (from inCanariPoint : CanariPoint) -> CGFloat {
    return CanariPoint.angleInRadian (CanariPoint (x: self.xCenter, y: self.yCenter), inCanariPoint)
  }

  //····················································································································
  //  Can be deleted
  //····················································································································

  override func canBeDeleted () -> Bool {
    return self.slaves_property.propval.count == 0
  }

  //····················································································································

  override func program () -> String {
    var s = "pad "
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
    s += " number "
    s += "\(self.padNumber)"
    if self.slaves.count > 0 {
      s += " id "
      s += "\(self.ebObjectIndex)"
    }
    s += ";\n"
    return s
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension EBBezierPath {

  //····················································································································

  static func pad (centerX inCenterX : Int,
                   centerY inCenterY : Int,
                   width inWidth : Int,
                   height inHeight : Int,
                   shape inShape : PadShape) -> EBBezierPath {
    let center = CanariPoint (x: inCenterX, y: inCenterY).cocoaPoint
    let size = CanariSize (width: inWidth, height: inHeight).cocoaSize
    let r = NSRect (center: center, size: size)
    switch inShape {
    case .rect :
      return EBBezierPath (rect: r)
    case .round :
      return EBBezierPath (oblongInRect: r)
    case .octo :
      return EBBezierPath (octogonInRect: r)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
