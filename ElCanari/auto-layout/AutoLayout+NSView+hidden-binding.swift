//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//  AutoLayout-extension-NSView.swift
//
//  Created by Pierre Molinaro on 07/02/2021.
//
// https://medium.com/macoclock/is-everything-connected-6f339dd8a0fb
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class HiddenBindingController : EBObservablePropertyController {

  //····················································································································

  private weak var mOutlet : NSView? = nil

  //····················································································································

  init (_ inExpression : EBMultipleBindingBooleanExpression, _ inOutlet : NSView) {
    self.mOutlet = inOutlet
    var modelArray = [EBObservableObjectProtocol] ()
    inExpression.addModelsTo (&modelArray)
    super.init (
      observedObjects: modelArray,
      callBack: nil
    )
    self.mEventCallBack = { [weak self] in self?.updateHiddenState (from: inExpression.compute ()) }
  }

  //····················································································································

  fileprivate func updateHiddenState (from inObject : EBSelection <Bool>) {
    switch inObject {
    case .empty, .multiple :
      self.mOutlet?.isHidden = false
    case .single (let v) :
      self.mOutlet?.isHidden = v
    }
    if let windowContentView = self.mOutlet?.window?.contentView as? AutoLayoutWindowContentView {
      windowContentView.triggerNextKeyViewSettingComputation ()
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
