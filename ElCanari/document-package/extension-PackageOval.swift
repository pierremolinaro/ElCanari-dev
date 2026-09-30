import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let PACKAGE_OVAL_BOTTOM = 1
let PACKAGE_OVAL_RIGHT  = 2
let PACKAGE_OVAL_LEFT   = 3
let PACKAGE_OVAL_TOP    = 4

//--------------------------------------------------------------------------------------------------
//   EXTENSION PackageOval
//--------------------------------------------------------------------------------------------------

extension PackageOval {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func cursorForKnob_PackageOval (knob inKnobIndex : Int) -> NSCursor? {
    if (inKnobIndex == PACKAGE_OVAL_RIGHT) && (inKnobIndex == PACKAGE_OVAL_LEFT) {
      return NSCursor.resizeLeftRight
    }else if (inKnobIndex == PACKAGE_OVAL_BOTTOM) && (inKnobIndex == PACKAGE_OVAL_TOP) {
      return NSCursor.resizeUpDown
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationAfterPasting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_PackageOval (additionalDictionary _ : [String : Any],
                                          optionalDocument _ : EBAutoLayoutManagedDocument?,
                                          objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_PackageOval (_ _ : inout [String : Any]) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Translation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_PackageOval  (xBy inDx: CanariLength, yBy inDy: CanariLength) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_PackageOval (xBy _ : CanariLength, yBy _ : CanariLength) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_PackageOval (xBy inDx: CanariLength,
                              yBy inDy: CanariLength,
                              userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.x += inDx
    self.y += inDy
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  HORIZONTAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_PackageOval () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_PackageOval () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  VERTICAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_PackageOval () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_PackageOval () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Knob
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_PackageOval (knob inKnobIndex : Int,
                            proposedUnalignedAlignedTranslation _ : CanariPoint,
                            proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                            unalignedMouseDraggedLocation _ : CanariPoint,
                            shift _ : Bool) -> CanariPoint {
    var dx = inProposedAlignedTranslation.x
    var dy = inProposedAlignedTranslation.y
    if inKnobIndex == PACKAGE_OVAL_LEFT {
      if (self.width - dx) < .zero {
        dx = self.width
      }
    }else if inKnobIndex == PACKAGE_OVAL_RIGHT {
      if (self.width + dx) < .zero {
        dx = -self.width
      }
    }else if inKnobIndex == PACKAGE_OVAL_BOTTOM {
      if (self.height - dy) < .zero {
        dy = self.height
      }
    }else if inKnobIndex == PACKAGE_OVAL_TOP {
      if (self.height + dy) < .zero {
        dy = -self.height
      }
    }
    return CanariPoint (x: dx, y: dy)
 }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_PackageOval (knob inKnobIndex : Int,
                         proposedDx inDx : CanariLength,
                         proposedDy inDy : CanariLength,
                         unalignedMouseLocationX _ : CanariLength,
                         unalignedMouseLocationY _ : CanariLength,
                         alignedMouseLocationX _ : CanariLength,
                         alignedMouseLocationY _ : CanariLength,
                         shift _ : Bool) {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Rotate 90°
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_PackageOval (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insert (x: self.x, y: self.y)
    accumulatedPoints.insert (x: self.x + self.width, y: self.y + self.height)
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90Clockwise_PackageOval (from inRotationCenter : CanariPoint,
                                      userSet _ : inout EBReferenceSet <EBManagedObject>) {
    let newCenter = inRotationCenter.rotated90Clockwise (x: self.x + self.width / 2, y: self.y + self.height / 2)
    (self.width, self.height) = (self.height, self.width)
    self.x = newCenter.x - self.width / 2
    self.y = newCenter.y - self.height / 2
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90CounterClockwise_PackageOval (from inRotationCenter : CanariPoint,
                                             userSet _ : inout EBReferenceSet <EBManagedObject>) {
    let newCenter = inRotationCenter.rotated90CounterClockwise (x: self.x + self.width / 2, y: self.y + self.height / 2)
    (self.width, self.height) = (self.height, self.width)
    self.x = newCenter.x - self.width / 2
    self.y = newCenter.y - self.height / 2
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_PackageOval (_ inGrid : CanariLength) -> Bool {
    var result = self.x.isAligned (on: inGrid)
    if !result {
      result = self.y.isAligned (on: inGrid)
    }
    if !result {
      result = self.width.isAligned (on: inGrid)
    }
    if !result {
      result = self.height.isAligned (on: inGrid)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_PackageOval (_ inGrid : CanariLength) {
    self.x.align (on: inGrid)
    self.y.align (on: inGrid)
    self.width.align (on: inGrid)
    self.height.align (on: inGrid)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_PackageOval () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insert (x: self.x, y: self.y)
    result.insert (x: self.x + self.width, y: self.y + self.height)
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationBeforeRemoving
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_PackageOval () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func program () -> String {
    var s = "oval "
    s += self.x.string (in: self.xUnit, fractionDigits: 2)
    s += " : "
    s += self.y.string (in: self.yUnit, fractionDigits: 2)
    s += " size "
    s += self.width.string (in: self.widthUnit, fractionDigits: 2)
    s += " : "
    s += self.height.string (in: self.heightUnit, fractionDigits: 2)
    s += ";\n"
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
