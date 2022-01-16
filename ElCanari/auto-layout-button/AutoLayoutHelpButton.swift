//
//  AutoLayoutHelpButton.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 27/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutHelpButton : AutoLayoutBase_NSButton {

  //····················································································································

  init (size inSize : EBControlSize) {
    super.init (title: "", size: inSize)
//    noteObjectAllocation (self)
//    self.translatesAutoresizingMaskIntoConstraints = false
//
//    self.controlSize = inSize.cocoaControlSize
//    self.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))
//    self.title = ""
    self.bezelStyle = .helpButton
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

//  deinit {
//    noteObjectDeallocation (self)
//  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
