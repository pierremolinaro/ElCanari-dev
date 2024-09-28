//
//  StackSpace.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class StackSpace : StackHierarchyProtocol {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inRoot : (any StackHierarchyProtocol)?,
        flexibleSpaceView inFlexibleSpaceView : AutoLayoutFlexibleSpace) {
    self.mBefore = inRoot
    self.mFlexibleSpaceView = inFlexibleSpaceView
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mBefore : (any StackHierarchyProtocol)?
  private let mFlexibleSpaceView : AutoLayoutFlexibleSpace
  private var mAfter : (any StackHierarchyProtocol)? = nil

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
  //--- Flexible space
    ioContraints.add (leftOf: self.mFlexibleSpaceView, equalToLeftOf: inVerticalStackView)
    ioContraints.add (rightOf: inVerticalStackView, equalToRightOf: self.mFlexibleSpaceView)
    if let lastSpace = ioFlexibleSpaceView {
      ioContraints.add (heightOf: lastSpace, equalToHeightOf: self.mFlexibleSpaceView)
    }
    if let lastBottomView = ioOptionalLastBottomView {
      ioContraints.add (bottomOf: lastBottomView, equalToTopOf: self.mFlexibleSpaceView, plus: inVerticalStackView.mSpacing)
    }else{
      ioContraints.add (topOf: inVerticalStackView, equalToTopOf: self.mFlexibleSpaceView, plus: inVerticalStackView.mTopMargin)
    }
    ioFlexibleSpaceView = self.mFlexibleSpaceView
  //--- After
    ioOptionalLastBottomView = self.mFlexibleSpaceView
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
  //--- Flexible space
    ioContraints.add (topOf: inHorizontalStackView, equalToTopOf: self.mFlexibleSpaceView)
    ioContraints.add (bottomOf: inHorizontalStackView, equalToBottomOf: self.mFlexibleSpaceView)
    if let lastSpace = ioFlexibleSpaceView {
      ioContraints.add (widthOf: lastSpace, equalToWidthOf: self.mFlexibleSpaceView)
    }
    if let lastLeftView = ioOptionalLastRightView {
      ioContraints.add (leftOf: self.mFlexibleSpaceView, equalToRightOf: lastLeftView, plus: inHorizontalStackView.mSpacing)
    }else{
      ioContraints.add (leftOf: self.mFlexibleSpaceView, equalToLeftOf: inHorizontalStackView, plus: inHorizontalStackView.mLeftMargin)
    }
    ioFlexibleSpaceView = self.mFlexibleSpaceView
  //--- After
    ioOptionalLastRightView = self.mFlexibleSpaceView
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
