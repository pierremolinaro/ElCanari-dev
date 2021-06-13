import Cocoa

//----------------------------------------------------------------------------------------------------------------------

let PACKAGE_BEZIER_CURVE_ENDPOINT_1 = 1
let PACKAGE_BEZIER_CURVE_ENDPOINT_2 = 2
let PACKAGE_BEZIER_CURVE_CONTROL_1  = 3
let PACKAGE_BEZIER_CURVE_CONTROL_2  = 4

//----------------------------------------------------------------------------------------------------------------------
//   EXTENSION SymbolBezierCurve
//----------------------------------------------------------------------------------------------------------------------

extension PackageBezier {

  //····················································································································

  override func cursorForKnob (knob inKnobIndex: Int) -> NSCursor? {
    return NSCursor.upDownRightLeftCursor
  }

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : ObjcObjectSet) {
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
  //  Knob
  //····················································································································

  override func move (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
    if inKnobIndex == PACKAGE_BEZIER_CURVE_ENDPOINT_1 {
      self.x1 += inDx
      self.y1 += inDy
    }else if inKnobIndex == PACKAGE_BEZIER_CURVE_ENDPOINT_2 {
      self.x2 += inDx
      self.y2 += inDy
    }else if inKnobIndex == PACKAGE_BEZIER_CURVE_CONTROL_1 {
      self.cpx1 += inDx
      self.cpy1 += inDy
    }else if inKnobIndex == PACKAGE_BEZIER_CURVE_CONTROL_2 {
      self.cpx2 += inDx
      self.cpy2 += inDy
    }
  }

  //····················································································································
  //  Flip horizontally
  //····················································································································

  override func canFlipHorizontally () -> Bool {
    return min (self.x1, self.x2, self.cpx1, self.cpx2) != max (self.x1, self.x2, self.cpx1, self.cpx2)
  }

  //····················································································································

  override func flipHorizontally () {
    let v = min (self.x1, self.x2, self.cpx1, self.cpx2) + max (self.x1, self.x2, self.cpx1, self.cpx2)
    self.x1 = v - self.x1
    self.x2 = v - self.x2
    self.cpx1 = v - self.cpx1
    self.cpx2 = v - self.cpx2
  }

  //····················································································································
  //  Flip vertically
  //····················································································································

  override func canFlipVertically () -> Bool {
    return min (self.y1, self.y2, self.cpy1, self.cpy2) != max (self.y1, self.y2, self.cpy1, self.cpy2)
  }

  //····················································································································

  override func flipVertically () {
    let v = min (self.y1, self.y2, self.cpy1, self.cpy2) + max (self.y1, self.y2, self.cpy1, self.cpy2)
    self.y1 = v - self.y1
    self.y2 = v - self.y2
    self.cpy1 = v - self.cpy1
    self.cpy2 = v - self.cpy2
  }

  //····················································································································
  //  Rotate 90°
  //····················································································································

  override func canRotate90 (accumulatedPoints : ObjcCanariPointSet) -> Bool {
    let p1  = CanariPoint (x: self.x1, y: self.y1)
    let p2  = CanariPoint (x: self.x2, y: self.y2)
    let cp1 = CanariPoint (x: self.cpx1, y: self.cpy1)
    let cp2 = CanariPoint (x: self.cpx2, y: cpy2)
    accumulatedPoints.insert (p1)
    accumulatedPoints.insert (p2)
    accumulatedPoints.insert (cp1)
    accumulatedPoints.insert (cp2)
    return true
  }

  //····················································································································

  override func rotate90Clockwise (from inRotationCenter : ObjcCanariPoint, userSet ioSet : ObjcObjectSet) {
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

  override func rotate90CounterClockwise (from inRotationCenter : ObjcCanariPoint, userSet ioSet : ObjcObjectSet) {
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
  //  COPY AND PASTE
  //····················································································································

  override func canCopyAndPaste () -> Bool {
    return true
  }

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  override func canSnapToGrid (_ inGrid : Int) -> Bool {
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

  override func snapToGrid (_ inGrid : Int) {
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

  override func alignmentPoints () -> ObjcCanariPointSet {
    let result = ObjcCanariPointSet ()
    result.insert (CanariPoint (x: self.x1, y: self.y1))
    result.insert (CanariPoint (x: self.x2, y: self.y2))
    result.insert (CanariPoint (x: self.cpx1, y: self.cpy1))
    result.insert (CanariPoint (x: self.cpx2, y: self.cpy2))
    return result
  }

  //····················································································································

  override func program () -> String {
    var s = "bezier "
    s += stringFrom (valueInCanariUnit: self.x1, displayUnit : self.x1Unit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.y1, displayUnit : self.y1Unit)
    s += " to "
    s += stringFrom (valueInCanariUnit: self.x2, displayUnit : self.x2Unit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.y2, displayUnit : self.y2Unit)
    s += " cp "
    s += stringFrom (valueInCanariUnit: self.cpx1, displayUnit : self.cpx1Unit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.cpy1, displayUnit : self.cpy1Unit)
    s += " cp "
    s += stringFrom (valueInCanariUnit: self.cpx2, displayUnit : self.cpx2Unit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.cpy2, displayUnit : self.cpy2Unit)
    s += ";\n"
    return s
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
