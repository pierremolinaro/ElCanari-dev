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

@objc(CanariStatusView) class CanariStatusView : NSButton, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override var isFlipped: Bool { return false }

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
    r = NSRect (
      x: centerX - s,
      y: s,
      width: 2.0 * s,
      height: 2.0 * s
    )
    bp = NSBezierPath (ovalIn: r)
    NSColor.green.setFill ()
    bp.fill ()
  //--- Orange
    r = NSRect (
      x: centerX - s,
      y: 4.0 * s,
      width: 2.0 * s,
      height: 2.0 * s
    )
    bp = NSBezierPath (ovalIn: r)
    NSColor.orange.setFill ()
    bp.fill ()
  //--- Green
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

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
