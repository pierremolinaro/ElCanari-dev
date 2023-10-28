//
//  NSLayoutConstraint-extensions.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/10/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Array where Element == NSLayoutConstraint {

  //--------------------------------------------------------------------------------------------------------------------

  mutating func append (makeWidthOf inView1 : NSView, equalToWidthOf inView2 : NSView) {
    let c = NSLayoutConstraint (
      item: inView1,
      attribute: .width,
      relatedBy: .equal,
      toItem: inView2,
      attribute: .width,
      multiplier: 1.0,
      constant: 0.0
    )
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func append (makeWidthOf inView : NSView, greaterThanOrEqual inWidth : CGFloat) {
    let c = NSLayoutConstraint (
      item: inView,
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

  mutating func append (makeWidthOf inView : NSView, equalTo inWidth : CGFloat) {
    let c = NSLayoutConstraint (
      item: inView,
      attribute: .width,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: inWidth
    )
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func append (makeHeightOf inView : NSView, equalTo inHeight : CGFloat) {
    let c = NSLayoutConstraint (
      item: inView,
      attribute: .height,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: inHeight
    )
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func append (makeHeightOf inView1 : NSView, equalToHeightOf inView2 : NSView) {
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

  mutating func append (setLeftOf inView1 : NSView,
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

  mutating func append (setRightOf inView1 : NSView,
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

  mutating func append (setTopOf inView1 : NSView,
                        equalToTopOf inView2 : NSView,
                        plus inOffset : CGFloat = 0.0) {
    let c = NSLayoutConstraint (
      item: inView1,
      attribute: .top,
      relatedBy: .equal,
      toItem: inView2,
      attribute: .top,
      multiplier: 1.0,
      constant: -inOffset // Vertical Axis is from to top to bottom
    )
    self.append (c)
  }

  //--------------------------------------------------------------------------------------------------------------------

  mutating func append (setBottomOf inView1 : NSView,
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

  mutating func append (setBottomOf inView1 : NSView,
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

  mutating func append (alignBottomOf inView1 : NSView, toBottomOf inView2 : NSView, plus inOffset : CGFloat) {
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

  mutating func append (alignXCenterOf inView1 : NSView, _ inView2 : NSView) {
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

  mutating func append (alignYCenterOf inView1 : NSView, _ inView2 : NSView) {
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
