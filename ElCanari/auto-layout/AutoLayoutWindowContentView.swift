//
//  AutoLayoutWindowContentView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutWindowContentView : NSView, EBUserClassNameProtocol {

  //····················································································································
  // INIT
  //····················································································································

  init (view inView : NSView) {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    do{
      self.addSubview (inView)
      let c0 = NSLayoutConstraint (item: self, attribute: .left,  relatedBy: .equal, toItem: inView, attribute: .left,  multiplier: 1.0, constant: 0.0)
      let c1 = NSLayoutConstraint (item: self, attribute: .right, relatedBy: .equal, toItem: inView, attribute: .right, multiplier: 1.0, constant: 0.0)
      let c2 = NSLayoutConstraint (item: self, attribute: .top,   relatedBy: .equal, toItem: inView, attribute: .top,  multiplier: 1.0, constant: 0.0)
      let c3 = NSLayoutConstraint (item: self, attribute: .bottom, relatedBy: .equal, toItem: inView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
      self.addConstraints ([c0, c1, c2, c3])
    }
    do{
      let view = HiliteView ()
      self.addSubview (view)
      let c0 = NSLayoutConstraint (item: self, attribute: .left,  relatedBy: .equal, toItem: view, attribute: .left,  multiplier: 1.0, constant: 0.0)
      let c1 = NSLayoutConstraint (item: self, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0)
      let c2 = NSLayoutConstraint (item: self, attribute: .top,   relatedBy: .equal, toItem: view, attribute: .top,  multiplier: 1.0, constant: 0.0)
      let c3 = NSLayoutConstraint (item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
      self.addConstraints ([c0, c1, c2, c3])
    }
  }

  //····················································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  private var mNextKeyViewSettingComputationHasBeenTriggered = false

  //····················································································································

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

  //····················································································································

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

  //····················································································································

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

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class HiliteView : NSView, EBUserClassNameProtocol {

  //····················································································································

  init () {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.setContentHuggingPriority (.defaultLow, for: .horizontal)
    self.setContentHuggingPriority (.defaultLow, for: .vertical)
    self.setContentCompressionResistancePriority (.defaultLow, for: .horizontal)
    self.setContentCompressionResistancePriority (.defaultLow, for: .vertical)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override var isOpaque : Bool { return false}
  override var acceptsFirstResponder : Bool { return false}
  override var canBecomeKeyView : Bool { return false}

  //····················································································································

  override func hitTest (_ point: NSPoint) -> NSView? {
    return nil
  }

  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    if showKeyResponderChain () {
      DEBUG_KEY_CHAIN_STROKE_COLOR.setStroke ()
      DEBUG_KEY_CHAIN_STROKE_COLOR.setFill ()
      let strokeBP = NSBezierPath ()
      let filledBP = NSBezierPath ()
      strokeBP.lineWidth = 1.0
      var optionalResponder = self.window?.initialFirstResponder
      var loop = true
      while let responder = optionalResponder, loop {
        let r = responder.convert (responder.bounds, to: self)
        strokeBP.appendRect (r)
        let optionalNextResponder = responder.nextKeyView
        if let nextResponder = optionalNextResponder {
          strokeBP.move (to: responder.convert (responder.bounds.center, to: nil))
          let p = nextResponder.convert (nextResponder.bounds.center, to: nil)
          strokeBP.addArrow (fillPath: filledBP, to: p, arrowSize: 6.0)
        }
        optionalResponder = optionalNextResponder
        loop = optionalResponder !== self.window?.initialFirstResponder
      }
      strokeBP.stroke ()
      filledBP.fill ()
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
