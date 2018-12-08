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

  override func acceptedXTranslation (by inDx : Int) -> Int {
    var acceptedTranslation = inDx
    do{
      let newX = self.xPin + acceptedTranslation
      if newX < 0 {
        acceptedTranslation = -self.xPin
      }
    }
    do{
      let newX = self.xName + acceptedTranslation
      if newX < 0 {
        acceptedTranslation = -self.xName
      }
    }
    do{
      let newX = self.xNumber + acceptedTranslation
      if newX < 0 {
        acceptedTranslation = -self.xNumber
      }
    }
    return acceptedTranslation
  }

  //····················································································································

  override func acceptedYTranslation (by inDy : Int) -> Int {
    var acceptedTranslation = inDy
    do{
      let newY = self.yPin + acceptedTranslation
      if newY < 0 {
        acceptedTranslation = -self.yPin
      }
    }
    do{
      let newY = self.yName + acceptedTranslation
      if newY < 0 {
        acceptedTranslation = -self.yName
      }
    }
    do{
      let newY = self.yNumber + acceptedTranslation
      if newY < 0 {
        acceptedTranslation = -self.yNumber
      }
    }
    return acceptedTranslation
  }

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    let newX = self.xPin + inDx
    let newY = self.yPin + inDy
    let newXLabel = self.xName + inDx
    let newYLabel = self.yName + inDy
    let newXNumber = self.xNumber + inDx
    let newYNumber = self.yNumber + inDy
    return (newX >= 0) && (newY >= 0) && (newXNumber >= 0) && (newYNumber >= 0) && (newXLabel >= 0) && (newYLabel >= 0)
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int) {
    self.xPin += inDx
    self.yPin += inDy
    self.xName += inDx
    self.yName += inDy
    self.xNumber += inDx
    self.yNumber += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) -> Bool {
    var accept = false
    if inKnobIndex == SYMBOL_PIN_ENDPOINT {
      let newX = self.xPin + inDx
      let newY = self.yPin + inDy
      let newXLabel = self.xName + inDx
      let newYLabel = self.yName + inDy
      let newXNumber = self.xNumber + inDx
      let newYNumber = self.yNumber + inDy
      accept = (newX >= 0) && (newY >= 0) && (newXNumber >= 0) && (newYNumber >= 0) && (newXLabel >= 0) && (newYLabel >= 0)
    }else if inKnobIndex == SYMBOL_PIN_LABEL {
      let newX = self.xName + inDx
      let newY = self.yName + inDy
      accept = (newX >= 0) && (newY >= 0)
    }else if inKnobIndex == SYMBOL_PIN_NUMBER {
      let newX = self.xNumber + inDx
      let newY = self.yNumber + inDy
      accept = (newX >= 0) && (newY >= 0)
    }
    return accept
 }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) {
    if inKnobIndex == SYMBOL_PIN_ENDPOINT {
      self.xPin += inDx
      self.yPin += inDy
      self.xName += inDx
      self.yName += inDy
      self.xNumber += inDx
      self.yNumber += inDy
    }else if inKnobIndex == SYMBOL_PIN_LABEL {
      self.xName += inDx
      self.yName += inDy
    }else if inKnobIndex == SYMBOL_PIN_NUMBER {
      self.xNumber += inDx
      self.yNumber += inDy
    }
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
    var result = (self.xPin % inGrid) != 0
    if !result {
      result = (self.yPin % inGrid) != 0
    }
    if !result {
      result = (self.xName % inGrid) != 0
    }
    if !result {
      result = (self.yName % inGrid) != 0
    }
    if !result {
      result = (self.xNumber % inGrid) != 0
    }
    if !result {
      result = (self.yNumber % inGrid) != 0
    }
    return result
  }

  //····················································································································

  override func snapToGrid (_ inGrid : Int) {
    self.xPin = ((self.xPin + inGrid / 2) / inGrid) * inGrid
    self.yPin = ((self.yPin + inGrid / 2) / inGrid) * inGrid
    self.xName = ((self.xName + inGrid / 2) / inGrid) * inGrid
    self.yName = ((self.yName + inGrid / 2) / inGrid) * inGrid
    self.xNumber = ((self.xNumber + inGrid / 2) / inGrid) * inGrid
    self.yNumber = ((self.yNumber + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
