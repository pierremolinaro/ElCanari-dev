//
//  AutoLayoutVerticalStackViewWithScrollBar.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 01/10/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

class AutoLayoutVerticalStackViewWithScrollBar : ALB_NSStackView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mScrollView = ALB_NSScrollView ()
  private let mStackView = AutoLayoutVerticalStackView ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    super.init (
      horizontalDispositionInVerticalStackView: .fill,
      verticalDispositionInHorizontalStackView: .fill
    )
  //--- Set clip view
    self.mScrollView.contentView = InternalClipView ()
  //--- Set document view (SHOULD BE DONE AFTER SETTING clip view)
    self.mScrollView.documentView = self.mStackView
  //--- Set background (SHOULD BE DONE AFTER SETTING contient view)
  //--- Do not set drawsBackground and backgroundColor of a clip view !!!
  // It is also important to note that setting drawsBackground to false in an NSScrollView
  // has the added effect of setting the NSClipView property copiesOnScroll to false.
  // The side effect of setting the drawsBackground property directly to the NSClipView is the
  // appearance of “trails” (vestiges of previous drawing) in the document view as it is scrolled.
    self.mScrollView.drawsBackground = false
  //--- By default, no scroller
    self.mScrollView.hasVerticalScroller = true
  //---
    self.addSubview (self.mScrollView)
  //--- Permanent constraints
    var constraints = [NSLayoutConstraint] ()
    constraints.add (x: self.leftAnchor, equalTo: self.mScrollView.leftAnchor)
    constraints.add (x: self.rightAnchor, equalTo: self.mScrollView.rightAnchor)
    constraints.add (y: self.topAnchor, equalTo: self.mScrollView.topAnchor)
    constraints.add (y: self.bottomAnchor, equalTo: self.mScrollView.bottomAnchor)

    constraints.add (x: self.mScrollView.contentView.leftAnchor, equalTo: self.mStackView.leftAnchor)
    constraints.add (x: self.mScrollView.contentView.rightAnchor, equalTo: self.mStackView.rightAnchor)
    self.addConstraints (constraints)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final override func appendView (_ inView : NSView) -> Self {
    _ = self.mStackView.appendView (inView)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final override func prependView (_ inView : NSView) -> Self {
    _ = self.mStackView.prependView (inView)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final override func removeView (_ inView : NSView) {
    self.mStackView.removeView (inView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendGutter () -> Self {
    _ = self.mStackView.appendGutter ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendDivider (canResizeWindow inFlag : Bool = false) -> Self {
    _ = self.mStackView.appendDivider (canResizeWindow: inFlag)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendFlexibleSpace () -> Self {
    _ = self.mStackView.appendFlexibleSpace ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendSeparator (ignoreHorizontalMargins inFlag : Bool = true) -> Self {
    _ = self.mStackView.appendSeparator (ignoreHorizontalMargins: inFlag)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func prependSeparator (ignoreHorizontalMargins inFlag : Bool = true) -> Self {
    _ = self.mStackView.prependSeparator (ignoreHorizontalMargins: inFlag)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func set (spacing inValue : MarginSize) -> Self {
    _ = self.mStackView.set (spacing: inValue)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func set (margins inValue : MarginSize) -> Self {
    _ = self.mStackView.set (margins: inValue)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func set (topMargin inValue : MarginSize) -> Self {
    _ = self.mStackView.set (topMargin: inValue)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func set (bottomMargin inValue : MarginSize) -> Self {
    _ = self.mStackView.set (bottomMargin: inValue)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func set (leftMargin inValue : MarginSize) -> Self {
    _ = self.mStackView.set (leftMargin: inValue)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func set (rightMargin inValue : MarginSize) -> Self {
    _ = self.mStackView.set (rightMargin: inValue)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func appendViewSurroundedByFlexibleSpaces (_ inView : NSView) -> Self {
//    let hStack = AutoLayoutHorizontalStackView ()
//      .appendFlexibleSpace ()
//      .appendView (inView)
//      .appendFlexibleSpace ()
//    return self.appendView (hStack)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func appendViewPreceededByFlexibleSpace (_ inView : NSView) -> Self {
//    let hStack = AutoLayoutHorizontalStackView ()
//      .appendFlexibleSpace ()
//      .appendView (inView)
//    return self.appendView (hStack)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Add row with two columns
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func append (left inLeftView : NSView, right inRightView : NSView) -> Self {
//    let hStack = AutoLayoutHorizontalStackView ()
//      .appendView (inLeftView)
//      .appendGutter ()
//      .appendView (inRightView)
//    return self.appendView (hStack)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func removeAllItems () {
    self.mStackView.removeAllItems ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Flipped
  // https://stackoverflow.com/questions/4697583/setting-nsscrollview-contents-to-top-left-instead-of-bottom-left-when-document-s
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final override var isFlipped : Bool { true } // So document view is at top

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Constraints
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  private var mConstraints = [NSLayoutConstraint] ()
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  override func updateConstraints () {
//  //--- Remove all constraints
//    self.removeConstraints (self.mConstraints)
//    self.mConstraints.removeAll (keepingCapacity: true)
//  //--- Permanent constraints
//    self.mConstraints.add (x: self.leftAnchor, equalTo: self.mScrollView.leftAnchor)
//    self.mConstraints.add (x: self.rightAnchor, equalTo: self.mScrollView.rightAnchor)
//    self.mConstraints.add (y: self.topAnchor, equalTo: self.mScrollView.topAnchor)
//    self.mConstraints.add (y: self.bottomAnchor, equalTo: self.mScrollView.bottomAnchor)
//
//    self.mConstraints.add (x: self.mScrollView.contentView.leftAnchor, equalTo: self.mStackView.leftAnchor)
//    self.mConstraints.add (x: self.mScrollView.contentView.rightAnchor, equalTo: self.mStackView.rightAnchor)
//  //--- Apply constaints
//    self.addConstraints (self.mConstraints)
//  //--- This should the last instruction: call super method
//    super.updateConstraints ()
//  }

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

  final override var isFlipped : Bool { true } // So document view is at top

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
