//
//  ALB_NSStackView.swift
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
    self.mVerticalDisposition = .lastBaseline
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.pmConfigureForAutolayout (hStretchingResistance: .lowest, vStrechingResistance: .high)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  enum HorizontalLayoutInVerticalCollectionView {
    case center
    case fillIgnoringMargins
    case fill
    case left
    case right
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  enum VerticalLayoutInHorizontalCollectionView {
    case center
    case fillIgnoringMargins
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

  final func appendView (_ inView : NSView) -> Self {
    self.addSubview (inView)
    self.invalidateIntrinsicContentSize ()
    Self.append (inView, toStackRoot: &self.mInternalStackRoot)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func prependView (_ inView : NSView) -> Self {
    self.addSubview (inView, positioned: .below, relativeTo: nil)
    self.invalidateIntrinsicContentSize ()
    Self.prepend (inView, toStackRoot: &self.mInternalStackRoot)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var mInternalStackRoot : (any StackRootProtocol)? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor static
  func append (_ inView : NSView,
               toStackRoot ioRoot : inout (any StackRootProtocol)?) {
    if let root = ioRoot {
      root.append (inView)
    }else{
      let root = StackSequence ()
      root.append (inView)
      ioRoot = root
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor static
  func prepend (_ inView : NSView,
                toStackRoot ioRoot : inout (any StackRootProtocol)?) {
    if let root = ioRoot {
      root.prepend (inView)
    }else{
      let root = StackSequence ()
      root.prepend (inView)
      ioRoot = root
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func removeView (_ inView : NSView) {
    for view in self.subviews {
      if view === inView {
        inView.removeFromSuperview ()
      }
    }
    self.mInternalStackRoot?.remove (inView)
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func set (width inWidth : Int) -> Self {
    let c = NSLayoutConstraint (
      item: self,
      attribute: .width,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: CGFloat (inWidth)
    )
    self.addConstraint (c)
    return self
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func set (minWidth inWidth : Int) -> Self {
    let c = NSLayoutConstraint (
      item: self,
      attribute: .width,
      relatedBy: .greaterThanOrEqual,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: CGFloat (inWidth)
    )
    self.addConstraint (c)
    return self
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func set (minHeight inHeight : Int) -> Self {
    let c = NSLayoutConstraint (
      item: self,
      attribute: .height,
      relatedBy: .greaterThanOrEqual,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: CGFloat (inHeight)
    )
    self.addConstraint (c)
    return self
  }
  
  // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  final func isFlexibleSpace (_ inView : NSView) -> Bool {
    return inView is AutoLayoutFlexibleSpace
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Changing isHidden does not invalidate constraints !!!!
  // So we perform this operation manually
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func viewDidHide () {
    if let superview = self.superview, !superview.isHidden {
      superview.invalidateIntrinsicContentSize ()
      buildResponderKeyChainForWindowThatContainsView (self)
    }
    super.viewDidHide ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func viewDidUnhide () {
    if let superview = self.superview, !superview.isHidden {
      superview.invalidateIntrinsicContentSize ()
    }
    super.viewDidUnhide ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func removeFromSuperview () {
    buildResponderKeyChainForWindowThatContainsView (self)
    super.removeFromSuperview ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
