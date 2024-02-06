import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

let SYMBOL_SOLID_RECT_BOTTOM = 1
let SYMBOL_SOLID_RECT_RIGHT  = 2
let SYMBOL_SOLID_RECT_TOP    = 3
let SYMBOL_SOLID_RECT_LEFT   = 4

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION SymbolSolidRect
//——————————————————————————————————————————————————————————————————————————————————————————————————

extension SymbolSolidRect {

  //····················································································································

  func cursorForKnob_SymbolSolidRect (knob inKnobIndex: Int) -> NSCursor? {
    if (inKnobIndex == SYMBOL_SOLID_RECT_BOTTOM) || (inKnobIndex == SYMBOL_SOLID_RECT_TOP) {
      return NSCursor.resizeUpDown
    }else{
      return NSCursor.resizeLeftRight
    }
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_SymbolSolidRect (additionalDictionary _ : [String : Any],
                                              optionalDocument _ : EBAutoLayoutManagedDocument?,
                                              objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_SymbolSolidRect (_ _ : inout [String : Any]) {
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_SymbolSolidRect (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }
  //····················································································································

  func acceptToTranslate_SymbolSolidRect (xBy _ : Int, yBy _ : Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_SymbolSolidRect (xBy inDx: Int, yBy inDy: Int, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.x += inDx
    self.y += inDy
  }

  //····················································································································
  //  HORIZONTAL FLIP
  //····················································································································

  func flipHorizontally_SymbolSolidRect () {
  }

  //····················································································································

  func canFlipHorizontally_SymbolSolidRect () -> Bool {
    return false
  }

  //····················································································································
  //  VERTICAL FLIP
  //····················································································································

  func flipVertically_SymbolSolidRect () {
  }

  //····················································································································

  func canFlipVertically_SymbolSolidRect () -> Bool {
    return false
  }

  //····················································································································
  //  ROTATE 90
  //····················································································································

  func canRotate90_SymbolSolidRect (accumulatedPoints _ : inout Set <CanariPoint>) -> Bool {
    return false
  }

  //····················································································································

  func rotate90Clockwise_SymbolSolidRect (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  //····················································································································

  func rotate90CounterClockwise_SymbolSolidRect (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  //····················································································································
  //  Knob
  //····················································································································

  func canMove_SymbolSolidRect (knob inKnobIndex : Int,
                                proposedUnalignedAlignedTranslation _ : CanariPoint,
                                proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                                unalignedMouseDraggedLocation _ : CanariPoint,
                                shift _ : Bool) -> CanariPoint {
    var dx = inProposedAlignedTranslation.x
    var dy = inProposedAlignedTranslation.y
    if inKnobIndex == SYMBOL_SOLID_RECT_LEFT {
      if (self.width - dx) < SYMBOL_GRID_IN_CANARI_UNIT {
        dx = SYMBOL_GRID_IN_CANARI_UNIT - self.width
      }
    }else if inKnobIndex == SYMBOL_SOLID_RECT_RIGHT {
      if (self.width + dx) < SYMBOL_GRID_IN_CANARI_UNIT {
        dx = -(SYMBOL_GRID_IN_CANARI_UNIT - self.width)
      }
    }else if inKnobIndex == SYMBOL_SOLID_RECT_BOTTOM {
      if (self.height - dy) < SYMBOL_GRID_IN_CANARI_UNIT {
        dy = SYMBOL_GRID_IN_CANARI_UNIT - self.height
      }
    }else if inKnobIndex == SYMBOL_SOLID_RECT_TOP {
      if (self.height + dy) < SYMBOL_GRID_IN_CANARI_UNIT {
        dy = -(SYMBOL_GRID_IN_CANARI_UNIT - self.height)
      }
    }
    return CanariPoint (x: dx, y: dy)
 }

  //····················································································································

  func move_SymbolSolidRect (knob inKnobIndex: Int,
                             proposedDx inDx: Int,
                             proposedDy inDy: Int,
                             unalignedMouseLocationX _ : Int,
                             unalignedMouseLocationY _ : Int,
                             alignedMouseLocationX _ : Int,
                             alignedMouseLocationY _ : Int,
                             shift _ : Bool) {
    if inKnobIndex == SYMBOL_SOLID_RECT_RIGHT {
      self.width += inDx
    }else if inKnobIndex == SYMBOL_SOLID_RECT_LEFT {
      self.x += inDx
      self.width -= inDx
    }else if inKnobIndex == SYMBOL_SOLID_RECT_TOP {
      self.height += inDy
    }else if inKnobIndex == SYMBOL_SOLID_RECT_BOTTOM {
      self.y += inDy
      self.height -= inDy
    }
  }

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  func canSnapToGrid_SymbolSolidRect (_ inGrid : Int) -> Bool {
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

  func snapToGrid_SymbolSolidRect (_ inGrid : Int) {
    self.x = ((self.x + inGrid / 2) / inGrid) * inGrid
    self.y = ((self.y + inGrid / 2) / inGrid) * inGrid
    self.width = ((self.width + inGrid / 2) / inGrid) * inGrid
    self.height = ((self.height + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  func alignmentPoints_SymbolSolidRect () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insertCanariPoint (x: self.x, y: self.y)
    result.insertCanariPoint (x: self.x + self.width, y: self.y + self.height)
    return result
  }

  //····················································································································
  //  operationBeforeRemoving
  //····················································································································

  func operationBeforeRemoving_SymbolSolidRect () {
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
