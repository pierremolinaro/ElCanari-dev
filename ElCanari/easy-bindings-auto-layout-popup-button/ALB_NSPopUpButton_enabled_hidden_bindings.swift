//
//  ALB_NSPopUpButton_enabled_hidden_bindings.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 12/08/2024.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————
//   ALB_NSPopUpButton
//——————————————————————————————————————————————————————————————————————————————————————————————————

class ALB_NSPopUpButton_enabled_hidden_bindings : ALB_NSPopUpButton {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $enabled binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mEnabledBindingController : EnabledBindingController? = nil
  final var enabledBindingController : EnabledBindingController? { return self.mEnabledBindingController }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_enabled (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
    self.mEnabledBindingController = EnabledBindingController (inExpression, self)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $hidden binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  private final var mHiddenBindingController : HiddenBindingController? = nil
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  final func bind_hidden (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
//    self.mHiddenBindingController = HiddenBindingController (inExpression, self)
//    return self
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
