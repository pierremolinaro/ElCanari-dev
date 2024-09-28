//
//  StackGutter.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class StackGutter : StackHierarchyProtocol {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inRoot : (any StackHierarchyProtocol)?, gutter inGutterView : NSView) {
    self.mBefore = inRoot
    self.mGutterView = inGutterView
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mBefore : (any StackHierarchyProtocol)?
  private let mGutterView : NSView
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
  //--- Gutter
    ioContraints.add (leftOf: self.mGutterView, equalToLeftOf: inVerticalStackView)
    ioContraints.add (rightOf: self.mGutterView, equalToRightOf: inVerticalStackView)
    ioContraints.add (heightOf: self.mGutterView, equalTo: GUTTER_HEIGHT)
    if let lastBottomView = ioOptionalLastBottomView {
      ioContraints.add (bottomOf: lastBottomView, equalToTopOf: self.mGutterView, plus: inVerticalStackView.mSpacing)
    }else{
      ioContraints.add (topOf: inVerticalStackView, equalToTopOf: self.mGutterView, plus: inVerticalStackView.mTopMargin)
    }
  //--- After
    ioOptionalLastBottomView = self.mGutterView
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
  //--- Gutter
    ioContraints.add (topOf: inHorizontalStackView, equalToTopOf: self.mGutterView)
    ioContraints.add (bottomOf: inHorizontalStackView, equalToBottomOf: self.mGutterView)
    ioContraints.add (widthOf: self.mGutterView, equalTo: GUTTER_WIDTH)
    if let lastLeftView = ioOptionalLastRightView {
      ioContraints.add (leftOf: self.mGutterView, equalToRightOf: lastLeftView, plus: inHorizontalStackView.mSpacing)
    }else{
      ioContraints.add (leftOf: self.mGutterView, equalToLeftOf: inHorizontalStackView, plus: inHorizontalStackView.mLeftMargin)
    }
  //--- After
    ioOptionalLastRightView = self.mGutterView
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

