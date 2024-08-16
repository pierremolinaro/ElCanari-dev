//
//  AutoLayout+NSView+expandableHeight.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/01/2022.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension NSView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func expandableHeight () -> Self {
    self.setContentHuggingPriority (.defaultLow, for: .vertical)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func notExpandableHeight () -> Self {
//    self.setContentHuggingPriority (.required, for: .vertical)
//    return self
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
