//
//  AutoLayoutVerticalStackView-divider.swift
//  essai-gridview
//
//  Created by Pierre Molinaro on 30/10/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutVerticalStackView {

  //--------------------------------------------------------------------------------------------------------------------
  // appendVerticalDivider
  //--------------------------------------------------------------------------------------------------------------------

  final func appendHorizontalDivider (drawFrame inDrawFrame : Bool,
                                      canResizeWindow inFlag : Bool) -> Self {
    let divider = Self.HorizontalDivider (drawFrame: inDrawFrame, canResizeWindow: inFlag)
    self.addSubview (divider)
    return self
  }

  //--------------------------------------------------------------------------------------------------------------------

  final func isHorizontalDivider (_ inView : NSView) -> Bool {
    return inView is HorizontalDivider
  }

  //--------------------------------------------------------------------------------------------------------------------
  // HorizontalDivider internal class
  //--------------------------------------------------------------------------------------------------------------------

  final class HorizontalDivider : NSView {

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var isFlipped : Bool { true }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    private let mDrawFrame : Bool
    private let mCanResizeWindow : Bool

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    init (drawFrame inDrawFrame : Bool = true, canResizeWindow inFlag : Bool = false) {
      self.mDrawFrame = inDrawFrame
      self.mCanResizeWindow = inFlag
      super.init (frame: .zero)
      self.pmConfigureForAutolayout (hStretchingResistance: .lowest, vStrechingResistance: .highest)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    required init? (coder inCoder : NSCoder) {
      fatalError ("init(coder:) has not been implemented")
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var intrinsicContentSize: NSSize { return NSSize (width: 1.0, height: 10.0) }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    private static let mLayoutSettings = AutoLayoutViewSettings (
      vLayoutInHorizontalContainer: .weakFill,
      hLayoutInVerticalContainer: .weakFillIgnoringMargins
    )

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var pmLayoutSettings : AutoLayoutViewSettings { Self.mLayoutSettings }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func draw (_ inDirtyRect : NSRect) {
      if self.mDrawFrame {
        let r = self.bounds.insetBy (dx: 0.5, dy: 0.5)
        if !r.isEmpty {
          NSColor.separatorColor.setStroke ()
          NSBezierPath.stroke (r)
        }
      }
      let s : CGFloat = 6.0
      let r = NSRect (x: NSMidX (self.bounds) - s / 2.0, y: NSMidY (self.bounds) - s / 2.0, width: s, height: s)
      if !r.isEmpty {
        NSColor.separatorColor.setFill ()
        let bp = NSBezierPath (ovalIn: r)
        bp.fill ()
      }
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
    //   Mouse
    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    private var mDividerConstraints = [NSLayoutConstraint] ()
    private var mDividerInitialTopLocationY : CGFloat = 0.0 // In vStack coordinates
    private var mInitialMouseDownLocationY : CGFloat = 0.0 // In vStack coordinates
    private var mCurrentMouseDraggedLocationY : CGFloat = 0.0  // In vStack coordinates

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseDown (with inEvent : NSEvent) {
      if let vStack = self.superview as? AutoLayoutVerticalStackView {
        if vStack.isFlipped {
          self.mDividerInitialTopLocationY = NSMinY (vStack.bounds) + vStack.convert (self.bounds.origin, from: self).y
        }else{
          self.mDividerInitialTopLocationY = NSMaxY (vStack.bounds) - vStack.convert (NSPoint (), from: self).y
        }
        self.mInitialMouseDownLocationY = vStack.convert (inEvent.locationInWindow, from: nil).y
        self.mCurrentMouseDraggedLocationY = self.mInitialMouseDownLocationY
      }
      super.mouseDown (with: inEvent)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseDragged (with inEvent: NSEvent) {
      NSCursor.resizeUpDown.set ()
      if let vStack = self.superview as? AutoLayoutVerticalStackView {
        self.mCurrentMouseDraggedLocationY = vStack.convert (inEvent.locationInWindow, from: nil).y
        self.needsUpdateConstraints = true
      }
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseUp (with inEvent: NSEvent) {
      NSCursor.arrow.set ()
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func updateConstraints () {
      if let vStack = self.superview as? AutoLayoutVerticalStackView {
        vStack.removeConstraints (self.mDividerConstraints)
        self.mDividerConstraints.removeAll (keepingCapacity: true)
        let priority : PMLayoutCompressionConstraintPriority = self.mCanResizeWindow ? .canResizeWindow : .cannotResizeWindow
        let dY = self.mCurrentMouseDraggedLocationY - self.mInitialMouseDownLocationY
        let newTop = self.mDividerInitialTopLocationY + (vStack.isFlipped ? dY : -dY)
        self.mDividerConstraints.add (topOf: vStack, equalToTopOf: self, plus: newTop, priority: priority)
        vStack.addConstraints (self.mDividerConstraints)
      }
      super.updateConstraints ()
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
    // Tracking mouse moved events
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

    override func mouseEntered (with inEvent : NSEvent) {
      NSCursor.resizeUpDown.set ()
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseExited (with inEvent : NSEvent) {
      NSCursor.arrow.set ()
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  }

  //--------------------------------------------------------------------------------------------------------------------

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
