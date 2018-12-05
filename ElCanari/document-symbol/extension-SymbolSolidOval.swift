import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SYMBOL_SOLID_OVAL_BOTTOM = 1
let SYMBOL_SOLID_OVAL_RIGHT  = 2
let SYMBOL_SOLID_OVAL_LEFT   = 3
let SYMBOL_SOLID_OVAL_TOP    = 4

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION SymbolSolidOval
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SymbolSolidOval {

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

  override func canMove (knob inKnobIndex : Int, by inTranslation: CGPoint) -> Bool {
    var accept = false
    if inKnobIndex == SYMBOL_SOLID_OVAL_LEFT {
      accept = ((self.x + cocoaToCanariUnit (inTranslation.x)) >= 0)
         && ((self.width - cocoaToCanariUnit (inTranslation.x)) >= SYMBOL_GRID_IN_CANARI_UNIT)
    }else if inKnobIndex == SYMBOL_SOLID_OVAL_RIGHT {
      accept = (self.width + cocoaToCanariUnit (inTranslation.x)) >= SYMBOL_GRID_IN_CANARI_UNIT
    }else if inKnobIndex == SYMBOL_SOLID_OVAL_BOTTOM {
      accept = (self.y + cocoaToCanariUnit (inTranslation.y)) >= 0
        && ((self.height - cocoaToCanariUnit (inTranslation.y)) >= SYMBOL_GRID_IN_CANARI_UNIT)
    }else if inKnobIndex == SYMBOL_SOLID_OVAL_TOP {
      accept = (self.height + cocoaToCanariUnit (inTranslation.y)) >= SYMBOL_GRID_IN_CANARI_UNIT
    }
    return accept
 }

  //····················································································································

  override func move (knob inKnobIndex : Int, by inTranslation: CGPoint) {
    if inKnobIndex == SYMBOL_SOLID_OVAL_RIGHT {
      self.width += cocoaToCanariUnit (inTranslation.x)
    }else if inKnobIndex == SYMBOL_SOLID_OVAL_LEFT {
      self.x += cocoaToCanariUnit (inTranslation.x)
      self.width -= cocoaToCanariUnit (inTranslation.x)
    }else if inKnobIndex == SYMBOL_SOLID_OVAL_TOP {
      self.height += cocoaToCanariUnit (inTranslation.y)
    }else if inKnobIndex == SYMBOL_SOLID_OVAL_BOTTOM {
      self.y += cocoaToCanariUnit (inTranslation.y)
      self.height -= cocoaToCanariUnit (inTranslation.y)
    }
  }

  //····················································································································
  //  COPY AND PASTE
  //····················································································································

  override func canCopyAndPaste () -> Bool {
    return true
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
