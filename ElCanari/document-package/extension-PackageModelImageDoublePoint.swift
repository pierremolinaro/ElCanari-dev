import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

let MODEL_IMAGE_FIRST_POINT = 1
let MODEL_IMAGE_SECOND_POINT = 2

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION PackageModelImageDoublePoint
//——————————————————————————————————————————————————————————————————————————————————————————————————

extension PackageModelImageDoublePoint {

  //································································································
  //  Cursor
  //································································································

  func cursorForKnob_PackageModelImageDoublePoint (knob _ : Int) -> NSCursor? {
    return nil // Uses default cursor
  }

  //································································································
  //  operationAfterPasting
  //································································································

  func operationAfterPasting_PackageModelImageDoublePoint (additionalDictionary _ : [String : Any],
                                                           optionalDocument _ : EBAutoLayoutManagedDocument?,
                                                           objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //································································································
  //  Save into additional dictionary
  //································································································

  func saveIntoAdditionalDictionary_PackageModelImageDoublePoint (_ _ : inout [String : Any]) {
  }

  //································································································
  //  Translation
  //································································································

  func acceptedTranslation_PackageModelImageDoublePoint  (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //································································································

  func acceptToTranslate_PackageModelImageDoublePoint (xBy _ : Int, yBy _ : Int) -> Bool {
    return true
  }

  //································································································

  func translate_PackageModelImageDoublePoint (xBy inDx: Int,
                                               yBy inDy: Int,
                                               userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.mFirstX += inDx
    self.mFirstY += inDy
  }

  //································································································
  //  Knob
  //································································································

  func canMove_PackageModelImageDoublePoint (knob _ : Int,
                                             proposedUnalignedAlignedTranslation _ : CanariPoint,
                                             proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                                             unalignedMouseDraggedLocation _ : CanariPoint,
                                             shift _ : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  //································································································

  func move_PackageModelImageDoublePoint (knob inKnobIndex : Int,
                                          proposedDx inDx : Int,
                                          proposedDy inDy : Int,
                                          unalignedMouseLocationX _ : Int,
                                          unalignedMouseLocationY _ : Int,
                                          alignedMouseLocationX _ : Int,
                                          alignedMouseLocationY _ : Int,
                                          shift _ : Bool) {
    if inKnobIndex == MODEL_IMAGE_FIRST_POINT {
      self.mFirstX += inDx
      self.mFirstY += inDy
    }else if inKnobIndex == MODEL_IMAGE_SECOND_POINT {
      self.mSecondDx += inDx
      self.mSecondDy += inDy
    }
  }

  //································································································

  func alignmentPoints_PackageModelImageDoublePoint () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insertCanariPoint (x: self.mFirstX, y: self.mFirstY)
    return result
  }

  //································································································
  //  operationBeforeRemoving
  //································································································

  func operationBeforeRemoving_PackageModelImageDoublePoint () {
  }

  //································································································
  //  HORIZONTAL FLIP
  //································································································

  func flipHorizontally_PackageModelImageDoublePoint () {
  }

  //································································································

  func canFlipHorizontally_PackageModelImageDoublePoint () -> Bool {
    return false
  }

  //································································································
  //  VERTICAL FLIP
  //································································································

  func flipVertically_PackageModelImageDoublePoint () {
  }

  //································································································

  func canFlipVertically_PackageModelImageDoublePoint () -> Bool {
    return false
  }

  //································································································
  //  ROTATE 90
  //································································································

  func canRotate90_PackageModelImageDoublePoint (accumulatedPoints _ : inout Set <CanariPoint>) -> Bool {
    return false
  }

 //····················································································································

  func rotate90Clockwise_PackageModelImageDoublePoint (from _ : CanariPoint,
                                                       userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

 //····················································································································

  func rotate90CounterClockwise_PackageModelImageDoublePoint (from _ : CanariPoint,
                                                              userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  //································································································
  //  Snap to grid
  //································································································

  func snapToGrid_PackageModelImageDoublePoint (_ _ : Int) {
  }

  //································································································

  func canSnapToGrid_PackageModelImageDoublePoint (_ _ : Int) -> Bool {
    return false
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
