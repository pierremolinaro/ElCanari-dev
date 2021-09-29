import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let MODEL_IMAGE_FIRST_POINT = 1
let MODEL_IMAGE_SECOND_POINT = 2

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION PackageModelImageDoublePoint
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackageModelImageDoublePoint {

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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
