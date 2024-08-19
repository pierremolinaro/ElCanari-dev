//
//  PMAbstractStackView.swift
//  essai-gridview
//
//  Created by Pierre Molinaro on 01/11/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// http://marginalfutility.net/2018/07/01/alignment-rects/
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class ALB_NSStackView : NSView {

  //--------------------------------------------------------------------------------------------------------------------

  init () {
    self.mHorizontalDisposition = .fill
    self.mVerticalDisposition = .fill
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.pmConfigureForAutolayout (hStretchingResistance: .lowest, vStrechingResistance: .lowest)
  }

  //--------------------------------------------------------------------------------------------------------------------

  init (horizontal inHorizontalDisposition : HorizontalLayoutInVerticalCollectionView,
        vertical inVerticalDisposition : VerticalLayoutInHorizontalCollectionView) {
    self.mHorizontalDisposition = inHorizontalDisposition
    self.mVerticalDisposition = inVerticalDisposition
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.pmConfigureForAutolayout (hStretchingResistance: .lowest, vStrechingResistance: .lowest)
  }

  //--------------------------------------------------------------------------------------------------------------------

  enum MarginSize : Int {
    case none = 0
    case small = 4
    case regular = 8
    case large = 12
  }

  //--------------------------------------------------------------------------------------------------------------------

  enum HorizontalLayoutInVerticalCollectionView {
    case center
    case weakFill
    case weakFillIgnoringMargins
    case fill
    case left
    case right
  }

  //--------------------------------------------------------------------------------------------------------------------

  enum VerticalLayoutInHorizontalCollectionView {
    case center
    case weakFill
    case weakFillIgnoringMargins
    case fill
    case lastBaseline
    case top
    case bottom
  }

  //--------------------------------------------------------------------------------------------------------------------

  let mHorizontalDisposition : HorizontalLayoutInVerticalCollectionView
  let mVerticalDisposition : VerticalLayoutInHorizontalCollectionView

  //--------------------------------------------------------------------------------------------------------------------

  required init?(coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
    objectDidDeinitSoReleaseHiddenControllers ()
  }

  //--------------------------------------------------------------------------------------------------------------------

  override var intrinsicContentSize : NSSize { NSSize (width: 1, height: 1) }

  //--------------------------------------------------------------------------------------------------------------------

  func appendView (_ inView : NSView) -> Self {
    self.addSubview (inView)
    return self
  }

  //--------------------------------------------------------------------------------------------------------------------

  func prependView (_ inView : NSView) -> Self {
    self.addSubview (inView, positioned: .below, relativeTo: nil)
    return self
  }

  //--------------------------------------------------------------------------------------------------------------------

  final func appendFlexibleSpace () -> Self {
    self.addSubview (PMFlexibleSpace ())
    return self
  }

  //--------------------------------------------------------------------------------------------------------------------

  final func removeView (_ inView : NSView) {
     for view in self.subviews {
       if view === inView {
         inView.removeFromSuperview ()
       }
     }
  }

  //····················································································································
  //  MARGINS
  //····················································································································

  private(set) var mLeftMargin : CGFloat = 0.0
  private(set) var mRightMargin : CGFloat = 0.0
  private(set) var mTopMargin : CGFloat = 0.0
  private(set) var mBottomMargin : CGFloat = 0.0
  private(set) var mSpacing : CGFloat = 4.0

  //····················································································································

  final func set (spacing inValue : Int) -> Self {
    self.mSpacing = CGFloat (inValue)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  //····················································································································

  final func set (margins inValue : MarginSize) -> Self {
    let v = CGFloat (inValue.rawValue)
    self.mLeftMargin   = v
    self.mBottomMargin = v
    self.mTopMargin    = v
    self.mRightMargin  = v
    self.invalidateIntrinsicContentSize ()
    return self
  }

  //····················································································································

  final func set (topMargin inValue : MarginSize) -> Self {
    self.mTopMargin = CGFloat (inValue.rawValue)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  //····················································································································

  final func set (bottomMargin inValue : MarginSize) -> Self {
    self.mBottomMargin = CGFloat (inValue.rawValue)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  //····················································································································

  final func set (leftMargin inValue : MarginSize) -> Self {
    self.mLeftMargin = CGFloat (inValue.rawValue)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  //····················································································································

  final func set (rightMargin inValue : MarginSize) -> Self {
    self.mRightMargin = CGFloat (inValue.rawValue)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func set (margins inValue : Int) -> Self {
    let v = CGFloat (inValue)
    self.mTopMargin    = v
    self.mLeftMargin   = v
    self.mBottomMargin = v
    self.mRightMargin  = v
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func set (topMargin inValue : Int) -> Self {
    self.mTopMargin = CGFloat (inValue)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func set (bottomMargin inValue : Int) -> Self {
    self.mBottomMargin = CGFloat (inValue)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func set (leftMargin inValue : Int) -> Self {
    self.mLeftMargin = CGFloat (inValue)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func set (rightMargin inValue : Int) -> Self {
    self.mRightMargin = CGFloat (inValue)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  //--------------------------------------------------------------------------------------------------------------------
  // Draw
  //--------------------------------------------------------------------------------------------------------------------

//  override func draw (_ inDirtyRect : NSRect) {
//    var flag = true
//    var v : NSView? = self.superview
//    while let superview = v?.superview {
//      v = superview
//      flag.toggle ()
//    }
//    let color = flag ? NSColor.orange : NSColor.yellow
//    color.setFill ()
//    inDirtyRect.fill ()
//    super.draw (inDirtyRect)
//  }

  //--------------------------------------------------------------------------------------------------------------------

  final func isFlexibleSpace (_ inView : NSView) -> Bool {
    return inView is PMFlexibleSpace
  }

  //--------------------------------------------------------------------------------------------------------------------

  @MainActor private class PMFlexibleSpace : NSView {

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    @MainActor init () {
      super.init (frame: .zero)
      self.pmConfigureForAutolayout (hStretchingResistance: .lowest, vStrechingResistance: .lowest)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    required init? (coder: NSCoder) {
      fatalError ("init(coder:) has not been implemented")
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

//    override var intrinsicContentSize : NSSize { NSSize () }
    
    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    private static let mFlexibleSpaceLayoutSettings = AutoLayoutViewSettings (
      vLayoutInHorizontalContainer: .weakFill,
      hLayoutInVerticalContainer: .weakFill
    )

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var pmLayoutSettings : AutoLayoutViewSettings { Self.mFlexibleSpaceLayoutSettings }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override func draw (_ inDirtyRect : NSRect) {
      super.draw (inDirtyRect)
      if !self.bounds.isEmpty {
        NSColor.orange.setFill ()
        self.bounds.fill ()
      }
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  }

  //--------------------------------------------------------------------------------------------------------------------

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
