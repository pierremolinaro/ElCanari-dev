//
//  ApplicationDelegate+layout-demos.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 19/08/2024.
//
//--------------------------------------------------------------------------------------------------

import Cocoa

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate var gRetainedWindows = [NSWindow] ()

//--------------------------------------------------------------------------------------------------

extension ApplicationDelegate {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func createDemosWindows () {
    self.createVerticalStackView (title: "Vertical Stack View")
    self.createHorizontalStackView (title: "Horizontal Stack View")
    self.createGridView2 (title: "Grid View")
    self.createHorizontalTableViews (title: "Table Views")
    self.createTextView (title: "Text View")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func createTextView (title inTitle : String) {
    let window = NSWindow (
      contentRect: NSRect (x: 0, y: 0, width: 200, height: 200),
      styleMask: [.titled, .resizable],
      backing: .buffered,
      defer: false
    )
    window.setFrameAutosaveName (inTitle)
    window.title = inTitle
    window.isReleasedWhenClosed = false

    let stack = AutoLayoutVerticalStackView ()
      .set (margins: .regular)
      .appendView (ALB_NSTextView (drawsBackground: true, horizontalScroller: true, verticalScroller: true, editable: true))
    window.contentView = stack
    window.makeKeyAndOrderFront (nil)
    gRetainedWindows.append (window)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func createVerticalStackView (title inTitle : String) {
    let window = NSWindow (
      contentRect: NSRect (x: 0, y: 0, width: 200, height: 200),
      styleMask: [.titled, .resizable],
      backing: .buffered,
      defer: false
    )
    window.setFrameAutosaveName (inTitle)
    window.title = inTitle
    window.isReleasedWhenClosed = false

    let stack = AutoLayoutVerticalStackView ()
      .set (margins: .regular)
      .appendFlexibleSpace ()
      .appendView (ALB_NSButton (title: "Button 0", size: .small))
      .appendFlexibleSpace ()
      .appendDivider (canResizeWindow: false)
      .appendView (ALB_NSButton (title: "Button 1", size: .regular))
      .appendFlexibleSpace ()
      .appendView (AutoLayoutHorizontalStackView ().appendView (ALB_NSButton (title: "Button 2", size: .regular)))
      .appendDivider (canResizeWindow: true)
      .appendFlexibleSpace ()
      .appendFlexibleSpace ()
      .appendView (ALB_NSButton (title: "Button 3", size: .mini))
    window.contentView = stack
    window.makeKeyAndOrderFront (nil)
    gRetainedWindows.append (window)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func createHorizontalStackView (title inTitle : String) {
    let window = NSWindow (
      contentRect: NSRect (x: 0, y: 0, width: 200, height: 200),
      styleMask: [.titled, .resizable],
      backing: .buffered,
      defer: true
    )
    window.setFrameAutosaveName (inTitle)
    window.title = inTitle
    window.isReleasedWhenClosed = false

    let stack = AutoLayoutHorizontalStackView ()
      .set (margins: .regular)
      .appendFlexibleSpace ()
      .appendView (ALB_NSButton (title: "Button 0", size: .small))
      .appendView (AutoLayoutVerticalStackView ().appendView (ALB_NSButton (title: "Button 0", size: .small)).appendFlexibleSpace ())
      .appendFlexibleSpace ()
      .appendDivider (canResizeWindow: false)
      .appendView (ALB_NSButton (title: "Button 1", size: .regular))
      .appendSeparator ()
      .appendFlexibleSpace ()
      .appendView (ALB_NSButton (title: "Button 2", size: .regular))
      .appendView (AutoLayoutHorizontalStackView ().appendView (ALB_NSButton (title: "Button 2", size: .regular)))
      .appendView (ALB_NSButton (title: "Button 2", size: .regular))
      .appendFlexibleSpace ()
      .appendDivider (canResizeWindow: true)
      .appendFlexibleSpace ()
      .appendFlexibleSpace ()
      .appendView (ALB_NSButton (title: "Button 3", size: .mini))
      .prependSeparator ()
    window.contentView = stack
    window.makeKeyAndOrderFront (nil)
    gRetainedWindows.append (window)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func createGridView2 (title inTitle : String) {
    let window = NSWindow (
      contentRect: NSRect (x: 0, y: 0, width: 200, height: 200),
      styleMask: [.titled, .resizable],
      backing: .buffered,
      defer: true
    )
    window.setFrameAutosaveName (inTitle)
    window.title = inTitle
    window.isReleasedWhenClosed = false

    let stack = AutoLayoutVerticalStackView ()
      .set (margins: .regular)
      .set (spacing: .large)
      .append (left: ALB_NSButton (title: "Button 0", size: .regular), right: ALB_NSButton (title: "Button 1", size: .regular))
//      .appendVerticalSeparator (ignoreHorizontalMargins: true)
      .append (left: ALB_NSButton (title: "Large Button 2", size: .regular), right: ALB_NSButton (title: "Button 3", size: .small))

    window.contentView = stack
    window.makeKeyAndOrderFront (nil)
    gRetainedWindows.append (window)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func createHorizontalTableViews (title inTitle : String) {
    let window = NSWindow (
      contentRect: NSRect (x: 0, y: 0, width: 200, height: 200),
      styleMask: [.titled, .resizable],
      backing: .buffered,
      defer: true
    )
    window.setFrameAutosaveName (inTitle)
    window.title = inTitle
    window.isReleasedWhenClosed = false

    let stack = AutoLayoutHorizontalStackView ()
      .set (margins: .regular)
      .appendView (AutoLayoutTableView (size: .regular, addControlButtons: true))
      .appendDivider (canResizeWindow: true)
      .appendView (AutoLayoutTableView (size: .regular, addControlButtons: false))

    window.contentView = stack
    window.makeKeyAndOrderFront (nil)
    gRetainedWindows.append (window)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
