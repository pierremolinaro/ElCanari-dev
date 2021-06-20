//
//  InternalAutoLayoutPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/06/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class InternalAutoLayoutPopUpButton : NSPopUpButton, EBUserClassNameProtocol {

  //····················································································································

  init (pullsDown inPullsDown : Bool,
        small inSmall : Bool) {
    super.init (frame: NSRect (), pullsDown: inPullsDown)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.autoenablesItems = false
    if let cell = self.cell as? NSPopUpButtonCell {
      cell.arrowPosition = .arrowAtBottom
    }

    self.controlSize = inSmall ? .small : .regular
    self.bezelStyle = autoLayoutCurrentStyle ().buttonStyle
    self.font = NSFont.systemFont (ofSize: inSmall ? NSFont.smallSystemFontSize : NSFont.systemFontSize)
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

  final func makeWidthExpandable () -> Self {
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
