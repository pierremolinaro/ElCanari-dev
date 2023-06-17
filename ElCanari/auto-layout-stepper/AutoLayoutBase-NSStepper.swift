//
//  AutoLayoutBase-NSStepper.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutBase_NSStepper : NSStepper {

  //····················································································································

  init () {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.setContentCompressionResistancePriority (.required, for: .vertical)
    self.setContentHuggingPriority (.required, for: .vertical)
    self.setContentCompressionResistancePriority (.required, for: .horizontal)
    self.setContentHuggingPriority (.required, for: .horizontal)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //  $enabled binding
  //····················································································································

  private final var mEnabledBindingController : EnabledBindingController? = nil
  final var enabledBindingController : EnabledBindingController? { return self.mEnabledBindingController }

  //····················································································································

//  final func bind_enabled (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
//    self.mEnabledBindingController = EnabledBindingController (inExpression, self)
//    return self
//  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
