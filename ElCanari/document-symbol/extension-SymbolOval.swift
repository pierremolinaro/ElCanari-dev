import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SYMBOL_OVAL_BOTTOM = 1
let SYMBOL_OVAL_RIGHT  = 2
let SYMBOL_OVAL_LEFT   = 3
let SYMBOL_OVAL_TOP    = 4

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION SymbolOval
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SymbolOval {

  //····················································································································

  func cursorForKnob_SymbolOval (knob inKnobIndex: Int) -> NSCursor? {
    if (inKnobIndex == SYMBOL_OVAL_BOTTOM) || (inKnobIndex == SYMBOL_OVAL_TOP) {
      return NSCursor.resizeUpDown
    }else{
      return NSCursor.resizeLeftRight
    }
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_SymbolOval (additionalDictionary inDictionary : NSDictionary,
                                             objectArray inObjectArray : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_SymbolOval (_ ioDictionary : NSMutableDictionary) {
  }

  //····················································································································

//  override func acceptedTranslation (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
//    var acceptedX = inDx
//    let newX = self.x + acceptedX
//    if newX < 0 {
//      acceptedX = -self.x
//    }
//    var acceptedY = inDy
//    let newY = self.y + acceptedY
//    if newY < 0 {
//      acceptedY = -self.y
//    }
//    return CanariPoint (x: acceptedX, y: acceptedY)
//  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_SymbolOval (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }
  
  //····················································································································

  func acceptToTranslate_SymbolOval (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
//    let newX = self.x + inDx
//    let newY = self.y + inDy
//    return (newX >= 0) && (newY >= 0)
  }

  //····················································································································

  func translate_SymbolOval (xBy inDx: Int, yBy inDy: Int, userSet ioSet : inout EBReferenceSet <AnyObject>) {
    self.x += inDx
    self.y += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  func canMove_SymbolOval (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                         shift inShift : Bool) -> CanariPoint {
    var dx = inProposedAlignedTranslation.x
    var dy = inProposedAlignedTranslation.y
    if inKnobIndex == SYMBOL_OVAL_LEFT {
//      if (self.x + dx) < 0 {
//        dx = -self.x
//      }
      if (self.width - dx) < SYMBOL_GRID_IN_CANARI_UNIT {
        dx = SYMBOL_GRID_IN_CANARI_UNIT - self.width
      }
    }else if inKnobIndex == SYMBOL_OVAL_RIGHT {
      if (self.width + dx) < SYMBOL_GRID_IN_CANARI_UNIT {
        dx = -(SYMBOL_GRID_IN_CANARI_UNIT - self.width)
      }
    }else if inKnobIndex == SYMBOL_OVAL_BOTTOM {
//      if (self.y + dy) < 0 {
//        dy = -self.y
//      }
      if (self.height - dy) < SYMBOL_GRID_IN_CANARI_UNIT {
        dy = SYMBOL_GRID_IN_CANARI_UNIT - self.height
      }
    }else if inKnobIndex == SYMBOL_OVAL_TOP {
      if (self.height + dy) < SYMBOL_GRID_IN_CANARI_UNIT {
        dy = -(SYMBOL_GRID_IN_CANARI_UNIT - self.height)
      }
    }
    return CanariPoint (x: dx, y: dy)
 }

  //····················································································································

  func move_SymbolOval (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
    if inKnobIndex == SYMBOL_OVAL_RIGHT {
      self.width += inDx
    }else if inKnobIndex == SYMBOL_OVAL_LEFT {
      self.x += inDx
      self.width -= inDx
    }else if inKnobIndex == SYMBOL_OVAL_TOP {
      self.height += inDy
    }else if inKnobIndex == SYMBOL_OVAL_BOTTOM {
      self.y += inDy
      self.height -= inDy
    }
  }

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  func canSnapToGrid_SymbolOval (_ inGrid : Int) -> Bool {
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

  func snapToGrid_SymbolOval (_ inGrid : Int) {
    self.x = ((self.x + inGrid / 2) / inGrid) * inGrid
    self.y = ((self.y + inGrid / 2) / inGrid) * inGrid
    self.width = ((self.width + inGrid / 2) / inGrid) * inGrid
    self.height = ((self.height + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  func alignmentPoints_SymbolOval () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insertCanariPoint (x: self.x, y: self.y)
    result.insertCanariPoint (x: self.x + self.width, y: self.y + self.height)
    return result
  }

  //····················································································································
  //  HORIZONTAL FLIP
  //····················································································································

  func flipHorizontally_SymbolOval () {
  }

  //····················································································································

  func canFlipHorizontally_SymbolOval () -> Bool {
    return false
  }

  //····················································································································
  //  VERTICAL FLIP
  //····················································································································

  func flipVertically_SymbolOval () {
  }

  //····················································································································

  func canFlipVertically_SymbolOval () -> Bool {
    return false
  }

  //····················································································································
  //  ROTATE 90
  //····················································································································

  func canRotate90_SymbolOval (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    return false
  }

  //····················································································································

  func rotate90Clockwise_SymbolOval (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <AnyObject>) {
  }

  //····················································································································

  func rotate90CounterClockwise_SymbolOval (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <AnyObject>) {
  }

  //····················································································································
  //  operationBeforeRemoving
  //····················································································································

  func operationBeforeRemoving_SymbolOval () {
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
