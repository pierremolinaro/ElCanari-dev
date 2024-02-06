//
//  AutoLayoutSheetCancelButton.swift
//
//  Created by Pierre Molinaro on 16/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
// Key equivalent should be "escape" ("\u{1b}" in Swift)
//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutSheetCancelButton : NSButton {

  //····················································································································

  init (title inTitle : String, size inSize : EBControlSize) {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.setButtonType (.momentaryPushIn)
    self.bezelStyle = .rounded
    self.title = inTitle
    self.controlSize = inSize.cocoaControlSize
    self.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))

    self.target = self
    self.action = #selector (Self.dismissSheetAction (_:))
    self.keyEquivalent = "\u{1b}"
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
    if let mySheet = self.window {
      mySheet.endEditing (for: nil)
      if let parent = mySheet.sheetParent {
        parent.endSheet (mySheet, returnCode: .cancel)
      }else{
        NSApplication.shared.abortModal ()
        self.window?.orderOut (nil)
      }
    }
  }


  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
