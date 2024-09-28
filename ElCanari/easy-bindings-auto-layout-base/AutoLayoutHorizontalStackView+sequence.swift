//
//  StackSequence.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutHorizontalStackView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // StackSequence internal class
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final class StackSequence : HorizontalStackHierarchyProtocol {

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

    func appendInHorizontalHierarchy (_ inView : NSView) {
      self.mViewArray.append (inView)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    func prependInHorizontalHierarchy (_ inView : NSView) {
      self.mViewArray.insert (inView, at: 0)
    }

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

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

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·

    func buildConstraintsFor (horizontalStackView inHorizontalStackView : AutoLayoutHorizontalStackView,
                              optionalLastRightView ioOptionalLastRightView : inout NSView?,
                              flexibleSpaceView ioFlexibleSpaceView : inout AutoLayoutHorizontalStackView.FlexibleSpace?,
                              _ ioContraints : inout [NSLayoutConstraint]) {
      var optionalLastBaselineRepresentativeView : [NSView?] = []
  //    var optionalLastView : NSView? = nil
  //    var optionalLastFlexibleSpace : NSView? = nil
  //    var referenceGutterArray = [AutoLayoutVerticalStackView.GutterSeparator] ()
      var optionalCurrentGutter : AutoLayoutVerticalStackView.HorizontalGutterView? = nil
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

    // · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · ·


  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
