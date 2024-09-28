//
//  StackSequence.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class StackSequence : StackRootProtocol {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mViewArray = [NSView] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func append (_ inView : NSView) {
    self.mViewArray.append (inView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func prepend (_ inView : NSView) {
    self.mViewArray.insert (inView, at: 0)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func remove (_ inView : NSView) {
    var idx = 0
    while idx < self.mViewArray.count {
      if self.mViewArray [idx] === inView {
        self.mViewArray.remove (at: idx)
      }else{
        idx += 1
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func buildConstraintsFor (verticalStackView inVerticalStackView : AutoLayoutVerticalStackView,
                            optionalLastBottomView ioOptionalLastBottomView : inout NSView?,
                            flexibleSpaceView ioFlexibleSpaceView : inout AutoLayoutFlexibleSpace?,
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func buildConstraintsFor (horizontalStackView inHorizontalStackView : AutoLayoutHorizontalStackView,
                            optionalLastRightView ioOptionalLastRightView : inout NSView?,
                            flexibleSpaceView ioFlexibleSpaceView : inout AutoLayoutFlexibleSpace?,
                            _ ioContraints : inout [NSLayoutConstraint]) {
    var optionalLastBaselineRepresentativeView : [NSView?] = []
//    var optionalLastView : NSView? = nil
//    var optionalLastFlexibleSpace : NSView? = nil
//    var referenceGutterArray = [AutoLayoutVerticalStackView.GutterSeparator] ()
    var optionalCurrentGutter : AutoLayoutVerticalStackView.GutterSeparator? = nil
  //--- Vertical constraints
    for view in self.mViewArray {
      if !view.isHidden {
        ioContraints.add (
          verticalConstraintsOf: view,
          inHorizontalContainer: inHorizontalStackView,
          currentGutter: optionalCurrentGutter,
          topMargin: inHorizontalStackView.mTopMargin,
          bottomMargin: inHorizontalStackView.mBottomMargin,
          optionalLastBaseLineView: &optionalLastBaselineRepresentativeView
        )
      }
    }
  //--- Horizontal constraints
    for view in self.mViewArray {
      if !view.isHidden {
        if let lastLeftView = ioOptionalLastRightView {
          ioContraints.add (leftOf: view, equalToRightOf: lastLeftView, plus: inHorizontalStackView.mSpacing)
        }else{
          ioContraints.add (leftOf: view, equalToLeftOf: inHorizontalStackView, plus: inHorizontalStackView.mLeftMargin)
        }
        ioOptionalLastRightView = view
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
