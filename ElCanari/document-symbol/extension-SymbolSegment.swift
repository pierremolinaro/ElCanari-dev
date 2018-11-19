import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SYMBOL_SEGMENT_ENDPOINT_1 = 1
let SYMBOL_SEGMENT_ENDPOINT_2 = 2

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION SymbolSegment
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SymbolSegment {

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
      let newX = canariUnitToCocoa (self.x2) + acceptedTranslation.x
      if newX < 0.0 {
        acceptedTranslation.x = -canariUnitToCocoa (self.x2)
      }
      let newY = canariUnitToCocoa (self.y2) + acceptedTranslation.y
      if newY < 0.0 {
        acceptedTranslation.y = -canariUnitToCocoa (self.y2)
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
    return (newX1 >= 0) && (newY1 >= 0) && (newX2 >= 0) && (newY2 >= 0)
  }

  //····················································································································

  override func translate (xBy inDx: CGFloat, yBy inDy: CGFloat) {
    self.x1 += cocoaToCanariUnit (inDx)
    self.y1 += cocoaToCanariUnit (inDy)
    self.x2 += cocoaToCanariUnit (inDx)
    self.y2 += cocoaToCanariUnit (inDy)
  }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: CGFloat, yBy inDy: CGFloat) {
    if inKnobIndex == SYMBOL_SEGMENT_ENDPOINT_1 {
      self.x1 += cocoaToCanariUnit (inDx)
      self.y1 += cocoaToCanariUnit (inDy)
    }else if inKnobIndex == SYMBOL_SEGMENT_ENDPOINT_2 {
      self.x2 += cocoaToCanariUnit (inDx)
      self.y2 += cocoaToCanariUnit (inDy)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
