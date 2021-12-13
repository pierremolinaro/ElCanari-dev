//
//  AutoLayoutAbstractSplitView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// Seee https://github.com/jwilling/JWSplitView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutAbstractSplitView : NSSplitView, EBUserClassNameProtocol {

  //····················································································································
  //   INIT
  //····················································································································

  init (dividersAreVertical inFlag : Bool) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.isVertical = inFlag
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .vertical)
  }

  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override func ebCleanUp () {
    for view in self.subviews {
      view.ebCleanUp ()
    }
    super.ebCleanUp ()
  }

  //····················································································································

  @discardableResult final func appendView (_ inView : NSView) -> Self {
 //   inView.translatesAutoresizingMaskIntoConstraints = true
    self.addSubview (inView)
    self.setHoldingPriority (.init (rawValue: 250.0), forSubviewAt: self.subviews.count - 1)
//    self.setHoldingPriority (.required, forSubviewAt: self.subviews.count - 1)
//    if self.subviews.count > 1 {
//      for i in 1 ..< self.subviews.count {
//        self.setPosition (CGFloat (i) / CGFloat (self.subviews.count), ofDividerAt: i)
//      }
//    }
    return self
  }

//  //····················································································································
//
//  override func layout () {
//    super.layout ()
//    Swift.print ("layout \(self.frame)")
//  }
//
  //····················································································································
  //   DRAW
  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    if debugAutoLayout () {
      var bp = NSBezierPath (rect: self.bounds)
      bp.lineWidth = 1.0
      bp.lineJoinStyle = .round
      DEBUG_STROKE_COLOR.setStroke ()
      let array : [CGFloat] = [1.0, 1.0]
      bp.setLineDash (array, count: array.count, phase: 0.0)
      bp.stroke ()
      bp = NSBezierPath (rect: self.bounds)
      bp.lineWidth = 1.0
      bp.lineJoinStyle = .round
      bp.stroke ()
    }
    super.draw (inDirtyRect)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
