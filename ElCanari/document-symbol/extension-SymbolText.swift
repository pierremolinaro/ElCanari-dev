import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION SymbolText
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SymbolText {

  //····················································································································

  override func acceptedXTranslation (by inDx : Int) -> Int {
    var acceptedTranslation = inDx
    let newX = self.x + acceptedTranslation
    if newX < 0 {
      acceptedTranslation = -self.x
    }
    return acceptedTranslation
  }

  //····················································································································

  override func acceptedYTranslation (by inDy : Int) -> Int {
    var acceptedTranslation = inDy
    let newY = self.y + acceptedTranslation
    if newY < 0 {
      acceptedTranslation = -self.y
    }
    return acceptedTranslation
  }

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    let newX = self.x + inDx
    let newY = self.y + inDy
    return (newX >= 0) && (newY >= 0)
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int) {
    self.x += inDx
    self.y += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) -> Bool {
    let newX = self.x + inDx
    let newY = self.y + inDy
    return (newX >= 0) && (newY >= 0)
 }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) {
    self.x += inDx
    self.y += inDy
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
    var result = (self.x % inGrid) != 0
    if !result {
      result = (self.y % inGrid) != 0
    }
    return result
  }

  //····················································································································

  override func snapToGrid (_ inGrid : Int) {
    self.x = ((self.x + inGrid / 2) / inGrid) * inGrid
    self.y = ((self.y + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
