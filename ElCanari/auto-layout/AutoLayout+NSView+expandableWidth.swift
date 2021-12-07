//
//  AutoLayout-extension-NSView-.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension NSView {

  final func expandableWidth () -> Self {
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
    return self
  }

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
