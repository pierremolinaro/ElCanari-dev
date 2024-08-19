//
//  AutoLayout--debug.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/02/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

let DEBUG_FLEXIBLE_SPACE_FILL_COLOR       = NSColor.systemGreen.withAlphaComponent (0.25)
let DEBUG_HORIZONTAL_SEPARATOR_FILL_COLOR = NSColor.systemPurple.withAlphaComponent (0.5)
let DEBUG_VERTICAL_SEPARATOR_FILL_COLOR   = NSColor.systemPink.withAlphaComponent (0.25)
let DEBUG_KEY_CHAIN_STROKE_COLOR          = NSColor.black
let DEBUG_STROKE_COLOR                    = NSColor.systemOrange

fileprivate let DEBUG_AUTOLAYOUT_PREFERENCES_KEY = "debug.autolayout"

//--------------------------------------------------------------------------------------------------
//   Public functions
//--------------------------------------------------------------------------------------------------

@MainActor func appendDebugAutoLayoutMenuItem (_ inMenu : NSMenu) {
  inMenu.addItem (gDebugAutoLayout.menuItem)
  inMenu.addItem (gDebugAutoLayout.responderKeyChainItem)
  inMenu.addItem (gDebugAutoLayout.showViewCurrentValuesItem)
}

//--------------------------------------------------------------------------------------------------

@MainActor func debugAutoLayout () -> Bool {
  return gDebugAutoLayout.mDebugAutoLayout
}

//--------------------------------------------------------------------------------------------------

@MainActor func showKeyResponderChain () -> Bool {
  return gDebugAutoLayout.mShowKeyResponderChain
}

//--------------------------------------------------------------------------------------------------

@MainActor func showViewCurrentValues () -> Bool {
  return gDebugAutoLayout.mShowViewCurrentValues
}

//--------------------------------------------------------------------------------------------------
//   Private entities
//--------------------------------------------------------------------------------------------------

@MainActor fileprivate var gDebugAutoLayout = DebugAutoLayout ()

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate final class DebugAutoLayout {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var mDebugAutoLayout = UserDefaults.standard.bool (forKey: DEBUG_AUTOLAYOUT_PREFERENCES_KEY)

  let menuItem = NSMenuItem (
    title: "Debug Auto Layout",
    action: #selector (Self.toggleDebugAutoLayout (_:)),
    keyEquivalent: ""
  )

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private(set) var mShowKeyResponderChain = false

  fileprivate let responderKeyChainItem = NSMenuItem (
    title: "Show Responder Key Chain",
    action: #selector (Self.toggleShowKeyResponderChain (_:)),
    keyEquivalent: ""
  )

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private(set) var mShowViewCurrentValues = false

  fileprivate let showViewCurrentValuesItem = NSMenuItem (
    title: "Show View Current Settings",
    action: #selector (Self.toggleViewCurrentValues (_:)),
    keyEquivalent: ""
  )

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    self.menuItem.target = self
    self.responderKeyChainItem.target = self
    self.showViewCurrentValuesItem.target = self
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func toggleDebugAutoLayout (_ inUnusedSender : Any?) {
    self.mDebugAutoLayout.toggle ()
    UserDefaults.standard.setValue (self.mDebugAutoLayout, forKey: DEBUG_AUTOLAYOUT_PREFERENCES_KEY)
    self.menuItem.state = self.mDebugAutoLayout ? .on : .off
    for window in NSApplication.shared.windows {
      if let mainView = window.contentView {
        self.propagateNeedsDisplay (mainView)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func toggleShowKeyResponderChain (_ _ : Any?) {
    self.mShowKeyResponderChain.toggle ()
    self.responderKeyChainItem.state = self.mShowKeyResponderChain ? .on : .off
    for window in NSApplication.shared.windows {
      if let mainView = window.contentView {
        self.propagateNeedsDisplay (mainView)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func toggleViewCurrentValues (_ _ : Any?) {
    self.mShowViewCurrentValues.toggle ()
    self.showViewCurrentValuesItem.state = self.mShowViewCurrentValues ? .on : .off
    for window in NSApplication.shared.windows {
      if let mainView = window.contentView as? AutoLayoutWindowContentView {
        mainView.set (displayViewCurrentSettings: self.mShowViewCurrentValues)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate final func propagateNeedsDisplay (_ inView : NSView) {
    inView.needsDisplay = true
    for view in inView.subviews {
      self.propagateNeedsDisplay (view)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
