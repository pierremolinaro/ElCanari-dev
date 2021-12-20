//
//  AutoLayoutBasePopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutBasePopUpButton : NSPopUpButton, EBUserClassNameProtocol {

  //····················································································································

  init (pullsDown inPullsDown : Bool, size inSize : EBControlSize) {
    super.init (frame: NSRect (), pullsDown: inPullsDown)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.autoenablesItems = false
    if let cell = self.cell as? NSPopUpButtonCell {
      cell.arrowPosition = .arrowAtBottom
    }

    self.controlSize = inSize.cocoaControlSize
    self.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))
    self.bezelStyle = autoLayoutCurrentStyle ().buttonStyle
  }

  //····················································································································

  required init?(coder inCoder: NSCoder) {
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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
