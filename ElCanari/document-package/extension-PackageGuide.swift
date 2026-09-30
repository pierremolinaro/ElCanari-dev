import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let PACKAGE_GUIDE_CENTER = 1
let PACKAGE_GUIDE_ENDPOINT_1 = 2
let PACKAGE_GUIDE_ENDPOINT_2 = 3

//--------------------------------------------------------------------------------------------------
//   EXTENSION PackageGuide
//--------------------------------------------------------------------------------------------------

extension PackageGuide {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func cursorForKnob_PackageGuide (knob inKnobIndex : Int) -> NSCursor? {
    if inKnobIndex == PACKAGE_GUIDE_CENTER {
      return nil
    }else{
      return NSCursor.upDownRightLeftCursor
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationAfterPasting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_PackageGuide (additionalDictionary _ : [String : Any],
                                           optionalDocument _ : EBAutoLayoutManagedDocument?,
                                           objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_PackageGuide (_ _ : inout [String : Any]) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Translation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_PackageGuide  (xBy inDx: CanariLength, yBy inDy: CanariLength) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_PackageGuide (xBy _ : CanariLength, yBy _ : CanariLength) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_PackageGuide (xBy inDx: CanariLength,
                               yBy inDy: CanariLength,
                               userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.x1 += inDx
    self.y1 += inDy
    self.x2 += inDx
    self.y2 += inDy
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Move
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_PackageGuide (knob _ : Int,
                             proposedUnalignedAlignedTranslation _ : CanariPoint,
                             proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                             unalignedMouseDraggedLocation _ : CanariPoint,
                             shift _ : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_PackageGuide (knob inKnobIndex : Int,
                          proposedDx inDx : CanariLength,
                          proposedDy inDy : CanariLength,
                          unalignedMouseLocationX _ : CanariLength,
                          unalignedMouseLocationY _ : CanariLength,
                          alignedMouseLocationX _ : CanariLength,
                          alignedMouseLocationY _ : CanariLength,
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Flip horizontally
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_PackageGuide () -> Bool {
    return self.x1 != self.x2
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_PackageGuide () {
    (self.x1, self.x2) = (self.x2, self.x1)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Flip vertically
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_PackageGuide () -> Bool {
    return self.y1 != self.y2
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_PackageGuide () {
    (self.y1, self.y2) = (self.y2, self.y1)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Rotate 90°
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_PackageGuide (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insert (x: self.x1, y: self.y1)
    accumulatedPoints.insert (x: self.x2, y: self.y2)
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90Clockwise_PackageGuide (from inRotationCenter : CanariPoint,
                                       userSet _ : inout EBReferenceSet <EBManagedObject>) {
    let p1 = inRotationCenter.rotated90Clockwise (x: self.x1, y: self.y1)
    self.x1 = p1.x
    self.y1 = p1.y
    let p2 = inRotationCenter.rotated90Clockwise (x: self.x2, y: self.y2)
    self.x2 = p2.x
    self.y2 = p2.y
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90CounterClockwise_PackageGuide (from inRotationCenter : CanariPoint,
                                              userSet _ : inout EBReferenceSet <EBManagedObject>) {
    let p1 = inRotationCenter.rotated90CounterClockwise (x: self.x1, y: self.y1)
    self.x1 = p1.x
    self.y1 = p1.y
    let p2 = inRotationCenter.rotated90CounterClockwise (x: self.x2, y: self.y2)
    self.x2 = p2.x
    self.y2 = p2.y
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_PackageGuide (_ inGrid : CanariLength) -> Bool {
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
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_PackageGuide (_ inGrid : CanariLength) {
    self.x1.align (on: inGrid)
    self.y1.align (on: inGrid)
    self.x2.align (on: inGrid)
    self.y2.align (on: inGrid)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_PackageGuide () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insert (x: self.x1, y: self.y1)
    result.insert (x: self.x2, y: self.y2)
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationBeforeRemoving
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_PackageGuide () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func program () -> String {
    var s = "guide "
    s += self.x1.string (in: self.x1Unit, fractionDigits: 2)
    s += " : "
    s += self.y1.string (in: self.y1Unit, fractionDigits: 2)
    s += " to "
    s += self.x2.string (in: self.x2Unit, fractionDigits: 2)
    s += " : "
    s += self.y2.string (in: self.y2Unit, fractionDigits: 2)
    s += ";\n"
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
