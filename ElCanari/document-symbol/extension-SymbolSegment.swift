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
  //  Knob
  //  @objc dynamic before func is required in order to allow function overriding in extensions
  //····················································································································

  override func canMove (knob inKnobIndex : Int, by inValue: CGPoint) -> Bool {
    var accept = false
    if inKnobIndex == SYMBOL_SEGMENT_ENDPOINT_1 {
      let newX = self.x1 + cocoaToCanariUnit (inValue.x)
      let newY = self.y1 + cocoaToCanariUnit (inValue.y)
      accept = (newX >= 0) && (newY >= 0)
    }else if inKnobIndex == SYMBOL_SEGMENT_ENDPOINT_2 {
      let newX = self.x2 + cocoaToCanariUnit (inValue.x)
      let newY = self.y2 + cocoaToCanariUnit (inValue.y)
      accept = (newX >= 0) && (newY >= 0)
    }
    return accept
 }

  //····················································································································

  override func move (knob inKnobIndex : Int, by inTranslation: CGPoint) {
    if inKnobIndex == SYMBOL_SEGMENT_ENDPOINT_1 {
      self.x1 += cocoaToCanariUnit (inTranslation.x)
      self.y1 += cocoaToCanariUnit (inTranslation.y)
    }else if inKnobIndex == SYMBOL_SEGMENT_ENDPOINT_2 {
      self.x2 += cocoaToCanariUnit (inTranslation.x)
      self.y2 += cocoaToCanariUnit (inTranslation.y)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
