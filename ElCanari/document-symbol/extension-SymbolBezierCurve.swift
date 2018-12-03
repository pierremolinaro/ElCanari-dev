import Cocoa

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

  override func acceptedTranslation (by inTranslation : CGPoint) -> CGPoint {
    var acceptedTranslation = inTranslation
    do{
      let newX = canariUnitToCocoa (self.x1) + acceptedTranslation.x
      if newX < 0.0 {
        acceptedTranslation.x = -canariUnitToCocoa (self.x1)
      }
      let newY = canariUnitToCocoa (self.y1) + acceptedTranslation.y
      if newY < 0.0 {
        acceptedTranslation.y = -canariUnitToCocoa (self.y1)
      }
    }
    do{
      let newX = canariUnitToCocoa (self.cpx1) + acceptedTranslation.x
      if newX < 0.0 {
        acceptedTranslation.x = -canariUnitToCocoa (self.cpx1)
      }
      let newY = canariUnitToCocoa (self.cpy1) + acceptedTranslation.y
      if newY < 0.0 {
        acceptedTranslation.y = -canariUnitToCocoa (self.cpy1)
      }
    }
    do{
      let newX = canariUnitToCocoa (self.x2) + acceptedTranslation.x
      if newX < 0.0 {
        acceptedTranslation.x = -canariUnitToCocoa (self.x2)
      }
      let newY = canariUnitToCocoa (self.y2) + acceptedTranslation.y
      if newY < 0.0 {
        acceptedTranslation.y = -canariUnitToCocoa (self.y2)
      }
    }
    do{
      let newX = canariUnitToCocoa (self.cpx2) + acceptedTranslation.x
      if newX < 0.0 {
        acceptedTranslation.x = -canariUnitToCocoa (self.cpx2)
      }
      let newY = canariUnitToCocoa (self.cpy2) + acceptedTranslation.y
      if newY < 0.0 {
        acceptedTranslation.y = -canariUnitToCocoa (self.cpy2)
      }
    }
    return acceptedTranslation
  }

  //····················································································································

  override func acceptToTranslate (xBy inDx: CGFloat, yBy inDy: CGFloat) -> Bool {
    let newX1 = self.x1 + cocoaToCanariUnit (inDx)
    let newY1 = self.y1 + cocoaToCanariUnit (inDy)
    let newX2 = self.x2 + cocoaToCanariUnit (inDx)
    let newY2 = self.y2 + cocoaToCanariUnit (inDy)
    let newCPX1 = self.cpx1 + cocoaToCanariUnit (inDx)
    let newCPY1 = self.cpy1 + cocoaToCanariUnit (inDy)
    let newCPX2 = self.cpx2 + cocoaToCanariUnit (inDx)
    let newCPY2 = self.cpy2 + cocoaToCanariUnit (inDy)
    return (newX1 >= 0) && (newY1 >= 0) && (newX2 >= 0) && (newY2 >= 0)
      && (newCPX1 >= 0) && (newCPY1 >= 0) && (newCPX2 >= 0) && (newCPY2 >= 0)
  }

  //····················································································································

  override func translate (xBy inDx: CGFloat, yBy inDy: CGFloat) {
    self.x1 += cocoaToCanariUnit (inDx)
    self.y1 += cocoaToCanariUnit (inDy)
    self.x2 += cocoaToCanariUnit (inDx)
    self.y2 += cocoaToCanariUnit (inDy)
    self.cpx1 += cocoaToCanariUnit (inDx)
    self.cpy1 += cocoaToCanariUnit (inDy)
    self.cpx2 += cocoaToCanariUnit (inDx)
    self.cpy2 += cocoaToCanariUnit (inDy)
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int, by inValue: CGPoint) -> Bool {
    var accept = false
    if inKnobIndex == SYMBOL_BEZIER_CURVE_ENDPOINT_1 {
      let newX = self.x1 + cocoaToCanariUnit (inValue.x)
      let newY = self.y1 + cocoaToCanariUnit (inValue.y)
      accept = (newX >= 0) && (newY >= 0)
    }else if inKnobIndex == SYMBOL_BEZIER_CURVE_ENDPOINT_2 {
      let newX = self.x2 + cocoaToCanariUnit (inValue.x)
      let newY = self.y2 + cocoaToCanariUnit (inValue.y)
      accept = (newX >= 0) && (newY >= 0)
    }else if inKnobIndex == SYMBOL_BEZIER_CURVE_CONTROL_1 {
      let newX = self.cpx1 + cocoaToCanariUnit (inValue.x)
      let newY = self.cpy1 + cocoaToCanariUnit (inValue.y)
      accept = (newX >= 0) && (newY >= 0)
    }else if inKnobIndex == SYMBOL_BEZIER_CURVE_CONTROL_2 {
      let newX = self.cpx2 + cocoaToCanariUnit (inValue.x)
      let newY = self.cpy2 + cocoaToCanariUnit (inValue.y)
      accept = (newX >= 0) && (newY >= 0)
    }
    return accept
 }

  //····················································································································

  override func move (knob inKnobIndex : Int, by inTranslation: CGPoint) {
    if inKnobIndex == SYMBOL_BEZIER_CURVE_ENDPOINT_1 {
      self.x1 += cocoaToCanariUnit (inTranslation.x)
      self.y1 += cocoaToCanariUnit (inTranslation.y)
    }else if inKnobIndex == SYMBOL_BEZIER_CURVE_ENDPOINT_2 {
      self.x2 += cocoaToCanariUnit (inTranslation.x)
      self.y2 += cocoaToCanariUnit (inTranslation.y)
    }else if inKnobIndex == SYMBOL_BEZIER_CURVE_CONTROL_1 {
      self.cpx1 += cocoaToCanariUnit (inTranslation.x)
      self.cpy1 += cocoaToCanariUnit (inTranslation.y)
    }else if inKnobIndex == SYMBOL_BEZIER_CURVE_CONTROL_2 {
      self.cpx2 += cocoaToCanariUnit (inTranslation.x)
      self.cpy2 += cocoaToCanariUnit (inTranslation.y)
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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
