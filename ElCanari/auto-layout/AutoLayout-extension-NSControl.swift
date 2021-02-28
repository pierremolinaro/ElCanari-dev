//----------------------------------------------------------------------------------------------------------------------
//
//  AutoLayout-extension-NSControl.swift
//
//  Created by Pierre Molinaro on 07/02/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   Enabled binding
//----------------------------------------------------------------------------------------------------------------------

private var gEnabledFromValueBindingDictionary = [NSControl : Bool] ()
private var gEnabledBindingValueDictionary = [NSControl : Bool] ()
private var gEnabledBindingControllerDictionary = [NSControl : EBReadOnlyPropertyController] ()

//----------------------------------------------------------------------------------------------------------------------

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

  final func bind_enabled (observedObjects inObjects : [EBObservableObjectProtocol],
                           computeFunction inFunction : @escaping () -> EBSelection <Bool>) -> Self {
    let controller = EBReadOnlyPropertyController (
      observedObjects: inObjects,
      callBack: { [weak self] in self?.update (from: inFunction ()) }
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

  fileprivate func enable (fromEnableBinding inValue : Bool) {
    gEnabledBindingValueDictionary [self] = inValue
    self.isEnabled = (gEnabledBindingValueDictionary [self] ?? true) && (gEnabledFromValueBindingDictionary [self] ?? true)
  }

  //····················································································································

  fileprivate func update (from inObject : EBSelection <Bool>) {
    switch inObject {
    case .empty, .multiple :
      self.enable (fromEnableBinding: false)
    case .single (let v) :
      self.enable (fromEnableBinding: v)
    }
  }

  //····················································································································

  func bind_run (target inTarget : NSObject, selector inSelector : Selector) -> Self {
    self.target = inTarget
    self.action = inSelector
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
