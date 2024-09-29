//
//  AutoLayoutVerticalStackView-divider.swift
//  essai-gridview
//
//  Created by Pierre Molinaro on 30/10/2023.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

let DIVIDER_HEIGHT = 10.0

//--------------------------------------------------------------------------------------------------

final class VerticalStackDivider : NSView, VerticalStackHierarchyProtocol {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inRoot : (any VerticalStackHierarchyProtocol)?,
        drawFrame inDrawFrame : Bool = true,
        canResizeWindow inFlag : Bool = false) {
    self.mAbove = inRoot
    self.mDrawFrame = inDrawFrame
    self.mCanResizeWindow = inFlag
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.pmConfigureForAutolayout (hStretchingResistance: .lowest, vStrechingResistance: .highest)
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

  private var mAbove : (any VerticalStackHierarchyProtocol)?
  private var mBelow : (any VerticalStackHierarchyProtocol)? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendInVerticalHierarchy (_ inView : NSView) {
    AutoLayoutVerticalStackView.appendInVerticalHierarchy (inView, toStackRoot: &self.mBelow)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func prependInVerticalHierarchy (_ inView : NSView) {
    AutoLayoutVerticalStackView.prependInVerticalHierarchy (inView, toStackRoot: &self.mAbove)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func removeInVerticalHierarchy (_ inView : NSView) {
    self.mAbove?.removeInVerticalHierarchy (inView)
    self.mBelow?.removeInVerticalHierarchy (inView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func buildConstraintsFor (verticalStackView inVerticalStackView : AutoLayoutVerticalStackView,
                            optionalLastBottomView ioOptionalLastBottomView : inout NSView?,
                            flexibleSpaceView ioFlexibleSpaceView : inout VerticalStackFlexibleSpace?,
                            _ ioContraints : inout [NSLayoutConstraint]) {
  //--- Before
    self.mAbove?.buildConstraintsFor (
      verticalStackView: inVerticalStackView,
      optionalLastBottomView: &ioOptionalLastBottomView,
      flexibleSpaceView: &ioFlexibleSpaceView,
      &ioContraints
    )
  //--- Divider
    ioContraints.add (leftOf: self, equalToLeftOf: inVerticalStackView)
    ioContraints.add (rightOf: inVerticalStackView, equalToRightOf: self)
    ioContraints.add (heightOf: self, equalTo: DIVIDER_HEIGHT)
    if let lastBottomView = ioOptionalLastBottomView {
      ioContraints.add (bottomOf: lastBottomView, equalToTopOf: self, plus: inVerticalStackView.mSpacing)
    }else{
      ioContraints.add (topOf: inVerticalStackView, equalToTopOf: self, plus: inVerticalStackView.mTopMargin)
    }
  //--- After
    ioOptionalLastBottomView = self
    self.mBelow?.buildConstraintsFor (
      verticalStackView: inVerticalStackView,
      optionalLastBottomView: &ioOptionalLastBottomView,
      flexibleSpaceView: &ioFlexibleSpaceView,
      &ioContraints
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func enumerateLastBaselineViews (_ ioArray : inout [NSView?],
                                   _ ioCurrentLastBaselineView : inout NSView?) {
    self.mAbove?.enumerateLastBaselineViews (&ioArray, &ioCurrentLastBaselineView)
    self.mBelow?.enumerateLastBaselineViews (&ioArray, &ioCurrentLastBaselineView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var isFlipped : Bool { true }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mDrawFrame : Bool
  private let mCanResizeWindow : Bool

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var intrinsicContentSize: NSSize { return NSSize (width: NSView.noIntrinsicMetric, height: DIVIDER_HEIGHT) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private static let mLayoutSettings = AutoLayoutViewSettings (
    vLayoutInHorizontalContainer: .fill,
    hLayoutInVerticalContainer: .fillIgnoringMargins
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
  private var mDividerInitialTopLocationY : CGFloat = 0.0 // In vStack coordinates
  private var mInitialMouseDownLocationY : CGFloat = 0.0 // In vStack coordinates
  private var mCurrentMouseDraggedLocationY : CGFloat = 0.0  // In vStack coordinates

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func mouseDragged (with inEvent: NSEvent) {
    NSCursor.resizeUpDown.set ()
    if let vStack = self.superview as? AutoLayoutVerticalStackView {
      self.mCurrentMouseDraggedLocationY = vStack.convert (inEvent.locationInWindow, from: nil).y
      self.needsUpdateConstraints = true
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func mouseUp (with inEvent: NSEvent) {
    NSCursor.arrow.set ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func updateConstraints () {
    if let vStack = self.superview as? AutoLayoutVerticalStackView {
      vStack.removeConstraints (self.mDividerConstraints)
      self.mDividerConstraints.removeAll (keepingCapacity: true)
      let priority : LayoutCompressionConstraintPriority = self.mCanResizeWindow ? .canResizeWindow : .cannotResizeWindow
      let dY = self.mCurrentMouseDraggedLocationY - self.mInitialMouseDownLocationY
      let newTop = self.mDividerInitialTopLocationY + (vStack.isFlipped ? dY : -dY)
      self.mDividerConstraints.add (topOf: vStack, equalToTopOf: self, plus: newTop, priority: priority)
      vStack.addConstraints (self.mDividerConstraints)
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
    NSCursor.resizeUpDown.set ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func mouseExited (with inEvent : NSEvent) {
    NSCursor.arrow.set ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignVerticalGutters (_ ioGutters : inout [HorizontalStackGutter],
                             _ ioContraints : inout [NSLayoutConstraint]) {
    self.mAbove?.alignVerticalGutters (&ioGutters, &ioContraints)
    self.mBelow?.alignVerticalGutters (&ioGutters, &ioContraints)
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
