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

  private var mInternalStackRoot : (any HorizontalStackHierarchyProtocol)? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final override func appendView (_ inView : NSView) -> Self {
    self.addSubview (inView)
    self.invalidateIntrinsicContentSize ()
    Self.appendInHorizontalHierarchy (inView, toStackRoot: &self.mInternalStackRoot)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final override func prependView (_ inView : NSView) -> Self {
    self.addSubview (inView, positioned: .below, relativeTo: nil)
    Self.prependInHorizontalHierarchy (inView, toStackRoot: &self.mInternalStackRoot)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final override func removeView (_ inView : NSView) {
    for view in self.subviews {
      if view === inView {
        inView.removeFromSuperview ()
      }
    }
    self.mInternalStackRoot?.removeInHorizontalHierarchy (inView)
    self.invalidateIntrinsicContentSize ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendGutter () -> Self {
    let newRoot = AutoLayoutHorizontalStackView.VerticalGutterView (self.mInternalStackRoot)
    self.addSubview (newRoot)
    self.mInternalStackRoot = newRoot
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendDivider (drawFrame inDrawFrame : Bool = true,
                            canResizeWindow inFlag : Bool = false) -> Self {
    let newRoot = AutoLayoutHorizontalStackView.VerticalDivider (
      self.mInternalStackRoot,
      drawFrame: inDrawFrame,
      canResizeWindow: inFlag
    )
    self.addSubview (newRoot)
    self.mInternalStackRoot = newRoot
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendFlexibleSpace () -> Self {
    let newRoot = Self.FlexibleSpace (self.mInternalStackRoot)
    self.addSubview (newRoot)
    self.mInternalStackRoot = newRoot
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor static
  func appendInHorizontalHierarchy (_ inView : NSView,
                          toStackRoot ioRoot : inout (any HorizontalStackHierarchyProtocol)?) {
    if let root = ioRoot {
      root.appendInHorizontalHierarchy (inView)
    }else{
      let root = StackSequence ()
      root.appendInHorizontalHierarchy (inView)
      ioRoot = root
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor static
  func prependInHorizontalHierarchy (_ inView : NSView,
                           toStackRoot ioRoot : inout (any HorizontalStackHierarchyProtocol)?) {
    if let root = ioRoot {
      root.prependInHorizontalHierarchy (inView)
    }else{
      let root = StackSequence ()
      root.prependInHorizontalHierarchy (inView)
      ioRoot = root
    }
  }

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

  override var lastBaselineRepresentativeViewArray : OptionalViewArray { // §§
    for view in self.subviews {
      if !view.isHidden {
        switch view.pmLayoutSettings.vLayoutInHorizontalContainer {
        case .center, .fill, .fillIgnoringMargins, .bottom, .top :
          ()
        case .lastBaseline :
          if let viewLastBaselineRepresentativeView = view.lastBaselineRepresentativeViewArray.last {
            return OptionalViewArray (viewLastBaselineRepresentativeView)
          }
        }
      }
    }
    return OptionalViewArray ()
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
    if let root = self.mInternalStackRoot {
      var flexibleSpaceView : FlexibleSpace? = nil
      var optionalLastRightView : NSView? = nil
      root.buildConstraintsFor (
        horizontalStackView: self,
        optionalLastRightView: &optionalLastRightView,
        flexibleSpaceView: &flexibleSpaceView,
        &self.mConstraints
      )
      if let lastRightView = optionalLastRightView {
        self.mConstraints.add (rightOf: self, equalToRightOf: lastRightView, plus: self.mRightMargin)
      }else{
        self.mConstraints.add (leftOf: self, equalToRightOf: self)
      }
    }else{
      self.mConstraints.add (leftOf: self, equalToRightOf: self)
    }
  //--- Apply constaints
    self.addConstraints (self.mConstraints)
  //--- This should the last instruction: call super method
    super.updateConstraints ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  override func updateConstraints () {
//  //--- Remove all constraints
//    self.removeConstraints (self.mConstraints)
//    self.mConstraints.removeAll (keepingCapacity: true)
//  //--- Build constraints
//    var optionalLastBaselineRepresentativeView : [NSView?] = []
//    var optionalLastView : NSView? = nil
//    var optionalLastFlexibleSpace : NSView? = nil
//    var referenceGutterArray = [AutoLayoutVerticalStackView.GutterSeparator] ()
//    var optionalCurrentGutter : AutoLayoutVerticalStackView.GutterSeparator? = nil
//    for view in self.subviews {
//      if !view.isHidden {
//      //--- Vertical constraints
//        self.mConstraints.add (
//          verticalConstraintsOf: view,
//          inHorizontalContainer: self,
//          currentGutter: optionalCurrentGutter,
//          topMargin: self.mTopMargin,
//          bottomMargin: self.mBottomMargin,
//          optionalLastBaseLineView: &optionalLastBaselineRepresentativeView
//        )
//        if (view is VerticalSeparator) || (view is VerticalDivider) {
//          optionalLastBaselineRepresentativeView = []
//        }
//      //--- Horizontal constraints
//        if let lastView = optionalLastView {
//          let spacing = self.isFlexibleSpace (view) ? 0.0 : self.mSpacing
//          self.mConstraints.add (leftOf: view, equalToRightOf: lastView, plus: spacing)
//        }else{
//          self.mConstraints.add (leftOf: view, equalToLeftOf: self, plus: self.mLeftMargin)
//        }
//      //--- Handle width constraint for views with lower hugging priority
//        if self.isFlexibleSpace (view) {
//          if let refView = optionalLastFlexibleSpace {
//            self.mConstraints.add (widthOf: refView, equalToWidthOf: view)
//          }
//          optionalLastFlexibleSpace = view
//        }
//        if self.isVerticalDivider (view) {
//          optionalLastFlexibleSpace = nil
//        }
//        if let v = view as? AutoLayoutVerticalStackView.GutterSeparator {
//          optionalCurrentGutter = v
//        }
//      //--- current is a vertical stack view ? enumerate its gutters
//        if let vStack = view as? AutoLayoutVerticalStackView {
//          var gutterArray = [AutoLayoutVerticalStackView.GutterSeparator] ()
//          var currentOptionalLastBaselineRepresentativeViewArray = [NSView?] ()
//          var currentOptionalLastBaselineRepresentativeView : NSView? = nil
//          for vStackSubView in vStack.subviews {
//            if !vStackSubView.isHidden {
//              if let v = vStackSubView.lastBaselineRepresentativeViewArray.last {
//                currentOptionalLastBaselineRepresentativeView = v
//              }
//              if let gutter = vStackSubView as? AutoLayoutVerticalStackView.GutterSeparator {
//                gutterArray.append (gutter)
//                currentOptionalLastBaselineRepresentativeViewArray.append (currentOptionalLastBaselineRepresentativeView)
//                currentOptionalLastBaselineRepresentativeView = nil
//              }
//            }
//          }
//          currentOptionalLastBaselineRepresentativeViewArray.append (currentOptionalLastBaselineRepresentativeView)
//          let n = min (referenceGutterArray.count, gutterArray.count)
//          for i in 0 ..< n {
//            self.mConstraints.add (topOf: referenceGutterArray [i], equalToTopOf: gutterArray [i])
//            self.mConstraints.add (bottomOf: referenceGutterArray [i], equalToBottomOf: gutterArray [i])
//          }
//          if referenceGutterArray.count < gutterArray.count {
//            referenceGutterArray = gutterArray
//            optionalLastBaselineRepresentativeView = currentOptionalLastBaselineRepresentativeViewArray
//          }
//        }
//      //---
//        optionalLastView = view
//      }
//    }
//  //--- Add right constraint for last view
//    if let lastView = optionalLastView {
//      self.mConstraints.add (rightOf: self, equalToRightOf: lastView, plus: self.mRightMargin)
//    }
//  //--- Apply constaints
//    self.addConstraints (self.mConstraints)
//  //--- This should the last instruction: call super method
//    super.updateConstraints ()
//  }

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

  @MainActor protocol HorizontalStackHierarchyProtocol : AnyObject {

    func appendInHorizontalHierarchy (_ inView : NSView)

    func prependInHorizontalHierarchy (_ inView : NSView)

    func removeInHorizontalHierarchy (_ inView : NSView)

    func buildConstraintsFor (horizontalStackView inHorizontalStackView : AutoLayoutHorizontalStackView,
                              optionalLastRightView ioOptionalLastRightView : inout NSView?,
                              flexibleSpaceView ioFlexibleSpaceView : inout AutoLayoutHorizontalStackView.FlexibleSpace?,
                              _ ioContraints : inout [NSLayoutConstraint])

  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
