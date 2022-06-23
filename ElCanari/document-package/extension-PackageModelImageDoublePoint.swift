import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let MODEL_IMAGE_FIRST_POINT = 1
let MODEL_IMAGE_SECOND_POINT = 2

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION PackageModelImageDoublePoint
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackageModelImageDoublePoint {

  //····················································································································
  //  Cursor
  //····················································································································

  func cursorForKnob_PackageModelImageDoublePoint (knob inKnobIndex: Int) -> NSCursor? {
    return nil // Uses default cursor
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_PackageModelImageDoublePoint (additionalDictionary inDictionary : NSDictionary,
                                             optionalDocument inOptionalDocument : EBAutoLayoutManagedDocument?,
                                             objectArray inObjectArray : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_PackageModelImageDoublePoint (_ ioDictionary : NSMutableDictionary) {
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_PackageModelImageDoublePoint  (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //····················································································································

  func acceptToTranslate_PackageModelImageDoublePoint (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_PackageModelImageDoublePoint (xBy inDx: Int, yBy inDy: Int, userSet ioSet : inout EBReferenceSet <AnyObject>) {
    self.mFirstX += inDx
    self.mFirstY += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  func canMove_PackageModelImageDoublePoint (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                         shift inShift : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  //····················································································································

  func move_PackageModelImageDoublePoint (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
    if inKnobIndex == MODEL_IMAGE_FIRST_POINT {
      self.mFirstX += inDx
      self.mFirstY += inDy
    }else if inKnobIndex == MODEL_IMAGE_SECOND_POINT {
      self.mSecondDx += inDx
      self.mSecondDy += inDy
    }
  }

  //····················································································································

  func alignmentPoints_PackageModelImageDoublePoint () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insertCanariPoint (x: self.mFirstX, y: self.mFirstY)
    return result
  }

  //····················································································································
  //  operationBeforeRemoving
  //····················································································································

  func operationBeforeRemoving_PackageModelImageDoublePoint () {
  }

  //····················································································································
  //  HORIZONTAL FLIP
  //····················································································································

  func flipHorizontally_PackageModelImageDoublePoint () {
  }

  //····················································································································

  func canFlipHorizontally_PackageModelImageDoublePoint () -> Bool {
    return false
  }

  //····················································································································
  //  VERTICAL FLIP
  //····················································································································

  func flipVertically_PackageModelImageDoublePoint () {
  }

  //····················································································································

  func canFlipVertically_PackageModelImageDoublePoint () -> Bool {
    return false
  }

  //····················································································································
  //  ROTATE 90
  //····················································································································

  func canRotate90_PackageModelImageDoublePoint (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    return false
  }

 //····················································································································

  func rotate90Clockwise_PackageModelImageDoublePoint (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <AnyObject>) {
  }

 //····················································································································

  func rotate90CounterClockwise_PackageModelImageDoublePoint (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <AnyObject>) {
  }

  //····················································································································
  //  Snap to grid
  //····················································································································

  func snapToGrid_PackageModelImageDoublePoint (_ inGrid : Int) {
  }

  //····················································································································

  func canSnapToGrid_PackageModelImageDoublePoint (_ inGrid : Int) -> Bool {
    return false
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
