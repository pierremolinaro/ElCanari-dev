import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let SYMBOL_BEZIER_CURVE_ENDPOINT_1 = 1
let SYMBOL_BEZIER_CURVE_ENDPOINT_2 = 2
let SYMBOL_BEZIER_CURVE_CONTROL_1  = 3
let SYMBOL_BEZIER_CURVE_CONTROL_2  = 4

//--------------------------------------------------------------------------------------------------
//   EXTENSION SymbolBezierCurve
//--------------------------------------------------------------------------------------------------

extension SymbolBezierCurve {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func cursorForKnob_SymbolBezierCurve (knob _ : Int) -> NSCursor? {
    return NSCursor.upDownRightLeftCursor
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationAfterPasting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_SymbolBezierCurve (additionalDictionary _ : [String : Any],
                                                optionalDocument _ : EBAutoLayoutManagedDocument?,
                                                objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_SymbolBezierCurve (_ _ : inout [String : Any]) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Translation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_SymbolBezierCurve (xBy inDx: CanariLength, yBy inDy: CanariLength) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_SymbolBezierCurve (xBy _ : CanariLength, yBy _ : CanariLength) -> Bool {
    return true
//    let newX1 = self.x1 + inDx
//    let newY1 = self.y1 + inDy
//    let newX2 = self.x2 + inDx
//    let newY2 = self.y2 + inDy
//    let newCPX1 = self.cpx1 + inDx
//    let newCPY1 = self.cpy1 + inDy
//    let newCPX2 = self.cpx2 + inDx
//    let newCPY2 = self.cpy2 + inDy
//    return (newX1 >= 0) && (newY1 >= 0) && (newX2 >= 0) && (newY2 >= 0)
//      && (newCPX1 >= 0) && (newCPY1 >= 0) && (newCPX2 >= 0) && (newCPY2 >= 0)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_SymbolBezierCurve (xBy inDx: CanariLength,
                                    yBy inDy: CanariLength,
                                    userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.x1 += inDx
    self.y1 += inDy
    self.x2 += inDx
    self.y2 += inDy
    self.cpx1 += inDx
    self.cpy1 += inDy
    self.cpx2 += inDx
    self.cpy2 += inDy
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Move
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_SymbolBezierCurve (knob _ : Int,
                                  proposedUnalignedAlignedTranslation _ : CanariPoint,
                                  proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                                  unalignedMouseDraggedLocation _ : CanariPoint,
                                  shift _ : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
 }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_SymbolBezierCurve (knob inKnobIndex: Int,
                               proposedDx inDx: CanariLength,
                               proposedDy inDy: CanariLength,
                               unalignedMouseLocationX _ : CanariLength,
                               unalignedMouseLocationY _ : CanariLength,
                               alignedMouseLocationX _ : CanariLength,
                               alignedMouseLocationY _ : CanariLength,
                               shift _ : Bool) {
    if inKnobIndex == SYMBOL_BEZIER_CURVE_ENDPOINT_1 {
      self.x1 += inDx
      self.y1 += inDy
    }else if inKnobIndex == SYMBOL_BEZIER_CURVE_ENDPOINT_2 {
      self.x2 += inDx
      self.y2 += inDy
    }else if inKnobIndex == SYMBOL_BEZIER_CURVE_CONTROL_1 {
      self.cpx1 += inDx
      self.cpy1 += inDy
    }else if inKnobIndex == SYMBOL_BEZIER_CURVE_CONTROL_2 {
      self.cpx2 += inDx
      self.cpy2 += inDy
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Flip horizontally
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_SymbolBezierCurve () -> Bool {
    return min (self.x1, self.x2, self.cpx1, self.cpx2) != max (self.x1, self.x2, self.cpx1, self.cpx2)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_SymbolBezierCurve () {
    let v = min (self.x1, self.x2, self.cpx1, self.cpx2) + max (self.x1, self.x2, self.cpx1, self.cpx2)
    self.x1 = v - self.x1
    self.x2 = v - self.x2
    self.cpx1 = v - self.cpx1
    self.cpx2 = v - self.cpx2
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Flip vertically
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_SymbolBezierCurve () -> Bool {
    return min (self.y1, self.y2, self.cpy1, self.cpy2) != max (self.y1, self.y2, self.cpy1, self.cpy2)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_SymbolBezierCurve () {
    let v = min (self.y1, self.y2, self.cpy1, self.cpy2) + max (self.y1, self.y2, self.cpy1, self.cpy2)
    self.y1 = v - self.y1
    self.y2 = v - self.y2
    self.cpy1 = v - self.cpy1
    self.cpy2 = v - self.cpy2
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Rotate 90°
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_SymbolBezierCurve (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insert (x: self.x1, y: self.y1)
    accumulatedPoints.insert (x: self.x2, y: self.y2)
    accumulatedPoints.insert (x: self.cpx1, y: self.cpy1)
    accumulatedPoints.insert (x: self.cpx2, y: cpy2)
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90Clockwise_SymbolBezierCurve (from inRotationCenter : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    let p1 = inRotationCenter.rotated90Clockwise (x: self.x1, y: self.y1)
    let p2 = inRotationCenter.rotated90Clockwise (x: self.x2, y: self.y2)
    let cp1 = inRotationCenter.rotated90Clockwise (x: self.cpx1, y: self.cpy1)
    let cp2 = inRotationCenter.rotated90Clockwise (x: self.cpx2, y: self.cpy2)
    self.x1 = p1.x
    self.y1 = p1.y
    self.cpx1 = cp1.x
    self.cpy1 = cp1.y
    self.x2 = p2.x
    self.y2 = p2.y
    self.cpx2 = cp2.x
    self.cpy2 = cp2.y
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90CounterClockwise_SymbolBezierCurve (from inRotationCenter : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    let p1 = inRotationCenter.rotated90CounterClockwise (x: self.x1, y: self.y1)
    let p2 = inRotationCenter.rotated90CounterClockwise (x: self.x2, y: self.y2)
    let cp1 = inRotationCenter.rotated90CounterClockwise (x: self.cpx1, y: self.cpy1)
    let cp2 = inRotationCenter.rotated90CounterClockwise (x: self.cpx2, y: self.cpy2)
    self.x1 = p1.x
    self.y1 = p1.y
    self.cpx1 = cp1.x
    self.cpy1 = cp1.y
    self.x2 = p2.x
    self.y2 = p2.y
    self.cpx2 = cp2.x
    self.cpy2 = cp2.y
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_SymbolBezierCurve (_ inGrid : CanariLength) -> Bool {
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
      result = self.cpx2.isAligned (on: inGrid)
    }
    if !result {
      result = self.cpy2.isAligned (on: inGrid)
    }
    if !result {
      result = self.cpx1.isAligned (on: inGrid)
    }
    if !result {
      result = self.cpy1.isAligned (on: inGrid)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_SymbolBezierCurve (_ inGrid : CanariLength) {
    self.x1.align (on: inGrid)
    self.y1.align (on: inGrid)
    self.x2.align (on: inGrid)
    self.y2.align (on: inGrid)
    self.cpx1.align (on: inGrid)
    self.cpy1.align (on: inGrid)
    self.cpx2.align (on: inGrid)
    self.cpy2.align (on: inGrid)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_SymbolBezierCurve () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insert (x: self.x1, y: self.y1)
    result.insert (x: self.x2, y: self.y2)
    result.insert (x: self.cpx1, y: self.cpy1)
    result.insert (x: self.cpx2, y: self.cpy2)
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationBeforeRemoving
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_SymbolBezierCurve () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
