import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PACKAGE_BEZIER_CURVE_ENDPOINT_1 = 1
let PACKAGE_BEZIER_CURVE_ENDPOINT_2 = 2
let PACKAGE_BEZIER_CURVE_CONTROL_1  = 3
let PACKAGE_BEZIER_CURVE_CONTROL_2  = 4

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION SymbolBezierCurve
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackageBezier {

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int) {
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

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) {
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
  //  Rotate clockwise
  //····················································································································

  override func canRotate90Clockwise () -> Bool {
    return true
  }

  //····················································································································

  override func rotate90Clockwise () {
    var p1  = CanariPoint (x: self.x1, y: self.y1)
    var p2  = CanariPoint (x: self.x2, y: self.y2)
    var cp1 = CanariPoint (x: self.cpx1, y: self.cpy1)
    var cp2 = CanariPoint (x: self.cpx2, y: cpy2)
    let r = CanariRect (p1: p1, p2: p2, p3: cp1, p4: cp2)
    p1 = r.rotated90Clockwise (p1)
    p2 = r.rotated90Clockwise (p2)
    cp1 = r.rotated90Clockwise (cp1)
    cp2 = r.rotated90Clockwise (cp2)
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
  //  Rotate counter clockwise
  //····················································································································

  override func canRotate90CounterClockwise () -> Bool {
    return true
  }

  //····················································································································

  override func rotate90CounterClockwise () {
    var p1  = CanariPoint (x: self.x1, y: self.y1)
    var p2  = CanariPoint (x: self.x2, y: self.y2)
    var cp1 = CanariPoint (x: self.cpx1, y: self.cpy1)
    var cp2 = CanariPoint (x: self.cpx2, y: cpy2)
    let r = CanariRect (p1: p1, p2: p2, p3: cp1, p4: cp2)
    p1 = r.rotated90CounterClockwise (p1)
    p2 = r.rotated90CounterClockwise (p2)
    cp1 = r.rotated90CounterClockwise (cp1)
    cp2 = r.rotated90CounterClockwise (cp2)
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

  override func alignmentPoints () -> OCCanariPointArray {
    let result = OCCanariPointArray ()
    result.points.append (CanariPoint (x: self.x1, y: self.y1))
    result.points.append (CanariPoint (x: self.x2, y: self.y2))
    result.points.append (CanariPoint (x: self.cpx1, y: self.cpy1))
    result.points.append (CanariPoint (x: self.cpx2, y: self.cpy2))
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
