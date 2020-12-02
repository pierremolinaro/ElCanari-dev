import Cocoa

//----------------------------------------------------------------------------------------------------------------------

let MODEL_IMAGE_FIRST_POINT = 1
let MODEL_IMAGE_SECOND_POINT = 2

//----------------------------------------------------------------------------------------------------------------------
//   EXTENSION PackageModelImageDoublePoint
//----------------------------------------------------------------------------------------------------------------------

extension PackageModelImageDoublePoint {

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : OCObjectSet) {
    self.mFirstX += inDx
    self.mFirstY += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int,
                         proposedAlignedTranslation inProposedAlignedTranslation : OCCanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : OCCanariPoint) -> OCCanariPoint {
    return inProposedAlignedTranslation
  }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int, newX inNewX : Int, newY inNewY : Int) {
    if inKnobIndex == MODEL_IMAGE_FIRST_POINT {
      self.mFirstX += inDx
      self.mFirstY += inDy
    }else if inKnobIndex == MODEL_IMAGE_SECOND_POINT {
      self.mSecondDx += inDx
      self.mSecondDy += inDy
    }
  }

  //····················································································································
  //  DELETE
  //····················································································································

  override func canBeDeleted () -> Bool {
    return false
  }

  //····················································································································

  override func alignmentPoints () -> OCCanariPointSet {
    let result = OCCanariPointSet ()
    result.insert (CanariPoint (x: self.mFirstX, y: self.mFirstY))
    return result
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
