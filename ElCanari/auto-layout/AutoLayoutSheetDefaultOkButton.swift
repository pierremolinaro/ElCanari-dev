//
//  AutoLayoutSheetDefaultOkButton.swift
//
//  Created by Pierre Molinaro on 16/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutSheetDefaultOkButton : NSButton, EBUserClassNameProtocol {

  //····················································································································

  init (title inTitle : String, small inSmall : Bool, sheet inPanel : NSPanel) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.setButtonType (.momentaryPushIn)
    self.bezelStyle = .rounded
    self.title = inTitle
    self.controlSize = inSmall ? .small : .regular
    self.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))
    if let cell = self.cell as? NSButtonCell {
      inPanel.defaultButtonCell = cell
    }
    self.target = self
    self.action = #selector (Self.dismissSheetAction (_:))
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

  @objc func dismissSheetAction (_ sender : Any?) {
    if let mySheet = self.window, let parent = mySheet.sheetParent {
      mySheet.endEditing (for: nil)
      parent.endSheet (mySheet, returnCode: .stop)
    }
  }


  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
