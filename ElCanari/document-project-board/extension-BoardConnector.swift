//
//  extension-BoardConnector.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/07/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

let BOARD_CONNECTOR_KNOB  = 0

//----------------------------------------------------------------------------------------------------------------------
//   EXTENSION BoardConnector
//----------------------------------------------------------------------------------------------------------------------

extension BoardConnector {

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx : Int, yBy inDy : Int, userSet ioSet : ObjcObjectSet) {
    if !ioSet.contains (self) {
      ioSet.insert (self)
      self.mX += inDx
      self.mY += inDy
    }
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : ObjcCanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : ObjcCanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : ObjcCanariPoint) -> ObjcCanariPoint {
    if (inKnobIndex == BOARD_CONNECTOR_KNOB) && !(self.connectedToComponent ?? true) {
      return inProposedAlignedTranslation
    }else{
      return ObjcCanariPoint (x: 0, y: 0)
    }
  }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int, newX inNewX : Int, newY inNewY : Int) {
    if inKnobIndex == BOARD_CONNECTOR_KNOB {
      self.mX += inDx
      self.mY += inDy
    }
  }

  //····················································································································
  //   SNAP TO GRID
  //····················································································································

  override func canSnapToGrid (_ inGrid : Int) -> Bool {
    var isAligned = self.mX.isAlignedOnGrid (inGrid)
    if isAligned {
      isAligned = self.mY.isAlignedOnGrid (inGrid)
    }
    return !isAligned
  }

  //····················································································································

  override func snapToGrid (_ inGrid : Int) {
    self.mX.align (onGrid: inGrid)
    self.mY.align (onGrid: inGrid)
  }

  //····················································································································
  //  REMOVING
  //····················································································································

  override func canBeDeleted () -> Bool {
    return false
  }

  //····················································································································

  func connectedTracksNet () -> NetInProject? {
    var netSet = Set <NetInProject> ()
    for t in self.mTracksP1 {
      if let net = t.mNet {
        netSet.insert (net)
      }
    }
    for t in self.mTracksP2 {
      if let net = t.mNet {
        netSet.insert (net)
      }
    }
    if netSet.count == 1 {
      return netSet.first
    }else{
      return nil
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
