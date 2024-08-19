//
//  AutoLayoutHorizontalStackView-divider.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/10/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutHorizontalStackView {

  //--------------------------------------------------------------------------------------------------------------------
  // appendVerticalDivider
  //--------------------------------------------------------------------------------------------------------------------

  final func appendVerticalDivider (drawFrame inDrawFrame : Bool,
                                    canResizeWindow inFlag : Bool) -> Self {
    let divider = Self.VerticalDivider (drawFrame: inDrawFrame, canResizeWindow: inFlag)
    self.addSubview (divider)
    return self
  }

  //--------------------------------------------------------------------------------------------------------------------

  final func isVerticalDivider (_ inView : NSView) -> Bool {
    return inView is VerticalDivider
  }

  //--------------------------------------------------------------------------------------------------------------------
  // VerticalDivider internal class
  //--------------------------------------------------------------------------------------------------------------------

   final class VerticalDivider : NSView {

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    private let mDrawFrame : Bool
    private let mCanResizeWindow : Bool

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    init (drawFrame inDrawFrame : Bool = true, canResizeWindow inFlag : Bool = false) {
      self.mDrawFrame = inDrawFrame
      self.mCanResizeWindow = inFlag
      super.init (frame: .zero)

      self.pmConfigureForAutolayout (hStretchingResistance: .highest, vStrechingResistance: .lowest)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    required init? (coder inCoder : NSCoder) {
      fatalError ("init(coder:) has not been implemented")
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var intrinsicContentSize: NSSize { return NSSize (width: 10.0, height: 0.0) }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    private static let mLayoutSettings = AutoLayoutViewSettings (
      vLayoutInHorizontalContainer: .weakFillIgnoringMargins,
      hLayoutInVerticalContainer: .weakFill
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
    private var mDividerInitialLeftLocationX : CGFloat = 0.0 // In hStack coordinates
    private var mInitialMouseDownLocationX : CGFloat = 0.0 // In hStack coordinates
    private var mCurrentMouseDraggedLocationX : CGFloat = 0.0  // In hStack coordinates

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseDown (with inEvent : NSEvent) {
      if let hStack = self.superview as? AutoLayoutHorizontalStackView {
        self.mDividerInitialLeftLocationX = hStack.convert (NSPoint (), from: self).x
        self.mInitialMouseDownLocationX = hStack.convert (inEvent.locationInWindow, from: nil).x
        self.mCurrentMouseDraggedLocationX = 0.0
      }
      super.mouseDown (with: inEvent)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseDragged (with inEvent: NSEvent) {
      NSCursor.resizeLeftRight.set ()
      if let hStack = self.superview as? AutoLayoutHorizontalStackView {
        self.mCurrentMouseDraggedLocationX = hStack.convert (inEvent.locationInWindow, from: nil).x
        self.needsUpdateConstraints = true
      }
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func mouseUp (with inEvent: NSEvent) {
      NSCursor.arrow.set ()
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func updateConstraints () {
      if let hStack = self.superview as? AutoLayoutHorizontalStackView {
        hStack.removeConstraints (self.mDividerConstraints)
        self.mDividerConstraints.removeAll (keepingCapacity: true)
        let priority : PMLayoutCompressionConstraintPriority = self.mCanResizeWindow ? .canResizeWindow : .cannotResizeWindow
        let dX = self.mCurrentMouseDraggedLocationX - self.mInitialMouseDownLocationX
        let newLeft = self.mDividerInitialLeftLocationX + dX
        self.mDividerConstraints.add (leftOf: self, equalToLeftOf: hStack, plus: newLeft, priority: priority)
        hStack.addConstraints (self.mDividerConstraints)
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
      NSCursor.resizeLeftRight.set ()
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
