import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SYMBOL_PIN_ENDPOINT = 1
let SYMBOL_PIN_LABEL    = 2
let SYMBOL_PIN_NUMBER   = 3

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION SymbolPin
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SymbolPin {

  //····················································································································

  override func acceptedTranslation (by inTranslation : CGPoint) -> CGPoint {
    var acceptedTranslation = inTranslation
    do{
      let newX = canariUnitToCocoa (self.xPin) + acceptedTranslation.x
      if newX < 0.0 {
        acceptedTranslation.x = -canariUnitToCocoa (self.xPin)
      }
      let newY = canariUnitToCocoa (self.yPin) + acceptedTranslation.y
      if newY < 0.0 {
        acceptedTranslation.y = -canariUnitToCocoa (self.yPin)
      }
    }
    do{
      let newX = canariUnitToCocoa (self.xLabel) + acceptedTranslation.x
      if newX < 0.0 {
        acceptedTranslation.x = -canariUnitToCocoa (self.xLabel)
      }
      let newY = canariUnitToCocoa (self.yLabel) + acceptedTranslation.y
      if newY < 0.0 {
        acceptedTranslation.y = -canariUnitToCocoa (self.yLabel)
      }
    }
    do{
      let newX = canariUnitToCocoa (self.xNumber) + acceptedTranslation.x
      if newX < 0.0 {
        acceptedTranslation.x = -canariUnitToCocoa (self.xNumber)
      }
      let newY = canariUnitToCocoa (self.yNumber) + acceptedTranslation.y
      if newY < 0.0 {
        acceptedTranslation.y = -canariUnitToCocoa (self.yNumber)
      }
    }
    return acceptedTranslation
  }

  //····················································································································

  override func acceptToTranslate (xBy inDx: CGFloat, yBy inDy: CGFloat) -> Bool {
    let newX = self.xPin + cocoaToCanariUnit (inDx)
    let newY = self.yPin + cocoaToCanariUnit (inDy)
    let newXLabel = self.xLabel + cocoaToCanariUnit (inDx)
    let newYLabel = self.yLabel + cocoaToCanariUnit (inDy)
    let newXNumber = self.xNumber + cocoaToCanariUnit (inDx)
    let newYNumber = self.yNumber + cocoaToCanariUnit (inDy)
    return (newX >= 0) && (newY >= 0) && (newXNumber >= 0) && (newYNumber >= 0) && (newXLabel >= 0) && (newYLabel >= 0)
  }

  //····················································································································

  override func translate (xBy inDx: CGFloat, yBy inDy: CGFloat) {
    self.xPin += cocoaToCanariUnit (inDx)
    self.yPin += cocoaToCanariUnit (inDy)
    self.xLabel += cocoaToCanariUnit (inDx)
    self.yLabel += cocoaToCanariUnit (inDy)
    self.xNumber += cocoaToCanariUnit (inDx)
    self.yNumber += cocoaToCanariUnit (inDy)
  }

  //····················································································································
  //  Knob
  //  @objc dynamic before func is required in order to allow function overriding in extensions
  //····················································································································

  override func canMove (knob inKnobIndex : Int, by inValue: CGPoint) -> Bool {
    var accept = false
    if inKnobIndex == SYMBOL_PIN_ENDPOINT {
      let newX = self.xPin + cocoaToCanariUnit (inValue.x)
      let newY = self.yPin + cocoaToCanariUnit (inValue.y)
      let newXLabel = self.xLabel + cocoaToCanariUnit (inValue.x)
      let newYLabel = self.yLabel + cocoaToCanariUnit (inValue.y)
      let newXNumber = self.xNumber + cocoaToCanariUnit (inValue.x)
      let newYNumber = self.yNumber + cocoaToCanariUnit (inValue.y)
      accept = (newX >= 0) && (newY >= 0) && (newXNumber >= 0) && (newYNumber >= 0) && (newXLabel >= 0) && (newYLabel >= 0)
    }else if inKnobIndex == SYMBOL_PIN_LABEL {
      let newX = self.xLabel + cocoaToCanariUnit (inValue.x)
      let newY = self.yLabel + cocoaToCanariUnit (inValue.y)
      accept = (newX >= 0) && (newY >= 0)
    }else if inKnobIndex == SYMBOL_PIN_NUMBER {
      let newX = self.xNumber + cocoaToCanariUnit (inValue.x)
      let newY = self.yNumber + cocoaToCanariUnit (inValue.y)
      accept = (newX >= 0) && (newY >= 0)
    }
    return accept
 }

  //····················································································································

  override func move (knob inKnobIndex : Int, by inTranslation: CGPoint) {
    if inKnobIndex == SYMBOL_PIN_ENDPOINT {
      self.xPin += cocoaToCanariUnit (inTranslation.x)
      self.yPin += cocoaToCanariUnit (inTranslation.y)
      self.xLabel += cocoaToCanariUnit (inTranslation.x)
      self.yLabel += cocoaToCanariUnit (inTranslation.y)
      self.xNumber += cocoaToCanariUnit (inTranslation.x)
      self.yNumber += cocoaToCanariUnit (inTranslation.y)
    }else if inKnobIndex == SYMBOL_PIN_LABEL {
      self.xLabel += cocoaToCanariUnit (inTranslation.x)
      self.yLabel += cocoaToCanariUnit (inTranslation.y)
    }else if inKnobIndex == SYMBOL_PIN_NUMBER {
      self.xNumber += cocoaToCanariUnit (inTranslation.x)
      self.yNumber += cocoaToCanariUnit (inTranslation.y)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
