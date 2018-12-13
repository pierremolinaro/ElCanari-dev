import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PACKAGE_SEGMENT_ENDPOINT_1 = 1
let PACKAGE_SEGMENT_ENDPOINT_2 = 2

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION SymbolSegment
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackageSegment {

  //····················································································································

  override func acceptedXTranslation (by inDx : Int) -> Int {
    var acceptedTranslation = inDx
    do{
      let newX = self.x1 + acceptedTranslation
      if newX < 0 {
        acceptedTranslation = -self.x1
      }
    }
    do{
      let newX = self.x2 + acceptedTranslation
      if newX < 0 {
        acceptedTranslation = -self.x2
      }
    }
    return acceptedTranslation
  }

  //····················································································································

  override func acceptedYTranslation (by inDy : Int) -> Int {
    var acceptedTranslation = inDy
    do{
      let newY = self.y1 + acceptedTranslation
      if newY < 0 {
        acceptedTranslation = -self.y1
      }
    }
    do{
      let newY = self.y2 + acceptedTranslation
      if newY < 0 {
        acceptedTranslation = -self.y2
      }
    }
    return acceptedTranslation
  }

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    let newX1 = self.x1 + inDx
    let newY1 = self.y1 + inDy
    let newX2 = self.x2 + inDx
    let newY2 = self.y2 + inDy
    return (newX1 >= 0) && (newY1 >= 0) && (newX2 >= 0) && (newY2 >= 0)
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int) {
    self.x1 += inDx
    self.y1 += inDy
    self.x2 += inDx
    self.y2 += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) -> Bool {
    var accept = false
    if inKnobIndex == PACKAGE_SEGMENT_ENDPOINT_1 {
      let newX = self.x1 + inDx
      let newY = self.y1 + inDy
      accept = (newX >= 0) && (newY >= 0)
    }else if inKnobIndex == PACKAGE_SEGMENT_ENDPOINT_2 {
      let newX = self.x2 + inDx
      let newY = self.y2 + inDy
      accept = (newX >= 0) && (newY >= 0)
    }
    return accept
 }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) {
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

  override func alignmentPoints () -> AlignmentPointArray {
    let result = AlignmentPointArray ()
    result.points.append (CanariPoint (x: self.x1, y: self.y1))
    result.points.append (CanariPoint (x: self.x2, y: self.y2))
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
