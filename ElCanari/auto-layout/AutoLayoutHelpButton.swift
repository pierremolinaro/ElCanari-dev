//
//  AutoLayoutHelpButton.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 27/02/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutHelpButton : NSButton, EBUserClassNameProtocol {

  //····················································································································

  init (small inSmall : Bool) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.controlSize = inSmall ? .small : .regular
    self.title = ""
    self.bezelStyle = .helpButton
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

}

//----------------------------------------------------------------------------------------------------------------------
