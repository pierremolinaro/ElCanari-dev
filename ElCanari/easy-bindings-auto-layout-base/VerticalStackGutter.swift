//
//  AutoLayoutVerticalStackView+gutter.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/08/2024.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

let GUTTER_HEIGHT = 4.0

//--------------------------------------------------------------------------------------------------

final class VerticalStackGutter : NSLayoutGuide, VerticalStackHierarchyProtocol {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inRoot : (any VerticalStackHierarchyProtocol)?) {
    self.mAbove = inRoot
    super.init ()
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mAbove : (any VerticalStackHierarchyProtocol)?
  private var mBelow : (any VerticalStackHierarchyProtocol)? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendInVerticalHierarchy (_ inView : NSView) {
    AutoLayoutVerticalStackView.appendInVerticalHierarchy (inView, toStackRoot: &self.mBelow)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func prependInVerticalHierarchy (_ inView : NSView) {
    AutoLayoutVerticalStackView.prependInVerticalHierarchy (inView, toStackRoot: &self.mAbove)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func removeInVerticalHierarchy (_ inView : NSView) {
    self.mAbove?.removeInVerticalHierarchy (inView)
    self.mBelow?.removeInVerticalHierarchy (inView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func buildConstraintsFor (verticalStackView inVerticalStackView : NSLayoutGuide,
                            spacing inSpacing : Double,
                            optionalLastBottomAnchor ioOptionalLastBottomAnchor : inout NSLayoutYAxisAnchor?,
                            flexibleSpaceView ioFlexibleSpaceView : inout VerticalStackFlexibleSpace?,
                            _ ioContraints : inout [NSLayoutConstraint]) {
  //--- Before
    self.mAbove?.buildConstraintsFor (
      verticalStackView: inVerticalStackView,
      spacing: inSpacing,
      optionalLastBottomAnchor: &ioOptionalLastBottomAnchor,
      flexibleSpaceView: &ioFlexibleSpaceView,
      &ioContraints
    )
  //--- Gutter
    ioContraints.add (x: self.leftAnchor, equalTo: inVerticalStackView.leftAnchor)
    ioContraints.add (x: self.rightAnchor, equalTo: inVerticalStackView.rightAnchor)
    ioContraints.add (dim: self.heightAnchor, equalToConstant: GUTTER_HEIGHT)
    if let lastBottomAnchor = ioOptionalLastBottomAnchor {
      ioContraints.add (y: lastBottomAnchor, equalTo: self.topAnchor, plus: inSpacing)
    }else{
      ioContraints.add (y: inVerticalStackView.topAnchor, equalTo: self.topAnchor)
    }
  //--- After
    ioOptionalLastBottomAnchor = self.bottomAnchor
    self.mBelow?.buildConstraintsFor (
      verticalStackView: inVerticalStackView,
      spacing: inSpacing,
      optionalLastBottomAnchor: &ioOptionalLastBottomAnchor,
      flexibleSpaceView: &ioFlexibleSpaceView,
      &ioContraints
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func enumerateLastBaselineViews (_ ioArray : inout [NSView?],
                                   _ ioCurrentLastBaselineView : inout NSView?) {
    self.mAbove?.enumerateLastBaselineViews (&ioArray, &ioCurrentLastBaselineView)
//    ioArray.append (ioCurrentLastBaselineView)
//    ioCurrentLastBaselineView = nil
    self.mBelow?.enumerateLastBaselineViews (&ioArray, &ioCurrentLastBaselineView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignVerticalGutters (_ ioGutters : inout [HorizontalStackGutter],
                             _ ioContraints : inout [NSLayoutConstraint]) {
    self.mAbove?.alignVerticalGutters (&ioGutters, &ioContraints)
    self.mBelow?.alignVerticalGutters (&ioGutters, &ioContraints)
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
