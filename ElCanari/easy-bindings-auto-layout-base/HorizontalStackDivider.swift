//
//  AutoLayoutHorizontalStackView-divider.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/10/2023.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

let DIVIDER_WIDTH = 10.0

//--------------------------------------------------------------------------------------------------

final class HorizontalStackDivider : NSView, HorizontalStackHierarchyProtocol {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mDrawFrame : Bool
  private let mCanResizeWindow : Bool

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inRoot : (any HorizontalStackHierarchyProtocol)?,
        drawFrame inDrawFrame : Bool,
        canResizeWindow inFlag : Bool) {
    self.mLeft = inRoot
    self.mDrawFrame = inDrawFrame
    self.mCanResizeWindow = inFlag
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.pmConfigureForAutolayout (hStretchingResistance: .highest, vStrechingResistance: .lowest)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mLeft : (any HorizontalStackHierarchyProtocol)?
  private var mRight : (any HorizontalStackHierarchyProtocol)? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendInHorizontalHierarchy (_ inView : NSView) {
    AutoLayoutHorizontalStackView.appendInHorizontalHierarchy (inView, toStackRoot: &self.mRight)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func prependInHorizontalHierarchy (_ inView : NSView) {
    AutoLayoutHorizontalStackView.prependInHorizontalHierarchy (inView, toStackRoot: &self.mLeft)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func removeInHorizontalHierarchy (_ inView : NSView) {
    self.mLeft?.removeInHorizontalHierarchy (inView)
    self.mRight?.removeInHorizontalHierarchy (inView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func buildConstraintsFor (horizontalStackView inHorizontalStackView : AutoLayoutHorizontalStackView,
                            optionalLastRightView ioOptionalLastRightAnchor : inout NSLayoutXAxisAnchor?,
                            flexibleSpaceView ioFlexibleSpaceView : inout HorizontalStackFlexibleSpace?,
                            _ ioContraints : inout [NSLayoutConstraint]) {
  //--- Before
    self.mLeft?.buildConstraintsFor (
      horizontalStackView: inHorizontalStackView,
      optionalLastRightView: &ioOptionalLastRightAnchor,
      flexibleSpaceView: &ioFlexibleSpaceView,
      &ioContraints
    )
  //--- Divider, vertical constraints
    ioContraints.add (y: inHorizontalStackView.topAnchor, equalTo: self.topAnchor)
    ioContraints.add (y: inHorizontalStackView.bottomAnchor, equalTo: self.bottomAnchor)
  //--- Divider, horizontal constraints
    ioContraints.add (dim: self.widthAnchor, equalToConstant: DIVIDER_WIDTH)
    if let lastRightAnchor = ioOptionalLastRightAnchor {
      ioContraints.add (x: self.leftAnchor, equalTo: lastRightAnchor, plus: inHorizontalStackView.mSpacing)
    }else{
      ioContraints.add (x: self.leftAnchor, equalTo: inHorizontalStackView.leftAnchor, plus: inHorizontalStackView.mLeftMargin)
    }
  //--- After
    ioOptionalLastRightAnchor = self.rightAnchor
    self.mRight?.buildConstraintsFor (
      horizontalStackView: inHorizontalStackView,
      optionalLastRightView: &ioOptionalLastRightAnchor,
      flexibleSpaceView: &ioFlexibleSpaceView,
      &ioContraints
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignHorizontalGutters (_ ioGutters : inout [VerticalStackGutter],
                               _ ioLastBaselineViews : inout [NSView?],
                               _ ioContraints : inout [NSLayoutConstraint]) {
    self.mLeft?.alignHorizontalGutters (&ioGutters, &ioLastBaselineViews, &ioContraints)
    self.mRight?.alignHorizontalGutters (&ioGutters, &ioLastBaselineViews, &ioContraints)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var intrinsicContentSize : NSSize {
    return NSSize (width: DIVIDER_WIDTH, height: NSView.noIntrinsicMetric)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private static let mLayoutSettings = AutoLayoutViewSettings (
    vLayoutInHorizontalContainer: .fillIgnoringMargins,
    hLayoutInVerticalContainer: .fill
  )

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var pmLayoutSettings : AutoLayoutViewSettings { Self.mLayoutSettings }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Mouse
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func mouseDragged (with inEvent: NSEvent) {
    NSCursor.resizeLeftRight.set ()
    if let hStack = self.superview as? AutoLayoutHorizontalStackView {
      self.mCurrentMouseDraggedLocationX = hStack.convert (inEvent.locationInWindow, from: nil).x
      self.needsUpdateConstraints = true
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func mouseUp (with inEvent: NSEvent) {
    NSCursor.arrow.set ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func updateConstraints () {
    if let hStack = self.superview as? AutoLayoutHorizontalStackView {
      hStack.removeConstraints (self.mDividerConstraints)
      self.mDividerConstraints.removeAll (keepingCapacity: true)
      let priority : LayoutCompressionConstraintPriority = self.mCanResizeWindow ? .canResizeWindow : .cannotResizeWindow
      let dX = self.mCurrentMouseDraggedLocationX - self.mInitialMouseDownLocationX
      let newLeft = self.mDividerInitialLeftLocationX + dX
      self.mDividerConstraints.add (x: self.leftAnchor, equalTo: hStack.leftAnchor, plus: newLeft, priority: priority)
      hStack.addConstraints (self.mDividerConstraints)
    }
    super.updateConstraints ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Tracking mouse moved events
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var mTrackingArea : NSTrackingArea? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func mouseEntered (with inEvent : NSEvent) {
    NSCursor.resizeLeftRight.set ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func mouseExited (with inEvent : NSEvent) {
    NSCursor.arrow.set ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}


//--------------------------------------------------------------------------------------------------
