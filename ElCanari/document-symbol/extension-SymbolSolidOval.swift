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
    var accept = false
    if inKnobIndex == SYMBOL_SOLID_OVAL_LEFT {
      accept = ((self.x + inDx) >= 0) && ((self.width - inDx) >= SYMBOL_GRID_IN_CANARI_UNIT)
    }else if inKnobIndex == SYMBOL_SOLID_OVAL_RIGHT {
      accept = (self.width + inDx) >= SYMBOL_GRID_IN_CANARI_UNIT
    }else if inKnobIndex == SYMBOL_SOLID_OVAL_BOTTOM {
      accept = ((self.y + inDy) >= 0) && ((self.height - inDy) >= SYMBOL_GRID_IN_CANARI_UNIT)
    }else if inKnobIndex == SYMBOL_SOLID_OVAL_TOP {
      accept = (self.height + inDy) >= SYMBOL_GRID_IN_CANARI_UNIT
    }
    return accept
 }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) {
    if inKnobIndex == SYMBOL_SOLID_OVAL_RIGHT {
      self.width += inDx
    }else if inKnobIndex == SYMBOL_SOLID_OVAL_LEFT {
      self.x += inDx
      self.width -= inDx
    }else if inKnobIndex == SYMBOL_SOLID_OVAL_TOP {
      self.height += inDy
    }else if inKnobIndex == SYMBOL_SOLID_OVAL_BOTTOM {
      self.y += inDy
      self.height -= inDy
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
    var result = (self.x % inGrid) != 0
    if !result {
      result = (self.y % inGrid) != 0
    }
    if !result {
      result = (self.width % inGrid) != 0
    }
    if !result {
      result = (self.height % inGrid) != 0
    }
    return result
  }

  //····················································································································

  override func snapToGrid (_ inGrid : Int) {
    self.x = ((self.x + inGrid / 2) / inGrid) * inGrid
    self.y = ((self.y + inGrid / 2) / inGrid) * inGrid
    self.width = ((self.width + inGrid / 2) / inGrid) * inGrid
    self.height = ((self.height + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
