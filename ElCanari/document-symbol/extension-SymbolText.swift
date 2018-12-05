import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION SymbolText
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SymbolText {

  //····················································································································

  override func acceptedTranslation (by inTranslation : CGPoint) -> CGPoint {
    var acceptedTranslation = inTranslation
    do{
      let newX = canariUnitToCocoa (self.x) + acceptedTranslation.x
      if newX < 0.0 {
        acceptedTranslation.x = -canariUnitToCocoa (self.x)
      }
      let newY = canariUnitToCocoa (self.y) + acceptedTranslation.y
      if newY < 0.0 {
        acceptedTranslation.y = -canariUnitToCocoa (self.y)
      }
    }
    return acceptedTranslation
  }

  //····················································································································

  override func acceptToTranslate (xBy inDx: CGFloat, yBy inDy: CGFloat) -> Bool {
    let newX = self.x + cocoaToCanariUnit (inDx)
    let newY = self.y + cocoaToCanariUnit (inDy)
    return (newX >= 0) && (newY >= 0)
  }

  //····················································································································

  override func translate (xBy inDx: CGFloat, yBy inDy: CGFloat) {
    self.x += cocoaToCanariUnit (inDx)
    self.y += cocoaToCanariUnit (inDy)
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int, by inValue: CGPoint) -> Bool {
    let newX = self.x + cocoaToCanariUnit (inValue.x)
    let newY = self.y + cocoaToCanariUnit (inValue.y)
    return (newX >= 0) && (newY >= 0)
 }

  //····················································································································

  override func move (knob inKnobIndex : Int, by inTranslation: CGPoint) {
    self.x += cocoaToCanariUnit (inTranslation.x)
    self.y += cocoaToCanariUnit (inTranslation.y)
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
