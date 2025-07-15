//
//  AutoLayout--debug.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/02/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   Public functions
//--------------------------------------------------------------------------------------------------

@MainActor func appendDebugAutoLayoutMenuItem (_ inMenu : NSMenu) {
  inMenu.addItem (gDebugAutoLayout.mDebugMenuItem)
  inMenu.addItem (gDebugAutoLayout.responderKeyChainItem)
  inMenu.addItem (gDebugAutoLayout.showViewCurrentValuesItem)
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

  let mDebugMenuItem = NSMenuItem (
    title: "Debug Auto Layout",
    action: #selector (Self.toggleDebugAutoLayout (_:)),
    keyEquivalent: ""
  )

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate let responderKeyChainItem = NSMenuItem (
    title: "Show Responder Key Chain",
    action: #selector (Self.toggleShowKeyResponderChain (_:)),
    keyEquivalent: ""
  )

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate let showViewCurrentValuesItem = NSMenuItem (
    title: "Show View Current Settings",
    action: #selector (Self.toggleViewCurrentValues (_:)),
    keyEquivalent: ""
  )

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    self.mDebugMenuItem.target = self
    self.mDebugMenuItem.state = getDebugAutoLayout () ? .on : .off
    self.responderKeyChainItem.target = self
    self.responderKeyChainItem.state = getDebugResponderChain () ? .on : .off
    self.showViewCurrentValuesItem.target = self
    self.showViewCurrentValuesItem.state = getShowViewCurrentSettings () ? .on : .off
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func toggleDebugAutoLayout (_ /* inUnusedSender */ : Any?) {
    setDebugAutoLayout (!getDebugAutoLayout ())
    self.mDebugMenuItem.state = getDebugAutoLayout () ? .on : .off
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func toggleShowKeyResponderChain (_ /* inUnusedSender */ : Any?) {
    setDebugResponderChain (!getDebugResponderChain ())
    self.responderKeyChainItem.state = getDebugResponderChain () ? .on : .off
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func toggleViewCurrentValues (_ /* inUnusedSender */ : Any?) {
    setShowViewCurrentSettings (!getShowViewCurrentSettings ())
    self.showViewCurrentValuesItem.state = getShowViewCurrentSettings () ? .on : .off
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
