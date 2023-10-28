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

  mutating func append (equalWidth inView1 : NSView, _ inView2 : NSView) {
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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
