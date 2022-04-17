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
        sheet inPanel : NSPanel) {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.setButtonType (.momentaryPushIn)
    self.bezelStyle = .rounded
    self.title = inTitle
    self.controlSize = inSize.cocoaControlSize
    self.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))
    if let buttonCell = self.cell as? NSButtonCell {
      DispatchQueue.main.async { inPanel.defaultButtonCell = buttonCell }
    }
//    if inInitialFirstResponder {
//      DispatchQueue.main.async { inPanel.initialFirstResponder = self }
//    }
    self.keyEquivalent = "\u{0D}"
    self.keyEquivalentModifierMask = .control

    _ = self.setDismissAction ()
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

//  override var acceptsFirstResponder : Bool { return true }

  //····················································································································

  func setDismissAction () -> Self {
    self.target = self
    self.action = #selector (Self.dismissSheetAction (_:))
    return self
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
