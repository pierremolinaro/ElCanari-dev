//
//  AutoLayoutSheetDefaultOkButton.swift
//
//  Created by Pierre Molinaro on 16/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————


import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutSheetDefaultOkButton : ALB_NSButton {

  //································································································

  private var mEventMonitor : Any? = nil // For tracking option key change

  //································································································

  init (title inTitle : String,
        size inSize : EBControlSize,
        sheet inPanel : NSPanel) {
    super.init (title: inTitle, size: inSize.cocoaControlSize)
//    noteObjectAllocation (self)
//    self.translatesAutoresizingMaskIntoConstraints = false

    self.setButtonType (.momentaryPushIn)
    self.bezelStyle = .rounded
    self.title = inTitle
    self.controlSize = inSize.cocoaControlSize
    self.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))
    if let buttonCell = self.cell as? NSButtonCell {
      DispatchQueue.main.async { inPanel.defaultButtonCell = buttonCell }
    }

    _ = self.setDismissAction ()

    self.mEventMonitor = NSEvent.addLocalMonitorForEvents (matching: .keyDown) {  [weak self] inEvent in
      if let me = self, let myWindow = me.window, myWindow.isVisible, let characters = inEvent.characters, characters.contains ("\u{0D}") {
        DispatchQueue.main.async { if me.isEnabled { me.dismissSheetAction (nil) } }
      }
      return inEvent
    }
  }

  //································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //································································································

//  deinit {
//    noteObjectDeallocation (self)
//  }

  //································································································

  func setDismissAction () -> Self {
    self.target = self
    self.action = #selector (Self.dismissSheetAction (_:))
    return self
  }

  //································································································

  @objc func dismissSheetAction (_ sender : Any?) {
    if let mySheet = self.window {
      mySheet.endEditing (for: nil)
      if let parent = mySheet.sheetParent {
        parent.endSheet (mySheet, returnCode: .stop)
      }else{
        NSApplication.shared.stopModal ()
        self.window?.orderOut (nil)
      }
    }
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
