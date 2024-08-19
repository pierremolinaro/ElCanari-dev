//
//  NSLayoutConstraint-extensions.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/10/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum PMViewForApplyingPriority {
  case firstView
  case secondView
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor extension Array where Element == NSLayoutConstraint {

  //--------------------------------------------------------------------------------------------------------------------
  //MARK: Width
  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (widthOf inView1 : NSView,
                     equalToWidthOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
    let c = inView1.widthAnchor.constraint (equalTo: inView2.widthAnchor, constant: inOffset)
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (widthOf inView1 : NSView,
                     greaterThanOrEqualToConstant inConstant : CGFloat) {
    let c = inView1.widthAnchor.constraint (greaterThanOrEqualToConstant: inConstant)
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (widthOf inView : NSView,
                     equalTo inWidth : CGFloat,
                     priority inPriority : PMLayoutCompressionConstraintPriority = .highest) {
    let c = inView.widthAnchor.constraint (equalToConstant: inWidth)
    c.priority = inPriority.cocoaPriority
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------
  //MARK: Height
  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (heightOf inView1 : NSView,
                     equalToHeightOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
    let c = inView1.heightAnchor.constraint (equalTo: inView2.heightAnchor, constant: inOffset)
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (heightOf inView : NSView,
                     equalTo inHeight : CGFloat,
                     priority inPriority : PMLayoutCompressionConstraintPriority = .highest) {
    let c = inView.heightAnchor.constraint (equalToConstant: inHeight)
    c.priority = inPriority.cocoaPriority
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------
  //MARK: Left
  //--------------------------------------------------------------------------------------------------------------------

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
                     priority inPriority : PMLayoutCompressionConstraintPriority = .highest) {
    let c = inView1.leftAnchor.constraint (equalTo: inView2.leftAnchor, constant: inOffset)
    c.priority = inPriority.cocoaPriority
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (leftOf inView1 : NSView,
                     equalToRightOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
    let c = inView1.leftAnchor.constraint (equalTo: inView2.rightAnchor, constant: inOffset)
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------
  //MARK: Right
  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (rightOf inView1 : NSView,
                     equalToRightOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
    let c = inView1.rightAnchor.constraint (equalTo: inView2.rightAnchor, constant: inOffset)
    c.priority = PMLayoutCompressionConstraintPriority.highest.cocoaPriority
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------
  //MARK: Top
  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (topOf inView1 : NSView,
                     equalToTopOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0,
                     withCompressionResistancePriorityOf inSelectedView : PMViewForApplyingPriority) {
  // Vertical Axis is from to top to bottom
    let c = inView1.topAnchor.constraint (equalTo: inView2.topAnchor, constant: -inOffset)
    switch inSelectedView {
    case .firstView  : c.priority = inView2.contentCompressionResistancePriority (for: .vertical)
    case .secondView : c.priority = inView1.contentCompressionResistancePriority (for: .vertical)
    }
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (topOf inView1 : NSView,
                     equalToTopOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
  // Vertical Axis is from to top to bottom
    let c = inView1.topAnchor.constraint (equalTo: inView2.topAnchor, constant: -inOffset)
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (topOf inView1 : NSView,
                     greaterThanOrEqualToTopOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
  // Vertical Axis is from to top to bottom
    let c = inView2.topAnchor.constraint (greaterThanOrEqualTo: inView1.topAnchor, constant: inOffset)
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (topOf inView1 : NSView,
                     equalToTopOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0,
                     priority inPriority : PMLayoutCompressionConstraintPriority = .highest) {
  // Vertical Axis is from to top to bottom
    let c = inView1.topAnchor.constraint (equalTo: inView2.topAnchor, constant: -inOffset)
    c.priority = inPriority.cocoaPriority
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------
  //MARK: Bottom
  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (bottomOf inView1 : NSView,
                     equalToTopOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
  // Vertical Axis is from to top to bottom
    let c = inView1.bottomAnchor.constraint (equalTo: inView2.topAnchor, constant: -inOffset)
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (bottomOf inView1 : NSView,
                     equalToBottomOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0,
                     withCompressionResistancePriorityOf inSelectedView : PMViewForApplyingPriority) {
  // Vertical Axis is from to top to bottom
    let c = inView1.bottomAnchor.constraint (equalTo: inView2.bottomAnchor, constant: -inOffset)
    switch inSelectedView {
    case .firstView  : c.priority = inView2.contentCompressionResistancePriority (for: .vertical)
    case .secondView : c.priority = inView1.contentCompressionResistancePriority (for: .vertical)
    }
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (bottomOf inView1 : NSView,
                     equalToBottomOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
  // Vertical Axis is from to top to bottom
    let c = inView1.bottomAnchor.constraint (equalTo: inView2.bottomAnchor, constant: -inOffset)
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (bottomOf inView1 : NSView,
                     greaterThanOrEqualToBottomOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
  // Vertical Axis is from to top to bottom
//    let c = inView1.bottomAnchor.constraint (lessThanOrEqualTo: inView2.bottomAnchor, constant: -inOffset)
    let c = inView2.bottomAnchor.constraint (greaterThanOrEqualTo: inView1.bottomAnchor, constant: inOffset)
    self.append (c)
  }


  //--------------------------------------------------------------------------------------------------------------------
  //MARK: Last Baseline
  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (lastBaselineOf inView1 : NSView,
                     equalToLastBaselineOf inView2 : NSView) {
    let c = inView1.lastBaselineAnchor.constraint (equalTo: inView2.lastBaselineAnchor)
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------
  //MARK: Center X
  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (centerXOf inView1 : NSView, equalToCenterXOf inView2 : NSView) {
    let c = inView1.centerXAnchor.constraint (equalTo: inView2.centerXAnchor)
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------
  //MARK: Center Y
  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (centerYOf inView1 : NSView, equalToCenterYOf inView2 : NSView) {
    let c = inView1.centerYAnchor.constraint (equalTo: inView2.centerYAnchor)
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
