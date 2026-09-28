//
//  utilities-symbol-issues.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 27/11/2018.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

private let LINE_WIDTH : CGFloat = 0.75

//--------------------------------------------------------------------------------------------------

@MainActor extension Array where Element == CanariIssue {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendSymbolEmptyPinNameIssueAt (x: CanariLength, y: CanariLength) {
    let r = NSRect (
      x: x.ptValue - CANARI_ISSUE_HILITE_SIZE / 2.0,
      y: y.ptValue - CANARI_ISSUE_HILITE_SIZE / 2.0,
      width: CANARI_ISSUE_HILITE_SIZE,
      height: CANARI_ISSUE_HILITE_SIZE
    )
    var bp = BezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .warning, message: "Empty Pin Name", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendSymbolEmptyTextIssueAt (x: CanariLength, y: CanariLength) {
    let r = NSRect (
      x: x.ptValue - CANARI_ISSUE_HILITE_SIZE / 2.0,
      y: y.ptValue - CANARI_ISSUE_HILITE_SIZE / 2.0,
      width: CANARI_ISSUE_HILITE_SIZE,
      height: CANARI_ISSUE_HILITE_SIZE
    )
    var bp = BezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .warning, message: "Empty Text", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendSymbolSeveralPinAtSameLocationIssue (pinLocation inPoint: CanariPoint) {
    let r = NSRect (
      x: inPoint.x.ptValue - CANARI_ISSUE_HILITE_SIZE / 2.0,
      y: inPoint.y.ptValue - CANARI_ISSUE_HILITE_SIZE / 2.0,
      width: CANARI_ISSUE_HILITE_SIZE,
      height: CANARI_ISSUE_HILITE_SIZE
    )
    var bp = BezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Several pin at the same location", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendSymbolDuplicatedPinNameIssueAt (rect: NSRect) {
    var bp = BezierPath (rect: rect)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Duplicated Pin Name", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendSymbolNoPinNameIssue () {
    self.append (CanariIssue (kind: .warning, message: "No Pin"))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendSymbolPinHorizontalIssueAt (x: CanariLength, y: CanariLength) {
    let r = NSRect (
      x: x.ptValue - CANARI_ISSUE_HILITE_SIZE / 2.0,
      y: y.ptValue - CANARI_ISSUE_HILITE_SIZE / 2.0,
      width: CANARI_ISSUE_HILITE_SIZE,
      height: CANARI_ISSUE_HILITE_SIZE
    )
    var bp = BezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Pin Horizontal Alignment", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendSymbolPinVerticalIssueAt (x: CanariLength, y: CanariLength) {
    let r = NSRect (
      x: x.ptValue - CANARI_ISSUE_HILITE_SIZE / 2.0,
      y: y.ptValue - CANARI_ISSUE_HILITE_SIZE / 2.0,
      width: CANARI_ISSUE_HILITE_SIZE,
      height: CANARI_ISSUE_HILITE_SIZE
    )
    var bp = BezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Pin Vertical Alignment", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendSymbolHorizontalIssueAt (x: CanariLength, y: CanariLength) {
    let r = NSRect (
      x: x.ptValue - CANARI_ISSUE_HILITE_SIZE / 2.0,
      y: y.ptValue - CANARI_ISSUE_HILITE_SIZE / 2.0,
      width: CANARI_ISSUE_HILITE_SIZE,
      height: CANARI_ISSUE_HILITE_SIZE
    )
    var bp = BezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Horizontal Alignment", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendSymbolVerticalIssueAt (x: CanariLength, y: CanariLength) {
    let r = NSRect (
      x: x.ptValue - CANARI_ISSUE_HILITE_SIZE / 2.0,
      y: y.ptValue - CANARI_ISSUE_HILITE_SIZE / 2.0,
      width: CANARI_ISSUE_HILITE_SIZE,
      height: CANARI_ISSUE_HILITE_SIZE
    )
    var bp = BezierPath (ovalIn: r)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Vertical Alignment", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendSymbolWidthIssueAt (x: CanariLength, y: CanariLength, width : CanariLength, height : CanariLength) {
    let r = NSRect (
      x: x.ptValue - CANARI_ISSUE_HILITE_SIZE / 2.0,
      y: (y + height / 2).ptValue - CANARI_ISSUE_HILITE_SIZE / 2.0,
      width: width.ptValue + CANARI_ISSUE_HILITE_SIZE,
      height: CANARI_ISSUE_HILITE_SIZE
    )
    var bp = BezierPath (roundedRect: r, xRadius: CANARI_ISSUE_HILITE_SIZE / 2.0, yRadius: CANARI_ISSUE_HILITE_SIZE / 2.0)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Width Alignment", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendSymbolHeightIssueAt (x: CanariLength, y: CanariLength, width : CanariLength, height : CanariLength) {
    let r = NSRect (
      x: (x + width / 2).ptValue - CANARI_ISSUE_HILITE_SIZE / 2.0,
      y: y.ptValue - CANARI_ISSUE_HILITE_SIZE / 2.0,
      width: CANARI_ISSUE_HILITE_SIZE,
      height: height.ptValue + CANARI_ISSUE_HILITE_SIZE
    )
    var bp = BezierPath (roundedRect: r, xRadius: CANARI_ISSUE_HILITE_SIZE / 2.0, yRadius: CANARI_ISSUE_HILITE_SIZE / 2.0)
    bp.lineWidth = LINE_WIDTH
    self.append (CanariIssue (kind: .error, message: "Height Alignment", pathes: [bp]))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

