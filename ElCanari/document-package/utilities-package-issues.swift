//
//  utiliters-symbol-issues.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/11/2018.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

private let LINE_WIDTH  : CGFloat = 0.75

//--------------------------------------------------------------------------------------------------

extension Array where Element == CanariIssue {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendOvalZeroWidthIssueAt (x: CanariLength, y: CanariLength) {
    let r = NSRect (
      x: x - .cu (CANARI_ISSUE_HILITE_SIZE) / 2.0,
      y: y - .cu (CANARI_ISSUE_HILITE_SIZE) / 2.0,
      width: .cu (CANARI_ISSUE_HILITE_SIZE),
      height: .cu (CANARI_ISSUE_HILITE_SIZE)
    )
    var bp = BezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Oval Width is null", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendOvalZeroHeightIssueAt (x: CanariLength, y: CanariLength) {
    let r = NSRect (
      x: x - .cu (CANARI_ISSUE_HILITE_SIZE) / 2.0,
      y: y - .cu (CANARI_ISSUE_HILITE_SIZE) / 2.0,
      width: .cu (CANARI_ISSUE_HILITE_SIZE),
      height: .cu (CANARI_ISSUE_HILITE_SIZE)
    )
    var bp = BezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Oval Height is null", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendZoneZeroWidthIssueAt (x: CanariLength, y: CanariLength) {
    let r = NSRect (
      x: x - .cu (CANARI_ISSUE_HILITE_SIZE) / 2.0,
      y: y - .cu (CANARI_ISSUE_HILITE_SIZE) / 2.0,
      width: .cu (CANARI_ISSUE_HILITE_SIZE),
      height: .cu (CANARI_ISSUE_HILITE_SIZE)
    )
    var bp = BezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Zone Width is null", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendZoneZeroHeightIssueAt (x: CanariLength, y: CanariLength) {
    let r = NSRect (
      x: x - .cu (CANARI_ISSUE_HILITE_SIZE) / 2.0,
      y: y - .cu (CANARI_ISSUE_HILITE_SIZE) / 2.0,
      width: .cu (CANARI_ISSUE_HILITE_SIZE),
      height: .cu (CANARI_ISSUE_HILITE_SIZE)
    )
    var bp = BezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Zone Height is null", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendZoneEmptyNameHeightIssueAt (x: CanariLength, y: CanariLength) {
    let r = NSRect (
      x: x - .cu (CANARI_ISSUE_HILITE_SIZE) / 2.0,
      y: y - .cu (CANARI_ISSUE_HILITE_SIZE) / 2.0,
      width: .cu (CANARI_ISSUE_HILITE_SIZE),
      height: .cu (CANARI_ISSUE_HILITE_SIZE)
    )
    var bp = BezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Zone Name is empty", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendZoneIntersectionIssueIn (rect: CanariRect) {
    var bp = BezierPath (rect: rect.ptValue.insetBy (dx: -LINE_WIDTH, dy: -LINE_WIDTH))
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Zone Intersection", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendDuplicatedZoneNameIssueIn (rect: NSRect) {
    var bp = BezierPath (rect: rect.insetBy (dx: -LINE_WIDTH, dy: -LINE_WIDTH))
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Duplicated Zone Name", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

