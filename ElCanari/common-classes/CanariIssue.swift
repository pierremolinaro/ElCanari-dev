//
//  class-CanariIssue.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/07/2018.
//
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

let CANARI_ISSUE_HILITE_SIZE : CGFloat = milsToCocoaUnit (25.0) * 4.0

//--------------------------------------------------------------------------------------------------
//   CanariIssue
//--------------------------------------------------------------------------------------------------

struct CanariIssue : Hashable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (kind inKind : CanariIssue.Kind,
        message inMessage : String,
        pathes inBezierPathes : [BézierPath] = [],
        representativeValue inValue : Int = 0) {
    self.message = inMessage
    self.pathes = inBezierPathes
    self.kind = inKind
    self.representativeValue = inValue
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Kind
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  enum Kind {
    case warning
    case error
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let kind : CanariIssue.Kind
  let message : String
  let pathes : [BézierPath]
  let representativeValue : Int

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Bezier path center point
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var center : NSPoint {
    if self.pathes.isEmpty {
      return NSPoint ()
    }else{
      var r = NSRect.null
      for path in self.pathes {
        r = r.union (path.bounds)
      }
      return NSPoint (x: r.midX, y: r.midY)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Sorting
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func displaySortingCompare (lhs: CanariIssue, rhs: CanariIssue) -> Bool {
    let lP = lhs.center
    let rP = rhs.center
    return (lP.x < rP.x) || ((lP.x == rP.x) && (lP.y < rP.y))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
