import Cocoa

//----------------------------------------------------------------------------------------------------------------------

let PACKAGE_SEGMENT_ENDPOINT_1 = 1
let PACKAGE_SEGMENT_ENDPOINT_2 = 2

//----------------------------------------------------------------------------------------------------------------------
//   EXTENSION PackageSegment
//----------------------------------------------------------------------------------------------------------------------

extension PackageSegment {

  //····················································································································

  override func cursorForKnob (knob inKnobIndex: Int) -> NSCursor? {
    return NSCursor.upDownRightLeftCursor
  }

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : OCObjectSet) {
    self.x1 += inDx
    self.y1 += inDy
    self.x2 += inDx
    self.y2 += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int, newX inNewX : Int, newY inNewY : Int) {
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

  override func canFlipHorizontally () -> Bool {
    return x1 != x2
  }

  //····················································································································

  override func flipHorizontally () {
    (x1, x2) = (x2, x1)
  }

  //····················································································································
  //  Flip vertically
  //····················································································································

  override func canFlipVertically () -> Bool {
    return y1 != y2
  }

  //····················································································································

  override func flipVertically () {
    (y1, y2) = (y2, y1)
  }

  //····················································································································
  //  Rotate 90°
  //····················································································································

  override func canRotate90 (accumulatedPoints : OCCanariPointSet) -> Bool {
    let p1  = CanariPoint (x: self.x1, y: self.y1)
    let p2  = CanariPoint (x: self.x2, y: self.y2)
    accumulatedPoints.insert (p1)
    accumulatedPoints.insert (p2)
    return true
  }

  //····················································································································

  override func rotate90Clockwise (from inRotationCenter : OCCanariPoint, userSet ioSet : OCObjectSet) {
    let p1 = inRotationCenter.rotated90Clockwise (x: self.x1, y: self.y1)
    let p2 = inRotationCenter.rotated90Clockwise (x: self.x2, y: self.y2)
    self.x1 = p1.x
    self.y1 = p1.y
    self.x2 = p2.x
    self.y2 = p2.y
  }

  //····················································································································

  override func rotate90CounterClockwise (from inRotationCenter : OCCanariPoint, userSet ioSet : OCObjectSet) {
    let p1 = inRotationCenter.rotated90CounterClockwise (x: self.x1, y: self.y1)
    let p2 = inRotationCenter.rotated90CounterClockwise (x: self.x2, y: self.y2)
    self.x1 = p1.x
    self.y1 = p1.y
    self.x2 = p2.x
    self.y2 = p2.y
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
    return result
  }

  //····················································································································

  override func snapToGrid (_ inGrid : Int) {
    self.x1 = ((self.x1 + inGrid / 2) / inGrid) * inGrid
    self.y1 = ((self.y1 + inGrid / 2) / inGrid) * inGrid
    self.x2 = ((self.x2 + inGrid / 2) / inGrid) * inGrid
    self.y2 = ((self.y2 + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  override func alignmentPoints () -> OCCanariPointSet {
    let result = OCCanariPointSet ()
    result.insert (CanariPoint (x: self.x1, y: self.y1))
    result.insert (CanariPoint (x: self.x2, y: self.y2))
    return result
  }

  //····················································································································

  override func program () -> String {
    var s = "segment "
    s += stringFrom (valueInCanariUnit: self.x1, displayUnit : self.x1Unit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.y1, displayUnit : self.y1Unit)
    s += " to "
    s += stringFrom (valueInCanariUnit: self.x2, displayUnit : self.x2Unit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.y2, displayUnit : self.y2Unit)
    s += ";\n"
    return s
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
