//
//  AutoLayout-extension-NSView-.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/06/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension NSView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func expandableWidth () -> Self {
    self.setContentHuggingPriority (.defaultLow, for: .horizontal)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func notExpandableWidth () -> Self {
    self.setContentHuggingPriority (.required, for: .horizontal)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
