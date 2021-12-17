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

fileprivate struct EnabledFromValueBindingDescriptor {
  let value : Bool
  private let mObjectIdentifier : ObjectIdentifier
  private weak var mControl : NSControl? {
    didSet {
      if self.mControl == nil {
        gEnabledFromValueBindingDictionary [self.mObjectIdentifier] = nil
      }
    }
  }

  init (control inControl : NSControl, value inValue : Bool) {
    self.value = inValue
    self.mControl = inControl
    self.mObjectIdentifier = ObjectIdentifier (inControl)
  }
}

fileprivate var gEnabledFromValueBindingDictionary = [ObjectIdentifier : EnabledFromValueBindingDescriptor] ()

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct EnabledFromEnabledBindingDescriptor {
  let enabled : Bool
  private let mObjectIdentifier : ObjectIdentifier
  private weak var mControl : NSControl? {
    didSet {
      if self.mControl == nil {
        gEnabledBindingValueDictionary [self.mObjectIdentifier] = nil
      }
    }
  }

  init (control inControl : NSControl, enabled inEnabled : Bool) {
    self.enabled = inEnabled
    self.mControl = inControl
    self.mObjectIdentifier = ObjectIdentifier (inControl)
  }
}

private var gEnabledBindingValueDictionary = [ObjectIdentifier : EnabledFromEnabledBindingDescriptor] ()

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct EnabledControllerDescriptor {
  private weak var controller : EBReadOnlyPropertyController?
  private let mObjectIdentifier : ObjectIdentifier
  private weak var mControl : NSControl? {
    didSet {
      if self.mControl == nil {
        self.controller?.unregister ()
        gEnabledBindingControllerDictionary [self.mObjectIdentifier] = nil
      }
    }
  }

  init (control inControl : NSControl, controller inController : EBReadOnlyPropertyController) {
    self.controller = inController
    self.mControl = inControl
    self.mObjectIdentifier = ObjectIdentifier (inControl)
  }

}

private var gEnabledBindingControllerDictionary = [ObjectIdentifier : EnabledControllerDescriptor] ()

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension NSControl {

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
    gEnabledBindingControllerDictionary [ObjectIdentifier (self)] = EnabledControllerDescriptor (control: self, controller: controller)
    return self
  }

  //····················································································································

  func enable (fromValueBinding inValue : Bool) {
    gEnabledFromValueBindingDictionary [ObjectIdentifier (self)] = EnabledFromValueBindingDescriptor (control: self, value: inValue)
    self.isEnabled = (gEnabledBindingValueDictionary [ObjectIdentifier (self)]?.enabled ?? true) && inValue
  }

  //····················································································································

  func enable (fromEnableBinding inEnabled : Bool) {
    gEnabledBindingValueDictionary [ObjectIdentifier (self)] = EnabledFromEnabledBindingDescriptor (control: self, enabled: inEnabled)
    self.isEnabled = inEnabled && (gEnabledFromValueBindingDictionary [ObjectIdentifier (self)]?.value ?? true)
  }

  //····················································································································

  fileprivate func updateEnableState (from inObject : EBSelection <Bool>) {
    switch inObject {
    case .empty, .multiple :
      self.enable (fromEnableBinding: false)
    case .single (let v) :
      self.enable (fromEnableBinding: v)
    }
    if let windowContentView = self.window?.contentView as? AutoLayoutWindowContentView {
      windowContentView.triggerNextKeyViewSettingComputation ()
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
