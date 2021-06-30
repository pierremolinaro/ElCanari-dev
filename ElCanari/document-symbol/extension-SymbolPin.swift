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

  override func cursorForKnob (knob inKnobIndex: Int) -> NSCursor? {
    if (inKnobIndex == SYMBOL_PIN_LABEL) || (inKnobIndex == SYMBOL_PIN_NUMBER) {
      return NSCursor.upDownRightLeftCursor
    }else{
      return nil
    }
  }

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : ObjcObjectSet) {
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

  override func canMove (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : ObjcCanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : ObjcCanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : ObjcCanariPoint,
                         shift inShift : Bool) -> ObjcCanariPoint {
    return inProposedAlignedTranslation
 }

  //····················································································································

  override func move (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
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

  override func alignmentPoints () -> ObjcCanariPointSet {
    let result = ObjcCanariPointSet ()
    result.insert (CanariPoint (x: self.xPin, y: self.yPin))
    result.insert (CanariPoint (x: self.xName, y: self.yName))
    result.insert (CanariPoint (x: self.xNumber, y: self.yNumber))
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
