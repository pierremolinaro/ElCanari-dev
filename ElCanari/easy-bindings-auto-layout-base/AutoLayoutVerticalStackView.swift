//
//  AutoLayoutVerticalStackView.swift
//  essai-gridview
//
//  Created by Pierre Molinaro on 30/10/2023.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

class AutoLayoutVerticalStackView : ALB_NSStackView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    super.init (
      horizontalDispositionInVerticalStackView: .fill,
      verticalDispositionInHorizontalStackView: .fill
    )
    self.addLayoutGuide (self.mStackGuide)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mStackGuide = NSLayoutGuide ()

  private var mVStackHierarchy : (any VerticalStackHierarchyProtocol)? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final override func appendView (_ inView : NSView) -> Self {
    self.addSubview (inView)
    Self.appendInVerticalHierarchy (inView, toStackRoot: &self.mVStackHierarchy)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func append (hStackWith inViews : [NSView?]) -> Self {
    let hStack = AutoLayoutHorizontalStackView ()
    for optionalView in inViews {
     if let view = optionalView {
        _ = hStack.appendView (view)
      }else{
        _ = hStack.appendFlexibleSpace ()
      }
    }
    return self.appendView (hStack)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final override func prependView (_ inView : NSView) -> Self {
    self.addSubview (inView)
    Self.prependInVerticalHierarchy (inView, toStackRoot: &self.mVStackHierarchy)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final override func removeView (_ inView : NSView) {
    for view in self.subviews {
      if view === inView {
        inView.removeFromSuperview ()
      }
    }
    self.mVStackHierarchy?.removeInVerticalHierarchy (inView)
    self.invalidateIntrinsicContentSize ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mGutterArray = [VerticalStackGutter] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendGutter () -> Self {
    let newRoot = VerticalStackGutter (self.mVStackHierarchy)
    self.mGutterArray.append (newRoot)
    self.addLayoutGuide (newRoot)
    self.mVStackHierarchy = newRoot
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendDivider (canResizeWindow inFlag : Bool = false) -> Self {
    let newRoot = VerticalStackDivider (self.mVStackHierarchy)
    self.addSubview (newRoot)
    self.mVStackHierarchy = newRoot
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendFlexibleSpace () -> Self {
    let newRoot = VerticalStackFlexibleSpace (self.mVStackHierarchy)
    self.addLayoutGuide (newRoot)
    self.mVStackHierarchy = newRoot
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendSeparator (ignoreHorizontalMargins inFlag : Bool = true) -> Self {
    let separator = VerticalStackSeparator (ignoreHorizontalMargins: inFlag)
    return self.appendView (separator)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func prependSeparator (ignoreHorizontalMargins inFlag : Bool = true) -> Self {
    let separator = VerticalStackSeparator (ignoreHorizontalMargins: inFlag)
    return self.prependView (separator)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendViewSurroundedByFlexibleSpaces (_ inView : NSView) -> Self {
    let hStack = AutoLayoutHorizontalStackView ()
      .appendFlexibleSpace ()
      .appendView (inView)
      .appendFlexibleSpace ()
    return self.appendView (hStack)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendViewPreceededByFlexibleSpace (_ inView : NSView) -> Self {
    let hStack = AutoLayoutHorizontalStackView ()
      .appendFlexibleSpace ()
      .appendView (inView)
    return self.appendView (hStack)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Add row with two columns
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func append (left inLeftView : NSView, right inRightView : NSView) -> Self {
    let hStack = AutoLayoutHorizontalStackView ()
      .appendView (inLeftView)
      .appendGutter ()
      .appendView (inRightView)
    return self.appendView (hStack)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor static
  func appendInVerticalHierarchy (_ inView : NSView,
                                  toStackRoot ioRoot : inout (any VerticalStackHierarchyProtocol)?) {
    if let root = ioRoot {
      root.appendInVerticalHierarchy (inView)
    }else{
      let root = VerticalStackSequence ()
      root.appendInVerticalHierarchy (inView)
      ioRoot = root
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor static
  func prependInVerticalHierarchy (_ inView : NSView,
                                   toStackRoot ioRoot : inout (any VerticalStackHierarchyProtocol)?) {
    if let root = ioRoot {
      root.prependInVerticalHierarchy (inView)
    }else{
      let root = VerticalStackSequence ()
      root.prependInVerticalHierarchy (inView)
      ioRoot = root
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func gutters () -> [VerticalStackGutter] {
    return self.mGutterArray
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func lastBaselineViews () -> [NSView?] {
    var array = [NSView?] ()
    var currentLastBaselineView : NSView? = nil
    self.mVStackHierarchy?.enumerateLastBaselineViews (&array, &currentLastBaselineView)
    array.append (currentLastBaselineView)
    return array
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func removeAllItems () {
    self.mVStackHierarchy = nil
    for guide in self.layoutGuides {
      if guide !== self.mStackGuide {
        self.removeLayoutGuide (guide)
      }
    }
    for view in self.subviews {
      view.removeFromSuperview ()
    }
    self.invalidateIntrinsicContentSize ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Flipped
  // https://stackoverflow.com/questions/4697583/setting-nsscrollview-contents-to-top-left-instead-of-bottom-left-when-document-s
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final override var isFlipped : Bool { true } // So document view is at top

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Constraints
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mConstraints = [NSLayoutConstraint] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func updateConstraints () {
  //--- Remove all constraints
    self.removeConstraints (self.mConstraints)
    self.mConstraints.removeAll (keepingCapacity: true)
  //--- Permanent constraints
    self.mConstraints.add (x: self.mStackGuide.leftAnchor, equalTo: self.leftAnchor, plus: self.mLeftMargin)
    self.mConstraints.add (x: self.rightAnchor, equalTo: self.mStackGuide.rightAnchor, plus: self.mRightMargin)
    self.mConstraints.add (y: self.topAnchor, equalTo: self.mStackGuide.topAnchor, plus: self.mTopMargin)
    self.mConstraints.add (y: self.mStackGuide.bottomAnchor, equalTo: self.bottomAnchor, plus: self.mBottomMargin)
  //--- Build constraints
    if let root = self.mVStackHierarchy {
      var flexibleSpaceView : VerticalStackFlexibleSpace? = nil
      var optionalLastBottomAnchor : NSLayoutYAxisAnchor? = nil
      root.buildConstraintsFor (
        verticalStackView: self.mStackGuide,
        spacing: self.mSpacing,
        optionalLastBottomAnchor: &optionalLastBottomAnchor,
        flexibleSpaceView: &flexibleSpaceView,
        &self.mConstraints
      )
      if let lastBottomAnchor = optionalLastBottomAnchor {
        self.mConstraints.add (y: lastBottomAnchor, equalTo: self.mStackGuide.bottomAnchor)
      }else{
        self.mConstraints.add (y: self.bottomAnchor, equalTo: self.topAnchor)
      }
    }else{
      self.mConstraints.add (y: self.bottomAnchor, equalTo: self.topAnchor)
    }
  //--- Align gutters
    var gutters = [HorizontalStackGutter] ()
    self.mVStackHierarchy?.alignVerticalGutters (&gutters, &self.mConstraints)
  //--- Apply constaints
    self.addConstraints (self.mConstraints)
  //--- This should the last instruction: call super method
    super.updateConstraints ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

//fileprivate final class InternalClipView : NSClipView {
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  init () {
//    super.init (frame: NSRect (x: 0, y: 0, width: 10, height: 10))
//    noteObjectAllocation (self)
//  //--- Do not set drawsBackground and backgroundColor of a clip view !!!
//  // It is also important to note that setting drawsBackground to false in an NSScrollView
//  // has the added effect of setting the NSClipView property copiesOnScroll to false.
//  // The side effect of setting the drawsBackground property directly to the NSClipView is the
//  // appearance of “trails” (vestiges of previous drawing) in the document view as it is scrolled.
//  }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  required init? (coder inCoder : NSCoder) {
//    fatalError ("init(coder:) has not been implemented")
//  }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  deinit {
//    noteObjectDeallocation (self)
//  }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  final override var isFlipped : Bool { true } // So document view is at top
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//}

//--------------------------------------------------------------------------------------------------

//fileprivate final class InternalReceiverView : ALB_NSView {
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  private weak var mRootView : AutoLayoutVerticalStackView? // Should be WEAK
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  init (rootView inRootView : AutoLayoutVerticalStackView) {
//    self.mRootView = inRootView
//    super.init ()
//  }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  required init? (coder inCoder : NSCoder) {
//    fatalError ("init(coder:) has not been implemented")
//  }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  override func invalidateIntrinsicContentSize () {
//    self.mRootView?.invalidateIntrinsicContentSize ()
//    super.invalidateIntrinsicContentSize ()
//  }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//}

//--------------------------------------------------------------------------------------------------
