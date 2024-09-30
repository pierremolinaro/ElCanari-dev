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

  init (verticalScroller inVerticalScroller : Bool = false) {
    self.mScrollView = inVerticalScroller ? ALB_NSScrollView () : nil
    super.init (
      horizontalDispositionInVerticalStackView: .fill,
      verticalDispositionInHorizontalStackView: .fill
    )
    if let scrollView = self.mScrollView {
   //--- Set document view
      let documentView = AutoLayoutVerticalStackView ()
      scrollView.documentView = documentView
    //--- Set clip view (SHOULD BE DONE AFTER SETTING document view)
      scrollView.contentView = InternalClipView ()
    //--- Set background (SHOULD BE DONE AFTER SETTING contient view)
      scrollView.drawsBackground = false
//      scrollView.backgroundColor = NSColor.red
      scrollView.hasVerticalScroller = true

      self.addSubview (scrollView)
    //--- Constraints
//      var constraints = [NSLayoutConstraint] ()
//      self.mPermanentsConstraints.add (x: self.leftAnchor, equalTo: scrollView.leftAnchor)
//      self.mPermanentsConstraints.add (x: self.rightAnchor, equalTo: scrollView.rightAnchor)
//      self.mPermanentsConstraints.add (y: self.topAnchor, equalTo: scrollView.topAnchor)
//      self.mPermanentsConstraints.add (y: self.bottomAnchor, equalTo: scrollView.bottomAnchor)

//      self.mPermanentsConstraints.add (x: documentView.leftAnchor, equalTo: scrollView.contentView.leftAnchor)
//      self.mPermanentsConstraints.add (x: documentView.rightAnchor, equalTo: scrollView.contentView.rightAnchor)
//      self.mPermanentsConstraints.add (y: documentView.topAnchor, equalTo: scrollView.contentView.topAnchor)
//      self.addConstraints (constraints)

    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  private var mPermanentsConstraints = [NSLayoutConstraint] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mScrollView : ALB_NSScrollView?

  private var receiverView : AutoLayoutVerticalStackView {
    return (self.mScrollView?.documentView as? AutoLayoutVerticalStackView) ?? self
  }

  private var mVStackHierarchy : (any VerticalStackHierarchyProtocol)? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final override func appendView (_ inView : NSView) -> Self {
    self.receiverView.addSubview (inView)
    Self.appendInVerticalHierarchy (inView, toStackRoot: &self.mVStackHierarchy)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final override func prependView (_ inView : NSView) -> Self {
    self.receiverView.addSubview (inView)
    Self.prependInVerticalHierarchy (inView, toStackRoot: &self.mVStackHierarchy)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final override func removeView (_ inView : NSView) {
    for view in self.receiverView.subviews {
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
    self.receiverView.addLayoutGuide (newRoot)
    self.mVStackHierarchy = newRoot
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendDivider (canResizeWindow inFlag : Bool = false) -> Self {
    let newRoot = VerticalStackDivider (self.mVStackHierarchy)
    self.receiverView.addSubview (newRoot)
    self.mVStackHierarchy = newRoot
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendFlexibleSpace () -> Self {
    let newRoot = VerticalStackFlexibleSpace (self.mVStackHierarchy)
    self.receiverView.addLayoutGuide (newRoot)
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

  //····················································································································
  // Flipped
  // https://stackoverflow.com/questions/4697583/setting-nsscrollview-contents-to-top-left-instead-of-bottom-left-when-document-s
  //····················································································································

  final override var isFlipped : Bool { true }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Last Baseline representative view
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  private var mLastBaselineRepresentativeView : NSView? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  override var lastBaselineRepresentativeView : NSView? { self.mLastBaselineRepresentativeView }

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
  //  Constraints
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mConstraints = [NSLayoutConstraint] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func updateConstraints () {
  //--- Remove all constraints
    self.removeConstraints (self.mConstraints)
    self.mConstraints.removeAll (keepingCapacity: true)
  //--- Permanent constraints
    if let scrollView = self.mScrollView {
      self.mConstraints.add (x: self.leftAnchor, equalTo: scrollView.leftAnchor)
      self.mConstraints.add (x: self.rightAnchor, equalTo: scrollView.rightAnchor)
      self.mConstraints.add (y: self.topAnchor, equalTo: scrollView.topAnchor)
      self.mConstraints.add (y: self.bottomAnchor, equalTo: scrollView.bottomAnchor)
    }
  //--- Build constraints
    let vStack = self.receiverView
    if let root = self.mVStackHierarchy {
      var flexibleSpaceView : VerticalStackFlexibleSpace? = nil
      var optionalLastBottomAnchor : NSLayoutYAxisAnchor? = nil
      root.buildConstraintsFor (
        verticalStackView: vStack,
        optionalLastBottomAnchor: &optionalLastBottomAnchor,
        flexibleSpaceView: &flexibleSpaceView,
        &self.mConstraints
      )
      if let lastBottomAnchor = optionalLastBottomAnchor {
        self.mConstraints.add (y: lastBottomAnchor, equalTo: vStack.bottomAnchor, plus: self.mBottomMargin)
      }else{
        self.mConstraints.add (y: vStack.bottomAnchor, equalTo: vStack.topAnchor)
      }
    }else{
      self.mConstraints.add (y: vStack.bottomAnchor, equalTo: vStack.topAnchor)
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

fileprivate final class InternalClipView : NSClipView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    super.init (frame: NSRect (x: 0, y: 0, width: 10, height: 10))
    noteObjectAllocation (self)
  //--- Do not set drawsBackground and backgroundColor of a clip view !!!
  // It is also important to note that setting drawsBackground to false in an NSScrollView
  // has the added effect of setting the NSClipView property copiesOnScroll to false.
  // The side effect of setting the drawsBackground property directly to the NSClipView is the
  // appearance of “trails” (vestiges of previous drawing) in the document view as it is scrolled.
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

}

//--------------------------------------------------------------------------------------------------
