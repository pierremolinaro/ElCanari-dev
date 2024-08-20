//
//  AutoLayout-extension-NSControl-run-binding.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/06/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension NSControl {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_run (target inTarget : NSObject, selector inSelector : Selector) -> Self {
    self.target = inTarget
    self.action = inSelector
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func unbind_run () -> Self {
//    self.target = nil
//    self.action = nil
//    return self
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
