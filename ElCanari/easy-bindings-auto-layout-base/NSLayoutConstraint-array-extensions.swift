//
//  NSLayoutConstraint-extensions.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/10/2023.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension Array where Element == NSLayoutConstraint {

  //--------------------------------------------------------------------------------------------------------------------
  //MARK: Width
  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (widthOf inView1 : NSView,
                     equalToWidthOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
    let c = NSLayoutConstraint (
      item: inView1,
      attribute: .width,
      relatedBy: .equal,
      toItem: inView2,
      attribute: .width,
      multiplier: 1.0,
      constant: inOffset
    )
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (widthOf inView : NSView,
                     equalTo inWidth : CGFloat,
                     priority inPriority : NSLayoutConstraint.Priority = .required) {
    let c = NSLayoutConstraint (
      item: inView,
      attribute: .width,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: inWidth
    )
    c.priority = inPriority
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (widthOf inView1 : NSView,
                     greaterThanOrEqualTo inWidth : CGFloat) {
    let c = NSLayoutConstraint (
      item: inView1,
      attribute: .width,
      relatedBy: .greaterThanOrEqual,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: inWidth
    )
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------
  //MARK: Height
  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (heightOf inView1 : NSView,
                     equalToHeightOf inView2 : NSView) {
    let c = NSLayoutConstraint (
      item: inView1,
      attribute: .height,
      relatedBy: .equal,
      toItem: inView2,
      attribute: .height,
      multiplier: 1.0,
      constant: 0.0
    )
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (heightOf inView1 : NSView,
                     equalToHalfHeightOf inView2 : NSView) {
    let c = NSLayoutConstraint (
      item: inView1,
      attribute: .height,
      relatedBy: .equal,
      toItem: inView2,
      attribute: .height,
      multiplier: 0.5,
      constant: 0.0
    )
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (heightOf inView : NSView,
                     equalTo inHeight : CGFloat,
                     priority inPriority : NSLayoutConstraint.Priority = .required) {
    let c = NSLayoutConstraint (
      item: inView,
      attribute: .height,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: inHeight
    )
    c.priority = inPriority
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------
  //MARK: Left
  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (leftOf inView1 : NSView,
                     equalToLeftOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
    let c = NSLayoutConstraint (
      item: inView1,
      attribute: .left,
      relatedBy: .equal,
      toItem: inView2,
      attribute: .left,
      multiplier: 1.0,
      constant: inOffset
    )
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (leftOf inView1 : NSView,
                     equalToRightOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
    let c = NSLayoutConstraint (
      item: inView1,
      attribute: .left,
      relatedBy: .equal,
      toItem: inView2,
      attribute: .right,
      multiplier: 1.0,
      constant: inOffset
    )
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------
  //MARK: Right
  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (rightOf inView1 : NSView,
                     equalToRightOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
    let c = NSLayoutConstraint (
      item: inView1,
      attribute: .right,
      relatedBy: .equal,
      toItem: inView2,
      attribute: .right,
      multiplier: 1.0,
      constant: inOffset
    )
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------
  //MARK: Top
  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (topOf inView1 : NSView,
                     equalToTopOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0,
                     priority inPriority : NSLayoutConstraint.Priority = .required) {
    let c = NSLayoutConstraint (
      item: inView1,
      attribute: .top,
      relatedBy: .equal,
      toItem: inView2,
      attribute: .top,
      multiplier: 1.0,
      constant: -inOffset // Vertical Axis is from to top to bottom
    )
    c.priority = inPriority
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------
  //MARK: Bottom
  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (bottomOf inView1 : NSView,
                     equalToTopOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
    let c = NSLayoutConstraint (
      item: inView1,
      attribute: .bottom,
      relatedBy: .equal,
      toItem: inView2,
      attribute: .top,
      multiplier: 1.0,
      constant: -inOffset // Vertical Axis is from to top to bottom
    )
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (bottomOf inView1 : NSView,
                     equalToBottomOf inView2 : NSView,
                     plus inOffset : CGFloat = 0.0) {
    let c = NSLayoutConstraint (
      item: inView1,
      attribute: .bottom,
      relatedBy: .equal,
      toItem: inView2,
      attribute: .bottom,
      multiplier: 1.0,
      constant: -inOffset // Vertical Axis is from to top to bottom
    )
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------
  //MARK: Last Baseline
  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (lastBaselineOf inView1 : NSView,
                     equalToLastBaselineOf inView2 : NSView) {
    let c = NSLayoutConstraint (
      item: inView1,
      attribute: .lastBaseline,
      relatedBy: .equal,
      toItem: inView2,
      attribute: .lastBaseline,
      multiplier: 1.0,
      constant: 0.0
    )
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------
  //MARK: Center X
  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (centerXOf inView1 : NSView, equalToCenterXOf inView2 : NSView) {
    let c = NSLayoutConstraint (
      item: inView1,
      attribute: .centerX,
      relatedBy: .equal,
      toItem: inView2,
      attribute: .centerX,
      multiplier: 1.0,
      constant: 0.0
    )
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------
  //MARK: Center Y
  //--------------------------------------------------------------------------------------------------------------------

  mutating func add (centerYOf inView1 : NSView, equalToCenterYOf inView2 : NSView) {
    let c = NSLayoutConstraint (
      item: inView1,
      attribute: .centerY,
      relatedBy: .equal,
      toItem: inView2,
      attribute: .centerY,
      multiplier: 1.0,
      constant: 0.0
    )
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

}

//--------------------------------------------------------------------------------------------------
