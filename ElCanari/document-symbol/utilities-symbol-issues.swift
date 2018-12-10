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

  mutating func appendSymbolEmptyPinNameIssueAt (x: Int, y: Int) {
    let r = NSRect (
      x: canariUnitToCocoa (x) - HILITE_SIZE / 2.0,
      y: canariUnitToCocoa (y) - HILITE_SIZE / 2.0,
      width: HILITE_SIZE,
      height: HILITE_SIZE
    )
    let bp = NSBezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .warning, message: "Empty Pin Name", path: bp))
  }

  //····················································································································

  mutating func appendSymbolEmptyTextIssueAt (x: Int, y: Int) {
    let r = NSRect (
      x: canariUnitToCocoa (x) - HILITE_SIZE / 2.0,
      y: canariUnitToCocoa (y) - HILITE_SIZE / 2.0,
      width: HILITE_SIZE,
      height: HILITE_SIZE
    )
    let bp = NSBezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .warning, message: "Empty Text", path: bp))
  }

  //····················································································································

  mutating func appendSymbolSeveralPinAtSameLocationIssue (pinLocation inPoint: CanariPoint) {
    let r = NSRect (
      x: canariUnitToCocoa (inPoint.x) - HILITE_SIZE / 2.0,
      y: canariUnitToCocoa (inPoint.y) - HILITE_SIZE / 2.0,
      width: HILITE_SIZE,
      height: HILITE_SIZE
    )
    let bp = NSBezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Several pin at the same location", path: bp))
  }

  //····················································································································

  mutating func appendSymbolDuplicatedPinNameIssueAt (rect: NSRect) {
    let bp = NSBezierPath (rect: rect)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Duplicated Pin Name", path: bp))
  }

  //····················································································································

  mutating func appendSymbolNoPinNameIssue () {
    self.append (CanariIssue (kind: .warning, message: "No Pin", path: NSBezierPath ()))
  }

  //····················································································································

  mutating func appendSymbolPinHorizontalIssueAt (x: Int, y: Int) {
    let r = NSRect (
      x: canariUnitToCocoa (x) - HILITE_SIZE / 2.0,
      y: canariUnitToCocoa (y) - HILITE_SIZE / 2.0,
      width: HILITE_SIZE,
      height: HILITE_SIZE
    )
    let bp = NSBezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Pin Horizontal Alignment", path: bp))
  }

  //····················································································································

  mutating func appendSymbolPinVerticalIssueAt (x: Int, y: Int) {
    let r = NSRect (
      x: canariUnitToCocoa (x) - HILITE_SIZE / 2.0,
      y: canariUnitToCocoa (y) - HILITE_SIZE / 2.0,
      width: HILITE_SIZE,
      height: HILITE_SIZE
    )
    let bp = NSBezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Pin Vertical Alignment", path: bp))
  }

  //····················································································································

  mutating func appendSymbolHorizontalIssueAt (x: Int, y: Int) {
    let r = NSRect (
      x: canariUnitToCocoa (x) - HILITE_SIZE / 2.0,
      y: canariUnitToCocoa (y) - HILITE_SIZE / 2.0,
      width: HILITE_SIZE,
      height: HILITE_SIZE
    )
    let bp = NSBezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Horizontal Alignment", path: bp))
  }

  //····················································································································

  mutating func appendSymbolVerticalIssueAt (x: Int, y: Int) {
    let r = NSRect (
      x: canariUnitToCocoa (x) - HILITE_SIZE / 2.0,
      y: canariUnitToCocoa (y) - HILITE_SIZE / 2.0,
      width: HILITE_SIZE,
      height: HILITE_SIZE
    )
    let bp = NSBezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Vertical Alignment", path: bp))
  }

  //····················································································································

  mutating func appendSymbolWidthIssueAt (x: Int, y: Int, width : Int, height : Int) {
    let r = NSRect (
      x: canariUnitToCocoa (x) - HILITE_SIZE / 2.0,
      y: canariUnitToCocoa (y + height / 2) - HILITE_SIZE / 2.0,
      width: canariUnitToCocoa (width) + HILITE_SIZE,
      height: HILITE_SIZE
    )
    let bp = NSBezierPath (roundedRect: r, xRadius: HILITE_SIZE / 2.0, yRadius: HILITE_SIZE / 2.0)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Width Alignment", path: bp))
  }

  //····················································································································

  mutating func appendSymbolHeightIssueAt (x: Int, y: Int, width : Int, height : Int) {
    let r = NSRect (
      x: canariUnitToCocoa (x + width / 2) - HILITE_SIZE / 2.0,
      y: canariUnitToCocoa (y) - HILITE_SIZE / 2.0,
      width: HILITE_SIZE,
      height: canariUnitToCocoa (height) + HILITE_SIZE
    )
    let bp = NSBezierPath (roundedRect: r, xRadius: HILITE_SIZE / 2.0, yRadius: HILITE_SIZE / 2.0)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Height Alignment", path: bp))
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

