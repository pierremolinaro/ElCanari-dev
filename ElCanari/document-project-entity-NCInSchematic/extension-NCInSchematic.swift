//
//  extension-NCInSchematic.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION NCInSchematic
//——————————————————————————————————————————————————————————————————————————————————————————————————

extension NCInSchematic {

  //····················································································································
  //  Cursor
  //····················································································································

  func cursorForKnob_NCInSchematic (knob _ : Int) -> NSCursor? {
    return nil // Uses default cursor
  }

  //····················································································································
  //  operationAfterPasting
  //····················································································································

  func operationAfterPasting_NCInSchematic (additionalDictionary _ : [String : Any],
                                            optionalDocument _ : EBAutoLayoutManagedDocument?,
                                            objectArray _ : [EBGraphicManagedObject]) -> String {
    return ""
  }

  //····················································································································
  //  Save into additional dictionary
  //····················································································································

  func saveIntoAdditionalDictionary_NCInSchematic (_ _ : inout [String : Any]) {
  }

  //····················································································································
  //  HORIZONTAL FLIP
  //····················································································································

  func flipHorizontally_NCInSchematic () {
  }

  //····················································································································

  func canFlipHorizontally_NCInSchematic () -> Bool {
    return false
  }

  //····················································································································
  //  VERTICAL FLIP
  //····················································································································

  func flipVertically_NCInSchematic () {
  }

  //····················································································································

  func canFlipVertically_NCInSchematic () -> Bool {
    return false
  }

  //····················································································································
  //  Translation
  //····················································································································

  func acceptedTranslation_NCInSchematic (xBy inDx: Int, yBy inDy: Int) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  //····················································································································

  func acceptToTranslate_NCInSchematic (xBy _ : Int, yBy _ : Int) -> Bool {
    return true
  }

  //····················································································································

  func translate_NCInSchematic (xBy _ : Int, yBy _ : Int, userSet _ : inout EBReferenceSet <EBManagedObject>) {
  }

  //····················································································································
  //  Alignment Points
  //····················································································································

  func alignmentPoints_NCInSchematic () -> Set <CanariPoint> {
    return Set <CanariPoint> ()
  }

  //····················································································································
  //  ROTATE 90
  //····················································································································

  func canRotate90_NCInSchematic (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    let p = self.mPoint!.location!
    accumulatedPoints.insert (p)
    return true
  }

  //····················································································································

  func rotate90Clockwise_NCInSchematic (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    switch self.mOrientation {
    case .rotation0 :
      self.mOrientation = .rotation270
    case .rotation90 :
      self.mOrientation = .rotation0
    case .rotation180 :
      self.mOrientation = .rotation90
    case .rotation270 :
      self.mOrientation = .rotation180
    }
  }

  //····················································································································

  func rotate90CounterClockwise_NCInSchematic (from _ : CanariPoint, userSet _ : inout EBReferenceSet <EBManagedObject>) {
    switch self.mOrientation {
    case .rotation0 :
      self.mOrientation = .rotation90
    case .rotation90 :
      self.mOrientation = .rotation180
    case .rotation180 :
      self.mOrientation = .rotation270
    case .rotation270 :
      self.mOrientation = .rotation0
    }
  }

  //····················································································································

  func operationBeforeRemoving_NCInSchematic () {
    if let p = self.mPoint {
      self.mPoint = nil // Detach from point
    //--- L'affectation suivante est inutile si le graphe d'objets n'a pas d'erreur, normalement un
    //    le point associé à NC n'a pas de net. En cas d'erreur, si un net est affecté par erreur, le lien est défait
      p.mNet = nil
    }
  }

  //····················································································································
  //  Snap to grid
  //····················································································································

  func snapToGrid_NCInSchematic (_ _ : Int) {
  }

  //····················································································································

  func canSnapToGrid_NCInSchematic (_ _ : Int) -> Bool {
    return false
  }

  //····················································································································
  //  Move
  //····················································································································

  func canMove_NCInSchematic (knob _ : Int,
                              proposedUnalignedAlignedTranslation _ : CanariPoint,
                              proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                              unalignedMouseDraggedLocation _ : CanariPoint,
                              shift _ : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
  }

  //····················································································································

  func move_NCInSchematic (knob _ : Int,
                           proposedDx _ : Int,
                           proposedDy _ : Int,
                           unalignedMouseLocationX _ : Int,
                           unalignedMouseLocationY _ : Int,
                           alignedMouseLocationX _ : Int,
                           alignedMouseLocationY _ : Int,
                           shift _ : Bool) {
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
