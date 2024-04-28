//
//  AutoLayoutWindowContentView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutWindowContentView : AutoLayoutBase_NSView {

  //································································································
  // INIT
  //································································································

  init (view inView : NSView) {
    super.init ()

    self.setContentHuggingPriority (.defaultLow, for: .horizontal)
    self.setContentHuggingPriority (.defaultLow, for: .vertical)
    self.setContentCompressionResistancePriority (.defaultLow, for: .horizontal)
    self.setContentCompressionResistancePriority (.defaultLow, for: .vertical)

    var constraints = [NSLayoutConstraint] ()

    self.addSubview (inView)
    constraints.add (leftOf: self, equalToLeftOf: inView)
    constraints.add (topOf: self, equalToTopOf: inView)
    constraints.add (rightOf: self, equalToRightOf: inView)
    constraints.add (bottomOf: self, equalToBottomOf: inView)

    let hiliteWiew = HiliteView ()
    self.addSubview (hiliteWiew)
    constraints.add (leftOf: self, equalToLeftOf: hiliteWiew)
    constraints.add (topOf: self, equalToTopOf: hiliteWiew)
    constraints.add (rightOf: self, equalToRightOf: hiliteWiew)
    constraints.add (bottomOf: self, equalToBottomOf: hiliteWiew)

    self.addConstraints (constraints)
  }

  //································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //································································································

  private var mNextKeyViewSettingComputationHasBeenTriggered = false

  //································································································

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

  //································································································

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

  //································································································

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

  //································································································
  //   DISPLAY VIEW CURRENT SETTINGS
  //································································································

  var mTrackingArea : NSTrackingArea? = nil
  var mCurrentTrackedView : NSView? = nil
  var mDisplayWindow : NSWindow? = nil
  var mDisplayViewCurrentSettings = showViewCurrentValues ()

  //································································································

  func set (displayViewCurrentSettings inFlag : Bool) {
    self.mDisplayViewCurrentSettings = inFlag
    self.updateTrackingAreas ()
  }

  //································································································

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

  //································································································

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

  //································································································

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

  //································································································

  override func mouseExited (with inEvent : NSEvent) {
    self.mCurrentTrackedView = nil
    self.mDisplayWindow?.orderOut (nil)
    self.mDisplayWindow = nil
    super.mouseExited (with: inEvent)
  }

  //································································································

  private func buildHelperWindow (forView inView : NSView) -> NSWindow {
    let window = NSPanel (
      contentRect: NSRect (x: 0, y: 0, width: 10, height: 10),
      styleMask: [.utilityWindow, .borderless],
      backing: .buffered,
      defer: false,
      screen: self.window?.screen
    )
 //   Swift.print ("Screen \(self.window?.screen?.visibleFrame)")
    window.backgroundColor = NSColor.white
    window.isOpaque = true
    window.isExcludedFromWindowsMenu = true
    let mainView = NSView ()
    mainView.translatesAutoresizingMaskIntoConstraints = false
    mainView.setContentHuggingPriority (.defaultLow, for: .horizontal)
    mainView.setContentHuggingPriority (.defaultLow, for: .vertical)
    mainView.setContentCompressionResistancePriority (.defaultLow, for: .horizontal)
    mainView.setContentCompressionResistancePriority (.defaultLow, for: .vertical)
    var constraints = [NSLayoutConstraint] ()
    self.appendTextField (titled: "Class: \(inView.className)", toMainView: mainView, &constraints)
    self.appendTextField (titled: "Bounds: \(inView.bounds)", toMainView: mainView, &constraints)
    self.appendTextField (titled: "Frame: \(inView.frame)", toMainView: mainView, &constraints)
    self.appendTextField (titled: "Intrinsic Size: \(inView.intrinsicContentSize)", toMainView: mainView, &constraints)
    self.appendTextField (titled: "firstBaselineOffsetFromTop: \(inView.firstBaselineOffsetFromTop)", toMainView: mainView, &constraints)
    self.appendTextField (titled: "lastBaselineOffsetFromBottom: \(inView.lastBaselineOffsetFromBottom)", toMainView: mainView, &constraints)
    self.appendTextField (titled: "baselineOffsetFromBottom: \(inView.baselineOffsetFromBottom)", toMainView: mainView, &constraints)
    if let lastView = mainView.subviews.last {
      constraints.add (bottomOf: lastView, equalToBottomOf: mainView, plus: 8.0)
    }
    mainView.addConstraints (constraints)
    window.contentView = mainView
    return window
  }

  //································································································

  private func appendTextField (titled inString : String,
                                toMainView inMainView : NSView,
                                _ ioConstraints : inout [NSLayoutConstraint]) {
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
    ioConstraints.add (widthOf: view, greaterThanOrEqualTo: s.width)
    ioConstraints.add (heightOf: view, equalTo: s.height)
    let optionalLastView = inMainView.subviews.last
    inMainView.addSubview (view)
    ioConstraints.add (leftOf: view, equalToLeftOf: inMainView, plus: 8.0)
    ioConstraints.add (rightOf: inMainView, equalToRightOf: view, plus: 8.0)
    if let lastView = optionalLastView {
      ioConstraints.add (bottomOf: lastView, equalToTopOf: view, plus: 4.0)
    }else{
      ioConstraints.add (topOf: inMainView, equalToTopOf: view, plus: 8.0)
    }
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class HiliteView : NSView {

  //································································································

  init () {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.setContentHuggingPriority (.defaultLow, for: .horizontal)
    self.setContentHuggingPriority (.defaultLow, for: .vertical)
    self.setContentCompressionResistancePriority (.defaultLow, for: .horizontal)
    self.setContentCompressionResistancePriority (.defaultLow, for: .vertical)
  }

  //································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //································································································

  override var isOpaque : Bool { return false}
  override var acceptsFirstResponder : Bool { return false}
  override var canBecomeKeyView : Bool { return false}

  //································································································

  override func hitTest (_ point: NSPoint) -> NSView? {
    return nil
  }

  //································································································

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

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
