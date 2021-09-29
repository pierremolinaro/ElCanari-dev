import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PACKAGE_OVAL_BOTTOM = 1
let PACKAGE_OVAL_RIGHT  = 2
let PACKAGE_OVAL_LEFT   = 3
let PACKAGE_OVAL_TOP    = 4

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION PackageOval
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackageOval {

  //····················································································································

  func cursorForKnob_PackageOval (knob inKnobIndex: Int) -> NSCursor? {
    if (inKnobIndex == PACKAGE_OVAL_RIGHT) && (inKnobIndex == PACKAGE_OVAL_LEFT) {
      return NSCursor.resizeLeftRight
    }else if (inKnobIndex == PACKAGE_OVAL_BOTTOM) && (inKnobIndex == PACKAGE_OVAL_TOP) {
      return NSCursor.resizeUpDown
    }else{
      return nil
    }
  }

  //····················································································································

  func acceptToTranslate_PackageOval (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_PackageOval (xBy inDx: Int, yBy inDy: Int, userSet ioSet : inout EBReferenceSet <AnyObject>) {
    self.x += inDx
    self.y += inDy
  }

  //····················································································································
  //  HORIZONTAL FLIP
  //····················································································································

  func flipHorizontally_PackageOval () {
  }

  //····················································································································

  func canFlipHorizontally_PackageOval () -> Bool {
    return false
  }

  //····················································································································
  //  VERTICAL FLIP
  //····················································································································

  func flipVertically_PackageOval () {
  }

  //····················································································································

  func canFlipVertically_PackageOval () -> Bool {
    return false
  }

  //····················································································································
  //  Knob
  //····················································································································

  func canMove_PackageOval (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                         shift inShift : Bool) -> CanariPoint {
    var dx = inProposedAlignedTranslation.x
    var dy = inProposedAlignedTranslation.y
    if inKnobIndex == PACKAGE_OVAL_LEFT {
      if (self.width - dx) < 0 {
        dx = self.width
      }
    }else if inKnobIndex == PACKAGE_OVAL_RIGHT {
      if (self.width + dx) < 0 {
        dx = -self.width
      }
    }else if inKnobIndex == PACKAGE_OVAL_BOTTOM {
      if (self.height - dy) < 0 {
        dy = self.height
      }
    }else if inKnobIndex == PACKAGE_OVAL_TOP {
      if (self.height + dy) < 0 {
        dy = -self.height
      }
    }
    return CanariPoint (x: dx, y: dy)
 }

  //····················································································································

  func move_PackageOval (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
    if inKnobIndex == PACKAGE_OVAL_RIGHT {
      self.width += inDx
    }else if inKnobIndex == PACKAGE_OVAL_LEFT {
      self.x += inDx
      self.width -= inDx
    }else if inKnobIndex == PACKAGE_OVAL_TOP {
      self.height += inDy
    }else if inKnobIndex == PACKAGE_OVAL_BOTTOM {
      self.y += inDy
      self.height -= inDy
    }
  }

  //····················································································································
  //  Rotate 90°
  //····················································································································

  func canRotate90_PackageOval (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insertCanariPoint (x: self.x, y: self.y)
    accumulatedPoints.insertCanariPoint (x: self.x + self.width, y: self.y + self.height)
    return true
  }

  //····················································································································

  func rotate90Clockwise_PackageOval (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <AnyObject>) {
    let newCenter = inRotationCenter.rotated90Clockwise (x: self.x + self.width / 2, y: self.y + self.height / 2)
    (self.width, self.height) = (self.height, self.width)
    self.x = newCenter.x - self.width / 2
    self.y = newCenter.y - self.height / 2
  }

  //····················································································································

  func rotate90CounterClockwise_PackageOval (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <AnyObject>) {
    let newCenter = inRotationCenter.rotated90CounterClockwise (x: self.x + self.width / 2, y: self.y + self.height / 2)
    (self.width, self.height) = (self.height, self.width)
    self.x = newCenter.x - self.width / 2
    self.y = newCenter.y - self.height / 2
  }

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  func canSnapToGrid_PackageOval (_ inGrid : Int) -> Bool {
    var result = (self.x % inGrid) != 0
    if !result {
      result = (self.y % inGrid) != 0
    }
    if !result {
      result = (self.width % inGrid) != 0
    }
    if !result {
      result = (self.height % inGrid) != 0
    }
    return result
  }

  //····················································································································

  func snapToGrid_PackageOval (_ inGrid : Int) {
    self.x = ((self.x + inGrid / 2) / inGrid) * inGrid
    self.y = ((self.y + inGrid / 2) / inGrid) * inGrid
    self.width = ((self.width + inGrid / 2) / inGrid) * inGrid
    self.height = ((self.height + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  func alignmentPoints_PackageOval () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insertCanariPoint (x: self.x, y: self.y)
    result.insertCanariPoint (x: self.x + self.width, y: self.y + self.height)
    return result
  }

  //····················································································································
  //  operationBeforeRemoving
  //····················································································································

  func operationBeforeRemoving_PackageOval () {
  }

  //····················································································································

  override func program () -> String {
    var s = "oval "
    s += stringFrom (valueInCanariUnit: self.x, displayUnit : self.xUnit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.y, displayUnit : self.yUnit)
    s += " size "
    s += stringFrom (valueInCanariUnit: self.width, displayUnit : self.widthUnit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.height, displayUnit : self.heightUnit)
    s += ";\n"
    return s
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
