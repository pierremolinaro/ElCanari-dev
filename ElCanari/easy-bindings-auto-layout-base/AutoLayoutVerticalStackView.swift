//
//  AutoLayoutVerticalStackView.swift
//  essai-gridview
//
//  Created by Pierre Molinaro on 30/10/2023.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

class AutoLayoutVerticalStackView : ALB_NSStackView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var pmLayoutSettings : AutoLayoutViewSettings {
    return AutoLayoutViewSettings (
      vLayoutInHorizontalContainer: self.mVerticalDisposition,
      hLayoutInVerticalContainer: self.mHorizontalDisposition
    )
  }

  //····················································································································
  // Flipped
  // https://stackoverflow.com/questions/4697583/setting-nsscrollview-contents-to-top-left-instead-of-bottom-left-when-document-s
  //····················································································································

  final override var isFlipped : Bool { true }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Last Baseline representative view
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mLastBaselineRepresentativeView : NSView? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var pmLastBaselineRepresentativeView : NSView? { self.mLastBaselineRepresentativeView }

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
    self.mLastBaselineRepresentativeView = nil
    var optionalLastView : NSView? = nil
    var optionalLastFlexibleSpace : NSView? = nil
    var referenceGutterArray = [AutoLayoutHorizontalStackView.GutterSeparator] ()
    for view in self.subviews {
      if !view.isHidden {
      //--- Horizontal constraints
        switch view.pmLayoutSettings.hLayoutInVerticalContainer {
        case .center :
          self.mConstraints.add (centerXOf: view, equalToCenterXOf: self)
        case .fill :
          self.mConstraints.add (leftOf: view, equalToLeftOf: self, plus: self.mLeftMargin)
          self.mConstraints.add (rightOf: self, equalToRightOf: view, plus: self.mRightMargin)
        case .fillIgnoringMargins :
          self.mConstraints.add (leftOf: view, equalToLeftOf: self)
          self.mConstraints.add (rightOf: self, equalToRightOf: view)
        case .left :
          self.mConstraints.add (leftOf: view, equalToLeftOf: self, plus: self.mLeftMargin)
        case .right :
          self.mConstraints.add (rightOf: self, equalToRightOf: view, plus: self.mRightMargin)
        }
      //--- Vertical constraints
        if let lastView = optionalLastView {
          let spacing = self.isFlexibleSpace (view) ? 0.0 : self.mSpacing
          self.mConstraints.add (bottomOf: lastView, equalToTopOf: view, plus: spacing)
        }else{
          self.mConstraints.add (topOf: self, equalToTopOf: view, plus: self.mTopMargin)
        }
        if let viewLastBaselineRepresentativeView = view.pmLastBaselineRepresentativeView {
          self.mLastBaselineRepresentativeView = viewLastBaselineRepresentativeView
        }
      //--- Handle height constraint for views with lower hugging priority
        if self.isFlexibleSpace (view) {
          if let refView = optionalLastFlexibleSpace {
            self.mConstraints.add (heightOf: refView, equalToHeightOf: view)
          }
          optionalLastFlexibleSpace = view
        }
        if self.isHorizontalDivider (view) {
          optionalLastFlexibleSpace = nil
        }
      //--- Gutter ?
        if let hStack = view as? AutoLayoutHorizontalStackView {
          var gutterArray = [AutoLayoutHorizontalStackView.GutterSeparator] ()
          for hStackSubView in hStack.subviews {
            if !hStackSubView.isHidden, let gutter = hStackSubView as? AutoLayoutHorizontalStackView.GutterSeparator {
              gutterArray.append (gutter)
            }
          }
          let n = min (referenceGutterArray.count, gutterArray.count)
          if n > 0 {
            for i in 0 ..< n {
              self.mConstraints.add (leftOf: referenceGutterArray [i], equalToLeftOf: gutterArray [i])
              self.mConstraints.add (rightOf: referenceGutterArray [i], equalToRightOf: gutterArray [i])
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
  //--- Add bottom constraint for last view
    if let lastView = optionalLastView {
      self.mConstraints.add (bottomOf: lastView, equalToBottomOf: self, plus: self.mBottomMargin)
    }
  //--- Apply constaints
    self.addConstraints (self.mConstraints)
  //--- This should the last instruction: call super method
    super.updateConstraints ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendViewSurroundedByFlexibleSpaces (_ inView : NSView) -> Self {
    let hStack = AutoLayoutHorizontalStackView ()
      .appendFlexibleSpace ()
      .appendView (inView)
      .appendFlexibleSpace ()
    self.addSubview (hStack)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendViewPreceededByFlexibleSpace (_ inView : NSView) -> Self {
    let hStack = AutoLayoutHorizontalStackView ()
      .appendFlexibleSpace ()
      .appendView (inView)
    self.addSubview (hStack)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------