import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let SYMBOL_OVAL_BOTTOM = 1
let SYMBOL_OVAL_RIGHT  = 2
let SYMBOL_OVAL_LEFT   = 3
let SYMBOL_OVAL_TOP    = 4

//--------------------------------------------------------------------------------------------------
//   EXTENSION SymbolOval
//--------------------------------------------------------------------------------------------------

extension SymbolOval {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func cursorForKnob_SymbolOval (knob inKnobIndex : Int) -> NSCursor? {
    if (inKnobIndex == SYMBOL_OVAL_BOTTOM) || (inKnobIndex == SYMBOL_OVAL_TOP) {
      return NSCursor.resizeUpDown
    }else{
      return NSCursor.resizeLeftRight
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationAfterPasting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_SymbolOval (additionalDictionary _ : [String : Any],
                                         optionalDocument _ : EBAutoLayoutManagedDocument?,
                                         objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_SymbolOval (_ _ : inout [String : Any]) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Translation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_SymbolOval (xBy inDx: CanariLength, yBy inDy: CanariLength) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_SymbolOval (xBy _ : CanariLength, yBy _ : CanariLength) -> Bool {
    return true
//    let newX = self.x + inDx
//    let newY = self.y + inDy
//    return (newX >= 0) && (newY >= 0)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_SymbolOval (xBy inDx: CanariLength, yBy inDy: CanariLength, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.x += inDx
    self.y += inDy
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Knob
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_SymbolOval (knob inKnobIndex : Int,
                           proposedUnalignedAlignedTranslation _ : CanariPoint,
                           proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                           unalignedMouseDraggedLocation _ : CanariPoint,
                           shift _ : Bool) -> CanariPoint {
    var dx = inProposedAlignedTranslation.x
    var dy = inProposedAlignedTranslation.y
    if inKnobIndex == SYMBOL_OVAL_LEFT {
      if (self.width - dx) < SYMBOL_GRID_LENGTH {
        dx = SYMBOL_GRID_LENGTH - self.width
      }
    }else if inKnobIndex == SYMBOL_OVAL_RIGHT {
      if (self.width + dx) < SYMBOL_GRID_LENGTH {
        dx = -(SYMBOL_GRID_LENGTH - self.width)
      }
    }else if inKnobIndex == SYMBOL_OVAL_BOTTOM {
      if (self.height - dy) < SYMBOL_GRID_LENGTH {
        dy = SYMBOL_GRID_LENGTH - self.height
      }
    }else if inKnobIndex == SYMBOL_OVAL_TOP {
      if (self.height + dy) < SYMBOL_GRID_LENGTH {
        dy = -(SYMBOL_GRID_LENGTH - self.height)
      }
    }
    return CanariPoint (x: dx, y: dy)
 }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_SymbolOval (knob inKnobIndex: Int,
                        proposedDx inDx: CanariLength,
                        proposedDy inDy: CanariLength,
                        unalignedMouseLocationX _ : CanariLength,
                        unalignedMouseLocationY _ : CanariLength,
                        alignedMouseLocationX _ : CanariLength,
                        alignedMouseLocationY _ : CanariLength,
                        shift _ : Bool) {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_SymbolOval (_ inGrid : CanariLength) -> Bool {
    var result = self.x.isAligned (on: inGrid)
    if !result {
      result = self.y.isAligned (on: inGrid)
    }
    if !result {
      result = self.width.isAligned (on: inGrid)
    }
    if !result {
      result = self.height.isAligned (on: inGrid)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_SymbolOval (_ inGrid : CanariLength) {
    self.x.align (on: inGrid)
    self.y.align (on: inGrid)
    self.width.align (on: inGrid)
    self.height.align (on: inGrid)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_SymbolOval () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insert (x: self.x, y: self.y)
    result.insert (x: self.x + self.width, y: self.y + self.height)
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  HORIZONTAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_SymbolOval () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_SymbolOval () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  VERTICAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_SymbolOval () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_SymbolOval () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  ROTATE 90
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_SymbolOval (accumulatedPoints _ : inout Set <CanariPoint>) -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90Clockwise_SymbolOval (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90CounterClockwise_SymbolOval (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationBeforeRemoving
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_SymbolOval () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
