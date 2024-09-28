//
//  StackDivider.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class StackDivider : StackRootProtocol {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inRoot : (any StackRootProtocol)?, divider inDivider : NSView) {
    self.mBefore = inRoot
    self.mDividerView = inDivider
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mBefore : (any StackRootProtocol)?
  private let mDividerView : NSView
  private var mAfter : (any StackRootProtocol)? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendInHierarchy (_ inView : NSView) {
    ALB_NSStackView.appendInHierarchy (inView, toStackRoot: &self.mAfter)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func prependInHierarchy (_ inView : NSView) {
    ALB_NSStackView.prependInHierarchy (inView, toStackRoot: &self.mBefore)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func removeInHierarchy (_ inView : NSView) {
    self.mBefore?.removeInHierarchy (inView)
    self.mAfter?.removeInHierarchy (inView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func buildConstraintsFor (verticalStackView inVerticalStackView : AutoLayoutVerticalStackView,
                            optionalLastBottomView ioOptionalLastBottomView : inout NSView?,
                            flexibleSpaceView ioFlexibleSpaceView : inout AutoLayoutFlexibleSpace?,
                            _ ioContraints : inout [NSLayoutConstraint]) {
  //--- Before
    self.mBefore?.buildConstraintsFor (
      verticalStackView: inVerticalStackView,
      optionalLastBottomView: &ioOptionalLastBottomView,
      flexibleSpaceView: &ioFlexibleSpaceView,
      &ioContraints
    )
  //--- Divider
    ioContraints.add (leftOf: self.mDividerView, equalToLeftOf: inVerticalStackView)
    ioContraints.add (rightOf: inVerticalStackView, equalToRightOf: self.mDividerView)
    ioContraints.add (heightOf: self.mDividerView, equalTo: DIVIDER_HEIGHT)
    if let lastBottomView = ioOptionalLastBottomView {
      ioContraints.add (bottomOf: lastBottomView, equalToTopOf: self.mDividerView, plus: inVerticalStackView.mSpacing)
    }else{
      ioContraints.add (topOf: inVerticalStackView, equalToTopOf: self.mDividerView, plus: inVerticalStackView.mTopMargin)
    }
  //--- After
    ioOptionalLastBottomView = self.mDividerView
    self.mAfter?.buildConstraintsFor (
      verticalStackView: inVerticalStackView,
      optionalLastBottomView: &ioOptionalLastBottomView,
      flexibleSpaceView: &ioFlexibleSpaceView,
      &ioContraints
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func buildConstraintsFor (horizontalStackView inHorizontalStackView : AutoLayoutHorizontalStackView,
                            optionalLastRightView ioOptionalLastRightView : inout NSView?,
                            flexibleSpaceView ioFlexibleSpaceView : inout AutoLayoutFlexibleSpace?,
                            _ ioContraints : inout [NSLayoutConstraint]) {
  //--- Before
    self.mBefore?.buildConstraintsFor (
      horizontalStackView: inHorizontalStackView,
      optionalLastRightView: &ioOptionalLastRightView,
      flexibleSpaceView: &ioFlexibleSpaceView,
      &ioContraints
    )
  //--- Divider
    ioContraints.add (topOf: inHorizontalStackView, equalToTopOf: self.mDividerView)
    ioContraints.add (bottomOf: inHorizontalStackView, equalToBottomOf: self.mDividerView)
    ioContraints.add (widthOf: self.mDividerView, equalTo: DIVIDER_WIDTH)
    if let lastLeftView = ioOptionalLastRightView {
      ioContraints.add (leftOf: self.mDividerView, equalToRightOf: lastLeftView, plus: inHorizontalStackView.mSpacing)
    }else{
      ioContraints.add (leftOf: self.mDividerView, equalToLeftOf: inHorizontalStackView, plus: inHorizontalStackView.mLeftMargin)
    }
  //--- After
    ioOptionalLastRightView = self.mDividerView
    self.mAfter?.buildConstraintsFor (
      horizontalStackView: inHorizontalStackView,
      optionalLastRightView: &ioOptionalLastRightView,
      flexibleSpaceView: &ioFlexibleSpaceView,
      &ioContraints
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

