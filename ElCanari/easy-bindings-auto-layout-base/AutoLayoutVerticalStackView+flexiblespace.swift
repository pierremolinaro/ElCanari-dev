//
//  AutoLayoutVerticalStackView+flexiblespace.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutVerticalStackView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // FlexibleSpace internal class
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final class FlexibleSpace : NSView, VerticalStackHierarchyProtocol {

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    init (_ inRoot : (any VerticalStackHierarchyProtocol)?) {
      self.mAbove = inRoot
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

    private static let mFlexibleSpaceLayoutSettings = AutoLayoutViewSettings (
      vLayoutInHorizontalContainer: .fill,
      hLayoutInVerticalContainer: .fill
    )

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    override var pmLayoutSettings : AutoLayoutViewSettings { Self.mFlexibleSpaceLayoutSettings }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    private var mAbove : (any VerticalStackHierarchyProtocol)?
    private var mBelow : (any VerticalStackHierarchyProtocol)? = nil

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    func appendInVerticalHierarchy (_ inView : NSView) {
      AutoLayoutVerticalStackView.appendInVerticalHierarchy (inView, toStackRoot: &self.mBelow)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    func prependInVerticalHierarchy (_ inView : NSView) {
      AutoLayoutVerticalStackView.prependInVerticalHierarchy (inView, toStackRoot: &self.mAbove)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    func removeInVerticalHierarchy (_ inView : NSView) {
      self.mAbove?.removeInVerticalHierarchy (inView)
      self.mBelow?.removeInVerticalHierarchy (inView)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    func buildConstraintsFor (verticalStackView inVerticalStackView : AutoLayoutVerticalStackView,
                              optionalLastBottomView ioOptionalLastBottomView : inout NSView?,
                              flexibleSpaceView ioFlexibleSpaceView : inout AutoLayoutVerticalStackView.FlexibleSpace?,
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
      ioFlexibleSpaceView = self
    //--- After
      ioOptionalLastBottomView = self
      self.mBelow?.buildConstraintsFor (
        verticalStackView: inVerticalStackView,
        optionalLastBottomView: &ioOptionalLastBottomView,
        flexibleSpaceView: &ioFlexibleSpaceView,
        &ioContraints
      )
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

