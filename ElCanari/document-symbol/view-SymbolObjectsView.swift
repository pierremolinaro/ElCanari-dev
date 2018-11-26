//
//  view-SymbolObjectsView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 19/11/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let SYMBOL_GRID_IN_COCOA_UNIT : CGFloat  = milsToCocoaUnit (25.0)
let SYMBOL_GRID_IN_CANARI_UNIT : Int  = milsToCanariUnit (25)

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   SymbolObjectsView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class SymbolObjectsView : CanariViewWithZoomAndFlip {

  //····················································································································
  //   INIT
  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    self.configurationOnInit ()
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    self.configurationOnInit ()
  }

  //····················································································································

  func configurationOnInit () {
    self.setZoom (500, activateZoomPopUpButton: true)
    self.set (arrowKeyMagnitude: SYMBOL_GRID_IN_COCOA_UNIT)
    self.set (shiftArrowKeyMagnitude: SYMBOL_GRID_IN_COCOA_UNIT * 4.0)
    self.mDraggingObjectsIsAlignedOnArrowKeyMagnitude = true
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
