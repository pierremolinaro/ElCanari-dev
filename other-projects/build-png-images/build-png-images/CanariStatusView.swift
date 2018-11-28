//
//  CanariStatusView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/11/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// https://stackoverflow.com/questions/5008213/adding-a-custom-view-to-toolbar

@objc(CanariStatusView) class CanariStatusView : NSView {

  //····················································································································

  override var isFlipped: Bool { return false }

  var mDrawGreen = false
  var mDrawOrange = false
  var mDrawRed = false

  //····················································································································
  //  Draw
  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
//    NSColor.blue.setFill ()
//    __NSRectFill (inDirtyRect)
    let s = min (self.frame.size.width / 4.0, self.frame.size.height / 10.0)
    let centerX = self.bounds.midX
    var r = NSRect (
      x: centerX - 2.0 * s,
      y: 0.0,
      width: 4.0 * s,
      height: 10.0 * s
    )
    var bp = NSBezierPath (roundedRect: r, xRadius: s * 2.0, yRadius: s * 2.0)
    NSColor.gridColor.setFill ()
    bp.fill ()
  //--- Green
    if self.mDrawGreen {
      r = NSRect (
        x: centerX - s,
        y: s,
        width: 2.0 * s,
        height: 2.0 * s
      )
      bp = NSBezierPath (ovalIn: r)
      NSColor.green.setFill ()
      bp.fill ()
    }
  //--- Orange
    if self.mDrawOrange {
      r = NSRect (
        x: centerX - s,
        y: 4.0 * s,
        width: 2.0 * s,
        height: 2.0 * s
      )
      bp = NSBezierPath (ovalIn: r)
      NSColor.orange.setFill ()
      bp.fill ()
    }
  //--- Red
    if self.mDrawRed {
      r = NSRect (
        x: centerX - s,
        y: 7.0 * s,
        width: 2.0 * s,
        height: 2.0 * s
      )
      bp = NSBezierPath (ovalIn: r)
      NSColor.red.setFill ()
      bp.fill ()
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
