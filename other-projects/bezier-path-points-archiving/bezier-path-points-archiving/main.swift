//
//  main.swift
//  bezier-path-points-archiving
//
//  Created by Pierre Molinaro on 27/06/2019.
//  Copyright © 2019 Pierre Molinaro. All rights reserved.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension NSBezierPath {

  //····················································································································

  var archiveString : String {
    var result = ""
    var idx = 0
    var points = [NSPoint] (repeating: .zero, count: 3)
    while idx < self.elementCount {
      let type = self.element (at: idx, associatedPoints: &points)
      idx += 1
      switch type {
      case .moveTo:
        result += ":\(points[0].x) \(points[0].y)"
      case .lineTo:
        result += ";\(points[0].x) \(points[0].y)"
      case .curveTo:
        result += "@\(points[0].x) \(points[0].y) \(points[1].x) \(points[1].y) \(points[2].x) \(points[2].y)"
      case .closePath:
        result += "#"
//      @unknown default:
//        ()
      }
    }
    return result
  }

  //····················································································································

  convenience init (withArchiveString inString : String) {
    self.init ()
    let scanner = Scanner (string: inString)
    var ok = true
    var loop = true
    while ok && loop {
      if scanner.scanString (":", into: nil) {
        var x = 0.0
        ok = scanner.scanDouble (&x)
        var y = 0.0
        if ok {
          ok = scanner.scanDouble (&y)
        }
        if ok {
          self.move (to: NSPoint (x: CGFloat (x), y: CGFloat (y)))
        }
      }else if scanner.scanString (";", into: nil) {
        var x = 0.0
        ok = scanner.scanDouble (&x)
        var y = 0.0
        if ok {
          ok = scanner.scanDouble (&y)
        }
        if ok {
          self.line (to: NSPoint (x: CGFloat (x), y: CGFloat (y)))
        }
      }else if scanner.scanString ("@", into: nil) {
        var x0 = 0.0
        ok = scanner.scanDouble (&x0)
        var y0 = 0.0
        if ok {
          ok = scanner.scanDouble (&y0)
        }
        var x1 = 0.0
        if ok {
          ok = scanner.scanDouble (&x1)
        }
        var y1 = 0.0
        if ok {
          ok = scanner.scanDouble (&y1)
        }
        var x2 = 0.0
        if ok {
          ok = scanner.scanDouble (&x2)
        }
        var y2 = 0.0
        if ok {
          ok = scanner.scanDouble (&y2)
        }
        if ok {
          self.curve (
            to: NSPoint (x: CGFloat (x2), y: CGFloat (y2)),
            controlPoint1: NSPoint (x: CGFloat (x0), y: CGFloat (y0)),
            controlPoint2: NSPoint (x: CGFloat (x1), y: CGFloat (y1))
          )
        }
      }else if scanner.scanString ("#", into: nil) {
        self.close ()
      }else if scanner.isAtEnd {
        loop = false
      }
    }
    print ("ok: \(ok)")
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let bp = NSBezierPath (roundedRect: NSRect (x: 10.0, y: 10.0, width: 200.0, height: 200.0), xRadius: 5.0, yRadius: 5.0)

//--- Keyed archiver
let mutableData = NSMutableData ()
let keyedArchiver0 = NSKeyedArchiver (forWritingWith: mutableData)
keyedArchiver0.encode (bp, forKey: NSKeyedArchiveRootObjectKey)
keyedArchiver0.finishEncoding ()
print ("keyed archive: \(mutableData.length) bytes")

//--- Archive string
let archiveString = bp.archiveString
print ("archive string: \(archiveString.count) bytes")
print ("archive string: '\(archiveString)'")
let unarchivedBP = NSBezierPath (withArchiveString: archiveString)
print ("Comparison: \(bp.isEqual (unarchivedBP))")
print ("new archive: \(unarchivedBP.archiveString)")
print ("archive comparison: \(unarchivedBP.archiveString == archiveString)")
