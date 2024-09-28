//
//  AutoLayoutVerticalStackView+sequence.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutVerticalStackView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final class VerticalStackSequence : VerticalStackHierarchyProtocol {

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    init () {
      noteObjectAllocation (self)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    deinit {
      noteObjectDeallocation (self)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    private var mViewArray = [NSView] ()

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    func appendInVerticalHierarchy (_ inView : NSView) {
      self.mViewArray.append (inView)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    func prependInVerticalHierarchy (_ inView : NSView) {
      self.mViewArray.insert (inView, at: 0)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    func removeInVerticalHierarchy (_ inView : NSView) {
      var idx = 0
      while idx < self.mViewArray.count {
        if self.mViewArray [idx] === inView {
          self.mViewArray.remove (at: idx)
        }else{
          idx += 1
        }
      }
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    func buildConstraintsFor (verticalStackView inVerticalStackView : AutoLayoutVerticalStackView,
                              optionalLastBottomView ioOptionalLastBottomView : inout NSView?,
                              flexibleSpaceView ioFlexibleSpaceView : inout AutoLayoutVerticalStackView.FlexibleSpace?,
                              _ ioContraints : inout [NSLayoutConstraint]) {
    //--- Horizontal constraints
      for view in self.mViewArray {
        if !view.isHidden {
          switch view.pmLayoutSettings.hLayoutInVerticalContainer {
          case .center :
            ioContraints.add (centerXOf: view, equalToCenterXOf: inVerticalStackView)
          case .fill :
            ioContraints.add (leftOf: view, equalToLeftOf: inVerticalStackView, plus: inVerticalStackView.mLeftMargin)
            ioContraints.add (rightOf: inVerticalStackView, equalToRightOf: view, plus: inVerticalStackView.mRightMargin)
          case .fillIgnoringMargins :
            ioContraints.add (leftOf: view, equalToLeftOf: inVerticalStackView)
            ioContraints.add (rightOf: inVerticalStackView, equalToRightOf: view)
          case .left :
            ioContraints.add (leftOf: view, equalToLeftOf: inVerticalStackView, plus: inVerticalStackView.mLeftMargin)
          case .right :
            ioContraints.add (rightOf: inVerticalStackView, equalToRightOf: view, plus: inVerticalStackView.mRightMargin)
          }
        }
      }
    //--- Vertical constraints
      for view in self.mViewArray {
        if !view.isHidden {
          if let lastBottomView = ioOptionalLastBottomView {
            ioContraints.add (bottomOf: lastBottomView, equalToTopOf: view, plus: inVerticalStackView.mSpacing)
          }else{
            ioContraints.add (topOf: inVerticalStackView, equalToTopOf: view, plus: inVerticalStackView.mTopMargin)
          }
          ioOptionalLastBottomView = view
        }
      }
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
