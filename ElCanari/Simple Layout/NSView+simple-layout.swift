//
//  NSView+simple-layout.swift
//
//  Created by Pierre Molinaro on 13/11/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension NSView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func ebMetrics () -> ViewMetric {
    return ViewMetric (view: self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

@MainActor final class ViewMetric : NSObject {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let fittingWidth : CGFloat
  let fittingHeight : CGFloat
  let lastBaselineFromBottomOfFrame : CGFloat?

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (control inControl : NSControl) {
    let s = inControl.fittingSize
    self.fittingWidth = s.width
    self.fittingHeight = s.height
    let r = NSRect (origin: .zero, size: s)
    let alignmentRect = inControl.alignmentRect (forFrame: r)
    self.lastBaselineFromBottomOfFrame = inControl.lastBaselineOffsetFromBottom + alignmentRect.origin.y
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (view inView : NSView) {
    let s = inView.fittingSize
    self.fittingWidth = s.width
    self.fittingHeight = s.height
    self.lastBaselineFromBottomOfFrame = nil
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (fittingSize inSize : NSSize,
        lastBaselineFromBottomOfFrame inBaseline : CGFloat?) {
    self.fittingWidth = inSize.width
    self.fittingHeight = inSize.height
    self.lastBaselineFromBottomOfFrame = inBaseline
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
