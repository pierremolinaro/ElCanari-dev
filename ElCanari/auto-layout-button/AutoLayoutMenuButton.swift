//
//  AutoLayoutMenuButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutMenuButton : AutoLayoutBase_NSView {

  //····················································································································

  static var size : CGFloat { return 12.0 }
  private var mMenu : NSMenu

  //····················································································································

  init (menu inMenu : NSMenu) {
    self.mMenu = inMenu
    super.init ()

    self.setContentCompressionResistancePriority (.required, for: .horizontal)
    self.setContentCompressionResistancePriority (.required, for: .vertical)
    self.setContentHuggingPriority (.defaultLow, for: .horizontal)
    self.setContentHuggingPriority (.defaultLow, for: .vertical)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override var intrinsicContentSize : NSSize {
    return NSSize (width: AutoLayoutMenuButton.size, height: AutoLayoutMenuButton.size)
  }

  //····················································································································
  //   DRAW
  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    super.draw (inDirtyRect)
  //--- Debug
    if debugAutoLayout () {
      let bp = NSBezierPath (rect: self.bounds)
      bp.lineWidth = 1.0
      bp.lineJoinStyle = .round
      DEBUG_STROKE_COLOR.setStroke ()
      bp.stroke ()
    }
  //--- Background
    if self.mMouseWithin {
//      let x : CGFloat = 0.75
//      let myGray = NSColor (red: x, green: x, blue: x, alpha: 0.5)
//      myGray.setFill ()
//      NSColor.systemGray.setFill ()
//      NSColor.selectedContentBackgroundColor.setFill ()
//      NSColor.controlBackgroundColor.setFill ()
//      NSColor.disabledControlTextColor.setFill ()
      NSColor.selectedTextBackgroundColor.setFill  ()
      NSBezierPath.fill (self.bounds)
    }
  //---
    var path = EBBezierPath ()
    let d = AutoLayoutMenuButton.size
    path.move (to: NSPoint (x: self.bounds.minX + d / 5.0, y: self.bounds.maxY - d / 3.0))
    path.line (to: NSPoint (x: self.bounds.maxX - d / 5.0, y: self.bounds.maxY - d / 3.0))
    path.line (to: NSPoint (x: self.bounds.midX , y: self.bounds.minY + d / 3.0))
    path.close ()
    NSColor.controlTextColor.setFill ()
    path.fill ()
  }

  //····················································································································

  override func mouseDown (with inEvent : NSEvent) {
    NSMenu.popUpContextMenu (self.mMenu, with: inEvent, for: self)
  }

  //····················································································································
  //  Hilite when mouse is within button
  //····················································································································

  private var mTrackingArea : NSTrackingArea? = nil

  //····················································································································

  override func updateTrackingAreas () { // This is required for receiving mouseEntered and mouseExited events
  //--- Remove current tracking area
    if let trackingArea = self.mTrackingArea {
      self.removeTrackingArea (trackingArea)
    }
  //--- Add Updated tracking area
    let trackingArea = NSTrackingArea (
      rect: self.bounds,
      options: [.mouseEnteredAndExited /* , .mouseMoved */, .activeInKeyWindow],
      owner: self,
      userInfo: nil
    )
    self.addTrackingArea (trackingArea)
    self.mTrackingArea = trackingArea
  //---
    super.updateTrackingAreas ()
  }

  //····················································································································

  private var mMouseWithin = false {
    didSet {
      if self.mMouseWithin != oldValue {
        self.needsDisplay = true
      }
    }
  }

  //····················································································································

  override func mouseEntered (with inEvent : NSEvent) {
    self.mMouseWithin = true
    super.mouseEntered (with: inEvent)
  }

  //····················································································································

//  override func mouseMoved (with inEvent : NSEvent) {
//    self.mMouseWithin = true
//    super.mouseMoved (with: inEvent)
//  }

  //····················································································································

  override func mouseExited (with inEvent : NSEvent) {
    self.mMouseWithin = false
    super.mouseExited (with: inEvent)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
