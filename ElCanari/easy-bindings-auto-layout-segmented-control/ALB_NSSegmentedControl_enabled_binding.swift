//
//  ALB_NSSegmentedControl_enabled_binding.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 12/08/2024.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

class ALB_NSSegmentedControl_enabled_binding : ALB_NSSegmentedControl {

  //································································································
  //  $enabled binding
  //································································································

  private final var mEnabledBindingController : EnabledBindingController? = nil
  final var enabledBindingController : EnabledBindingController? { return self.mEnabledBindingController }

  //································································································

  final func bind_enabled2 (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
    self.mEnabledBindingController = EnabledBindingController (inExpression, self)
    return self
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
