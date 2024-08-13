//
//  Preferences_SuperClass.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/01/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor class Preferences_SuperClass : NSObject {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override init () {
    super.init ()
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final var mLibraryUpdateLogWindow : CanariWindow? = nil
  final var mLibraryUpdateLogTextView : AutoLayoutStaticTextView? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final var mLibraryConsistencyLogWindow : CanariWindow? = nil
//  final var mLibraryConsistencyLogTextView : AutoLayoutStaticTextView? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
      _ = window.setFrameAutosaveName ("LibraryUpdateLogWindowSettings")
      window.title = "Library Update Log"
      window.isReleasedWhenClosed = false
      let textView = AutoLayoutStaticTextView (drawsBackground: false, horizontalScroller: true, verticalScroller: true)
        .expandableWidth ()
        .expandableHeight ()
      self.mLibraryUpdateLogTextView = textView
      window.contentView = textView
      return window
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mCheckingForLibraryUpdateWindow : CanariWindow? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
      _ = window.setFrameAutosaveName ("CheckForLibraryUpdatesWindowSettings")
      window.title = "Checking for Library Updates…"
      window.isReleasedWhenClosed = false

      let contents = AutoLayoutVerticalStackView ()
      _ = contents.appendFlexibleSpace ()
      let hStack = AutoLayoutHorizontalStackView ()
      _ = hStack.appendFlexibleSpace ()
      _ = hStack.appendView (AutoLayoutSpinningProgressIndicator (size: .regular))
      _ = hStack.appendFlexibleSpace ()
      _ = contents.appendView (hStack)
      _ = contents.appendFlexibleSpace ()

      window.contentView = contents
    }
    window.makeKeyAndOrderFront (nil)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func hideCheckingForLibraryUpdateWindow () {
    self.mCheckingForLibraryUpdateWindow?.orderOut (nil)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
