//
//  NSControl-enabled-binding.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/08/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension NSControl {

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

@MainActor func performRetain (enabledBindingController inController : EnabledBindingController,
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
