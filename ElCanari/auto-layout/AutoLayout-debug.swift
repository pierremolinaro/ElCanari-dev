//
//  AutoLayout--debug.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let DEBUG_FLEXIBLE_SPACE_FILL_COLOR       = NSColor.systemGreen.withAlphaComponent (0.25)
let DEBUG_HORIZONTAL_SEPARATOR_FILL_COLOR = NSColor.systemPurple.withAlphaComponent (0.5)
let DEBUG_VERTICAL_SEPARATOR_FILL_COLOR   = NSColor.systemPink.withAlphaComponent (0.25)
let DEBUG_KEY_CHAIN_STROKE_COLOR          = NSColor.systemBrown
let DEBUG_STROKE_COLOR                    = NSColor.systemOrange

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Public functions
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func appendDebugAutoLayoutMenuItem (_ inMenu : NSMenu) {
  inMenu.addItem (gDebugAutoLayout.menuItem)
  inMenu.addItem (gDebugAutoLayout.responderKeyChainItem)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func debugAutoLayout () -> Bool {
  return gDebugAutoLayout.mDebugAutoLayout
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func showKeyResponderChain () -> Bool {
  return gDebugAutoLayout.mShowKeyResponderChain
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Private entities
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate var gDebugAutoLayout = DebugAutoLayout ()

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class DebugAutoLayout : EBSwiftBaseObject {

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
    action: #selector (Self.toggleShowKeyResponserChain (_:)),
    keyEquivalent: ""
  )

  //····················································································································
  //  Init
  //····················································································································

  override init () {
    super.init ()
    self.menuItem.target = self
    self.responderKeyChainItem.target = self
  }

  //····················································································································

  @objc func toggleDebugAutoLayout (_ inSender : Any?) {
    self.mDebugAutoLayout.toggle ()
    self.menuItem.state = self.mDebugAutoLayout ? .on : .off
    for window in NSApp.windows {
      if let mainView = window.contentView {
        self.propagateNeedsDisplay (mainView)
      }
    }
  }

  //····················································································································
  //····················································································································

  @objc func toggleShowKeyResponserChain (_ inSender : Any?) {
    self.mShowKeyResponderChain.toggle ()
    self.responderKeyChainItem.state = self.mShowKeyResponderChain ? .on : .off
    for window in NSApp.windows {
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
