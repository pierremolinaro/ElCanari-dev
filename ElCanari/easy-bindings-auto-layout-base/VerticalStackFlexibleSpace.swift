//
//  AutoLayoutVerticalStackView+flexiblespace.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class VerticalStackFlexibleSpace : ALB_NSView, VerticalStackHierarchyProtocol {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inRoot : (any VerticalStackHierarchyProtocol)?) {
    self.mAbove = inRoot
    super.init ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private static let mFlexibleSpaceLayoutSettings = AutoLayoutViewSettings (
    vLayoutInHorizontalContainer: .fill,
    hLayoutInVerticalContainer: .fill
  )

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var pmLayoutSettings : AutoLayoutViewSettings { Self.mFlexibleSpaceLayoutSettings }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mAbove : (any VerticalStackHierarchyProtocol)?
  private var mBelow : (any VerticalStackHierarchyProtocol)? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendInVerticalHierarchy (_ inView : NSView) {
    AutoLayoutVerticalStackView.appendInVerticalHierarchy (inView, toStackRoot: &self.mBelow)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func prependInVerticalHierarchy (_ inView : NSView) {
    AutoLayoutVerticalStackView.prependInVerticalHierarchy (inView, toStackRoot: &self.mAbove)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func removeInVerticalHierarchy (_ inView : NSView) {
    self.mAbove?.removeInVerticalHierarchy (inView)
    self.mBelow?.removeInVerticalHierarchy (inView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func buildConstraintsFor (verticalStackView inVerticalStackView : AutoLayoutVerticalStackView,
                            optionalLastBottomView ioOptionalLastBottomView : inout NSView?,
                            flexibleSpaceView ioFlexibleSpaceView : inout VerticalStackFlexibleSpace?,
                            _ ioContraints : inout [NSLayoutConstraint]) {
  //--- Before
    self.mAbove?.buildConstraintsFor (
      verticalStackView: inVerticalStackView,
      optionalLastBottomView: &ioOptionalLastBottomView,
      flexibleSpaceView: &ioFlexibleSpaceView,
      &ioContraints
    )
  //--- Flexible space
    ioContraints.add (leftOf: self, equalToLeftOf: inVerticalStackView)
    ioContraints.add (rightOf: inVerticalStackView, equalToRightOf: self)
    if let lastSpace = ioFlexibleSpaceView {
      ioContraints.add (heightOf: lastSpace, equalToHeightOf: self)
    }
    if let lastBottomView = ioOptionalLastBottomView {
      ioContraints.add (bottomOf: lastBottomView, equalToTopOf: self, plus: inVerticalStackView.mSpacing)
    }else{
      ioContraints.add (topOf: inVerticalStackView, equalToTopOf: self, plus: inVerticalStackView.mTopMargin)
    }
    ioOptionalLastBottomView = self
    ioFlexibleSpaceView = self
  //--- After
    self.mBelow?.buildConstraintsFor (
      verticalStackView: inVerticalStackView,
      optionalLastBottomView: &ioOptionalLastBottomView,
      flexibleSpaceView: &ioFlexibleSpaceView,
      &ioContraints
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func enumerateLastBaselineViews (_ ioArray : inout [NSView?],
                                   _ ioCurrentLastBaselineView : inout NSView?) {
    self.mAbove?.enumerateLastBaselineViews (&ioArray, &ioCurrentLastBaselineView)
    self.mBelow?.enumerateLastBaselineViews (&ioArray, &ioCurrentLastBaselineView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignVerticalGutters (_ ioGutters : inout [HorizontalStackGutter],
                             _ ioContraints : inout [NSLayoutConstraint]) {
    self.mAbove?.alignVerticalGutters (&ioGutters, &ioContraints)
    self.mBelow?.alignVerticalGutters (&ioGutters, &ioContraints)
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

