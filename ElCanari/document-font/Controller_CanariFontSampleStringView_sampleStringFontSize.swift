//
//  Controller_CanariFontSampleStringView_sampleStringFontSize.swift
//  ElCanari
//
//  Created by Pierre Molinaro on November 13th, 2016.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariFontSampleStringView_sampleStringFontSize
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariFontSampleStringView_sampleStringFontSize : EBSimpleController {

  private let mObject : EBReadOnlyProperty_Double
  private let mOutlet : CanariFontSampleStringView

  //····················································································································

  init (object : EBReadOnlyProperty_Double, outlet : CanariFontSampleStringView) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object], outlet:outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  final private func updateOutlet () {
    switch mObject.prop {
    case .empty, .multiple :
      break ;
    case .single (let fontSize) :
      mOutlet.updateDisplayFromFontSizeController (fontSize)
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
