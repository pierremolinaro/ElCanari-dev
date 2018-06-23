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
//   Controller_CanariCharacterView_advance
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariCharacterView_advance : EBSimpleController {

  private let mObject : EBReadOnlyProperty_Int
  private let mOutlet : CanariCharacterView

  //····················································································································

  init (object : EBReadOnlyProperty_Int, outlet : CanariCharacterView) {
    mObject = object
    mOutlet = outlet
    super.init (objects:[object], outlet:outlet)
    mObject.addEBObserver (self)
  }

  //····················································································································
  
  final func unregister () {
    mObject.removeEBObserver (self)
  }

  //····················································································································

  final override func sendUpdateEvent () {
    switch mObject.prop {
    case .noSelection, .multipleSelection :
      break ;
    case .singleSelection (let value) :
      mOutlet.setAdvance (value)
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
