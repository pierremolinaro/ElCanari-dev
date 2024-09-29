//
//  AutoLayoutHorizontalStackView+flexiblespace.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class HorizontalStackFlexibleSpace : NSLayoutGuide, HorizontalStackHierarchyProtocol {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inRoot : (any HorizontalStackHierarchyProtocol)?) {
    self.mLeft = inRoot
    super.init ()
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder: NSCoder) {
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
  //--- Flexible space
    ioContraints.add (topOfView: inHorizontalStackView, equalToTopOfGuide: self, plus: inHorizontalStackView.mTopMargin)
    ioContraints.add (bottomOfGuide: self, equalToBottomOfView: inHorizontalStackView, plus: inHorizontalStackView.mBottomMargin)
    if let lastSpace = ioFlexibleSpaceView {
      ioContraints.add (widthOfGuide: lastSpace, equalToWidthOfGuide: self)
    }
    ioFlexibleSpaceView = self
    if let lastLeftView = ioOptionalLastRightView {
//      if lastLeftView is Self {
//        ioContraints.add (leftOf: self, equalToRightOf: lastLeftView)
//      }else{
      ioContraints.add (leftOfGuide: self, equalToAnchor: lastLeftView, plus: inHorizontalStackView.mSpacing)
//      }
    }else{
      ioContraints.add (leftOfGuide: self, equalToLeftOfView: inHorizontalStackView, plus: inHorizontalStackView.mLeftMargin)
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

