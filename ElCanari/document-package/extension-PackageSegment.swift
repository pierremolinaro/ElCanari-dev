import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PACKAGE_SEGMENT_ENDPOINT_1 = 1
let PACKAGE_SEGMENT_ENDPOINT_2 = 2

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION PackageSegment
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackageSegment {

  //····················································································································

  func cursorForKnob_PackageSegment (knob _ : Int) -> NSCursor? {
    return NSCursor.upDownRightLeftCursor
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_PackageSegment (additionalDictionary _ : [String : Any],
                                             optionalDocument _ : EBAutoLayoutManagedDocument?,
                                             objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_PackageSegment (_ _ : inout [String : Any]) {
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_PackageSegment  (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //····················································································································

  func acceptToTranslate_PackageSegment (xBy _ : Int, yBy _ : Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_PackageSegment (xBy inDx: Int,
                                 yBy inDy: Int,
                                 userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.x1 += inDx
    self.y1 += inDy
    self.x2 += inDx
    self.y2 += inDy
  }

  //····················································································································
  //  Move
  //····················································································································

  func canMove_PackageSegment (knob _ : Int,
                               proposedUnalignedAlignedTranslation _ : CanariPoint,
                               proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                               unalignedMouseDraggedLocation _ : CanariPoint,
                               shift _ : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  //····················································································································

  func move_PackageSegment (knob inKnobIndex : Int,
                            proposedDx inDx : Int,
                            proposedDy inDy : Int,
                            unalignedMouseLocationX _ : Int,
                            unalignedMouseLocationY _ : Int,
                            alignedMouseLocationX _ : Int,
                            alignedMouseLocationY _ : Int,
                            shift _ : Bool) {
    if inKnobIndex == PACKAGE_SEGMENT_ENDPOINT_1 {
      self.x1 += inDx
      self.y1 += inDy
    }else if inKnobIndex == PACKAGE_SEGMENT_ENDPOINT_2 {
      self.x2 += inDx
      self.y2 += inDy
    }
  }

  //····················································································································
  //  Flip horizontally
  //····················································································································

  func canFlipHorizontally_PackageSegment () -> Bool {
    return x1 != x2
  }

  //····················································································································

  func flipHorizontally_PackageSegment () {
    (x1, x2) = (x2, x1)
  }

  //····················································································································
  //  Flip vertically
  //····················································································································

  func canFlipVertically_PackageSegment () -> Bool {
    return y1 != y2
  }

  //····················································································································

  func flipVertically_PackageSegment () {
    (y1, y2) = (y2, y1)
  }

  //····················································································································
  //  Rotate 90°
  //····················································································································

  func canRotate90_PackageSegment (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insertCanariPoint (x: self.x1, y: self.y1)
    accumulatedPoints.insertCanariPoint (x: self.x2, y: self.y2)
    return true
  }

  //····················································································································

  func rotate90Clockwise_PackageSegment (from inRotationCenter : CanariPoint,
                                         userSet _ : inout EBReferenceSet <EBManagedObject>) {
    let p1 = inRotationCenter.rotated90Clockwise (x: self.x1, y: self.y1)
    let p2 = inRotationCenter.rotated90Clockwise (x: self.x2, y: self.y2)
    self.x1 = p1.x
    self.y1 = p1.y
    self.x2 = p2.x
    self.y2 = p2.y
  }

  //····················································································································

  func rotate90CounterClockwise_PackageSegment (from inRotationCenter : CanariPoint,
                                                userSet _ : inout EBReferenceSet <EBManagedObject>) {
    let p1 = inRotationCenter.rotated90CounterClockwise (x: self.x1, y: self.y1)
    let p2 = inRotationCenter.rotated90CounterClockwise (x: self.x2, y: self.y2)
    self.x1 = p1.x
    self.y1 = p1.y
    self.x2 = p2.x
    self.y2 = p2.y
  }

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  func canSnapToGrid_PackageSegment (_ inGrid : Int) -> Bool {
    var result = (self.x1 % inGrid) != 0
    if !result {
      result = (self.y1 % inGrid) != 0
    }
    if !result {
      result = (self.x2 % inGrid) != 0
    }
    if !result {
      result = (self.y2 % inGrid) != 0
    }
    return result
  }

  //····················································································································

  func snapToGrid_PackageSegment (_ inGrid : Int) {
    self.x1 = ((self.x1 + inGrid / 2) / inGrid) * inGrid
    self.y1 = ((self.y1 + inGrid / 2) / inGrid) * inGrid
    self.x2 = ((self.x2 + inGrid / 2) / inGrid) * inGrid
    self.y2 = ((self.y2 + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  func alignmentPoints_PackageSegment () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insertCanariPoint (x: self.x1, y: self.y1)
    result.insertCanariPoint (x: self.x2, y: self.y2)
    return result
  }

  //····················································································································
  //  operationBeforeRemoving
  //····················································································································

  func operationBeforeRemoving_PackageSegment () {
  }

  //····················································································································

  override func program () -> String {
    var s = "segment "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.x1, displayUnit : self.x1Unit)
    s += " : "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.y1, displayUnit : self.y1Unit)
    s += " to "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.x2, displayUnit : self.x2Unit)
    s += " : "
    s += intValueAndUnitStringFrom (valueInCanariUnit: self.y2, displayUnit : self.y2Unit)
    s += ";\n"
    return s
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
