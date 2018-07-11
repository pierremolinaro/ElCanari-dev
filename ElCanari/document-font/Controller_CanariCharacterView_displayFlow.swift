//
//  Controller-CanariCharacterView-advance.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 10/11/2016.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariCharacterView_displayFlow
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariCharacterView_displayFlow : EBSimpleController {

  private let mObject : EBReadOnlyProperty_Bool
  private let mOutlet : CanariCharacterView

  //····················································································································

  init (object : EBReadOnlyProperty_Bool, outlet : CanariCharacterView) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object], outlet:outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  final private func updateOutlet () {
    _ = mObject.prop // Required for flushing event
    mOutlet.updateSegmentDrawingsFromDisplayFlowController ()
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
