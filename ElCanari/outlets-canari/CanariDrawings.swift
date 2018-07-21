//
//  CanariDrawings.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CanariDrawings : Hashable {

  //····················································································································
  //  Property
  //····················································································································

  let paths : [([NSBezierPath], NSColor, StrokeOrFill)]

  //····················································································································
  //  init
  //····················································································································

  init (paths inPaths : [([NSBezierPath], NSColor, StrokeOrFill)]) {
    paths = inPaths
  }

  //····················································································································
  //  Draw Rect
  //····················································································································

  func draw (_ dirtyRect: NSRect) {
    for (paths, color, operation) in self.paths {
      switch operation {
      case .stroke :
        color.setStroke ()
        for bp in paths {
          bp.stroke ()
        }
      case .fill :
        color.setFill ()
        for bp in paths {
          bp.fill ()
        }
      }
    }
  }

  //····················································································································
  /// Returns a Boolean value indicating whether two values are equal.
  ///
  /// Equality is the inverse of inequality. For any values `a` and `b`,
  /// `a == b` implies that `a != b` is `false`.
  ///
  /// - Parameters:
  ///   - lhs: A value to compare.
  ///   - rhs: Another value to compare.
  //····················································································································

  public static func == (lhs: CanariDrawings, rhs: CanariDrawings) -> Bool {
    var equal = lhs.paths.count == rhs.paths.count
    if equal {
      var idx = 0
      while idx < lhs.paths.count {
        equal = (lhs.paths [idx].0.count == rhs.paths [idx].0.count) && (lhs.paths [idx].1 == rhs.paths [idx].1) && (lhs.paths [idx].2 == rhs.paths [idx].2)
        if equal {
          var idy = 0
          while idy < lhs.paths [idx].0.count {
            equal = lhs.paths [idx].0 [idy] == rhs.paths [idx].0 [idy]
            if !equal {
              break
            }
            idy += 1
          }
        }
        if !equal {
          break
        }
        idx += 1
      }
    }
    return equal
  }

  //····················································································································
  /// The hash value.
  ///
  /// Hash values are not guaranteed to be equal across different executions of
  /// your program. Do not save hash values to use during a future execution.
  //····················································································································

  public var hashValue : Int {
    var h = 0
    for (bps, color, op) in self.paths {
      h ^= color.hashValue ^ op.rawValue.hashValue
      for pb in bps {
        h ^= pb.hashValue
      }
    }
    return h
  }


  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
