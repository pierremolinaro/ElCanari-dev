//
//  VerticalStackSequence.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/09/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class VerticalStackSequence : VerticalStackHierarchyProtocol {

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

  func appendInVerticalHierarchy (_ inView : NSView) {
    self.mViewArray.append (inView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func prependInVerticalHierarchy (_ inView : NSView) {
    self.mViewArray.insert (inView, at: 0)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func buildConstraintsFor (verticalStackView inVerticalStackView : AutoLayoutVerticalStackView,
                            optionalLastBottomAnchor ioOptionalLastBottomAnchor : inout NSLayoutYAxisAnchor?,
                            flexibleSpaceView ioFlexibleSpaceView : inout VerticalStackFlexibleSpace?,
                            _ ioContraints : inout [NSLayoutConstraint]) {
  //--- Horizontal constraints
    for view in self.mViewArray {
      if !view.isHidden {
        switch view.pmLayoutSettings.hLayoutInVerticalContainer {
        case .center :
          ioContraints.add (x: view.centerXAnchor, equalTo: inVerticalStackView.centerXAnchor)
        case .fill :
          ioContraints.add (x: view.leftAnchor, equalTo: inVerticalStackView.leftAnchor, plus: inVerticalStackView.mLeftMargin)
          ioContraints.add (x: inVerticalStackView.rightAnchor, equalTo: view.rightAnchor, plus: inVerticalStackView.mRightMargin)
        case .fillIgnoringMargins :
          ioContraints.add (x: view.leftAnchor, equalTo: inVerticalStackView.leftAnchor)
          ioContraints.add (x: inVerticalStackView.rightAnchor, equalTo: view.rightAnchor)
        case .left :
          ioContraints.add (x: view.leftAnchor, equalTo: inVerticalStackView.leftAnchor, plus: inVerticalStackView.mLeftMargin)
        case .right :
          ioContraints.add (x: inVerticalStackView.rightAnchor, equalTo: view.rightAnchor, plus: inVerticalStackView.mRightMargin)
        }
      }
    }
  //--- Vertical constraints
    for view in self.mViewArray {
      if !view.isHidden {
        if let lastBottomView = ioOptionalLastBottomAnchor {
          ioContraints.add (y: lastBottomView, equalTo: view.topAnchor, plus: inVerticalStackView.mSpacing)
        }else{
          ioContraints.add (y: inVerticalStackView.topAnchor, equalTo: view.topAnchor, plus: inVerticalStackView.mTopMargin)
        }
        ioOptionalLastBottomAnchor = view.bottomAnchor
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func enumerateLastBaselineViews (_ ioArray : inout [NSView?],
                                   _ ioCurrentLastBaselineView : inout NSView?) {
    for view in self.mViewArray {
      if !view.isHidden {
        switch view.pmLayoutSettings.vLayoutInHorizontalContainer {
        case .center, .fill, .fillIgnoringMargins, .bottom, .top :
          ()
        case .lastBaseline :
          if let viewLastBaselineRepresentativeView = view.lastBaselineRepresentativeView {
            ioCurrentLastBaselineView = viewLastBaselineRepresentativeView
          }
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignVerticalGutters (_ ioGutters : inout [HorizontalStackGutter],
                             _ ioContraints : inout [NSLayoutConstraint]) {
    for view in self.mViewArray {
      if !view.isHidden, let hStack = view as? AutoLayoutHorizontalStackView {
      //--- Gutters
        let gutters = hStack.gutters
        let n = Swift.min (gutters.count, ioGutters.count)
        for i in 0 ..< n {
          ioContraints.add (x: gutters [i].leftAnchor, equalTo: ioGutters [i].leftAnchor)
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
