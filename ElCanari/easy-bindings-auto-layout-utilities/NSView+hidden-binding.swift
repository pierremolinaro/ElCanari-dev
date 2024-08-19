//--------------------------------------------------------------------------------------------------
//
//  AutoLayout-extension-NSView.swift
//
//  Created by Pierre Molinaro on 07/02/2021.
//
// https://medium.com/macoclock/is-everything-connected-6f339dd8a0fb
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension NSView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $hidden binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_hidden (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
    let hiddenBindingController = HiddenBindingController (inExpression, self)
    performRetain (hiddenBindingController: hiddenBindingController, forObject: self)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

final class HiddenBindingController : EBObservablePropertyController {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private weak var mOutlet : NSView? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

@MainActor
fileprivate func performRetain (hiddenBindingController inController : HiddenBindingController,
                                forObject inObject : NSView) {
  gArray.append (Entry (inObject, inController))
}

//--------------------------------------------------------------------------------------------------

nonisolated func objectDidDeinitSoReleaseHiddenControllers () {
  DispatchQueue.main.async {
    if !gNeedToUpdateArray {
      gNeedToUpdateArray = true
      DispatchQueue.main.async {
        gNeedToUpdateArray = false
        var newArray = [Entry] ()
        for entry in gArray {
          if entry.mObject != nil {
            newArray.append (entry)
          }
        }
        gArray = newArray
      }
    }
  }
}

//--------------------------------------------------------------------------------------------------

fileprivate struct Entry {
  weak var mObject : NSView? // SHOULD BE WEAK
  let mController : AnyObject

  init (_ inObject : NSView, _ inController : HiddenBindingController) {
    self.mObject = inObject
    self.mController = inController
  }
}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate var gNeedToUpdateArray = false
@MainActor fileprivate var gArray = [Entry] ()

//--------------------------------------------------------------------------------------------------
