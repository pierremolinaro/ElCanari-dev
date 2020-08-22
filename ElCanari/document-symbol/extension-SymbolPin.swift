import Cocoa

//----------------------------------------------------------------------------------------------------------------------

let SYMBOL_PIN_ENDPOINT = 1
let SYMBOL_PIN_LABEL    = 2
let SYMBOL_PIN_NUMBER   = 3

//----------------------------------------------------------------------------------------------------------------------
//   EXTENSION SymbolPin
//----------------------------------------------------------------------------------------------------------------------

extension SymbolPin {

  //····················································································································

//  override func acceptedTranslation (xBy inDx: Int, yBy inDy: Int) -> OCCanariPoint {
//    var acceptedX = inDx
//    do{
//      let newX = self.xPin + acceptedX
//      if newX < 0 {
//        acceptedX = -self.xPin
//      }
//    }
//    do{
//      let newX = self.xName + acceptedX
//      if newX < 0 {
//        acceptedX = -self.xName
//      }
//    }
//    do{
//      let newX = self.xNumber + acceptedX
//      if newX < 0 {
//        acceptedX = -self.xNumber
//      }
//    }
//    var acceptedY = inDy
//    do{
//      let newY = self.yPin + acceptedY
//      if newY < 0 {
//        acceptedY = -self.yPin
//      }
//    }
//    do{
//      let newY = self.yName + acceptedY
//      if newY < 0 {
//        acceptedY = -self.yName
//      }
//    }
//    do{
//      let newY = self.yNumber + acceptedY
//      if newY < 0 {
//        acceptedY = -self.yNumber
//      }
//    }
//    return OCCanariPoint (x: acceptedX, y: acceptedY)
//  }

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
//    let newX = self.xPin + inDx
//    let newY = self.yPin + inDy
//    let newXLabel = self.xName + inDx
//    let newYLabel = self.yName + inDy
//    let newXNumber = self.xNumber + inDx
//    let newYNumber = self.yNumber + inDy
//    return (newX >= 0) && (newY >= 0) && (newXNumber >= 0) && (newYNumber >= 0) && (newXLabel >= 0) && (newYLabel >= 0)
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : OCObjectSet) {
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

  override func canMove (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) -> OCCanariPoint {
//    var dx = inDx
//    var dy = inDy
//    if inKnobIndex == SYMBOL_PIN_ENDPOINT {
////      if (self.xPin + dx) < 0 {
//        dx = -self.xPin
////      }
////      if (self.yPin + dy) < 0 {
//        dy = -self.yPin
////      }
////      if (self.xName + dx) < 0 {
//        dx = -self.xName
////      }
////      if (self.yName + dy) < 0 {
//        dy = -self.yName
////      }
////      if (self.xNumber + dx) < 0 {
//        dx = -self.xNumber
////      }
////      if (self.yNumber + dy) < 0 {
//        dy = -self.yNumber
////      }
//    }else if inKnobIndex == SYMBOL_PIN_LABEL {
////      if (self.xName + dx) < 0 {
//        dx = -self.xName
////      }
////      if (self.yName + dy) < 0 {
//        dy = -self.yName
////      }
//    }else if inKnobIndex == SYMBOL_PIN_NUMBER {
////      if (self.xNumber + dx) < 0 {
//        dx = -self.xNumber
////      }
////      if (self.yNumber + dy) < 0 {
//        dy = -self.yNumber
////      }
//    }
    return OCCanariPoint (x: inDx, y: inDy)
 }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int, newX inNewX : Int, newY inNewY : Int) {
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

  override func alignmentPoints () -> OCCanariPointSet {
    let result = OCCanariPointSet ()
    result.insert (CanariPoint (x: self.xPin, y: self.yPin))
    result.insert (CanariPoint (x: self.xName, y: self.yName))
    result.insert (CanariPoint (x: self.xNumber, y: self.yNumber))
    return result
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
