import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SYMBOL_BEZIER_CURVE_ENDPOINT_1 = 1
let SYMBOL_BEZIER_CURVE_ENDPOINT_2 = 2
let SYMBOL_BEZIER_CURVE_CONTROL_1  = 3
let SYMBOL_BEZIER_CURVE_CONTROL_2  = 4

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION SymbolBezierCurve
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SymbolBezierCurve {

  //····················································································································

  func cursorForKnob_SymbolBezierCurve (knob inKnobIndex: Int) -> NSCursor? {
    return NSCursor.upDownRightLeftCursor
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_SymbolBezierCurve (additionalDictionary inDictionary : NSDictionary,
                                             optionalDocument inOptionalDocument : EBAutoLayoutManagedDocument?,
                                             objectArray inObjectArray : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_SymbolBezierCurve (_ ioDictionary : inout [String : Any]) {
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_SymbolBezierCurve (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }


//  override func acceptedTranslation (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
//    var acceptedX = inDx
//    do{
//      let newX = self.x1 + acceptedX
//      if newX < 0 {
//        acceptedX = -self.x1
//      }
//    }
//    do{
//      let newX = self.cpx1 + acceptedX
//      if newX < 0 {
//        acceptedX = -self.cpx1
//      }
//    }
//    do{
//      let newX = self.x2 + acceptedX
//      if newX < 0 {
//        acceptedX = -self.x2
//      }
//    }
//    do{
//      let newX = self.cpx2 + acceptedX
//      if newX < 0 {
//        acceptedX = -self.cpx2
//      }
//    }
//    var acceptedY = inDy
//    do{
//      let newY = self.y1 + acceptedY
//      if newY < 0 {
//        acceptedY = -self.y1
//      }
//    }
//    do{
//      let newY = self.cpy1 + acceptedY
//      if newY < 0 {
//        acceptedY = -self.cpy1
//      }
//    }
//    do{
//      let newY = self.y2 + acceptedY
//      if newY < 0 {
//        acceptedY = -self.y2
//      }
//    }
//    do{
//      let newY = self.cpy2 + acceptedY
//      if newY < 0 {
//        acceptedY = -self.cpy2
//      }
//    }
//    return CanariPoint (x: acceptedX, y: acceptedY)
//  }

  //····················································································································

  func acceptToTranslate_SymbolBezierCurve (xBy inDx: Int, yBy inDy: Int) -> Bool {
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

  //····················································································································

  func translate_SymbolBezierCurve (xBy inDx: Int, yBy inDy: Int, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    self.x1 += inDx
    self.y1 += inDy
    self.x2 += inDx
    self.y2 += inDy
    self.cpx1 += inDx
    self.cpy1 += inDy
    self.cpx2 += inDx
    self.cpy2 += inDy
  }

  //····················································································································
  //  Move
  //····················································································································

  func canMove_SymbolBezierCurve (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                         shift inShift : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
 }

  //····················································································································

  func move_SymbolBezierCurve (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
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

  //····················································································································
  //  Flip horizontally
  //····················································································································

  func canFlipHorizontally_SymbolBezierCurve () -> Bool {
    return min (self.x1, self.x2, self.cpx1, self.cpx2) != max (self.x1, self.x2, self.cpx1, self.cpx2)
  }

  //····················································································································

  func flipHorizontally_SymbolBezierCurve () {
    let v = min (self.x1, self.x2, self.cpx1, self.cpx2) + max (self.x1, self.x2, self.cpx1, self.cpx2)
    self.x1 = v - self.x1
    self.x2 = v - self.x2
    self.cpx1 = v - self.cpx1
    self.cpx2 = v - self.cpx2
  }

  //····················································································································
  //  Flip vertically
  //····················································································································

  func canFlipVertically_SymbolBezierCurve () -> Bool {
    return min (self.y1, self.y2, self.cpy1, self.cpy2) != max (self.y1, self.y2, self.cpy1, self.cpy2)
  }

  //····················································································································

  func flipVertically_SymbolBezierCurve () {
    let v = min (self.y1, self.y2, self.cpy1, self.cpy2) + max (self.y1, self.y2, self.cpy1, self.cpy2)
    self.y1 = v - self.y1
    self.y2 = v - self.y2
    self.cpy1 = v - self.cpy1
    self.cpy2 = v - self.cpy2
  }

  //····················································································································
  //  Rotate 90°
  //····················································································································

  func canRotate90_SymbolBezierCurve (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insertCanariPoint (x: self.x1, y: self.y1)
    accumulatedPoints.insertCanariPoint (x: self.x2, y: self.y2)
    accumulatedPoints.insertCanariPoint (x: self.cpx1, y: self.cpy1)
    accumulatedPoints.insertCanariPoint (x: self.cpx2, y: cpy2)
    return true
  }

  //····················································································································

  func rotate90Clockwise_SymbolBezierCurve (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
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

  //····················································································································

  func rotate90CounterClockwise_SymbolBezierCurve (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
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

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  func canSnapToGrid_SymbolBezierCurve (_ inGrid : Int) -> Bool {
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
      result = (self.cpx2 % inGrid) != 0
    }
    if !result {
      result = (self.cpy2 % inGrid) != 0
    }
    if !result {
      result = (self.cpx1 % inGrid) != 0
    }
    if !result {
      result = (self.cpy1 % inGrid) != 0
    }
    return result
  }

  //····················································································································

  func snapToGrid_SymbolBezierCurve (_ inGrid : Int) {
    self.x1 = ((self.x1 + inGrid / 2) / inGrid) * inGrid
    self.y1 = ((self.y1 + inGrid / 2) / inGrid) * inGrid
    self.x2 = ((self.x2 + inGrid / 2) / inGrid) * inGrid
    self.y2 = ((self.y2 + inGrid / 2) / inGrid) * inGrid
    self.cpx1 = ((self.cpx1 + inGrid / 2) / inGrid) * inGrid
    self.cpy1 = ((self.cpy1 + inGrid / 2) / inGrid) * inGrid
    self.cpx2 = ((self.cpx2 + inGrid / 2) / inGrid) * inGrid
    self.cpy2 = ((self.cpy2 + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  func alignmentPoints_SymbolBezierCurve () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insertCanariPoint (x: self.x1, y: self.y1)
    result.insertCanariPoint (x: self.x2, y: self.y2)
    result.insertCanariPoint (x: self.cpx1, y: self.cpy1)
    result.insertCanariPoint (x: self.cpx2, y: self.cpy2)
    return result
  }

  //····················································································································
  //  operationBeforeRemoving
  //····················································································································

  func operationBeforeRemoving_SymbolBezierCurve () {
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
