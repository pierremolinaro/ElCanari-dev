//
//  InternalAutoLayoutButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/06/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class InternalAutoLayoutButton : NSButton, EBUserClassNameProtocol {

  //····················································································································

  init (title inTitle : String, small inSmall : Bool) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.title = inTitle
    self.controlSize = inSmall ? .small : .regular
    self.font = NSFont.systemFont (ofSize: inSmall ? NSFont.smallSystemFontSize : NSFont.systemFontSize)
    self.bezelStyle = autoLayoutCurrentStyle ().buttonStyle
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

  override final func updateAutoLayoutUserInterfaceStyle () {
    super.updateAutoLayoutUserInterfaceStyle ()
    self.bezelStyle = autoLayoutCurrentStyle ().buttonStyle
  }

  //····················································································································

  final func makeWidthExpandable () -> Self {
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
