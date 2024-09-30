//
//  AutoLayoutHorizontalStackView+gutter.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/08/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

let GUTTER_WIDTH = 4.0

//--------------------------------------------------------------------------------------------------

final class HorizontalStackGutter : NSLayoutGuide, HorizontalStackHierarchyProtocol {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inRoot : (any HorizontalStackHierarchyProtocol)?) {
    self.mLeft = inRoot
    super.init ()
    noteObjectAllocation (self)
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

  private var mLeft : (any HorizontalStackHierarchyProtocol)?
  private var mRight : (any HorizontalStackHierarchyProtocol)? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendInHorizontalHierarchy (_ inView : NSView) {
    AutoLayoutHorizontalStackView.appendInHorizontalHierarchy (inView, toStackRoot: &self.mRight)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func prependInHorizontalHierarchy (_ inView : NSView) {
    AutoLayoutHorizontalStackView.prependInHorizontalHierarchy (inView, toStackRoot: &self.mLeft)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func removeInHorizontalHierarchy (_ inView : NSView) {
    self.mLeft?.removeInHorizontalHierarchy (inView)
    self.mRight?.removeInHorizontalHierarchy (inView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func buildConstraintsFor (horizontalStackView inHorizontalStackView : AutoLayoutHorizontalStackView,
                            optionalLastRightView ioOptionalLastRightView : inout NSLayoutXAxisAnchor?,
                            flexibleSpaceView ioFlexibleSpaceView : inout HorizontalStackFlexibleSpace?,
                            _ ioContraints : inout [NSLayoutConstraint]) {
  //--- Before
    self.mLeft?.buildConstraintsFor (
      horizontalStackView: inHorizontalStackView,
      optionalLastRightView: &ioOptionalLastRightView,
      flexibleSpaceView: &ioFlexibleSpaceView,
      &ioContraints
    )
  //--- Gutter
    ioContraints.add (y: inHorizontalStackView.topAnchor, equalTo: self.topAnchor)
    ioContraints.add (y: inHorizontalStackView.bottomAnchor, equalTo: self.bottomAnchor)
    ioContraints.add (dim: self.widthAnchor, equalToConstant: GUTTER_WIDTH)
    if let lastLeftView = ioOptionalLastRightView {
      ioContraints.add (x: self.leftAnchor, equalTo: lastLeftView, plus: inHorizontalStackView.mSpacing)
    }else{
//      ioContraints.add (leftOfGuide: self, equalToLeftOfView: inHorizontalStackView, plus: inHorizontalStackView.mLeftMargin)
      ioContraints.add (x: self.leftAnchor, equalTo: inHorizontalStackView.leftAnchor, plus: inHorizontalStackView.mLeftMargin)
    }
  //--- After
    ioOptionalLastRightView = self.rightAnchor
    self.mRight?.buildConstraintsFor (
      horizontalStackView: inHorizontalStackView,
      optionalLastRightView: &ioOptionalLastRightView,
      flexibleSpaceView: &ioFlexibleSpaceView,
      &ioContraints
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignHorizontalGutters (_ ioGutters : inout [VerticalStackGutter],
                               _ ioLastBaselineViews : inout [NSView?],
                               _ ioContraints : inout [NSLayoutConstraint]) {
    self.mLeft?.alignHorizontalGutters (&ioGutters, &ioLastBaselineViews, &ioContraints)
    self.mRight?.alignHorizontalGutters (&ioGutters, &ioLastBaselineViews, &ioContraints)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
