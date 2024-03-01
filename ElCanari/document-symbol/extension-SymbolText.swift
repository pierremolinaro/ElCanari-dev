import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION SymbolText
//——————————————————————————————————————————————————————————————————————————————————————————————————

extension SymbolText {

  //································································································
  //  Cursor
  //································································································

  func cursorForKnob_SymbolText (knob _ : Int) -> NSCursor? {
    return nil // Uses default cursor
  }

  //································································································
  //  operationAfterPasting
  //································································································

  func operationAfterPasting_SymbolText (additionalDictionary _ : [String : Any],
                                         optionalDocument _ : EBAutoLayoutManagedDocument?,
                                         objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //································································································
  //  Save into additional dictionary
  //································································································

  func saveIntoAdditionalDictionary_SymbolText (_ _ : inout [String : Any]) {
  }

  //································································································
  //  HORIZONTAL FLIP
  //································································································

  func flipHorizontally_SymbolText () {
  }

  //································································································

  func canFlipHorizontally_SymbolText () -> Bool {
    return false
  }

  //································································································
  //  VERTICAL FLIP
  //································································································

  func flipVertically_SymbolText () {
  }

  //································································································

  func canFlipVertically_SymbolText () -> Bool {
    return false
  }

  //································································································
  //  ROTATE 90
  //································································································

  func canRotate90_SymbolText (accumulatedPoints _ : inout Set <CanariPoint>) -> Bool {
    return false
  }

  //································································································

  func rotate90Clockwise_SymbolText (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  //································································································

  func rotate90CounterClockwise_SymbolText (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  //································································································
  //  Alignment Points
  //································································································

  func alignmentPoints_SymbolText () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  //································································································
  //  Translation
  //································································································

  func acceptedTranslation_SymbolText (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }
  //································································································

  func acceptToTranslate_SymbolText (xBy _ : Int, yBy _ : Int) -> Bool {
    return true
  }

  //································································································

  func translate_SymbolText (xBy inDx: Int, yBy inDy: Int, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.x += inDx
    self.y += inDy
  }

  //································································································
  //  Knob
  //································································································

  func canMove_SymbolText (knob _ : Int,
                           proposedUnalignedAlignedTranslation _ : CanariPoint,
                           proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                           unalignedMouseDraggedLocation _ : CanariPoint,
                           shift _ : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
 }

  //································································································

  func move_SymbolText (knob _: Int,
                        proposedDx inDx: Int,
                        proposedDy inDy: Int,
                        unalignedMouseLocationX _ : Int,
                        unalignedMouseLocationY _ : Int,
                        alignedMouseLocationX _ : Int,
                        alignedMouseLocationY _ : Int,
                        shift _ : Bool) {
    self.x += inDx
    self.y += inDy
  }

  //································································································
  //  SNAP TO GRID
  //································································································

  func canSnapToGrid_SymbolText (_ inGrid : Int) -> Bool {
    var result = (self.x % inGrid) != 0
    if !result {
      result = (self.y % inGrid) != 0
    }
    return result
  }

  //································································································

  func snapToGrid_SymbolText (_ inGrid : Int) {
    self.x = ((self.x + inGrid / 2) / inGrid) * inGrid
    self.y = ((self.y + inGrid / 2) / inGrid) * inGrid
  }

  //································································································
  //  operationBeforeRemoving
  //································································································

  func operationBeforeRemoving_SymbolText () {
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
