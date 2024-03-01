//
//  Preferences+buildLibraryCheckLogView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/06/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension Preferences {

  //································································································

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
      let button = AutoLayoutButton (title: "Check Library", size: .regular)
        .expandableWidth ()
      button.setClosureAction {
        checkLibrary (windowForSheet: window, logWindow: window)
      }
    //---------- Tab View
      let label = AutoLayoutStaticLabel (
        title: "The check has not yet been run",
        bold: true,
        size: .regular,
        alignment: .center
      ).expandableWidth ().expandableHeight ()
      window.contentView = AutoLayoutVerticalStackView ().set (margins: 12).appendView (button).appendView (label)
      self.mLibraryConsistencyLogWindow = window
      _ = window.setFrameAutosaveName ("LibraryConsistencyLogWindowSettings")
      window.title = "Library Consistency Log"
      window.isReleasedWhenClosed = false
    }
    return window
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
