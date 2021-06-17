//
//  AutoLayout--debug.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/02/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

let BUTTON_STYLE = NSButton.BezelStyle.rounded
let SEGMENTED_CONTROL_STYLE = NSSegmentedControl.Style.rounded

//let BUTTON_STYLE = NSButton.BezelStyle.roundRect
//let SEGMENTED_CONTROL_STYLE = NSSegmentedControl.Style.roundRect

//----------------------------------------------------------------------------------------------------------------------

let DEBUG_FILL_COLOR = NSColor.gray.withAlphaComponent (0.05)
let DEBUG_STROKE_COLOR = NSColor.orange

//----------------------------------------------------------------------------------------------------------------------
//   Public functions
//----------------------------------------------------------------------------------------------------------------------

func appendDebugAutoLayoutMenuItem (_ inMenu : NSMenu) {
  inMenu.addItem (gDebugAutoLayout.menuItem)
}

//----------------------------------------------------------------------------------------------------------------------

func debugAutoLayout () -> Bool {
  return gDebugAutoLayout.debugAutoLayout
}

//----------------------------------------------------------------------------------------------------------------------
//   Private entities
//----------------------------------------------------------------------------------------------------------------------

fileprivate var gDebugAutoLayout = DebugAutoLayout ()

//----------------------------------------------------------------------------------------------------------------------

fileprivate final class DebugAutoLayout : EBObject {

  //····················································································································
  //  Properties
  //····················································································································

  var debugAutoLayout = false
  let menuItem = NSMenuItem (
    title: "Debug Auto Layout",
    action: #selector (DebugAutoLayout.toggleDebugAutoLayout (_:)),
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

//----------------------------------------------------------------------------------------------------------------------
