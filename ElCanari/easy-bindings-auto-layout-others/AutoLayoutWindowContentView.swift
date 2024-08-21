//
//  AutoLayoutWindowContentView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/12/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class AutoLayoutWindowContentView : NSView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // INIT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (view inView : NSView) {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false


    var constraints = [NSLayoutConstraint] ()

    self.addSubview (inView)
    constraints.add (leftOf: self, equalToLeftOf: inView)
    constraints.add (topOf: self, equalToTopOf: inView)
    constraints.add (rightOf: self, equalToRightOf: inView)
    constraints.add (bottomOf: self, equalToBottomOf: inView, withCompressionResistancePriorityOf: .secondView)

    self.setContentHuggingPriority (inView.contentHuggingPriority (for: .horizontal), for: .horizontal)
    self.setContentHuggingPriority (inView.contentHuggingPriority (for: .vertical), for: .vertical)
    self.setContentCompressionResistancePriority (inView.contentCompressionResistancePriority (for: .horizontal), for: .horizontal)
    self.setContentCompressionResistancePriority (inView.contentCompressionResistancePriority (for: .vertical), for: .vertical)

    let hiliteWiew = FilePrivateHiliteView ()
    self.addSubview (hiliteWiew)
    constraints.add (leftOf: self, equalToLeftOf: hiliteWiew)
    constraints.add (topOf: self, equalToTopOf: hiliteWiew)
    constraints.add (rightOf: self, equalToRightOf: hiliteWiew)
    constraints.add (bottomOf: self, equalToBottomOf: hiliteWiew, withCompressionResistancePriorityOf: .secondView)

    self.addConstraints (constraints)
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
        self.subviews [1].needsDisplay = true
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func buildAutoLayoutKeyViewChain (_ inView : NSView, _ ioCurrentNextKeyView : inout NSView?, _ outLastView : inout NSView?) {
    for view in inView.subviews.reversed () {
      if !view.isHidden {
        if view.canBecomeKeyView {
          if outLastView == nil {
            outLastView = view
          }
          view.nextKeyView = ioCurrentNextKeyView
          // Swift.print ("Responder of \(view) is \(ioCurrentNextKeyView)")
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
        if view.canBecomeKeyView {
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
  var mDisplayViewCurrentSettings = showViewCurrentValues ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func set (displayViewCurrentSettings inFlag : Bool) {
    self.mDisplayViewCurrentSettings = inFlag
    self.updateTrackingAreas ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func updateTrackingAreas () { // This is required for receiving mouse moved and mouseExited events
  //--- Remove current tracking area
    if let trackingArea = self.mTrackingArea {
      self.removeTrackingArea (trackingArea)
    }
  //--- Add Updated tracking area (.activeInKeyWindow is required, otherwise crash)
    if self.mDisplayViewCurrentSettings {
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
    for view in inView.subviews {
     let p = view.convert (inPoint, from: inView)
     let v = self.findSubView (in: view, at: p) ;
      if v != nil {
        return v
      }
    }
    if inView.bounds.contains (inPoint) {
      return inView
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func mouseMoved (with inEvent : NSEvent) {
    if self.mDisplayViewCurrentSettings {
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
    let mainView = FilePrivateHelperView ()
    mainView.configure (forView: inView)
    window.contentView = mainView
    window.updateConstraintsIfNeeded ()
    return window
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate final class FilePrivateHelperView : ALB_NSView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func configure (forView inView : NSView) {
    self.setContentHuggingPriority (.defaultLow, for: .horizontal)
    self.setContentHuggingPriority (.defaultLow, for: .vertical)
    self.setContentCompressionResistancePriority (.defaultHigh, for: .horizontal)
    self.setContentCompressionResistancePriority (.defaultHigh, for: .vertical)
    self.appendTextField (titled: "Class: \(inView.className)")
    self.appendTextField (titled: "Bounds: \(inView.bounds)")
    self.appendTextField (titled: "Frame: \(inView.frame)")
    self.appendTextField (titled: "Intrinsic Size: \(inView.intrinsicContentSize)")
    self.appendTextField (titled: "firstBaselineOffsetFromTop: \(inView.firstBaselineOffsetFromTop)")
    self.appendTextField (titled: "lastBaselineOffsetFromBottom: \(inView.lastBaselineOffsetFromBottom)")
    self.appendTextField (titled: "baselineOffsetFromBottom: \(inView.baselineOffsetFromBottom)")
    if let lastView = self.subviews.last {
      self.mNewConstraints.add (bottomOf: lastView, equalToBottomOf: self, plus: 8.0, withCompressionResistancePriorityOf: .firstView)
    }
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendTextField (titled inString : String) {
    let view = NSTextField (frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isBezeled = false
    view.isBordered = false
    view.drawsBackground = true
    view.isEnabled = true
    view.isEditable = false
    view.alignment = .left
    view.font = NSFont.systemFont (ofSize: NSFont.systemFontSize)
    view.stringValue = inString
    let s = view.intrinsicContentSize
    self.mNewConstraints.add (widthOf: view, greaterThanOrEqualToConstant: s.width)
    self.mNewConstraints.add (heightOf: view, equalTo: s.height)
    let optionalLastView = self.subviews.last
    self.addSubview (view)
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

  init () {
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
  override var acceptsFirstResponder : Bool { return false}
  override var canBecomeKeyView : Bool { return false}

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func hitTest (_ point: NSPoint) -> NSView? {
    return nil
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func draw (_ inDirtyRect : NSRect) {
    if showKeyResponderChain () {
      let strokeBP = NSBezierPath ()
      let filledBP = NSBezierPath ()
      var optionalResponder = self.window?.initialFirstResponder
      var loop = true
      while let responder = optionalResponder, loop {
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
      NSColor.yellow.setStroke ()
      strokeBP.lineWidth = 7.0
      strokeBP.stroke ()
      DEBUG_KEY_CHAIN_STROKE_COLOR.setStroke ()
      strokeBP.lineWidth = 1.0
      strokeBP.stroke ()
      DEBUG_KEY_CHAIN_STROKE_COLOR.setFill ()
      filledBP.fill ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
