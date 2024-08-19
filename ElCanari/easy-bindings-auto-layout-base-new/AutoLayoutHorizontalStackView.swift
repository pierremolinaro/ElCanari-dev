//
//  PMHorizontalStackView.swift
//  essai-gridview
//
//  Created by Pierre Molinaro on 28/10/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutHorizontalStackView : ALB_NSStackView {

  //--------------------------------------------------------------------------------------------------------------------

  override var pmLayoutSettings : AutoLayoutViewSettings {
    return AutoLayoutViewSettings (
      vLayoutInHorizontalContainer: self.mVerticalDisposition,
      hLayoutInVerticalContainer: self.mHorizontalDisposition
    )
  }

  //--------------------------------------------------------------------------------------------------------------------
  //  Last Baseline representative view
  //--------------------------------------------------------------------------------------------------------------------

  private var mLastBaselineRepresentativeView : NSView? = nil

  override var pmLastBaselineRepresentativeView : NSView? { self.mLastBaselineRepresentativeView }

  //--------------------------------------------------------------------------------------------------------------------
  //  Constraints
  //--------------------------------------------------------------------------------------------------------------------

  private var mConstraints = [NSLayoutConstraint] ()

  //--------------------------------------------------------------------------------------------------------------------

  override func updateConstraints () {
  //--- Remove all constraints
    self.removeConstraints (self.mConstraints)
    self.mConstraints.removeAll (keepingCapacity: true)
  //--- Build constraints
    self.mLastBaselineRepresentativeView = nil
    var optionalLastView : NSView? = nil
    var optionalLastFlexibleSpace : NSView? = nil
    for view in self.subviews {
      if !view.isHidden {
      //--- Vertical constraints
        switch view.pmLayoutSettings.vLayoutInHorizontalContainer {
        case .center :
          self.mConstraints.add (topOf: self, greaterThanOrEqualToTopOf: view, plus: self.mTopMargin)
          self.mConstraints.add (bottomOf: view, greaterThanOrEqualToBottomOf: self, plus: self.mTopMargin)
          self.mConstraints.add (centerYOf: view, equalToCenterYOf: self)
        case .fill, .weakFill :
          self.mConstraints.add (topOf: self, equalToTopOf: view, plus: self.mTopMargin)
          self.mConstraints.add (bottomOf: view, equalToBottomOf: self, plus: self.mBottomMargin)
        case .weakFillIgnoringMargins :
          self.mConstraints.add (topOf: self, equalToTopOf: view)
          self.mConstraints.add (bottomOf: view, equalToBottomOf: self)
        case .bottom :
          self.mConstraints.add (topOf: self, greaterThanOrEqualToTopOf: view, plus: self.mTopMargin)
          self.mConstraints.add (bottomOf: view, equalToBottomOf: self, plus: self.mBottomMargin)
        case .top :
          self.mConstraints.add (topOf: self, equalToTopOf: view, plus: self.mTopMargin)
          self.mConstraints.add (bottomOf: view, greaterThanOrEqualToBottomOf: self, plus: self.mTopMargin)
        case .lastBaseline :
          if let viewLastBaselineRepresentativeView = view.pmLastBaselineRepresentativeView {
            self.mConstraints.add (topOf: self, greaterThanOrEqualToTopOf: view, plus: self.mTopMargin)
            self.mConstraints.add (bottomOf: view, greaterThanOrEqualToBottomOf: self, plus: self.mTopMargin)
            self.mConstraints.add (topOf: self, equalToTopOf: view, plus: self.mTopMargin, withCompressionResistancePriorityOf: .secondView)
            self.mConstraints.add (bottomOf: view, equalToBottomOf: self, plus: self.mTopMargin, withCompressionResistancePriorityOf: .firstView)
            if let lastBaselineRepresentativeView = self.mLastBaselineRepresentativeView {
              self.mConstraints.add (lastBaselineOf: viewLastBaselineRepresentativeView, equalToLastBaselineOf: lastBaselineRepresentativeView)
            }else{
              self.mLastBaselineRepresentativeView = view
            }
          }else{
            self.mConstraints.add (topOf: self, equalToTopOf: view, plus: self.mTopMargin)
            self.mConstraints.add (bottomOf: view, equalToBottomOf: self, plus: self.mBottomMargin)
          }
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
    let hStack = AutoLayoutHorizontalStackView ()
    _ = hStack.appendView (inView)
    _ = hStack.appendFlexibleSpace ()
    return hStack
  }

  //--------------------------------------------------------------------------------------------------------------------

//  override func draw (_ inDirtyRect : NSRect) {
//    super.draw (inDirtyRect)
//    let r = self.bounds.insetBy (dx: 0.5, dy: 0.5)
//    if !r.isEmpty {
//      let bp = NSBezierPath (rect: r)
//      bp.lineWidth = 1.0
//      NSColor.black.setStroke ()
//      bp.stroke ()
//    }
//  }

  //--------------------------------------------------------------------------------------------------------------------
  // OBSOLETE
  //--------------------------------------------------------------------------------------------------------------------

  final func setFirstBaselineAlignment () -> Self { // §
    return self
  }

  //--------------------------------------------------------------------------------------------------------------------

  final func setTopAlignment () -> Self { // §
    return self
  }

  //--------------------------------------------------------------------------------------------------------------------

  final func equalWidth () -> Self { // §
    return self
  }

  //--------------------------------------------------------------------------------------------------------------------

  final func setCenterYAlignment () -> Self { // §
    return self
  }

  //--------------------------------------------------------------------------------------------------------------------

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
