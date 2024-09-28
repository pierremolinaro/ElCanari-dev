//
//  AutoLayoutVerticalStackView+gutter.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/08/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

let GUTTER_HEIGHT = 4.0

//--------------------------------------------------------------------------------------------------

final class VerticalStackGutter : ALB_NSView, VerticalStackHierarchyProtocol {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inRoot : (any VerticalStackHierarchyProtocol)?) {
    self.mAbove = inRoot
    super.init ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var intrinsicContentSize : NSSize {
    NSSize (width: NSView.noIntrinsicMetric, height: GUTTER_HEIGHT)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var pmLayoutSettings : AutoLayoutViewSettings {
    return AutoLayoutViewSettings (
      vLayoutInHorizontalContainer: .fill, // non significant, as h separator cannot be inside a vertical stack view
      hLayoutInVerticalContainer: .fillIgnoringMargins
    )
  }

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
  //--- Gutter
    ioContraints.add (leftOf: self, equalToLeftOf: inVerticalStackView)
    ioContraints.add (rightOf: self, equalToRightOf: inVerticalStackView)
    ioContraints.add (heightOf: self, equalTo: GUTTER_HEIGHT)
    if let lastBottomView = ioOptionalLastBottomView {
      ioContraints.add (bottomOf: lastBottomView, equalToTopOf: self, plus: inVerticalStackView.mSpacing)
    }else{
      ioContraints.add (topOf: inVerticalStackView, equalToTopOf: self, plus: inVerticalStackView.mTopMargin)
    }
  //--- After
    ioOptionalLastBottomView = self
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
    ioArray.append (ioCurrentLastBaselineView)
    ioCurrentLastBaselineView = nil
    self.mBelow?.enumerateLastBaselineViews (&ioArray, &ioCurrentLastBaselineView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
