//
//  AutoLayoutHorizontalStackView+flexiblespace.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutHorizontalStackView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // FlexibleSpace internal class
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final class FlexibleSpace : NSView, HorizontalStackHierarchyProtocol {

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    init (_ inRoot : (any HorizontalStackHierarchyProtocol)?) {
      self.mLeft = inRoot
      super.init (frame: .zero)
      noteObjectAllocation (self)
      self.pmConfigureForAutolayout (hStretchingResistance: .lowest, vStrechingResistance: .lowest)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    required init? (coder: NSCoder) {
      fatalError ("init(coder:) has not been implemented")
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    deinit {
      noteObjectDeallocation (self)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    private var mLeft : (any HorizontalStackHierarchyProtocol)?
    private var mRight : (any HorizontalStackHierarchyProtocol)? = nil

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    func appendInHorizontalHierarchy (_ inView : NSView) {
      AutoLayoutHorizontalStackView.appendInHorizontalHierarchy (inView, toStackRoot: &self.mRight)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    func prependInHorizontalHierarchy (_ inView : NSView) {
      AutoLayoutHorizontalStackView.prependInHorizontalHierarchy (inView, toStackRoot: &self.mLeft)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    func removeInHorizontalHierarchy (_ inView : NSView) {
      self.mLeft?.removeInHorizontalHierarchy (inView)
      self.mRight?.removeInHorizontalHierarchy (inView)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    func buildConstraintsFor (horizontalStackView inHorizontalStackView : AutoLayoutHorizontalStackView,
                              optionalLastRightView ioOptionalLastRightView : inout NSView?,
                              flexibleSpaceView ioFlexibleSpaceView : inout AutoLayoutHorizontalStackView.FlexibleSpace?,
                              _ ioContraints : inout [NSLayoutConstraint]) {
      //--- Before
      self.mLeft?.buildConstraintsFor (
        horizontalStackView: inHorizontalStackView,
        optionalLastRightView: &ioOptionalLastRightView,
        flexibleSpaceView: &ioFlexibleSpaceView,
        &ioContraints
      )
    //--- Flexible space
      ioContraints.add (topOf: inHorizontalStackView, equalToTopOf: self)
      ioContraints.add (bottomOf: inHorizontalStackView, equalToBottomOf: self)
      if let lastSpace = ioFlexibleSpaceView {
        ioContraints.add (widthOf: lastSpace, equalToWidthOf: self)
      }
      if let lastLeftView = ioOptionalLastRightView {
        ioContraints.add (leftOf: self, equalToRightOf: lastLeftView, plus: inHorizontalStackView.mSpacing)
      }else{
        ioContraints.add (leftOf: self, equalToLeftOf: inHorizontalStackView, plus: inHorizontalStackView.mLeftMargin)
      }
      ioFlexibleSpaceView = self
    //--- After
      ioOptionalLastRightView = self
      self.mRight?.buildConstraintsFor (
        horizontalStackView: inHorizontalStackView,
        optionalLastRightView: &ioOptionalLastRightView,
        flexibleSpaceView: &ioFlexibleSpaceView,
        &ioContraints
      )
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    func alignHorizontalGutters (_ ioGutters : inout [AutoLayoutVerticalStackView.HorizontalGutterView],
                                 _ ioContraints : inout [NSLayoutConstraint]) {
      self.mLeft?.alignHorizontalGutters (&ioGutters, &ioContraints)
      self.mRight?.alignHorizontalGutters (&ioGutters, &ioContraints)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    private static let mFlexibleSpaceLayoutSettings = AutoLayoutViewSettings (
      vLayoutInHorizontalContainer: .fill,
      hLayoutInVerticalContainer: .fill
    )

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var pmLayoutSettings : AutoLayoutViewSettings { Self.mFlexibleSpaceLayoutSettings }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
