//
//  AutoLayoutWindowContentView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/12/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension NSWindow {
  @MainActor func setContentView (_ inContentView : NSView) {
    self.contentView = AutoLayoutWindowContentView (view: inContentView)
  }
}

//--------------------------------------------------------------------------------------------------

fileprivate let DEBUG_FLEXIBLE_SPACE_FILL_COLOR      = NSColor.systemGreen.withAlphaComponent (0.25)
fileprivate let DEBUG_LAST_BASELINE_COLOR            = NSColor.systemPink
fileprivate let DEBUG_LAST_STACK_VIEW_BASELINE_COLOR = NSColor.systemBlue
fileprivate let DEBUG_STROKE_COLOR                   = NSColor.systemOrange
fileprivate let DEBUG_MARGIN_COLOR                   = NSColor.systemYellow.withAlphaComponent (0.25)
fileprivate let DEBUG_KEY_CHAIN_STROKE_COLOR         = NSColor.systemPurple

//--------------------------------------------------------------------------------------------------
//  Show view current settings
//--------------------------------------------------------------------------------------------------

fileprivate let SHOW_VIEW_SETTINGS_PREFERENCES_KEY = "debug.show.view.settings"

@MainActor fileprivate var gShowViewCurrentSettings = UserDefaults.standard.bool (forKey: SHOW_VIEW_SETTINGS_PREFERENCES_KEY)

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

@MainActor func getShowViewCurrentSettings () -> Bool {
  return gShowViewCurrentSettings
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

@MainActor func setShowViewCurrentSettings (_ inFlag : Bool) {
  if gShowViewCurrentSettings != inFlag {
    gShowViewCurrentSettings = inFlag
    UserDefaults.standard.setValue (inFlag, forKey: SHOW_VIEW_SETTINGS_PREFERENCES_KEY)
    for window in NSApplication.shared.windows {
      if let mainView = window.contentView as? AutoLayoutWindowContentView {
        mainView.updateTrackingAreas ()
      }
    }
  }
}

//--------------------------------------------------------------------------------------------------
//  Debug Responder Chain
//--------------------------------------------------------------------------------------------------

fileprivate let DEBUG_RESPONDER_CHAIN_PREFERENCES_KEY = "debug.responder.chain"

@MainActor fileprivate var gDebugResponderChain = UserDefaults.standard.bool (forKey: DEBUG_RESPONDER_CHAIN_PREFERENCES_KEY)

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

@MainActor func getDebugResponderChain () -> Bool {
  return gDebugResponderChain
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

@MainActor func setDebugResponderChain (_ inFlag : Bool) {
  if gDebugResponderChain != inFlag {
    gDebugResponderChain = inFlag
    UserDefaults.standard.setValue (inFlag, forKey: DEBUG_RESPONDER_CHAIN_PREFERENCES_KEY)
    for window in NSApplication.shared.windows {
      if let mainView = window.contentView {
        propagateNeedsDisplay (mainView)
      }
    }
  }
}

//--------------------------------------------------------------------------------------------------
//  Debug Autolayout
//--------------------------------------------------------------------------------------------------

fileprivate let DEBUG_AUTOLAYOUT_PREFERENCES_KEY = "debug.autolayout"

@MainActor fileprivate var gDebugAutoLayout = UserDefaults.standard.bool (forKey: DEBUG_AUTOLAYOUT_PREFERENCES_KEY)

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

@MainActor func getDebugAutoLayout () -> Bool {
  return gDebugAutoLayout
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

@MainActor func setDebugAutoLayout (_ inFlag : Bool) {
  if gDebugAutoLayout != inFlag {
    gDebugAutoLayout = inFlag
    UserDefaults.standard.setValue (inFlag, forKey: DEBUG_AUTOLAYOUT_PREFERENCES_KEY)
    for window in NSApplication.shared.windows {
      if let mainView = window.contentView {
        propagateNeedsDisplay (mainView)
      }
    }
  }
}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate func propagateNeedsDisplay (_ inView : NSView) {
  inView.needsDisplay = true
  for view in inView.subviews {
    propagateNeedsDisplay (view)
  }
}

//--------------------------------------------------------------------------------------------------

@MainActor func buildResponderKeyChainForWindowThatContainsView (_ inView : NSView?) {
  if let windowContentView = inView?.window?.contentView as? AutoLayoutWindowContentView {
    windowContentView.triggerNextKeyViewSettingComputation ()
  }
}

//--------------------------------------------------------------------------------------------------

final fileprivate class AutoLayoutWindowContentView : NSView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mHiliteView : FilePrivateHiliteView

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // INIT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (view inView : NSView) {
    self.mHiliteView = FilePrivateHiliteView (rootView: inView)
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    var constraints = [NSLayoutConstraint] ()

    self.addSubview (inView)
    constraints.add (leftOf: self, equalToLeftOf: inView)
    constraints.add (topOf: self, equalToTopOf: inView)
    constraints.add (rightOf: self, equalToRightOf: inView)
    constraints.add (bottomOf: self, equalToBottomOf: inView)

//    self.setContentHuggingPriority (inView.contentHuggingPriority (for: .horizontal), for: .horizontal)
//    self.setContentHuggingPriority (inView.contentHuggingPriority (for: .vertical), for: .vertical)
//    self.setContentCompressionResistancePriority (inView.contentCompressionResistancePriority (for: .horizontal), for: .horizontal)
//    self.setContentCompressionResistancePriority (inView.contentCompressionResistancePriority (for: .vertical), for: .vertical)

    self.addSubview (self.mHiliteView)
    constraints.add (leftOf: self, equalToLeftOf: self.mHiliteView)
    constraints.add (topOf: self, equalToTopOf: self.mHiliteView)
    constraints.add (rightOf: self, equalToRightOf: self.mHiliteView)
    constraints.add (bottomOf: self, equalToBottomOf: self.mHiliteView)

    self.addConstraints (constraints)

    self.triggerNextKeyViewSettingComputation ()

    self.updateTrackingAreas ()

    checkAutoLayoutAdoption (self, [])

    if getDebugAutoLayout () {
      DispatchQueue.main.async {
        self.mHiliteView.needsDisplay = true
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mNextKeyViewSettingComputationHasBeenTriggered = false

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func triggerNextKeyViewSettingComputation () {
    if !self.mNextKeyViewSettingComputationHasBeenTriggered {
      self.mNextKeyViewSettingComputationHasBeenTriggered = true
      DispatchQueue.main.async {
        self.mNextKeyViewSettingComputationHasBeenTriggered = false
        var currentView : NSView? = nil
        var optionalLastView : NSView? = nil
        self.buildAutoLayoutKeyViewChain (self, &currentView, &optionalLastView)
        if let lastView = optionalLastView {
          _ = self.setAutoLayoutFirstKeyViewInChain (self, lastView)
        }
        self.mHiliteView.needsDisplay = true
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func buildAutoLayoutKeyViewChain (_ inView : NSView,
                                            _ ioCurrentNextKeyView : inout NSView?,
                                            _ outLastView : inout NSView?) {
    for view in inView.subviews.reversed () {
      if !view.isHidden {
        if view.canBecomeKeyView && view.acceptsFirstResponder {
          if outLastView == nil {
            // Swift.print ("Last Key View: \(view.className)")
            outLastView = view
          }
          view.nextKeyView = ioCurrentNextKeyView
          ioCurrentNextKeyView = view
        }else{
          self.buildAutoLayoutKeyViewChain (view, &ioCurrentNextKeyView, &outLastView)
        }
      }else{
        view.nextResponder = nil
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func setAutoLayoutFirstKeyViewInChain (_ inView : NSView, _ inLastView : NSView) -> Bool {
    for view in inView.subviews {
      if !view.isHidden {
        if view.canBecomeKeyView && view.acceptsFirstResponder {
          inLastView.nextKeyView = view
          self.window?.initialFirstResponder = view
          return true
        }else{
          let found = self.setAutoLayoutFirstKeyViewInChain (view, inLastView)
          if found {
            return true
          }
        }
      }
    }
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   DISPLAY VIEW CURRENT SETTINGS
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var mTrackingArea : NSTrackingArea? = nil
  var mCurrentTrackedView : NSView? = nil
  var mDisplayWindow : NSWindow? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func updateTrackingAreas () { // This is required for receiving mouse moved and mouseExited events
  //--- Remove current tracking area
    if let trackingArea = self.mTrackingArea {
      self.removeTrackingArea (trackingArea)
    }
  //--- Add Updated tracking area (.activeInKeyWindow is required, otherwise crash)
    if getShowViewCurrentSettings () || getDebugAutoLayout () {
      let trackingArea = NSTrackingArea (
        rect: self.bounds,
        options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow],
        owner: self,
        userInfo: nil
      )
      self.addTrackingArea (trackingArea)
      self.mTrackingArea = trackingArea
    }
  //---
    super.updateTrackingAreas ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func findSubView (in inView: NSView, at inPoint : NSPoint) -> NSView? {
    for view in inView.subviews.reversed () {
     let p = view.convert (inPoint, from: inView)
     let v = self.findSubView (in: view, at: p)
      if v != nil {
        return v
      }
    }
    if inView.self.bounds.contains (inPoint) {
      return inView
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func wantsForwardedScrollEvents (for axis: NSEvent.GestureAxis) -> Bool {
    if getDebugAutoLayout () {
      self.mHiliteView.needsDisplay = true
    }
    return super.wantsForwardedScrollEvents (for: axis)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  override func trackSwipeEvent (options: NSEvent.SwipeTrackingOptions = [],
//      dampenAmountThresholdMin minDampenThreshold: CGFloat,
//      max maxDampenThreshold: CGFloat,
//      usingHandler trackingHandler: @escaping (CGFloat, NSEvent.Phase, Bool, UnsafeMutablePointer<ObjCBool>) -> Void)) {
//   super.trackSwipeEvent (
//      options: options,
//      dampenAmountThresholdMin: minDampenThreshold,
//      max: maxDampenThreshold,
//      usingHandler: trackingHandler
//    )
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func mouseMoved (with inEvent : NSEvent) {
    if getDebugAutoLayout () {
      self.mHiliteView.needsDisplay = true
    }
    if getShowViewCurrentSettings () {
      let windowContentView = self.subviews [0]
      let mouseLocation = windowContentView.convert (inEvent.locationInWindow, from: nil)
      let optionalView = self.findSubView (in: windowContentView, at: mouseLocation)
      if optionalView != self.mCurrentTrackedView {
        self.mCurrentTrackedView = optionalView
        self.mDisplayWindow?.orderOut (nil)
        self.mDisplayWindow = nil
        if let view = optionalView {
          self.mDisplayWindow = buildHelperWindow (forView: view)
          self.mDisplayWindow?.orderFront (nil)
        }
      }
      var p = self.window!.convertPoint (toScreen: inEvent.locationInWindow)
      p.x += 10.0
      p.y += 10.0
      self.mDisplayWindow?.setFrameOrigin (p)
    }
    super.mouseMoved (with: inEvent)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func mouseExited (with inEvent : NSEvent) {
    self.mCurrentTrackedView = nil
    self.mDisplayWindow?.orderOut (nil)
    self.mDisplayWindow = nil
    super.mouseExited (with: inEvent)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func buildHelperWindow (forView inView : NSView) -> NSWindow {
    let window = NSPanel (
      contentRect: NSRect (x: 0, y: 0, width: 10, height: 10),
      styleMask: [.utilityWindow, .borderless, .resizable],
      backing: .buffered,
      defer: false,
      screen: self.window?.screen
    )
    window.backgroundColor = NSColor.white
    window.isOpaque = true
    window.isExcludedFromWindowsMenu = true
    let mainView = FilePrivateHelperView (configuredWithView: inView)
    window.contentView = mainView
//    window.updateConstraintsIfNeeded ()
    return window
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate final class FilePrivateHelperView : ALB_NSView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (configuredWithView inView : NSView) {
    super.init ()
    self.setContentHuggingPriority (.defaultLow, for: .horizontal)
    self.setContentHuggingPriority (.defaultLow, for: .vertical)
    self.setContentCompressionResistancePriority (.defaultHigh, for: .horizontal)
    self.setContentCompressionResistancePriority (.defaultHigh, for: .vertical)
    self.appendTextField (titled: "Class: \(String (describing: type (of: inView)))")
//    self.appendTextField (titled: "Bounds: \(inView.bounds)")
    self.appendTextField (titled: "Frame: \(inView.frame)")
    self.appendTextField (titled: "Intrinsic Size: \(inView.intrinsicContentSize)")
//    self.appendTextField (titled: "firstBaselineOffsetFromTop: \(inView.firstBaselineOffsetFromTop)")
//    self.appendTextField (titled: "lastBaselineOffsetFromBottom: \(inView.lastBaselineOffsetFromBottom)")
    self.appendTextField (titled: "baselineOffsetFromBottom: \(inView.baselineOffsetFromBottom)")
//    self.appendTextField (titled: "acceptsFirstResponder: \(inView.acceptsFirstResponder)")
//    self.appendTextField (titled: "canBecomeKeyView: \(inView.canBecomeKeyView)")
    self.appendTextField (titled: "h Compression Resistance: \(inView.contentCompressionResistancePriority (for: .horizontal).rawValue)")
    self.appendTextField (titled: "v Compression Resistance: \(inView.contentCompressionResistancePriority (for: .vertical).rawValue)")
    self.appendTextField (titled: "h Stretching Resistance: \(inView.contentHuggingPriority (for: .horizontal).rawValue)")
    self.appendTextField (titled: "v Stretching Resistance: \(inView.contentHuggingPriority (for: .vertical).rawValue)")
    if let lastView = self.subviews.last {
      self.mNewConstraints.add (bottomOf: lastView, equalToBottomOf: self, plus: 8.0)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendTextField (titled inString : String) {
    let view = NSTextField (frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.setContentCompressionResistancePriority (.defaultHigh, for: .horizontal)
    view.setContentCompressionResistancePriority (.defaultHigh, for: .vertical)
    view.isBezeled = false
    view.isBordered = false
    view.drawsBackground = true
    view.isEnabled = true
    view.isEditable = false
    view.alignment = .left
    view.font = NSFont.systemFont (ofSize: NSFont.systemFontSize)
    view.stringValue = inString
    let optionalLastView = self.subviews.last
    self.addSubview (view)
//    let s = view.intrinsicContentSize
//    self.mNewConstraints.add (widthOf: view, greaterThanOrEqualToConstant: s.width)
//    self.mNewConstraints.add (heightOf: view, equalToHeightOf: s.height)
    self.mNewConstraints.add (leftOf: view, equalToLeftOf: self, plus: 8.0)
    self.mNewConstraints.add (rightOf: self, equalToRightOf: view, plus: 8.0)
    if let lastView = optionalLastView {
      self.mNewConstraints.add (bottomOf: lastView, equalToTopOf: view, plus: 4.0)
    }else{
      self.mNewConstraints.add (topOf: self, equalToTopOf: view, plus: 8.0)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Constraints
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mNewConstraints = [NSLayoutConstraint] ()
  private var mCurrentConstraints = [NSLayoutConstraint] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func updateConstraints () {
  //--- Remove all constraints
    self.removeConstraints (self.mCurrentConstraints)
  //--- Build constraints
    self.mCurrentConstraints = self.mNewConstraints
  //--- Apply constaints
    self.addConstraints (self.mCurrentConstraints)
  //--- This should the last instruction: call super method
    super.updateConstraints ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate final class FilePrivateHiliteView : NSView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mRootView : NSView

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (rootView inRootView : NSView) {
    self.mRootView = inRootView
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.setContentHuggingPriority (.defaultLow, for: .horizontal)
    self.setContentHuggingPriority (.defaultLow, for: .vertical)
    self.setContentCompressionResistancePriority (.defaultLow, for: .horizontal)
    self.setContentCompressionResistancePriority (.defaultLow, for: .vertical)
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

  override var isOpaque : Bool { return false}
  override var isFlipped : Bool { false } // Y axis is ascending
  override var acceptsFirstResponder : Bool { false }
  override var canBecomeKeyView : Bool { false }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func hitTest (_ inUnusedPoint : NSPoint) -> NSView? {
    return nil
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func draw (_ inDirtyRect : NSRect) {
    if getDebugAutoLayout () {
      self.drawViewRects (self.mRootView)
    }
    if getDebugResponderChain () {
      let strokeBP = NSBezierPath ()
      let filledBP = NSBezierPath ()
      var optionalResponder = self.window?.initialFirstResponder
      var loop = true
      while let responder = optionalResponder, loop {
//        Swift.print ("\(responder.className)")
        let r = responder.convert (responder.bounds, to: self)
        strokeBP.appendRect (r)
        let optionalNextResponder = responder.nextKeyView
        if let nextResponder = optionalNextResponder {
          strokeBP.move (to: responder.convert (responder.bounds.center, to: nil))
          let p = nextResponder.convert (nextResponder.bounds.center, to: nil)
          strokeBP.addArrow (withFilledPath: filledBP, to: p, arrowSize: 6.0)
        }
        optionalResponder = optionalNextResponder
        loop = optionalResponder !== self.window?.initialFirstResponder
      }
      DEBUG_KEY_CHAIN_STROKE_COLOR.withAlphaComponent (0.125).setStroke ()
      strokeBP.lineWidth = 11.0
      strokeBP.stroke ()
      DEBUG_KEY_CHAIN_STROKE_COLOR.setStroke ()
      strokeBP.lineWidth = 1.0
      strokeBP.stroke ()
      DEBUG_KEY_CHAIN_STROKE_COLOR.setFill ()
      filledBP.fill ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func drawViewRects (_ inView : NSView) {
    if !inView.frame.isEmpty {
      let viewFrame = self.convert (inView.alignmentRect (forFrame: inView.bounds), from: inView)
      var exploreSubviews = true
      if let stackView = inView as? ALB_NSStackView { // Draw margins
        DEBUG_MARGIN_COLOR.setFill ()
        if stackView.mBottomMargin > 0.0 {
          var r = viewFrame
          r.size.height = stackView.mBottomMargin
          NSBezierPath.fill (r)
        }
        if stackView.mTopMargin > 0.0 {
          var r = viewFrame
          r.origin.y += r.size.height - stackView.mTopMargin
          r.size.height = stackView.mTopMargin
          NSBezierPath.fill (r)
        }
        if stackView.mLeftMargin > 0.0 {
          var r = viewFrame
          r.size.width = stackView.mLeftMargin
          NSBezierPath.fill (r)
        }
        if stackView.mRightMargin > 0.0 {
          var r = viewFrame
          r.origin.x += r.size.width - stackView.mRightMargin
          r.size.width = stackView.mRightMargin
          NSBezierPath.fill (r)
        }
      }else if inView is AutoLayoutFlexibleSpace {
        DEBUG_FLEXIBLE_SPACE_FILL_COLOR.setFill ()
        NSBezierPath.fill (viewFrame)
      }else if inView is AutoLayoutHorizontalStackView.VerticalSeparator { // Do not frame
        exploreSubviews = false
      }else if inView is AutoLayoutVerticalStackView.HorizontalSeparator { // Do not frame
        exploreSubviews = false
      }else{ // Frame
        let bp = NSBezierPath (rect: viewFrame)
        bp.lineWidth = 1.0
        bp.lineJoinStyle = .round
        DEBUG_STROKE_COLOR.setStroke ()
        bp.stroke ()
      }
    //--- Last baseline
      if let representativeView = inView.pmLastBaselineRepresentativeView {
        let representativeViewFrame = self.convert (representativeView.alignmentRect (forFrame: representativeView.bounds), from: representativeView)
        let bp = NSBezierPath ()
        let p = NSPoint (
          x: viewFrame.origin.x,
          y: representativeViewFrame.origin.y + representativeView.lastBaselineOffsetFromBottom
        )
        bp.move (to: p)
        bp.relativeLine (to: NSPoint (x: viewFrame.size.width, y: 0.0))
        if (inView is ALB_NSStackView) || (inView is AutoLayoutToolBar) {
          DEBUG_LAST_STACK_VIEW_BASELINE_COLOR.setStroke ()
        }else{
          DEBUG_LAST_BASELINE_COLOR.setStroke ()
        }
        bp.stroke ()
      }
    //--- Explore subviews
      if exploreSubviews {
        exploreSubviews = !(inView is NSSegmentedControl)
      }
      if exploreSubviews {
        exploreSubviews = !(inView is NSTableView)
      }
      if exploreSubviews {
        exploreSubviews = !(inView is NSPopUpButton)
      }
      if exploreSubviews {
        exploreSubviews = !(inView is NSButton)
      }
      if exploreSubviews {
        for view in inView.subviews {
          self.drawViewRects (view)
        }
      }
    }
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

@MainActor private func checkAutoLayoutAdoption (_ inView : NSView, _ inHierarchy : [NSView]) {
  if inView.translatesAutoresizingMaskIntoConstraints {
    var s = ""
    for view in inHierarchy {
      s += String (describing: type (of: view)) + "/"
    }
    s += String (describing: type (of: inView))
    presentErrorWindow (#file, #line, s)
  }
  var examineSubviews = !(inView is NSControl)
  if examineSubviews {
    examineSubviews = !(inView is NSScrollView)
  }
  if examineSubviews {
    for view in inView.subviews {
      checkAutoLayoutAdoption (view, inHierarchy + [view])
    }
  }
}

//--------------------------------------------------------------------------------------------------
