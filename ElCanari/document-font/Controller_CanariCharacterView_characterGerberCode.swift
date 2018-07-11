//
//  Controller-CanariCharacterView-characterGerberCode.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 10/11/2016.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   http://www.raywenderlich.com/90488/calayer-in-ios-with-swift-10-examples
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariCharacterView_characterGerberCode
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariCharacterView_characterGerberCode : EBSimpleController {

  private let mObject : EBReadOnlyProperty_CharacterSegmentListClass
  private let mOutlet : CanariCharacterView

  //····················································································································

  init (object : EBReadOnlyProperty_CharacterSegmentListClass, outlet : CanariCharacterView) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object], outlet:outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  final private func updateOutlet () {
    _ = mObject.prop // Required for flushing event
    mOutlet.updateSegmentDrawingsFromCharacterSegmentListController () // Just for triggering display, mObject value not used
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
