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

  init () {
    super.init (
      horizontalDispositionInVerticalStackView: .fill,
      verticalDispositionInHorizontalStackView: .lastBaseline
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mHStackHierarchy : (any HorizontalStackHierarchyProtocol)? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final override func appendView (_ inView : NSView) -> Self {
    self.addSubview (inView)
    Self.appendInHorizontalHierarchy (inView, toStackRoot: &self.mHStackHierarchy)
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final override func prependView (_ inView : NSView) -> Self {
    self.addSubview (inView)
    Self.prependInHorizontalHierarchy (inView, toStackRoot: &self.mHStackHierarchy)
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
    self.mHStackHierarchy?.removeInHorizontalHierarchy (inView)
    self.invalidateIntrinsicContentSize ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mGutterArray = [HorizontalStackGutter] ()
  var gutters : [HorizontalStackGutter] { self.mGutterArray }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendGutter () -> Self {
    let newRoot = HorizontalStackGutter (self.mHStackHierarchy)
    self.addLayoutGuide (newRoot)
    self.mGutterArray.append (newRoot)
    self.mHStackHierarchy = newRoot
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendDivider (drawFrame inDrawFrame : Bool = true,
                            canResizeWindow inFlag : Bool = false) -> Self {
    let newRoot = HorizontalStackDivider (
      self.mHStackHierarchy,
      drawFrame: inDrawFrame,
      canResizeWindow: inFlag
    )
    self.addSubview (newRoot)
    self.mHStackHierarchy = newRoot
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendFlexibleSpace () -> Self {
    let newRoot = HorizontalStackFlexibleSpace (self.mHStackHierarchy)
    self.addLayoutGuide (newRoot)
    self.mHStackHierarchy = newRoot
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func appendSeparator (ignoreVerticalMargins inFlag : Bool = true) -> Self {
    let separator = HorizontalStackSeparator (ignoreVerticalMargins: inFlag)
    return self.appendView (separator)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func prependSeparator (ignoreVerticalMargins inFlag : Bool = true) -> Self {
    let separator = HorizontalStackSeparator (ignoreVerticalMargins: inFlag)
    return self.prependView (separator)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor static
  func appendInHorizontalHierarchy (_ inView : NSView,
                          toStackRoot ioRoot : inout (any HorizontalStackHierarchyProtocol)?) {
    if let root = ioRoot {
      root.appendInHorizontalHierarchy (inView)
    }else{
      let root = HorizontalStackSequence ()
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
      let root = HorizontalStackSequence ()
      root.prependInHorizontalHierarchy (inView)
      ioRoot = root
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Last Baseline representative view
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var lastBaselineRepresentativeView : NSView? {
    for view in self.subviews {
      if !view.isHidden {
        switch view.pmLayoutSettings.vLayoutInHorizontalContainer {
        case .center, .fill, .fillIgnoringMargins, .bottom, .top :
          ()
        case .lastBaseline :
          if let viewLastBaselineRepresentativeView = view.lastBaselineRepresentativeView {
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
    if let root = self.mHStackHierarchy {
      var flexibleSpaceView : HorizontalStackFlexibleSpace? = nil
      var optionalLastRightView : NSLayoutXAxisAnchor? = nil
      root.buildConstraintsFor (
        horizontalStackView: self,
        optionalLastRightView: &optionalLastRightView,
        flexibleSpaceView: &flexibleSpaceView,
        &self.mConstraints
      )
      if let lastRightView = optionalLastRightView {
        self.mConstraints.add (x: self.rightAnchor, equalTo: lastRightView, plus: self.mRightMargin)
      }else{
        self.mConstraints .add (x: self.leftAnchor, equalTo: self.rightAnchor)
      }
    }else{
      self.mConstraints .add (x: self.leftAnchor, equalTo: self.rightAnchor)
    }
  //--- Align gutters
    var gutters = [VerticalStackGutter] ()
    var lastBaselineViews = [NSView?] ()
    self.mHStackHierarchy?.alignHorizontalGutters (&gutters, &lastBaselineViews, &self.mConstraints)
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

}

//--------------------------------------------------------------------------------------------------
