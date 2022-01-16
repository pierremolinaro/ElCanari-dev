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

  init (title inTitle : String,
        size inSize : EBControlSize,
        sheet inPanel : NSPanel,
        isInitialFirstResponder inInitialFirstResponder : Bool) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.setButtonType (.momentaryPushIn)
    self.bezelStyle = .rounded
    self.title = inTitle
    self.controlSize = inSize.cocoaControlSize
    self.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))
    if let buttonCell = self.cell as? NSButtonCell {
      inPanel.defaultButtonCell = buttonCell
    }
    if inInitialFirstResponder {
      inPanel.initialFirstResponder = self
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
    if let mySheet = self.window {
      mySheet.endEditing (for: nil)
      if let parent = mySheet.sheetParent {
        parent.endSheet (mySheet, returnCode: .stop)
      }else{
        NSApp.stopModal ()
        self.window?.orderOut (nil)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
