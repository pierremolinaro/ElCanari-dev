//
//  AutoLayoutVerticalStackView-horizontal-divider.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/10/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutVerticalStackView {

  //····················································································································

  final func appendHorizontalDivider () -> Self {
    let divider = Self.HorizontalDivider ()
    _ = self.appendView (divider)
    return self
  }

  //····················································································································
  // HorizontalDivider internal class
  //····················································································································

   final class HorizontalDivider : AutoLayoutBase_NSView {

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override init () {
      super.init ()
      self.setContentCompressionResistancePriority (.defaultLow, for: .horizontal)
      self.setContentHuggingPriority (.defaultLow, for: .horizontal)
      self.setContentCompressionResistancePriority (.required, for: .vertical)
      self.setContentHuggingPriority (.required, for: .vertical)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    required init? (coder inCoder : NSCoder) {
      fatalError ("init(coder:) has not been implemented")
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var intrinsicContentSize : NSSize { return NSSize (width: 0.0, height: 10.0) }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func draw (_ inDirtyRect : NSRect) {
      let s : CGFloat = 6.0
      let r = NSRect (x: NSMidX (self.bounds) - s / 2.0, y: NSMidY (self.bounds) - s / 2.0, width: s, height: s)
      NSColor.separatorColor.setFill ()
      let bp = NSBezierPath (ovalIn: r)
      bp.fill ()
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
    //   Mouse
    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    private var mDividerConstraint : NSLayoutConstraint? = nil
    private var mMouseDownDy : CGFloat = 0.0

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseDown (with inEvent: NSEvent) {
      if let vStack = self.superview as? AutoLayoutVerticalStackView {
        let p1 = vStack.convert (inEvent.locationInWindow, from: nil)
        let p2 = vStack.convert (NSPoint (), from: self)
        self.mMouseDownDy = p1.y - p2.y
        //Swift.print ("dy \(dy)")
      }
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseDragged (with inEvent: NSEvent) {
      if let vStack = self.superview as? AutoLayoutVerticalStackView {
        if let c = self.mDividerConstraint {
          vStack.removeConstraint (c)
        }
        let p = vStack.convert (inEvent.locationInWindow, from: nil)
        let c = NSLayoutConstraint (
          item: self,
          attribute: .bottom,
          relatedBy: .equal,
          toItem: vStack,
          attribute: .bottom,
          multiplier: 1.0,
          constant: self.mMouseDownDy - p.y
        )
        c.priority = NSLayoutConstraint.Priority.dragThatCannotResizeWindow
        self.mDividerConstraint = c
        vStack.addConstraint (c)
        self.needsUpdateConstraints = true
      }
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseUp (with inEvent: NSEvent) {
      NSCursor.arrow.set ()
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

     override func updateConstraints () {
       super.updateConstraints ()
       DispatchQueue.main.async { self.updateCursor () }
     }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
    // Mouse moved events, cursor display
    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    var mTrackingArea : NSTrackingArea? = nil

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    final override func updateTrackingAreas () { // This is required for receiving mouse moved and mouseExited events
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

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    private func updateCursor () {
      if self.constraintIsSatisfied () {
        NSCursor.resizeUpDown.set ()
      }else{
        NSCursor.resizeDown.set ()
      }
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseEntered (with inEvent : NSEvent) {
      self.updateCursor ()
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseExited (with inEvent : NSEvent) {
      NSCursor.arrow.set ()
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    private func constraintIsSatisfied () -> Bool {
       if let constraint = self.mDividerConstraint, let vStack = self.superview as? AutoLayoutVerticalStackView {
         let p = vStack.convert (NSPoint (), from: self)
         let constant = constraint.constant
         let satisfied = (constant + p.y) > 0.0
         // Swift.print ("\(constant), p.y \(p.y) satisfied \(satisfied)")
         return satisfied
       }else{
         return true
       }
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
