import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PACKAGE_GUIDE_CENTER = 1
let PACKAGE_GUIDE_ENDPOINT_1 = 2
let PACKAGE_GUIDE_ENDPOINT_2 = 3

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION PackageGuide
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackageGuide {

  //····················································································································

  func cursorForKnob_PackageGuide (knob inKnobIndex : Int) -> NSCursor? {
    if inKnobIndex == PACKAGE_GUIDE_CENTER {
      return nil
    }else{
      return NSCursor.upDownRightLeftCursor
    }
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_PackageGuide (additionalDictionary _ : [String : Any],
                                           optionalDocument _ : EBAutoLayoutManagedDocument?,
                                           objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_PackageGuide (_ _ : inout [String : Any]) {
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_PackageGuide  (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //····················································································································

  func acceptToTranslate_PackageGuide (xBy _ : Int, yBy _ : Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_PackageGuide (xBy inDx: Int,
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

  func canMove_PackageGuide (knob _ : Int,
                             proposedUnalignedAlignedTranslation _ : CanariPoint,
                             proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                             unalignedMouseDraggedLocation _ : CanariPoint,
                             shift _ : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  //····················································································································

  func move_PackageGuide (knob inKnobIndex : Int,
                          proposedDx inDx : Int,
                          proposedDy inDy : Int,
                          unalignedMouseLocationX _ : Int,
                          unalignedMouseLocationY _ : Int,
                          alignedMouseLocationX _ : Int,
                          alignedMouseLocationY _ : Int,
                          shift _ : Bool) {
    if inKnobIndex == PACKAGE_GUIDE_CENTER {
      self.x1 += inDx
      self.y1 += inDy
      self.x2 += inDx
      self.y2 += inDy
    }else if inKnobIndex == PACKAGE_GUIDE_ENDPOINT_1 {
        self.x1 += inDx
        self.y1 += inDy
    }else if inKnobIndex == PACKAGE_GUIDE_ENDPOINT_2 {
      self.x2 += inDx
      self.y2 += inDy
    }
  }

  //····················································································································
  //  Flip horizontally
  //····················································································································

  func canFlipHorizontally_PackageGuide () -> Bool {
    return self.x1 != self.x2
  }

  //····················································································································

  func flipHorizontally_PackageGuide () {
    (self.x1, self.x2) = (self.x2, self.x1)
  }

  //····················································································································
  //  Flip vertically
  //····················································································································

  func canFlipVertically_PackageGuide () -> Bool {
    return self.y1 != self.y2
  }

  //····················································································································

  func flipVertically_PackageGuide () {
    (self.y1, self.y2) = (self.y2, self.y1)
  }

  //····················································································································
  //  Rotate 90°
  //····················································································································

  func canRotate90_PackageGuide (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insertCanariPoint (x: self.x1, y: self.y1)
    accumulatedPoints.insertCanariPoint (x: self.x2, y: self.y2)
    return true
  }

  //····················································································································

  func rotate90Clockwise_PackageGuide (from inRotationCenter : CanariPoint,
                                       userSet _ : inout EBReferenceSet <EBManagedObject>) {
    let p1 = inRotationCenter.rotated90Clockwise (x: self.x1, y: self.y1)
    self.x1 = p1.x
    self.y1 = p1.y
    let p2 = inRotationCenter.rotated90Clockwise (x: self.x2, y: self.y2)
    self.x2 = p2.x
    self.y2 = p2.y
  }

  //····················································································································

  func rotate90CounterClockwise_PackageGuide (from inRotationCenter : CanariPoint,
                                              userSet _ : inout EBReferenceSet <EBManagedObject>) {
    let p1 = inRotationCenter.rotated90CounterClockwise (x: self.x1, y: self.y1)
    self.x1 = p1.x
    self.y1 = p1.y
    let p2 = inRotationCenter.rotated90CounterClockwise (x: self.x2, y: self.y2)
    self.x2 = p2.x
    self.y2 = p2.y
  }

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  func canSnapToGrid_PackageGuide (_ inGrid : Int) -> Bool {
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

  func snapToGrid_PackageGuide (_ inGrid : Int) {
    self.x1 = ((self.x1 + inGrid / 2) / inGrid) * inGrid
    self.y1 = ((self.y1 + inGrid / 2) / inGrid) * inGrid
    self.x2 = ((self.x2 + inGrid / 2) / inGrid) * inGrid
    self.y2 = ((self.y2 + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  func alignmentPoints_PackageGuide () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insertCanariPoint (x: self.x1, y: self.y1)
    result.insertCanariPoint (x: self.x2, y: self.y2)
    return result
  }

  //····················································································································
  //  operationBeforeRemoving
  //····················································································································

  func operationBeforeRemoving_PackageGuide () {
  }

  //····················································································································

  override func program () -> String {
    var s = "guide "
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
