import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PACKAGE_DIMENSION_CENTER = 1
let PACKAGE_DIMENSION_ENDPOINT_1 = 2
let PACKAGE_DIMENSION_ENDPOINT_2 = 3
let PACKAGE_DIMENSION_TEXT       = 4

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION PackageDimension
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackageDimension {

  //····················································································································

  func cursorForKnob_PackageDimension (knob inKnobIndex: Int) -> NSCursor? {
    if inKnobIndex == PACKAGE_DIMENSION_CENTER {
      return nil
    }else{
      return NSCursor.upDownRightLeftCursor
    }
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_PackageDimension (additionalDictionary inDictionary : NSDictionary,
                                             optionalDocument inOptionalDocument : EBAutoLayoutManagedDocument?,
                                             objectArray inObjectArray : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_PackageDimension (_ ioDictionary : NSMutableDictionary) {
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_PackageDimension  (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //····················································································································

  func acceptToTranslate_PackageDimension (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_PackageDimension (xBy inDx: Int, yBy inDy: Int, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    self.x1 += inDx
    self.y1 += inDy
    self.x2 += inDx
    self.y2 += inDy
  }

  //····················································································································
  //  Move
  //····················································································································

  func canMove_PackageDimension (knob inKnobIndex : Int,
                proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                shift inShift : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  //····················································································································

  func move_PackageDimension (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
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

  //····················································································································
  //  Flip horizontally
  //····················································································································

  func canFlipHorizontally_PackageDimension () -> Bool {
    return self.x1 != self.x2
  }

  //····················································································································

  func flipHorizontally_PackageDimension () {
    (self.x1, self.x2) = (self.x2, self.x1)
  }

  //····················································································································
  //  Flip vertically
  //····················································································································

  func canFlipVertically_PackageDimension () -> Bool {
    return self.y1 != self.y2
  }

  //····················································································································

  func flipVertically_PackageDimension () {
    (self.y1, self.y2) = (self.y2, self.y1)
  }

  //····················································································································
  //  Rotate 90°
  //····················································································································

  func canRotate90_PackageDimension (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insertCanariPoint (x: self.x1, y: self.y1)
    accumulatedPoints.insertCanariPoint (x: self.x2, y: self.y2)
    return true
  }

  //····················································································································

  func rotate90Clockwise_PackageDimension (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
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

  //····················································································································

  func rotate90CounterClockwise_PackageDimension (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
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

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  func canSnapToGrid_PackageDimension (_ inGrid : Int) -> Bool {
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
    if !result {
      result = (self.xDimension % inGrid) != 0
    }
    if !result {
      result = (self.yDimension % inGrid) != 0
    }
    return result
  }

  //····················································································································

  func snapToGrid_PackageDimension (_ inGrid : Int) {
    self.x1 = ((self.x1 + inGrid / 2) / inGrid) * inGrid
    self.y1 = ((self.y1 + inGrid / 2) / inGrid) * inGrid
    self.x2 = ((self.x2 + inGrid / 2) / inGrid) * inGrid
    self.y2 = ((self.y2 + inGrid / 2) / inGrid) * inGrid
    self.xDimension = ((self.xDimension + inGrid / 2) / inGrid) * inGrid
    self.yDimension = ((self.yDimension + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  func alignmentPoints_PackageDimension () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insertCanariPoint (x: self.x1, y: self.y1)
    result.insertCanariPoint (x: self.x2, y: self.y2)
    result.insertCanariPoint (x: self.xDimension, y: self.yDimension)
    return result
  }

  //····················································································································
  //  operationBeforeRemoving
  //····················································································································

  func operationBeforeRemoving_PackageDimension () {
  }

  //····················································································································

  override func program () -> String {
    var s = "dimension "
    s += stringFrom (valueInCanariUnit: self.x1, displayUnit : self.x1Unit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.y1, displayUnit : self.y1Unit)
    s += " to "
    s += stringFrom (valueInCanariUnit: self.x2, displayUnit : self.x2Unit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.y2, displayUnit : self.y2Unit)
    s += " label "
    s += stringFrom (valueInCanariUnit: self.xDimension, displayUnit : self.xDimensionUnit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.yDimension, displayUnit : self.yDimensionUnit)
    s += " unit "
    s += stringFrom (displayUnit : self.distanceUnit)
    s += ";\n"
    return s
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
