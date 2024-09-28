//
//  StackSequence.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class HorizontalStackStackSequence : HorizontalStackHierarchyProtocol {

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

  func appendInHorizontalHierarchy (_ inView : NSView) {
    self.mViewArray.append (inView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func prependInHorizontalHierarchy (_ inView : NSView) {
    self.mViewArray.insert (inView, at: 0)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func removeInHorizontalHierarchy (_ inView : NSView) {
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

  func buildConstraintsFor (horizontalStackView inHorizontalStackView : AutoLayoutHorizontalStackView,
                            optionalLastRightView ioOptionalLastRightView : inout NSView?,
                            flexibleSpaceView ioFlexibleSpaceView : inout HorizontalStackFlexibleSpace?,
                            _ ioContraints : inout [NSLayoutConstraint]) {
    var optionalLastBaselineRepresentativeView : [NSView?] = []
  //--- Vertical constraints
    for view in self.mViewArray {
      if !view.isHidden {
        ioContraints.add (
          verticalConstraintsOf: view,
          inHorizontalContainer: inHorizontalStackView,
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

  func alignHorizontalGutters (_ ioGutters : inout [VerticalStackGutter],
                               _ ioContraints : inout [NSLayoutConstraint]) {
    for view in self.mViewArray {
      if !view.isHidden, let vStack = view as? AutoLayoutVerticalStackView {
        let gutters = vStack.gutters ()
        let n = Swift.min (gutters.count, ioGutters.count)
        for i in 0 ..< n {
          ioContraints.add (bottomOf: gutters [i], equalToBottomOf: ioGutters [i])
        }
        for i in n ..< gutters.count {
          ioGutters.append (gutters [i])
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
