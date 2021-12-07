//
//  AutoLayout--debug.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let DEBUG_FLEXIBLE_SPACE_FILL_COLOR = NSColor.systemGreen.withAlphaComponent (0.25)
let DEBUG_HORIZONTAL_SEPARATOR_FILL_COLOR = NSColor.systemPurple.withAlphaComponent (0.5)
let DEBUG_VERTICAL_SEPARATOR_FILL_COLOR   = NSColor.systemPink.withAlphaComponent (0.25)
let DEBUG_STROKE_COLOR = NSColor.orange

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Public functions
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func appendDebugAutoLayoutMenuItem (_ inMenu : NSMenu) {
  inMenu.addItem (gDebugAutoLayout.menuItem)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func debugAutoLayout () -> Bool {
  return gDebugAutoLayout.debugAutoLayout
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

  var debugAutoLayout = false
  let menuItem = NSMenuItem (
    title: "Debug Auto Layout",
    action: #selector (Self.toggleDebugAutoLayout (_:)),
    keyEquivalent: ""
  )

  //····················································································································
  //  Init
  //····················································································································

  override init () {
    super.init ()
    menuItem.target = self
  }

  //····················································································································

  @objc func toggleDebugAutoLayout (_ inSender : Any?) {
    self.debugAutoLayout.toggle ()
    self.menuItem.state = self.debugAutoLayout ? .on : .off
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
