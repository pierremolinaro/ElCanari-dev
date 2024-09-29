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

  mutating func add (widthOf inView1 : any AnchorProtocol,
                     equalToWidthOf inView2 : any AnchorProtocol) {
    let c = inView1.widthAnchor.constraint (equalTo: inView2.widthAnchor)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  mutating func add (widthOfGuide inView1 : NSLayoutGuide,
//                     equalToWidthOfGuide inView2 : NSLayoutGuide) {
//    let c = inView1.widthAnchor.constraint (equalTo: inView2.widthAnchor)
//    self.append (c)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (widthOf inView1 : any AnchorProtocol,
                     greaterThanOrEqualToConstant inConstant : CGFloat) {
    let c = inView1.widthAnchor.constraint (greaterThanOrEqualToConstant: inConstant)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (widthOf inView : any AnchorProtocol,
                     equalTo inValue : CGFloat) {
    let c = inView.widthAnchor.constraint (equalToConstant: inValue)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  mutating func add (widthOfGuide inView : NSLayoutGuide,
//                     equalTo inValue : CGFloat) {
//    let c = inView.widthAnchor.constraint (equalToConstant: inValue)
//    self.append (c)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK: Height
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (heightOf inView : any AnchorProtocol,
                     equalTo inValue : CGFloat) {
    let c = inView.heightAnchor.constraint (equalToConstant: inValue)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  mutating func add (heightOfGuide inView : NSLayoutGuide,
//                     equalTo inValue : CGFloat) {
//    let c = inView.heightAnchor.constraint (equalToConstant: inValue)
//    self.append (c)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (heightOf inView1 : any AnchorProtocol,
                     equalToHeightOf inView2 : any AnchorProtocol) {
    let c = inView1.heightAnchor.constraint (equalTo: inView2.heightAnchor)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  mutating func add (heightOfGuide inView1 : NSLayoutGuide,
//                     equalToHeightOfGuide inView2 : NSLayoutGuide) {
//    let c = inView1.heightAnchor.constraint (equalTo: inView2.heightAnchor)
//    self.append (c)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (heightOf inView : any AnchorProtocol,
                     greaterThanOrEqualToConstant inConstant : CGFloat) {
    let c = inView.heightAnchor.constraint (greaterThanOrEqualToConstant: inConstant)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK: Left
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (leftOf inView1 : any AnchorProtocol,
                     equalToLeftOf inView2 : any AnchorProtocol,
                     plus inOffset : CGFloat = 0.0) {
    let c = inView1.leftAnchor.constraint (equalTo: inView2.leftAnchor, constant: inOffset)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  mutating func add (leftOfGuide inView1 : NSLayoutGuide,
//                     equalToLeftOf inView2 : NSView,
//                     plus inOffset : CGFloat = 0.0) {
//    let c = inView1.leftAnchor.constraint (equalTo: inView2.leftAnchor, constant: inOffset)
//    self.append (c)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  mutating func add (leftOfGuide inView1 : NSLayoutGuide,
//                     equalToLeftOfGuide inView2 : NSLayoutGuide,
//                     plus inOffset : CGFloat = 0.0) {
//    let c = inView1.leftAnchor.constraint (equalTo: inView2.leftAnchor, constant: inOffset)
//    self.append (c)
//  }

 //--------------------------------------------------------------------------------------------------------------------

  mutating func add (leftOf inView1 : any AnchorProtocol,
                     equalToLeftOf inView2 : any AnchorProtocol,
                     plus inOffset : CGFloat = 0.0,
                     priority inPriority : LayoutCompressionConstraintPriority = .highest) {
    let c = inView1.leftAnchor.constraint (equalTo: inView2.leftAnchor, constant: inOffset)
    c.priority = inPriority.cocoaPriority
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (leftOf inView1 : any AnchorProtocol,
                     equalToRightOf inView2 : any AnchorProtocol,
                     plus inOffset : CGFloat = 0.0) {
    let c = inView1.leftAnchor.constraint (equalTo: inView2.rightAnchor, constant: inOffset)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  mutating func add (leftOfGuide inView1 : NSLayoutGuide,
//                     equalToAnchor inAnchor : NSLayoutXAxisAnchor,
//                     plus inOffset : CGFloat = 0.0) {
//    let c = inView1.leftAnchor.constraint (equalTo: inAnchor, constant: inOffset)
//    self.append (c)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  mutating func add (leftOf inView1 : NSView,
//                     equalToAnchor inAnchor : NSLayoutXAxisAnchor,
//                     plus inOffset : CGFloat = 0.0) {
//    let c = inView1.leftAnchor.constraint (equalTo: inAnchor, constant: inOffset)
//    self.append (c)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK: Right
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  mutating func add (rightOfGuide inView1 : NSLayoutGuide,
//                     equalToRightOf inView2 : NSView,
//                     plus inOffset : CGFloat = 0.0) {
//    let c = inView1.rightAnchor.constraint (equalTo: inView2.rightAnchor, constant: inOffset)
//    c.priority = LayoutCompressionConstraintPriority.highest.cocoaPriority
//    self.append (c)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (rightOf inView1 : any AnchorProtocol,
                     equalToRightOf inView2 : any AnchorProtocol,
                     plus inOffset : CGFloat = 0.0) {
    let c = inView1.rightAnchor.constraint (equalTo: inView2.rightAnchor, constant: inOffset)
    c.priority = LayoutCompressionConstraintPriority.highest.cocoaPriority
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  mutating func add (rightOf inView1 : NSView,
//                     equalToAnchor inAnchor : NSLayoutXAxisAnchor,
//                     plus inOffset : CGFloat = 0.0) {
//    let c = inView1.rightAnchor.constraint (equalTo: inAnchor, constant: inOffset)
//    c.priority = LayoutCompressionConstraintPriority.highest.cocoaPriority
//    self.append (c)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  mutating func add (rightOf inView1 : NSView,
//                     equalToRightOfGuide inView2 : NSLayoutGuide,
//                     plus inOffset : CGFloat = 0.0) {
//    let c = inView1.rightAnchor.constraint (equalTo: inView2.rightAnchor, constant: inOffset)
//    c.priority = LayoutCompressionConstraintPriority.highest.cocoaPriority
//    self.append (c)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK: Top
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (topOf inView1 : any AnchorProtocol,
                     equalToTopOf inView2 : any AnchorProtocol,
                     plus inOffset : CGFloat = 0.0) {
  // Vertical Axis is from to top to bottom
    let c = inView1.topAnchor.constraint (equalTo: inView2.topAnchor, constant: -inOffset)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  mutating func add (topOf inView1 : NSView,
//                     equalToTopOfGuide inGuide : NSLayoutGuide,
//                     plus inOffset : CGFloat = 0.0) {
//  // Vertical Axis is from to top to bottom
//    let c = inView1.topAnchor.constraint (equalTo: inGuide.topAnchor, constant: -inOffset)
//    self.append (c)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (topOf inView1 : any AnchorProtocol,
                     greaterThanOrEqualToTopOf inView2 : any AnchorProtocol,
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
                             closeToTopOfContainer inContainer : any AnchorProtocol,
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

  mutating func add (topOf inView1 : any AnchorProtocol,
                     equalToTopOf inView2 : any AnchorProtocol,
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

  mutating func add (bottomOf inView1 : any AnchorProtocol,
                     equalToBottomOf inView2 : any AnchorProtocol,
                     plus inOffset : CGFloat = 0.0) {
  // Vertical Axis is from to top to bottom
    let c = inView1.bottomAnchor.constraint (equalTo: inView2.bottomAnchor, constant: -inOffset)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  mutating func add (bottomOfGuide inView1 : NSLayoutGuide,
//                     equalToBottomOfGuide inView2 : NSLayoutGuide,
//                     plus inOffset : CGFloat = 0.0) {
//  // Vertical Axis is from to top to bottom
//    let c = inView1.bottomAnchor.constraint (equalTo: inView2.bottomAnchor, constant: -inOffset)
//    self.append (c)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  mutating func add (bottomOf inView1 : NSView,
//                     equalToBottomOfGuide inGuide : NSLayoutGuide,
//                     plus inOffset : CGFloat = 0.0) {
//  // Vertical Axis is from to top to bottom
//    let c = inView1.bottomAnchor.constraint (equalTo: inGuide.bottomAnchor, constant: -inOffset)
//    self.append (c)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (bottomOf inView1 : any AnchorProtocol,
                     equalToTopOf inView2 : any AnchorProtocol,
                     plus inOffset : CGFloat = 0.0) {
  // Vertical Axis is from to top to bottom
    let c = inView1.bottomAnchor.constraint (equalTo: inView2.topAnchor, constant: -inOffset)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  mutating func add (bottomAnchor inBottomAnchor : NSLayoutYAxisAnchor,
//                     equalToTopOfGuide inGuide : NSLayoutGuide,
//                     plus inOffset : CGFloat = 0.0) {
//  // Vertical Axis is from to top to bottom
//    let c = inBottomAnchor.constraint (equalTo: inGuide.topAnchor, constant: -inOffset)
//    self.append (c)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  mutating func add (bottomAnchor inBottomAnchor : NSLayoutYAxisAnchor,
//                     equalToTopOfView inView : NSView,
//                     plus inOffset : CGFloat = 0.0) {
//  // Vertical Axis is from to top to bottom
//    let c = inBottomAnchor.constraint (equalTo: inView.topAnchor, constant: -inOffset)
//    self.append (c)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  mutating func add (bottomAnchor inBottomAnchor : NSLayoutYAxisAnchor,
//                     equalToBottomOfView inView : NSView,
//                     plus inOffset : CGFloat = 0.0) {
//  // Vertical Axis is from to top to bottom
//    let c = inBottomAnchor.constraint (equalTo: inView.bottomAnchor, constant: -inOffset)
//    self.append (c)
//  }

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

  mutating func add (bottomOf inView1 : any AnchorProtocol,
                     greaterThanOrEqualToTopOf inView2 : any AnchorProtocol,
                     plus inOffset : CGFloat = 0.0) {
  // Vertical Axis is from to top to bottom
    let c = inView1.bottomAnchor.constraint (greaterThanOrEqualTo: inView2.topAnchor, constant: -inOffset)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (bottomOf inView1 : any AnchorProtocol,
                     greaterThanOrEqualToBottomOf inView2 : any AnchorProtocol,
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

  mutating func add (centerXOf inView1 : any AnchorProtocol,
                     equalToCenterXOf inView2 : any AnchorProtocol) {
    let c = inView1.centerXAnchor.constraint (equalTo: inView2.centerXAnchor)
    self.append (c)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK: Center Y
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func add (centerYOf inView1 : any AnchorProtocol,
                     equalToCenterYOf inView2 : any AnchorProtocol) {
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
