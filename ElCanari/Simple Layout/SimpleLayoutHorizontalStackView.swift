//
//  SimpleLayoutHorizontalStackView.swift
//  auto-layout
//
//  Created by Pierre Molinaro on 28/10/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

class SimpleLayoutHorizontalStackView : NSView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let MARGIN = 8.0
  let SPACING = 8.0

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    super.init (frame: .zero)
    noteObjectAllocation (self)
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
    objectDidDeinitSoReleaseHiddenControllers ()
    objectDidDeinitSoReleaseEnabledBindingController ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func ebMetrics () -> ViewMetric {
    var aboveLastBottomBaseLine = 0.0
    var belowLastBottomBaseLine = 0.0
    var w = MARGIN * 2.0
    for view in self.subviews {
      let s = view.ebMetrics ()
      if let b = s.lastBaselineFromBottomOfFrame {
        belowLastBottomBaseLine = max (belowLastBottomBaseLine, b)
        aboveLastBottomBaseLine = max (aboveLastBottomBaseLine, s.fittingHeight - b)
      }
      w += s.fittingWidth
    }
    if self.subviews.count > 1 {
      w += SPACING * Double (self.subviews.count - 1)
    }
    let height = MARGIN * 2.0 + aboveLastBottomBaseLine + belowLastBottomBaseLine
    return ViewMetric (fittingSize: NSSize (width: w, height: height), lastBaselineFromBottomOfFrame: aboveLastBottomBaseLine)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mTrigger = false

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func viewDidMoveToWindow () {
    super.viewDidMoveToWindow ()
    if let w = self.window, w.contentView === self {
      let s = self.ebMetrics ()
      w.contentMinSize = NSSize (width: s.fittingWidth, height: s.fittingHeight)
      var windowSize = self.frame.size
      if windowSize.width < s.fittingWidth {
        windowSize.width = s.fittingWidth
        w.setContentSize (windowSize)
      }
    }
    self.triggerComputeLayout ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func resizeSubviews (withOldSize oldSize: NSSize) {
    super.resizeSubviews (withOldSize: oldSize)
    self.triggerComputeLayout ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func triggerComputeLayout () {
    if !self.mTrigger {
      self.mTrigger = true
      DispatchQueue.main.async {
        self.computeLayout ()
        self.mTrigger = false
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func computeLayout () {
//    Swift.print ("computeLayout")
    if self.subviews.count > 0 {
      let s = self.ebMetrics ()
      let r = self.frame
      let rabX = (r.width - s.fittingWidth) / Double (self.subviews.count)
      var x = MARGIN
      for view in self.subviews {
        let m = view.ebMetrics ()
        let b = s.lastBaselineFromBottomOfFrame! - m.lastBaselineFromBottomOfFrame!
        view.frame = NSRect (
          x: x,
          y: MARGIN + b,
          width: m.fittingWidth + rabX,
          height: m.fittingHeight
        )
        x += m.fittingWidth + rabX + SPACING
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
