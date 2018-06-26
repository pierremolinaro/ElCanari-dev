//
//  Controller-CanariCharacterView-transparency.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 10/11/2016.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariCharacterView_transparency
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariCharacterView_transparency : EBSimpleController {

  private let mObject : EBReadOnlyProperty_Double
  private let mOutlet : CanariCharacterView

  //····················································································································

  init (object : EBReadOnlyProperty_Double, outlet : CanariCharacterView) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object], outlet:outlet)
  }

  //····················································································································

  final override func sendUpdateEvent () {
    _ = mObject.prop // Required for flushing event
    mOutlet.updateSegmentDrawingsFromTransparencyController ()
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
