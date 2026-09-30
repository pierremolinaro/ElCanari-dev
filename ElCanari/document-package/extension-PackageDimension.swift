import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let PACKAGE_DIMENSION_CENTER = 1
let PACKAGE_DIMENSION_ENDPOINT_1 = 2
let PACKAGE_DIMENSION_ENDPOINT_2 = 3
let PACKAGE_DIMENSION_TEXT       = 4

//--------------------------------------------------------------------------------------------------
//   EXTENSION PackageDimension
//--------------------------------------------------------------------------------------------------

extension PackageDimension {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func cursorForKnob_PackageDimension (knob inKnobIndex : Int) -> NSCursor? {
    if inKnobIndex == PACKAGE_DIMENSION_CENTER {
      return nil
    }else{
      return NSCursor.upDownRightLeftCursor
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationAfterPasting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_PackageDimension (additionalDictionary _ : [String : Any],
                                               optionalDocument _ : EBAutoLayoutManagedDocument?,
                                               objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_PackageDimension (_ _ : inout [String : Any]) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Translation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_PackageDimension (xBy inDx: CanariLength, yBy inDy: CanariLength) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_PackageDimension (xBy _ : CanariLength, yBy _ : CanariLength) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_PackageDimension (xBy inDx: CanariLength, yBy inDy: CanariLength, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.x1 += inDx
    self.y1 += inDy
    self.x2 += inDx
    self.y2 += inDy
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Move
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_PackageDimension (knob _ : Int,
                                 proposedUnalignedAlignedTranslation _ : CanariPoint,
                                 proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                                 unalignedMouseDraggedLocation _ : CanariPoint,
                                 shift _ : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_PackageDimension (knob inKnobIndex: Int,
                              proposedDx inDx: CanariLength,
                              proposedDy inDy: CanariLength,
                              unalignedMouseLocationX _ : CanariLength,
                              unalignedMouseLocationY _ : CanariLength,
                              alignedMouseLocationX _ : CanariLength,
                              alignedMouseLocationY _ : CanariLength,
                              shift _ : Bool) {
    if inKnobIndex == PACKAGE_DIMENSION_CENTER {
      self.x1 += inDx
      self.y1 += inDy
      self.x2 += inDx
      self.y2 += inDy
    }else if inKnobIndex == PACKAGE_DIMENSION_ENDPOINT_1 {
        self.x1 += inDx
        self.y1 += inDy
    }else if inKnobIndex == PACKAGE_DIMENSION_ENDPOINT_2 {
      self.x2 += inDx
      self.y2 += inDy
    }else if inKnobIndex == PACKAGE_DIMENSION_TEXT {
      self.xDimension += inDx
      self.yDimension += inDy
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Flip horizontally
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_PackageDimension () -> Bool {
    return self.x1 != self.x2
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_PackageDimension () {
    (self.x1, self.x2) = (self.x2, self.x1)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Flip vertically
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_PackageDimension () -> Bool {
    return self.y1 != self.y2
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_PackageDimension () {
    (self.y1, self.y2) = (self.y2, self.y1)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Rotate 90°
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_PackageDimension (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insert (x: self.x1, y: self.y1)
    accumulatedPoints.insert (x: self.x2, y: self.y2)
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90Clockwise_PackageDimension (from inRotationCenter : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    let p1 = inRotationCenter.rotated90Clockwise (x: self.x1, y: self.y1)
    self.x1 = p1.x
    self.y1 = p1.y
    let p2 = inRotationCenter.rotated90Clockwise (x: self.x2, y: self.y2)
    self.x2 = p2.x
    self.y2 = p2.y
    let p = inRotationCenter.rotated90Clockwise (x: self.xDimension, y: self.yDimension)
    self.xDimension = p.x
    self.yDimension = p.y
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90CounterClockwise_PackageDimension (from inRotationCenter : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    let p1 = inRotationCenter.rotated90CounterClockwise (x: self.x1, y: self.y1)
    self.x1 = p1.x
    self.y1 = p1.y
    let p2 = inRotationCenter.rotated90CounterClockwise (x: self.x2, y: self.y2)
    self.x2 = p2.x
    self.y2 = p2.y
    let p = inRotationCenter.rotated90CounterClockwise (x: self.xDimension, y: self.yDimension)
    self.xDimension = p.x
    self.yDimension = p.y
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_PackageDimension (_ inGrid : CanariLength) -> Bool {
    var result = self.x1.isAligned (on: inGrid)
    if !result {
      result = self.y1.isAligned (on: inGrid)
    }
    if !result {
      result = self.x2.isAligned (on: inGrid)
    }
    if !result {
      result = self.y2.isAligned (on: inGrid)
    }
    if !result {
      result = self.xDimension.isAligned (on: inGrid)
    }
    if !result {
      result = self.yDimension.isAligned (on: inGrid)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_PackageDimension (_ inGrid : CanariLength) {
    self.x1.align (on: inGrid)
    self.y1.align (on: inGrid)
    self.x2.align (on: inGrid)
    self.y2.align (on: inGrid)
    self.xDimension.align (on: inGrid)
    self.yDimension.align (on: inGrid)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_PackageDimension () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insert (x: self.x1, y: self.y1)
    result.insert (x: self.x2, y: self.y2)
    result.insert (x: self.xDimension, y: self.yDimension)
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationBeforeRemoving
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_PackageDimension () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func program () -> String {
    var s = "dimension "
    s += self.x1.string (in: self.x1Unit, fractionDigits: 2)
    s += " : "
    s += self.y1.string (in: self.y1Unit, fractionDigits: 2)
    s += " to "
    s += self.x2.string (in: self.x2Unit, fractionDigits: 2)
    s += " : "
    s += self.y2.string (in: self.y2Unit, fractionDigits: 2)
    s += " label "
    s += self.xDimension.string (in: self.xDimensionUnit, fractionDigits: 2)
    s += " : "
    s += self.yDimension.string (in: self.yDimensionUnit, fractionDigits: 2)
    s += " unit "
    s += self.distanceUnit.unitString
    s += ";\n"
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
