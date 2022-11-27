//
//  Preferences+buildLibraryCheckLogView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/06/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Preferences {

  //····················································································································

  func buildLibraryConsistencyLogWindow () -> NSWindow {
    let window : CanariWindow
    if let w = self.mLibraryConsistencyLogWindow {
      window = w
    }else{
      window = CanariWindow (
        contentRect: NSRect (x: 0, y: 0, width: 500, height: 400),
        styleMask: [.closable, .resizable, .titled],
        backing: .buffered,
        defer: false
      )
      self.mLibraryConsistencyLogWindow = window
      _ = window.setFrameAutosaveName ("LibraryConsistencyLogWindowSettings")
      window.title = "Library Consistency Log"
      window.isReleasedWhenClosed = false
      let textView = AutoLayoutStaticTextView (drawsBackground: false, horizontalScroller: true, verticalScroller: true)
        .expandableWidth ()
        .expandableHeight ()
      self.mLibraryConsistencyLogTextView = textView
      window.contentView = textView
    }
    return window
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
