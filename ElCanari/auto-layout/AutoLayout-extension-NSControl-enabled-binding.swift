//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//  AutoLayout-extension-NSControl.swift
//
//  Created by Pierre Molinaro on 07/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Enabled binding
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private var gEnabledFromValueBindingDictionary = [NSControl : Bool] ()
private var gEnabledBindingValueDictionary = [NSControl : Bool] ()
private var gEnabledBindingControllerDictionary = [NSControl : EBReadOnlyPropertyController] ()

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension NSControl {

  //····················································································································

  override func autoLayoutCleanUp () {
    gEnabledFromValueBindingDictionary [self] = nil
    gEnabledBindingValueDictionary [self] = nil
    if let controller = gEnabledBindingControllerDictionary [self] {
      controller.unregister ()
      gEnabledBindingControllerDictionary [self] = nil
    }
    super.autoLayoutCleanUp ()
  }

  //····················································································································
  //  $enabled binding
  //····················································································································

  final func bind_enabled (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
    var modelArray = [EBObservableObjectProtocol] ()
    inExpression.addModelsTo (&modelArray)
    let controller = EBReadOnlyPropertyController (
      observedObjects: modelArray,
      callBack: { [weak self] in self?.updateEnableState (from: inExpression.compute ()) }
    )
    gEnabledBindingControllerDictionary [self] = controller
    return self
  }

  //····················································································································

  func enable (fromValueBinding inValue : Bool) {
    gEnabledFromValueBindingDictionary [self] = inValue
    self.isEnabled = (gEnabledBindingValueDictionary [self] ?? true) && (gEnabledFromValueBindingDictionary [self] ?? true)
  }

  //····················································································································

  func enable (fromEnableBinding inValue : Bool) {
    gEnabledBindingValueDictionary [self] = inValue
    self.isEnabled = (gEnabledBindingValueDictionary [self] ?? true) && (gEnabledFromValueBindingDictionary [self] ?? true)
  }

  //····················································································································

  fileprivate func updateEnableState (from inObject : EBSelection <Bool>) {
    switch inObject {
    case .empty, .multiple :
      self.enable (fromEnableBinding: false)
    case .single (let v) :
      self.enable (fromEnableBinding: v)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
