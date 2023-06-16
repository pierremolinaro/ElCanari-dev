//
//  AutoLayout--debug.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let DEBUG_FLEXIBLE_SPACE_FILL_COLOR       = NSColor.systemGreen.withAlphaComponent (0.25)
let DEBUG_HORIZONTAL_SEPARATOR_FILL_COLOR = NSColor.systemPurple.withAlphaComponent (0.5)
let DEBUG_VERTICAL_SEPARATOR_FILL_COLOR   = NSColor.systemPink.withAlphaComponent (0.25)
let DEBUG_KEY_CHAIN_STROKE_COLOR          = NSColor.systemBrown
let DEBUG_STROKE_COLOR                    = NSColor.systemOrange
//let DEBUG_FILL_COLOR                      = NSColor.systemGray.withAlphaComponent (0.07)

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Public functions
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func appendDebugAutoLayoutMenuItem (_ inMenu : NSMenu) {
  inMenu.addItem (gDebugAutoLayout.menuItem)
  inMenu.addItem (gDebugAutoLayout.responderKeyChainItem)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func debugAutoLayout () -> Bool {
  return gDebugAutoLayout.mDebugAutoLayout
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func showKeyResponderChain () -> Bool {
  return gDebugAutoLayout.mShowKeyResponderChain
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Private entities
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor fileprivate var gDebugAutoLayout = DebugAutoLayout ()

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor fileprivate final class DebugAutoLayout {

  //····················································································································
  //  Properties
  //····················································································································

  var mDebugAutoLayout = false

  let menuItem = NSMenuItem (
    title: "Debug Auto Layout",
    action: #selector (Self.toggleDebugAutoLayout (_:)),
    keyEquivalent: ""
  )

  //····················································································································

  var mShowKeyResponderChain = false

  let responderKeyChainItem = NSMenuItem (
    title: "Show Responder Key Chain",
    action: #selector (Self.toggleShowKeyResponderChain (_:)),
    keyEquivalent: ""
  )

  //····················································································································
  //  Init
  //····················································································································

  init () {
    self.menuItem.target = self
    self.responderKeyChainItem.target = self
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  @objc func toggleDebugAutoLayout (_ _ : Any?) {
    self.mDebugAutoLayout.toggle ()
    self.menuItem.state = self.mDebugAutoLayout ? .on : .off
    for window in NSApplication.shared.windows {
      if let mainView = window.contentView {
        self.propagateNeedsDisplay (mainView)
      }
    }
  }

  //····················································································································

  @objc func toggleShowKeyResponderChain (_ _ : Any?) {
    self.mShowKeyResponderChain.toggle ()
    self.responderKeyChainItem.state = self.mShowKeyResponderChain ? .on : .off
    for window in NSApplication.shared.windows {
      if let mainView = window.contentView {
        self.propagateNeedsDisplay (mainView)
      }
    }
  }

  //····················································································································

  fileprivate final func propagateNeedsDisplay (_ inView : NSView) {
    inView.needsDisplay = true
    for view in inView.subviews {
      self.propagateNeedsDisplay (view)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
