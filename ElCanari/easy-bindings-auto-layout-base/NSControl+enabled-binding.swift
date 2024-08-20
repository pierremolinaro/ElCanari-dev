//--------------------------------------------------------------------------------------------------
//
//  AutoLayout-extension-NSControl.swift
//
//  Created by Pierre Molinaro on 07/02/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension NSControl {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func enable (fromValueBinding inValue : Bool,
                     _ inEnableBindingController : EnabledBindingController?) {
    if let controller = inEnableBindingController {
      controller.enable (fromValueBinding: inValue)
    }else{
      self.isEnabled = inValue
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func enable (fromEnableBinding inValue : Bool,
                     _ inEnableBindingController : EnabledBindingController?) {
    if let controller = inEnableBindingController {
      controller.enable (fromEnableBinding: inValue)
    }else{
      self.isEnabled = inValue
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $enabled binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func enabledBindingController () -> EnabledBindingController? {
    let key = Key (self)
    return gDictionary [key]
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_enabled (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
    let enabledBindingController = EnabledBindingController (inExpression, self)
    performRetain (enabledBindingController: enabledBindingController, forObject: self)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

final class EnabledBindingController : EBObservablePropertyController {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private weak var mControlOutlet : NSControl? = nil
  private var mIsEnabledFromValueBinding = true
  private var mIsEnabledFromEnabledBinding = true

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inExpression : EBMultipleBindingBooleanExpression, _ inOutlet : NSControl) {
    self.mControlOutlet = inOutlet
    var modelArray = [EBObservableObjectProtocol] ()
    inExpression.addModelsTo (&modelArray)
    super.init (
      observedObjects: modelArray,
      callBack: nil
    )
    self.mEventCallBack = { [weak self] in self?.updateEnableState (from: inExpression.compute ()) }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateEnableState (from inObject : EBSelection <Bool>) {
    switch inObject {
    case .empty, .multiple :
      self.enable (fromEnableBinding: false)
    case .single (let v) :
      self.enable (fromEnableBinding: v)
    }
    if let windowContentView = self.mControlOutlet?.window?.contentView as? AutoLayoutWindowContentView {
      windowContentView.triggerNextKeyViewSettingComputation ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func enable (fromEnableBinding inValue : Bool) {
    self.mIsEnabledFromEnabledBinding = inValue
    self.mControlOutlet?.isEnabled = self.mIsEnabledFromValueBinding && self.mIsEnabledFromEnabledBinding
    if let outlet = self.mControlOutlet as? NSTextField {
      outlet.isEditable = self.mIsEnabledFromValueBinding && self.mIsEnabledFromEnabledBinding
    }
    if let windowContentView = self.mControlOutlet?.window?.contentView as? AutoLayoutWindowContentView {
      windowContentView.triggerNextKeyViewSettingComputation ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func enable (fromValueBinding inValue : Bool) {
    self.mIsEnabledFromValueBinding = inValue
    self.mControlOutlet?.isEnabled = self.mIsEnabledFromValueBinding && self.mIsEnabledFromEnabledBinding
    if let outlet = self.mControlOutlet as? NSTextField {
      outlet.isEditable = self.mIsEnabledFromValueBinding && self.mIsEnabledFromEnabledBinding
    }
    if let windowContentView = self.mControlOutlet?.window?.contentView as? AutoLayoutWindowContentView {
      windowContentView.triggerNextKeyViewSettingComputation ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate func performRetain (enabledBindingController inController : EnabledBindingController,
                                           forObject inObject : NSControl) {
  let key = Key (inObject)
  gDictionary [key] = inController
}

//--------------------------------------------------------------------------------------------------

nonisolated func objectDidDeinitSoReleaseEnabledBindingController () {
  DispatchQueue.main.async {
    if !gNeedToUpdateDictionary {
      gNeedToUpdateDictionary = true
      DispatchQueue.main.async {
        gNeedToUpdateDictionary = false
        var newDict = [Key : EnabledBindingController] ()
        for (key, controller) in gDictionary {
          if key.mObject != nil {
            newDict [key] = controller
          }
        }
        gDictionary = newDict
      }
    }
  }
}

//--------------------------------------------------------------------------------------------------

fileprivate struct Key : Hashable {
  weak var mObject : NSControl?

  init (_ inObject : NSControl) {
    self.mObject = inObject
  }
}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate var gNeedToUpdateDictionary = false
@MainActor fileprivate var gDictionary = [Key : EnabledBindingController] ()

//--------------------------------------------------------------------------------------------------
