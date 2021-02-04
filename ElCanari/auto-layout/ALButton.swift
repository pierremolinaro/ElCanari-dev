//
//  EBButton.swift
//  essai-custom-stack-view
//
//  Created by Pierre Molinaro on 19/10/2019.
//  Copyright © 2019 Pierre Molinaro. All rights reserved.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class ALButton : NSButton {

  //····················································································································

  init (_ inTitle : String) {
    super.init (frame: NSRect ())
    self.title = inTitle
    self.font = NSFont.systemFont (ofSize: NSFont.systemFontSize)
    self.bezelStyle = .regularSquare
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  static func make (_ title : String) -> ALButton {
    let b = ALButton (title)
    gCurrentStack?.addView (b, in: .leading)
    return b
  }

  //····················································································································
  // SET FLEXIBLE WIDTH
  //····················································································································

  func setFlexibleWidth () -> Self {
    // Swift.print ("\(self.contentHuggingPriority (for: .horizontal))")
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
    self.needsUpdateConstraints = true
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
