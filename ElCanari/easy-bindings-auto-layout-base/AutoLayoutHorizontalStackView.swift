//
//  PMHorizontalStackView.swift
//  essai-gridview
//
//  Created by Pierre Molinaro on 28/10/2023.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

class AutoLayoutHorizontalStackView : ALB_NSStackView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var pmLayoutSettings : AutoLayoutViewSettings {
    return AutoLayoutViewSettings (
      vLayoutInHorizontalContainer: self.mVerticalDisposition,
      hLayoutInVerticalContainer: self.mHorizontalDisposition
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Last Baseline representative view
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var pmLastBaselineRepresentativeView : NSView? {
    for view in self.subviews {
      if !view.isHidden {
        switch view.pmLayoutSettings.vLayoutInHorizontalContainer {
        case .center, .fill, .fillIgnoringMargins, .bottom, .top :
          ()
        case .lastBaseline :
          if let viewLastBaselineRepresentativeView = view.pmLastBaselineRepresentativeView {
            return viewLastBaselineRepresentativeView
          }
        }
      }
    }
    return nil
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Constraints
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mConstraints = [NSLayoutConstraint] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func updateConstraints () {
  //--- Remove all constraints
    self.removeConstraints (self.mConstraints)
    self.mConstraints.removeAll (keepingCapacity: true)
  //--- Build constraints
    var optionalLastBaselineRepresentativeView : NSView? = nil
    var optionalLastView : NSView? = nil
    var optionalLastFlexibleSpace : NSView? = nil
    var referenceGutterArray = [AutoLayoutVerticalStackView.GutterSeparator] ()
    for view in self.subviews {
      if !view.isHidden {
      //--- Vertical constraints
        self.mConstraints.add (
          verticalConstraintsOf: view,
          inHorizontalContainer: self,
          topMargin: self.mTopMargin,
          bottomMargin : self.mBottomMargin,
          optionalLastBaseLineView: &optionalLastBaselineRepresentativeView
        )
        if (view is VerticalSeparator) || (view is VerticalDivider) {
          optionalLastBaselineRepresentativeView = nil
        }
      //--- Horizontal constraints
        if let lastView = optionalLastView {
          let spacing = self.isFlexibleSpace (view) ? 0.0 : self.mSpacing
          self.mConstraints.add (leftOf: view, equalToRightOf: lastView, plus: spacing)
        }else{
          self.mConstraints.add (leftOf: view, equalToLeftOf: self, plus: self.mLeftMargin)
        }
      //--- Handle width constraint for views with lower hugging priority
        if self.isFlexibleSpace (view) {
          if let refView = optionalLastFlexibleSpace {
            self.mConstraints.add (widthOf: refView, equalToWidthOf: view)
          }
          optionalLastFlexibleSpace = view
        }
        if self.isVerticalDivider (view) {
          optionalLastFlexibleSpace = nil
        }
      //--- Gutter ?
        if let vStack = view as? AutoLayoutVerticalStackView {
          var gutterArray = [AutoLayoutVerticalStackView.GutterSeparator] ()
          for vStackSubView in vStack.subviews {
            if !vStackSubView.isHidden, let gutter = vStackSubView as? AutoLayoutVerticalStackView.GutterSeparator {
              gutterArray.append (gutter)
            }
          }
          let n = min (referenceGutterArray.count, gutterArray.count)
          if n > 0 {
            for i in 0 ..< n {
              self.mConstraints.add (topOf: referenceGutterArray [i], equalToTopOf: gutterArray [i])
              self.mConstraints.add (bottomOf: referenceGutterArray [i], equalToBottomOf: gutterArray [i])
            }
          }
          if referenceGutterArray.count < gutterArray.count {
            referenceGutterArray = gutterArray
          }
        }
      //---
        optionalLastView = view
      }
    }
  //--- Add right constraint for last view
    if let lastView = optionalLastView {
      self.mConstraints.add (rightOf: self, equalToRightOf: lastView, plus: self.mRightMargin)
    }
  //--- Apply constaints
    self.addConstraints (self.mConstraints)
  //--- This should the last instruction: call super method
    super.updateConstraints ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Facilities
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendViewPreceededByFlexibleSpace (_ inView : NSView) -> Self {
    let hStack = AutoLayoutVerticalStackView ()
      .appendFlexibleSpace ()
      .appendView (inView)
    self.addSubview (hStack)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendViewSurroundedByFlexibleSpaces (_ inView : NSView) -> Self {
    let hStack = AutoLayoutVerticalStackView ()
      .appendFlexibleSpace ()
      .appendView (inView)
      .appendFlexibleSpace ()
    self.addSubview (hStack)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  class final func viewFollowedByFlexibleSpace (_ inView : NSView) -> AutoLayoutHorizontalStackView {
    return AutoLayoutHorizontalStackView ().appendView (inView).appendFlexibleSpace ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
