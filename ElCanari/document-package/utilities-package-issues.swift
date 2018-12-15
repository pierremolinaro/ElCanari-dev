//
//  utiliters-symbol-issues.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/11/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let HILITE_SIZE = SYMBOL_GRID_IN_COCOA_UNIT * 4.0
private let LINE_WIDTH : CGFloat = 0.75

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Array where Element == CanariIssue {

  //····················································································································

  mutating func appendOvalZeroWidthIssueAt (x: Int, y: Int) {
    let r = NSRect (
      x: canariUnitToCocoa (x) - HILITE_SIZE / 2.0,
      y: canariUnitToCocoa (y) - HILITE_SIZE / 2.0,
      width: HILITE_SIZE,
      height: HILITE_SIZE
    )
    let bp = NSBezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Oval Width is null", path: bp))
  }

  //····················································································································

  mutating func appendOvalZeroHeightIssueAt (x: Int, y: Int) {
    let r = NSRect (
      x: canariUnitToCocoa (x) - HILITE_SIZE / 2.0,
      y: canariUnitToCocoa (y) - HILITE_SIZE / 2.0,
      width: HILITE_SIZE,
      height: HILITE_SIZE
    )
    let bp = NSBezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Oval Height is null", path: bp))
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

