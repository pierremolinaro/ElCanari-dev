//
//  HorizontalStackSequence.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class HorizontalStackSequence : HorizontalStackHierarchyProtocol {

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
                            optionalLastRightView ioOptionalLastRightView : inout NSLayoutXAxisAnchor?,
                            flexibleSpaceView ioFlexibleSpaceView : inout HorizontalStackFlexibleSpace?,
                            _ ioContraints : inout [NSLayoutConstraint]) {
  //--- Vertical constraints
    var lastBaselineRefView : NSView? = nil
    for view in self.mViewArray {
      if !view.isHidden {
        ioContraints.add (
          verticalConstraintsOf: view,
          forHorizontalStackView: inHorizontalStackView,
          lastBaselineRefView: &lastBaselineRefView
        )
        if (view is HorizontalStackSeparator) || (view is HorizontalStackDivider) {
          lastBaselineRefView = nil
        }
      }
    }
  //--- Horizontal constraints
    for view in self.mViewArray {
      if !view.isHidden {
        if let lastRightAnchor = ioOptionalLastRightView {
          ioContraints.add (x: view.leftAnchor, equalTo: lastRightAnchor, plus: inHorizontalStackView.mSpacing)
        }else{
          ioContraints.add (x: view.leftAnchor, equalTo: inHorizontalStackView.leftAnchor, plus: inHorizontalStackView.mLeftMargin)
        }
        ioOptionalLastRightView = view.rightAnchor
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignHorizontalGutters (_ ioGutters : inout [VerticalStackGutter],
                               _ ioLastBaselineViews : inout [NSView?],
                               _ ioContraints : inout [NSLayoutConstraint]) {
    for view in self.mViewArray {
      if !view.isHidden, let vStack = view as? AutoLayoutVerticalStackView {
      //--- Gutters
        let gutters = vStack.gutters ()
        let n = Swift.min (gutters.count, ioGutters.count)
        for i in 0 ..< n {
          ioContraints.add (y: gutters [i].bottomAnchor, equalTo: ioGutters [i].bottomAnchor)
        }
        for i in n ..< gutters.count {
          ioGutters.append (gutters [i])
        }
      //--- Last baseline views
        if ioGutters.count > 0 {
          let lastBaselineViews = vStack.lastBaselineViews ()
          let m = Swift.min (lastBaselineViews.count, ioLastBaselineViews.count)
          for i in 0 ..< m {
            if let lastBaselineView = lastBaselineViews [i] {
              if let refLastBaselineView = ioLastBaselineViews [i] {
                ioContraints.add (y: lastBaselineView.lastBaselineAnchor, equalTo: refLastBaselineView.lastBaselineAnchor)
              }else{
                ioLastBaselineViews [i] = lastBaselineViews [i]
              }
            }
          }
          for i in m ..< lastBaselineViews.count {
            ioLastBaselineViews.append (lastBaselineViews [i])
          }
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
