import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let SYMBOL_PIN_ENDPOINT = 1
let SYMBOL_PIN_LABEL    = 2
let SYMBOL_PIN_NUMBER   = 3

//--------------------------------------------------------------------------------------------------
//   EXTENSION SymbolPin
//--------------------------------------------------------------------------------------------------

extension SymbolPin {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func cursorForKnob_SymbolPin (knob inKnobIndex: Int) -> NSCursor? {
    if (inKnobIndex == SYMBOL_PIN_LABEL) || (inKnobIndex == SYMBOL_PIN_NUMBER) {
      return NSCursor.upDownRightLeftCursor
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationAfterPasting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_SymbolPin (additionalDictionary _ : [String : Any],
                                        optionalDocument _ : EBAutoLayoutManagedDocument?,
                                        objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_SymbolPin (_ _ : inout [String : Any]) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Translation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_SymbolPin (xBy inDx: CanariLength, yBy inDy: CanariLength) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_SymbolPin (xBy _ : CanariLength, yBy _ : CanariLength) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_SymbolPin (xBy inDx: CanariLength, yBy inDy: CanariLength, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.xPin += inDx
    self.yPin += inDy
    self.xName += inDx
    self.yName += inDy
    self.xNumber += inDx
    self.yNumber += inDy
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  HORIZONTAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_SymbolPin () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_SymbolPin () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  VERTICAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_SymbolPin () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_SymbolPin () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  ROTATE 90
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_SymbolPin (accumulatedPoints _ : inout Set <CanariPoint>) -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90Clockwise_SymbolPin (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90CounterClockwise_SymbolPin (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Knob
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_SymbolPin (knob _ : Int,
                          proposedUnalignedAlignedTranslation _ : CanariPoint,
                          proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                          unalignedMouseDraggedLocation _ : CanariPoint,
                          shift _ : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
 }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_SymbolPin (knob inKnobIndex: Int,
                       proposedDx inDx: CanariLength,
                       proposedDy inDy: CanariLength,
                       unalignedMouseLocationX _ : CanariLength,
                       unalignedMouseLocationY _ : CanariLength,
                       alignedMouseLocationX _ : CanariLength,
                       alignedMouseLocationY _ : CanariLength,
                       shift _ : Bool) {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_SymbolPin (_ inGrid : CanariLength) -> Bool {
    var result = self.xPin.isAligned (on: inGrid)
    if !result {
      result = self.yPin.isAligned (on: inGrid)
    }
    if !result {
      result = self.xName.isAligned (on: inGrid)
    }
    if !result {
      result = self.yName.isAligned (on: inGrid)
    }
    if !result {
      result = self.xNumber.isAligned (on: inGrid)
    }
    if !result {
      result = self.yNumber.isAligned (on: inGrid)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_SymbolPin (_ inGrid : CanariLength) {
    self.xPin.align (on: inGrid)
    self.yPin.align (on: inGrid)
    self.xName.align (on: inGrid)
    self.yName.align (on: inGrid)
    self.xNumber.align (on: inGrid)
    self.yNumber.align (on: inGrid)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_SymbolPin () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insert (x: self.xPin, y: self.yPin)
    result.insert (x: self.xName, y: self.yName)
    result.insert (x: self.xNumber, y: self.yNumber)
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationBeforeRemoving
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_SymbolPin () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
