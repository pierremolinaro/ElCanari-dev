import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SYMBOL_SEGMENT_ENDPOINT_1 = 1
let SYMBOL_SEGMENT_ENDPOINT_2 = 2

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION SymbolSegment
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SymbolSegment {

  //····················································································································

  func cursorForKnob_SymbolSegment (knob inKnobIndex: Int) -> NSCursor? {
    return NSCursor.upDownRightLeftCursor
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_SymbolSegment (additionalDictionary inDictionary : NSDictionary,
                                             optionalDocument inOptionalDocument : EBAutoLayoutManagedDocument?,
                                             objectArray inObjectArray : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_SymbolSegment (_ ioDictionary : NSMutableDictionary) {
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_SymbolSegment (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }



//  func acceptedTranslation (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
//    var acceptedX = inDx
//    do{
//      let newX = self.x1 + acceptedX
//      if newX < 0 {
//        acceptedX = -self.x1
//      }
//    }
//    do{
//      let newX = self.x2 + acceptedX
//      if newX < 0 {
//        acceptedX = -self.x2
//      }
//    }
//    var acceptedY = inDy
//    do{
//      let newY = self.y1 + acceptedY
//      if newY < 0 {
//        acceptedY = -self.y1
//      }
//    }
//    do{
//      let newY = self.y2 + acceptedY
//      if newY < 0 {
//        acceptedY = -self.y2
//      }
//    }
//    return CanariPoint (x: acceptedX, y: acceptedY)
//  }

  //····················································································································

  func acceptToTranslate_SymbolSegment (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
//    let newX1 = self.x1 + inDx
//    let newY1 = self.y1 + inDy
//    let newX2 = self.x2 + inDx
//    let newY2 = self.y2 + inDy
//    return (newX1 >= 0) && (newY1 >= 0) && (newX2 >= 0) && (newY2 >= 0)
  }

  //····················································································································

  func translate_SymbolSegment (xBy inDx: Int, yBy inDy: Int, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
    self.x1 += inDx
    self.y1 += inDy
    self.x2 += inDx
    self.y2 += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  func canMove_SymbolSegment (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : CanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : CanariPoint,
                         shift inShift : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
 }

  //····················································································································

  func move_SymbolSegment (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
//    Swift.print ("inDx \(inDx), inDy \(inDy)")
    if inKnobIndex == SYMBOL_SEGMENT_ENDPOINT_1 {
      self.x1 += inDx
      self.y1 += inDy
    }else if inKnobIndex == SYMBOL_SEGMENT_ENDPOINT_2 {
      self.x2 += inDx
      self.y2 += inDy
    }
  }

  //····················································································································
  //  Flip horizontally
  //····················································································································

  func canFlipHorizontally_SymbolSegment () -> Bool {
    return x1 != x2
  }

  //····················································································································

  func flipHorizontally_SymbolSegment () {
    (x1, x2) = (x2, x1)
  }

  //····················································································································
  //  Flip vertically
  //····················································································································

  func canFlipVertically_SymbolSegment () -> Bool {
    return y1 != y2
  }

  //····················································································································

  func flipVertically_SymbolSegment () {
    (y1, y2) = (y2, y1)
  }

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  func canSnapToGrid_SymbolSegment (_ inGrid : Int) -> Bool {
    var result = (self.x1 % inGrid) != 0
    if !result {
      result = (self.y1 % inGrid) != 0
    }
    if !result {
      result = (self.x2 % inGrid) != 0
    }
    if !result {
      result = (self.y2 % inGrid) != 0
    }
    return result
  }

  //····················································································································

  func snapToGrid_SymbolSegment (_ inGrid : Int) {
    self.x1 = ((self.x1 + inGrid / 2) / inGrid) * inGrid
    self.y1 = ((self.y1 + inGrid / 2) / inGrid) * inGrid
    self.x2 = ((self.x2 + inGrid / 2) / inGrid) * inGrid
    self.y2 = ((self.y2 + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  func alignmentPoints_SymbolSegment () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insertCanariPoint (x: self.x1, y: self.y1)
    result.insertCanariPoint (x: self.x2, y: self.y2)
    return result
  }

  //····················································································································
  //  operationBeforeRemoving
  //····················································································································

  func operationBeforeRemoving_SymbolSegment () {
  }

  //····················································································································
  //  ROTATE 90
  //····················································································································

  func canRotate90_SymbolSegment (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    return false
  }

 //····················································································································

  func rotate90Clockwise_SymbolSegment (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
  }

 //····················································································································

  func rotate90CounterClockwise_SymbolSegment (from inRotationCenter : CanariPoint, userSet ioSet : inout EBReferenceSet <EBManagedObject>) {
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
