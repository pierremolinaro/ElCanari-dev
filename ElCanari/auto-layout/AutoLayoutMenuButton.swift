//
//  AutoLayoutMenuButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//fileprivate let PULL_DOWN_ARROW_SIZE : CGFloat = 8.0
//fileprivate let PULL_DOWN_ARROW_TOP_MARGIN : CGFloat = 4.0

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutMenuButton : AutoLayoutBase_NSView {

  //····················································································································

  static var size : CGFloat { return 12.0 }
  private var mMenu : NSMenu

  //····················································································································

  init (size inSize : EBControlSize, menu inMenu : NSMenu) {
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
      let x : CGFloat = 0.75
      let myGray = NSColor (red: x, green: x, blue: x, alpha: 0.5)
      myGray.setFill ()
      NSBezierPath.fill (self.bounds)
    }
  //---
    var path = EBBezierPath ()
    let d = AutoLayoutMenuButton.size
    path.move (to: NSPoint (x: self.bounds.minX + d / 5.0, y: self.bounds.maxY - d / 3.0))
    path.line (to: NSPoint (x: self.bounds.maxX - d / 5.0, y: self.bounds.maxY - d / 3.0))
    path.line (to: NSPoint (x: self.bounds.midX , y: self.bounds.minY + d / 3.0))
    path.close ()
    NSColor.systemBrown.setFill ()
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
      options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow],
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

  override func mouseMoved (with inEvent : NSEvent) {
    self.mMouseWithin = true
    super.mouseMoved (with: inEvent)
  }

  //····················································································································

  override func mouseExited (with inEvent : NSEvent) {
    self.mMouseWithin = false
    super.mouseExited (with: inEvent)
  }

  //····················································································································
  //   DRAW
  //····················································································································

//  override func draw (_ inDirtyRect : NSRect) {
//    super.draw (inDirtyRect)
//    if debugAutoLayout () {
//      let bp = NSBezierPath (rect: self.bounds)
//      bp.lineWidth = 1.0
//      bp.lineJoinStyle = .round
//      DEBUG_STROKE_COLOR.setStroke ()
//      bp.stroke ()
//    }
//    NSColor.white.setFill ()
//    NSBezierPath.fill (self.pullDownRightMenuRect ())
//    NSBezierPath.fill (self.pullDownLeftMenuRect ())
//    let x : CGFloat = 0.75
//    let myGray = NSColor (red: x, green: x, blue: x, alpha: 0.5)
//    myGray.setFill ()
//    switch self.mMouseZone {
//    case .outside :
//      ()
//    case .insideRightPullDown :
//      NSBezierPath.fill (self.pullDownRightMenuRect ())
//    case .insideLeftPullDown :
//      NSBezierPath.fill (self.pullDownLeftMenuRect ())
//    case .insideDrag :
//      let bp = NSBezierPath ()
//      let b = self.bounds
//      bp.move (to: NSPoint (x: b.minX, y: b.maxY))
//      let v = PULL_DOWN_ARROW_TOP_MARGIN + PULL_DOWN_ARROW_SIZE / 2.0
//      if self.mLeftContextualMenu != nil, self.mRightContextualMenu != nil {
//        bp.line (to: NSPoint (x: b.minX, y: b.minY + v))
//        bp.line (to: NSPoint (x: b.maxX, y: b.minY + v))
//      }else if self.mLeftContextualMenu != nil { // Only left contextual menu
//        bp.line (to: NSPoint (x: b.minX, y: b.minY + v))
//        bp.line (to: NSPoint (x: b.midX, y: b.minY + v))
//        bp.line (to: NSPoint (x: b.midX, y: b.minY))
//        bp.line (to: NSPoint (x: b.maxX, y: b.minY))
//      }else if self.mRightContextualMenu != nil { // Only right contextual menu
//        bp.line (to: NSPoint (x: b.minX, y: b.minY))
//        bp.line (to: NSPoint (x: b.midX, y: b.minY))
//        bp.line (to: NSPoint (x: b.midX, y: b.minY + v))
//        bp.line (to: NSPoint (x: b.maxX, y: b.minY + v))
//      }else{ // No contextual menu
//        bp.line (to: NSPoint (x: b.minX, y: b.minY))
//        bp.line (to: NSPoint (x: b.maxX, y: b.minY))
//      }
//      bp.line (to: NSPoint (x: b.maxX, y: b.maxY))
//      bp.close ()
//      bp.fill ()
//    }
//    if self.mRightContextualMenu != nil {
//      var path = EBBezierPath ()
//      path.move (to: NSPoint (x: self.bounds.maxX - PULL_DOWN_ARROW_SIZE, y: self.bounds.minY + PULL_DOWN_ARROW_SIZE / 2.0))
//      path.line (to: NSPoint (x: self.bounds.maxX, y: self.bounds.minY + PULL_DOWN_ARROW_SIZE / 2.0))
//      path.line (to: NSPoint (x: self.bounds.maxX - PULL_DOWN_ARROW_SIZE / 2.0, y: self.bounds.minY))
//      path.close ()
//      NSColor.black.setFill ()
//      path.fill ()
//    }
//    if self.mLeftContextualMenu != nil {
//      var path = EBBezierPath ()
//      path.move (to: NSPoint (x: 0.0, y: self.bounds.minY + PULL_DOWN_ARROW_SIZE / 2.0))
//      path.line (to: NSPoint (x: PULL_DOWN_ARROW_SIZE, y: self.bounds.minY + PULL_DOWN_ARROW_SIZE / 2.0))
//      path.line (to: NSPoint (x: PULL_DOWN_ARROW_SIZE / 2.0, y: self.bounds.minY))
//      path.close ()
//      NSColor.black.setFill ()
//      path.fill ()
//    }
//  }
  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
