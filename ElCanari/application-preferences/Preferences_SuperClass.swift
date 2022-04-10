//
//  Preferences_SuperClass.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/01/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class Preferences_SuperClass : EBObjcBaseObject {

  //····················································································································

  var mLibraryUpdateLogWindow : CanariWindow? = nil
  var mLibraryUpdateLogTextView : AutoLayoutStaticTextView? = nil

  //····················································································································

  var mLibraryConsistencyLogWindow : CanariWindow? = nil
  var mLibraryConsistencyLogTextView : AutoLayoutStaticTextView? = nil

  //····················································································································

  final func setUpLibraryUpdateLogWindow () -> CanariWindow {
    if let window = self.mLibraryUpdateLogWindow {
      return window
    }else{
      let window = CanariWindow (
        contentRect: NSRect (x: 0, y: 0, width: 500, height: 400),
        styleMask: [.closable, .resizable, .titled],
        backing: .buffered,
        defer: false
      )
      self.mLibraryUpdateLogWindow = window
      window.setFrameAutosaveName ("LibraryUpdateLogWindowSettings")
      window.title = "Library Update Log"
      window.isReleasedWhenClosed = false
      let textView = AutoLayoutStaticTextView (string: "")
        .expandableWidth ()
        .expandableHeight ()
        .setScroller (horizontal: true, vertical: true)

      self.mLibraryUpdateLogTextView = textView
      window.contentView = textView
//      window.contentView = AutoLayoutWindowContentView (view: textView)
      return window
    }
  }

  //····················································································································

  private var mCheckingForLibraryUpdateWindow : CanariWindow? = nil

  //····················································································································

  final func showCheckingForLibraryUpdateWindow () {
    let window : CanariWindow
    if let w = self.mCheckingForLibraryUpdateWindow {
      window = w
    }else{
      window = CanariWindow (
        contentRect: NSRect (x: 0, y: 0, width: 250, height: 100),
        styleMask: [.titled],
        backing: .buffered,
        defer: false
      )
      self.mCheckingForLibraryUpdateWindow = window
      window.setFrameAutosaveName ("CheckForLibraryUpdatesWindowSettings")
      window.title = "Checking for Library Updates…"
      window.isReleasedWhenClosed = false

      let contents = AutoLayoutVerticalStackView ()
      contents.appendFlexibleSpace ()
      let hStack = AutoLayoutHorizontalStackView ()
      hStack.appendFlexibleSpace ()
      hStack.appendView (AutoLayoutSpinningProgressIndicator (size: .regular))
      hStack.appendFlexibleSpace ()
      contents.appendView (hStack)
      contents.appendFlexibleSpace ()

      window.contentView = contents
    }
    window.makeKeyAndOrderFront (nil)
  }

  //····················································································································

  final func hideCheckingForLibraryUpdateWindow () {
    self.mCheckingForLibraryUpdateWindow?.orderOut (nil)
  }

  //····················································································································

  final func showUpToDateAlertSheetForLibraryUpdateWindow () {
    if let window = self.mCheckingForLibraryUpdateWindow {
      let alert = NSAlert ()
      alert.messageText = "The library is up to date"
      alert.beginSheetModal (
        for: window,
        completionHandler: { (response : NSApplication.ModalResponse) in window.orderOut (nil) }
      )
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
