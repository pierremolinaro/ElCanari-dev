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

class AutoLayoutButton : NSButton, EBUserClassNameProtocol {

  //····················································································································

  init (title inTitle : String, small inSmall : Bool) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.title = inTitle
    let fontSize = inSmall ? NSFont.smallSystemFontSize : NSFont.systemFontSize
    self.font = NSFont.systemFont (ofSize: fontSize)
    self.bezelStyle = .regularSquare
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································
  // SET FLEXIBLE WIDTH
  //····················································································································

//  func setFlexibleWidth () -> Self {
//    // Swift.print ("\(self.contentHuggingPriority (for: .horizontal))")
//    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
//    self.needsUpdateConstraints = true
//    return self
//  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
