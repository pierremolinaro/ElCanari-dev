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
    case .singleSelection (let fontSize) :
      mOutlet.updateDisplayFromFontSizeController (fontSize)
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
