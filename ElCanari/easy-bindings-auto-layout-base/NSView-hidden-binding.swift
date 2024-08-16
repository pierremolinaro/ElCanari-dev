//
//  NSView-hidden-binding.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/08/2024.
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
    performRetain (property: hiddenBindingController, forObject: self)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
