//
//  AutoLayoutStepper.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutStepper : AutoLayoutBase_NSStepper {

  //····················································································································

  override init () {
    super.init ()

    self.minValue = 32.0
    self.maxValue = 65535.0
    self.increment = 1.0
    self.valueWraps = true
    self.autorepeat = true

    self.target = self
    self.action = #selector (Self.stepperAction (_:))
  }

  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  @objc private func stepperAction (_ _ : AutoLayoutStepper) {
    let v = Int (self.doubleValue.rounded (.toNearestOrEven))
    self.mValueController?.updateModel (withValue: v)
  }

  //····················································································································
  //  $value binding
  //····················································································································

  fileprivate func updateStepper (from inObject : EBObservableProperty <Int>) {
    switch inObject.selection {
    case .empty, .multiple :
      self.enable (fromValueBinding: false, self.enabledBindingController)
    case .single (let v) :
      self.enable (fromValueBinding: true, self.enabledBindingController)
      self.doubleValue = Double (v)
    }
  }

  //····················································································································

  private var mValueController : EBGenericReadWritePropertyController <Int>? = nil

  //····················································································································

  final func bind_value (_ inObject : EBObservableMutableProperty <Int>) -> Self {
    NSColorPanel.shared.showsAlpha = true
    self.mValueController = EBGenericReadWritePropertyController <Int> (
      observedObject: inObject,
      callBack: { [weak self] in self?.updateStepper (from: inObject)  }
    )
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————