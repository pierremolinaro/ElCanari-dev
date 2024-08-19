//
//  PMAbstractStackView.swift
//  essai-gridview
//
//  Created by Pierre Molinaro on 01/11/2023.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
// http://marginalfutility.net/2018/07/01/alignment-rects/
//--------------------------------------------------------------------------------------------------

class ALB_NSStackView : NSView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    self.mHorizontalDisposition = .fill
    self.mVerticalDisposition = .fill
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.pmConfigureForAutolayout (hStretchingResistance: .lowest, vStrechingResistance: .lowest)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (horizontal inHorizontalDisposition : HorizontalLayoutInVerticalCollectionView,
        vertical inVerticalDisposition : VerticalLayoutInHorizontalCollectionView) {
    self.mHorizontalDisposition = inHorizontalDisposition
    self.mVerticalDisposition = inVerticalDisposition
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.pmConfigureForAutolayout (hStretchingResistance: .lowest, vStrechingResistance: .lowest)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  enum HorizontalLayoutInVerticalCollectionView {
    case center
    case weakFill
    case weakFillIgnoringMargins
    case fill
    case left
    case right
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  enum VerticalLayoutInHorizontalCollectionView {
    case center
    case weakFill
    case weakFillIgnoringMargins
    case fill
    case lastBaseline
    case top
    case bottom
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let mHorizontalDisposition : HorizontalLayoutInVerticalCollectionView
  let mVerticalDisposition : VerticalLayoutInHorizontalCollectionView

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init?(coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
    objectDidDeinitSoReleaseHiddenControllers ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  override var intrinsicContentSize : NSSize { NSSize (width: 1, height: 1) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendView (_ inView : NSView) -> Self {
    self.addSubview (inView)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func prependView (_ inView : NSView) -> Self {
    self.addSubview (inView, positioned: .below, relativeTo: nil)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendFlexibleSpace () -> Self {
    self.addSubview (AutoLayoutFlexibleSpace ())
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func removeView (_ inView : NSView) {
    for view in self.subviews {
      if view === inView {
        inView.removeFromSuperview ()
      }
    }
    self.invalidateIntrinsicContentSize ()
  }

  //····················································································································
  //  MARGINS
  //····················································································································

  private(set) var mLeftMargin : CGFloat = 0.0
  private(set) var mRightMargin : CGFloat = 0.0
  private(set) var mTopMargin : CGFloat = 0.0
  private(set) var mBottomMargin : CGFloat = 0.0
  private(set) var mSpacing : CGFloat = MarginSize.regular.floatValue

  //····················································································································

  final func set (spacing inValue : MarginSize) -> Self {
    self.mSpacing = inValue.floatValue
    self.invalidateIntrinsicContentSize ()
    return self
  }

  //····················································································································

  final func set (margins inValue : MarginSize) -> Self {
    let v = inValue.floatValue
    self.mLeftMargin   = v
    self.mBottomMargin = v
    self.mTopMargin    = v
    self.mRightMargin  = v
    self.invalidateIntrinsicContentSize ()
    return self
  }

  //····················································································································

  final func set (topMargin inValue : MarginSize) -> Self {
    self.mTopMargin = inValue.floatValue
    self.invalidateIntrinsicContentSize ()
    return self
  }

  //····················································································································

  final func set (bottomMargin inValue : MarginSize) -> Self {
    self.mBottomMargin = inValue.floatValue
    self.invalidateIntrinsicContentSize ()
    return self
  }

  //····················································································································

  final func set (leftMargin inValue : MarginSize) -> Self {
    self.mLeftMargin = inValue.floatValue
    self.invalidateIntrinsicContentSize ()
    return self
  }

  //····················································································································

  final func set (rightMargin inValue : MarginSize) -> Self {
    self.mRightMargin = inValue.floatValue
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·
  // Draw
  // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  override func draw (_ inDirtyRect : NSRect) {
    super.draw (inDirtyRect)
    if debugAutoLayout () && !self.bounds.isEmpty {
    //--- Top margin
      DEBUG_MARGIN_COLOR.setFill ()
      if self.mBottomMargin > 0.0 {
        var r = self.bounds
        r.origin.y += r.size.height - self.mBottomMargin
        r.size.height = self.mBottomMargin
        NSBezierPath.fill (r)
      }
      if self.mTopMargin > 0.0 {
        var r = self.bounds
        r.size.height = self.mTopMargin
        NSBezierPath.fill (r)
      }
      if self.mLeftMargin > 0.0 {
        var r = self.bounds
        r.size.width = self.mLeftMargin
        NSBezierPath.fill (r)
      }
      if self.mRightMargin > 0.0 {
        var r = self.bounds
        r.origin.x += r.size.width - self.mRightMargin
        r.size.width = self.mRightMargin
        NSBezierPath.fill (r)
      }
    //--- Frame
      let bp = NSBezierPath (rect: self.bounds)
      bp.lineWidth = 1.0
      bp.lineJoinStyle = .round
      DEBUG_STROKE_COLOR.setStroke ()
      bp.stroke ()
    }
  }

  // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  final func isFlexibleSpace (_ inView : NSView) -> Bool {
    return inView is AutoLayoutFlexibleSpace
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
