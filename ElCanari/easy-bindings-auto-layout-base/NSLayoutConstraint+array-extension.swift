//
//  NSLayoutConstraint-extensions.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/10/2023.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
// https://developer.apple.com/library/archive/releasenotes/UserExperience/RNAutomaticLayout/index.html#//apple_ref/doc/uid/TP40010631
//--------------------------------------------------------------------------------------------------

@MainActor extension Array where Element == NSLayoutConstraint {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK: Width
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (widthOf inView1 : NSView,
                     equalToWidthOf inView2 : NSView) {
    let c = inView1.widthAnchor.constraint (equalTo: inView2.widthAnchor)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (widthOf inView1 : NSView,
                     greaterThanOrEqualToConstant inConstant : CGFloat) {
    let c = inView1.widthAnchor.constraint (greaterThanOrEqualToConstant: inConstant)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (widthOf inView : NSView,
                     equalTo inValue : CGFloat) {
    let c = inView.widthAnchor.constraint (equalToConstant: inValue)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK: Height
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (heightOf inView : NSView,
                     equalTo inValue : CGFloat) {
    let c = inView.heightAnchor.constraint (equalToConstant: inValue)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (heightOf inView1 : NSView,
                     equalToHeightOf inView2 : NSView) {
    let c = inView1.heightAnchor.constraint (equalTo: inView2.heightAnchor)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (heightOf inView : NSView,
                     greaterThanOrEqualToConstant inConstant : CGFloat) {
    let c = inView.heightAnchor.constraint (greaterThanOrEqualToConstant: inConstant)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK: Left
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (leftOf inView1 : NSView,
                     equalToLeftOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
    let c = inView1.leftAnchor.constraint (equalTo: inView2.leftAnchor, constant: inOffset)
    self.append (c)
  }

 //--------------------------------------------------------------------------------------------------------------------

  mutating func add (leftOf inView1 : NSView,
                     equalToLeftOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0,
                     priority inPriority : LayoutCompressionConstraintPriority = .highest) {
    let c = inView1.leftAnchor.constraint (equalTo: inView2.leftAnchor, constant: inOffset)
    c.priority = inPriority.cocoaPriority
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (leftOf inView1 : NSView,
                     equalToRightOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
    let c = inView1.leftAnchor.constraint (equalTo: inView2.rightAnchor, constant: inOffset)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK: Right
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (rightOf inView1 : NSView,
                     equalToRightOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
    let c = inView1.rightAnchor.constraint (equalTo: inView2.rightAnchor, constant: inOffset)
    c.priority = LayoutCompressionConstraintPriority.highest.cocoaPriority
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK: Top
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (topOf inView1 : NSView,
                     equalToTopOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
  // Vertical Axis is from to top to bottom
    let c = inView1.topAnchor.constraint (equalTo: inView2.topAnchor, constant: -inOffset)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (topOf inView1 : NSView,
                     greaterThanOrEqualToTopOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
  // Vertical Axis is from to top to bottom
    let c = inView2.topAnchor.constraint (greaterThanOrEqualTo: inView1.topAnchor, constant: inOffset)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating private func add (topOf inView : NSView,
                             closeToBottomOfGutter inGutter : VerticalStackGutter) {
  // Vertical Axis is from to top to bottom
  //--- >= Constraint
    var c = inView.topAnchor.constraint (greaterThanOrEqualTo: inGutter.bottomAnchor)
    self.append (c)
  //--- == Constraint
    c = inView.topAnchor.constraint (equalTo: inGutter.bottomAnchor)
    var p = inView.contentHuggingPriority (for: .vertical)
    p = NSLayoutConstraint.Priority (rawValue: p.rawValue - 1.0)
    c.priority = p
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating private func add (topOf inView : NSView,
                             closeToTopOfContainer inContainer : NSView,
                             topMargin inTopMargin : CGFloat) {
  // Vertical Axis is from to top to bottom
  //--- >= Constraint
    var c = inView.topAnchor.constraint (greaterThanOrEqualTo: inContainer.topAnchor, constant: inTopMargin)
    self.append (c)
  //--- == Constraint
    c = inView.topAnchor.constraint (equalTo: inContainer.topAnchor, constant: inTopMargin)
    var p = inView.contentHuggingPriority (for: .vertical)
    p = NSLayoutConstraint.Priority (rawValue: p.rawValue - 1.0)
    c.priority = p
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (topOf inView1 : NSView,
                     equalToTopOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0,
                     priority inPriority : LayoutCompressionConstraintPriority = .highest) {
  // Vertical Axis is from to top to bottom
    let c = inView1.topAnchor.constraint (equalTo: inView2.topAnchor, constant: -inOffset)
    c.priority = inPriority.cocoaPriority
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK: Bottom
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (bottomOf inView1 : NSView,
                     equalToBottomOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
  // Vertical Axis is from to top to bottom
    let c = inView1.bottomAnchor.constraint (equalTo: inView2.bottomAnchor, constant: -inOffset)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (bottomOf inView1 : NSView,
                     equalToTopOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
  // Vertical Axis is from to top to bottom
    let c = inView1.bottomAnchor.constraint (equalTo: inView2.topAnchor, constant: -inOffset)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating private func add (bottomOf inView : NSView,
                             closeToBottomOfContainer inContainer : NSView,
                             bottomMargin inBottomMargin : CGFloat) {
  // Vertical Axis is from to top to bottom
  //--- >= constraint
    var c = inContainer.bottomAnchor.constraint (greaterThanOrEqualTo: inView.bottomAnchor, constant: inBottomMargin)
    self.append (c)
  //--- == constraint
    c = inContainer.bottomAnchor.constraint (equalTo: inView.bottomAnchor, constant: inBottomMargin)
    var p = inView.contentHuggingPriority (for: .vertical)
    p = NSLayoutConstraint.Priority (rawValue: p.rawValue - 1.0)
    c.priority = p
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (bottomOf inView1 : NSView,
                     greaterThanOrEqualToTopOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
  // Vertical Axis is from to top to bottom
    let c = inView1.bottomAnchor.constraint (greaterThanOrEqualTo: inView2.topAnchor, constant: -inOffset)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (bottomOf inView1 : NSView,
                     greaterThanOrEqualToBottomOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
  // Vertical Axis is from to top to bottom
    let c = inView2.bottomAnchor.constraint (greaterThanOrEqualTo: inView1.bottomAnchor, constant: inOffset)
    self.append (c)
  }


  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK: Last Baseline
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (lastBaselineOf inView1 : NSView,
                     equalToLastBaselineOf inView2 : NSView) {
    let c = inView1.lastBaselineAnchor.constraint (equalTo: inView2.lastBaselineAnchor)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK: Center X
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (centerXOf inView1 : NSView, equalToCenterXOf inView2 : NSView) {
    let c = inView1.centerXAnchor.constraint (equalTo: inView2.centerXAnchor)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK: Center Y
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (centerYOf inView1 : NSView, equalToCenterYOf inView2 : NSView) {
    let c = inView1.centerYAnchor.constraint (equalTo: inView2.centerYAnchor)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK: Vertical constraint in horizontal container
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (verticalConstraintsOf inView : NSView,
                     forHorizontalStackView inHStackView : AutoLayoutHorizontalStackView,
                     lastBaselineRefView ioLastBaselineRefView : inout NSView?) {
    let topMargin = inHStackView.mTopMargin
    let bottomMargin = inHStackView.mBottomMargin
    switch inView.pmLayoutSettings.vLayoutInHorizontalContainer {
    case .center :
      self.add (centerYOf: inView, equalToCenterYOf: inHStackView)
      self.add (topOf: inView, closeToTopOfContainer: inHStackView, topMargin: topMargin)
      self.add (bottomOf: inView, closeToBottomOfContainer: inHStackView, bottomMargin: bottomMargin)
    case .fill :
      self.add (topOf: inHStackView, equalToTopOf: inView, plus: topMargin)
      self.add (bottomOf: inView, equalToBottomOf: inHStackView, plus: bottomMargin)
    case .fillIgnoringMargins :
      self.add (topOf: inHStackView, equalToTopOf: inView)
      self.add (bottomOf: inView, equalToBottomOf: inHStackView)
    case .bottom :
      self.add (topOf: inView, closeToTopOfContainer: inHStackView, topMargin: topMargin)
      self.add (bottomOf: inView, equalToBottomOf: inHStackView, plus: bottomMargin)
    case .top :
      self.add (topOf: inHStackView, equalToTopOf: inView, plus: topMargin)
      self.add (bottomOf: inView, closeToBottomOfContainer: inHStackView, bottomMargin: bottomMargin)
    case .lastBaseline :
      self.add (topOf: inView, closeToTopOfContainer: inHStackView, topMargin: topMargin)
      self.add (bottomOf: inView, closeToBottomOfContainer: inHStackView, bottomMargin: bottomMargin)
      if let v = ioLastBaselineRefView {
        self.add (lastBaselineOf: v, equalToLastBaselineOf: inView)
      }
      ioLastBaselineRefView = inView
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
