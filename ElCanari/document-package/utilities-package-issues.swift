//
//  utiliters-symbol-issues.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/11/2018.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

private let LINE_WIDTH  : CGFloat = 0.75

//--------------------------------------------------------------------------------------------------

extension Array where Element == CanariIssue {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendOvalZeroWidthIssueAt (x: Int, y: Int) {
    let r = NSRect (
      x: canariUnitToCocoa (x) - CANARI_ISSUE_HILITE_SIZE / 2.0,
      y: canariUnitToCocoa (y) - CANARI_ISSUE_HILITE_SIZE / 2.0,
      width: CANARI_ISSUE_HILITE_SIZE,
      height: CANARI_ISSUE_HILITE_SIZE
    )
    var bp = EBBezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Oval Width is null", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendOvalZeroHeightIssueAt (x: Int, y: Int) {
    let r = NSRect (
      x: canariUnitToCocoa (x) - CANARI_ISSUE_HILITE_SIZE / 2.0,
      y: canariUnitToCocoa (y) - CANARI_ISSUE_HILITE_SIZE / 2.0,
      width: CANARI_ISSUE_HILITE_SIZE,
      height: CANARI_ISSUE_HILITE_SIZE
    )
    var bp = EBBezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Oval Height is null", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendZoneZeroWidthIssueAt (x: Int, y: Int) {
    let r = NSRect (
      x: canariUnitToCocoa (x) - CANARI_ISSUE_HILITE_SIZE / 2.0,
      y: canariUnitToCocoa (y) - CANARI_ISSUE_HILITE_SIZE / 2.0,
      width: CANARI_ISSUE_HILITE_SIZE,
      height: CANARI_ISSUE_HILITE_SIZE
    )
    var bp = EBBezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Zone Width is null", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendZoneZeroHeightIssueAt (x: Int, y: Int) {
    let r = NSRect (
      x: canariUnitToCocoa (x) - CANARI_ISSUE_HILITE_SIZE / 2.0,
      y: canariUnitToCocoa (y) - CANARI_ISSUE_HILITE_SIZE / 2.0,
      width: CANARI_ISSUE_HILITE_SIZE,
      height: CANARI_ISSUE_HILITE_SIZE
    )
    var bp = EBBezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Zone Height is null", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendZoneEmptyNameHeightIssueAt (x: Int, y: Int) {
    let r = NSRect (
      x: canariUnitToCocoa (x) - CANARI_ISSUE_HILITE_SIZE / 2.0,
      y: canariUnitToCocoa (y) - CANARI_ISSUE_HILITE_SIZE / 2.0,
      width: CANARI_ISSUE_HILITE_SIZE,
      height: CANARI_ISSUE_HILITE_SIZE
    )
    var bp = EBBezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Zone Name is empty", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendZoneIntersectionIssueIn (rect: CanariRect) {
    var bp = EBBezierPath (rect: rect.cocoaRect.insetBy (dx: -LINE_WIDTH, dy: -LINE_WIDTH))
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Zone Intersection", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendDuplicatedZoneNameIssueIn (rect: NSRect) {
    var bp = EBBezierPath (rect: rect.insetBy (dx: -LINE_WIDTH, dy: -LINE_WIDTH))
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Duplicated Zone Name", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

