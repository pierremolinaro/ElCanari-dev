import Cocoa

//----------------------------------------------------------------------------------------------------------------------

let PACKAGE_DIMENSION_CENTER = 1
let PACKAGE_DIMENSION_ENDPOINT_1 = 2
let PACKAGE_DIMENSION_ENDPOINT_2 = 3
let PACKAGE_DIMENSION_TEXT       = 4

//----------------------------------------------------------------------------------------------------------------------
//   EXTENSION PackageDimension
//----------------------------------------------------------------------------------------------------------------------

extension PackageDimension {

  //····················································································································

  override func cursorForKnob (knob inKnobIndex: Int) -> NSCursor? {
    if inKnobIndex == PACKAGE_DIMENSION_CENTER {
      return nil
    }else{
      return NSCursor.upDownRightLeftCursor
    }
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
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int, newX inNewX : Int, newY inNewY : Int) {
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

  override func canFlipHorizontally () -> Bool {
    return self.x1 != self.x2
  }

  //····················································································································

  override func flipHorizontally () {
    (self.x1, self.x2) = (self.x2, self.x1)
  }

  //····················································································································
  //  Flip vertically
  //····················································································································

  override func canFlipVertically () -> Bool {
    return self.y1 != self.y2
  }

  //····················································································································

  override func flipVertically () {
    (self.y1, self.y2) = (self.y2, self.y1)
  }

  //····················································································································
  //  Rotate 90°
  //····················································································································

  override func canRotate90 (accumulatedPoints : ObjcCanariPointSet) -> Bool {
    accumulatedPoints.insert (x: self.x1, y: self.y1)
    accumulatedPoints.insert (x: self.x2, y: self.y2)
    return true
  }

  //····················································································································

  override func rotate90Clockwise (from inRotationCenter : ObjcCanariPoint, userSet ioSet : ObjcObjectSet) {
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

  override func rotate90CounterClockwise (from inRotationCenter : ObjcCanariPoint, userSet ioSet : ObjcObjectSet) {
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
      result = (self.xDimension % inGrid) != 0
    }
    if !result {
      result = (self.yDimension % inGrid) != 0
    }
    return result
  }

  //····················································································································

  override func snapToGrid (_ inGrid : Int) {
    self.x1 = ((self.x1 + inGrid / 2) / inGrid) * inGrid
    self.y1 = ((self.y1 + inGrid / 2) / inGrid) * inGrid
    self.x2 = ((self.x2 + inGrid / 2) / inGrid) * inGrid
    self.y2 = ((self.y2 + inGrid / 2) / inGrid) * inGrid
    self.xDimension = ((self.xDimension + inGrid / 2) / inGrid) * inGrid
    self.yDimension = ((self.yDimension + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  override func alignmentPoints () -> ObjcCanariPointSet {
    let result = ObjcCanariPointSet ()
    result.insert (CanariPoint (x: self.x1, y: self.y1))
    result.insert (CanariPoint (x: self.x2, y: self.y2))
    result.insert (CanariPoint (x: self.xDimension, y: self.yDimension))
    return result
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

//----------------------------------------------------------------------------------------------------------------------
