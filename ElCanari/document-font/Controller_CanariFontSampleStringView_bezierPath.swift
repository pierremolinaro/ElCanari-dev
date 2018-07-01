//
//  Controller_CanariFontSampleStringView_bezierPath.swift
//  ElCanari
//
//  Created by Pierre Molinaro on November 13th, 2016.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariFontSampleStringView_bezierPath
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariFontSampleStringView_bezierPath : EBSimpleController {

  private let mObject : EBReadOnlyProperty_CGPath
  private let mOutlet : CanariFontSampleStringView

  //····················································································································

  init (object : EBReadOnlyProperty_CGPath, outlet : CanariFontSampleStringView) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object], outlet:outlet)
  }

  //····················································································································

  final override func sendUpdateEvent () {
    switch mObject.prop {
    case .empty, .multiple :
      break ;
    case .single (let bezierPath) :
      mOutlet.updateDisplayFromBezierPathController (bezierPath)
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
