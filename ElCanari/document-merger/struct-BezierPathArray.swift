//
//  struct-BezierPathArray.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 18/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   BezierPathArray
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct BezierPathArray : Hashable {

  //····················································································································

  private var mPathes = [NSBezierPath] ()

  //····················································································································

  var array : [NSBezierPath] { return mPathes }

  //····················································································································

  public static func == (lhs: BezierPathArray, rhs: BezierPathArray) -> Bool {
    var equal = lhs.mPathes.count == rhs.mPathes.count
    if equal {
      var idx = 0
      while idx < lhs.mPathes.count {
        if lhs.mPathes [idx] != rhs.mPathes [idx] {
          equal = false
          idx = lhs.mPathes.count // For exiting loop
        }
        idx += 1
      }
    }
    return equal
  }

  //····················································································································

//  public var hashValue: Int {
//    var hash = 0
//    for path in mPathes {
//      hash = hash ^ path.hashValue
//    }
//    return hash
//  }
//  func hash (into hasher: inout Hasher) {
//    for path in mPathes {
//      path.hash (into: &hasher)
//    }
//  }

  //····················································································································

  mutating func append (_ inBP : NSBezierPath) {
    mPathes.append (inBP)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
