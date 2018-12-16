//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let CohenSutherlandOutcodeLEFT   : UInt8 = 1
let CohenSutherlandOutcodeRIGHT  : UInt8 = 2
let CohenSutherlandOutcodeBOTTOM : UInt8 = 4
let CohenSutherlandOutcodeTOP    : UInt8 = 8

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION CGRect
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CGRect : Hashable {

  //····················································································································

  init (point p1: CGPoint, point p2: CGPoint) {
    self.init ()
    self.origin = CGPoint (x: min (p1.x, p2.x), y: min (p1.y, p2.y))
    self.size = CGSize (width: abs (p1.x - p2.x), height: abs (p1.y - p2.y))
  }

  //····················································································································
  //   Contains point
  //····················································································································

  func CohenSutherlandOutcode (x inX : CGFloat, y inY : CGFloat) -> UInt8 {
    var result : UInt8 = 0
    if inX < self.minX {
      result |= CohenSutherlandOutcodeLEFT
    }else if inX > self.maxX {
      result |= CohenSutherlandOutcodeRIGHT
    }
    if inY < self.minY {
      result |= CohenSutherlandOutcodeBOTTOM
    }else if inY > self.maxY {
      result |= CohenSutherlandOutcodeTOP
    }
    return result
  }

  //····················································································································
  // https://en.wikipedia.org/wiki/Cohen–Sutherland_algorithm

  func clippedSegment (p1 inP1 : CGPoint, p2 inP2 : CGPoint) -> (CGPoint, CGPoint)? {
    var result : (CGPoint, CGPoint)? = nil
    var p1 = inP1
    var p2 = inP2
    var loop = true
    while loop {
      let p1OutCode = self.CohenSutherlandOutcode (x: p1.x, y: p1.y)
      let p2OutCode = self.CohenSutherlandOutcode (x: p2.x, y: p2.y)
      if (p1OutCode | p2OutCode) == 0 { // Both points are inside
        result = (p1, p2)
        loop = false
      }else if (p1OutCode & p2OutCode) != 0 { // Both points are outside, no intersection
        loop = false // returns nil
      }else{ // non trivial case
      // Failed both tests, so calculate the line segment to clip from an outside point to an intersection with clip edge
        let p : CGPoint
      // At least one endpoint is outside the clip rectangle; pick it.
        let outcode = (p1OutCode != 0) ? p1OutCode : p2OutCode
      // Now find the intersection point;
      // use formulas:
      //   slope = (y2 - y1) / (x2 - x1)
      //   x = x1 + (1 / slope) * (ym - y1), where ym is ymin or ymax
      //   y = y1 + slope * (xm - x1), where xm is xmin or xmax
      // No need to worry about divide-by-zero because, in each case, the
      // outcode bit being tested guarantees the denominator is non-zero
        if (outcode & CohenSutherlandOutcodeTOP) != 0 {           // point is above the clip window
          p = CGPoint (x: p1.x + (p2.x - p1.x) * (self.maxY - p1.y) / (p2.y - p1.y), y: self.maxY)
        }else if (outcode & CohenSutherlandOutcodeBOTTOM) != 0 { // point is below the clip window
          p = CGPoint (x: p1.x + (p2.x - p1.x) * (self.minY - p1.y) / (p2.y - p1.y), y: self.minY)
        }else if (outcode & CohenSutherlandOutcodeRIGHT) != 0 {  // point is to the right of clip window
          p = CGPoint (x: self.maxX, y: p1.y + (p2.y - p1.y) * (self.maxX - p1.x) / (p2.x - p1.x))
        }else{ // if (outcode & CohenSutherlandOutcodeLEFT) != 0 {   // point is to the left of clip window
          p = CGPoint (x: self.minX, y:p1.y + (p2.y - p1.y) * (self.minX - p1.x) / (p2.x - p1.x))
        }
      // Now we move outside point to intersection point to clip and get ready for next pass.
        if outcode == p1OutCode {
          p1 = p
  //				outcode0 = ComputeOutCode(x0, y0);
        }else{
          p2 = p
  //				outcode1 = ComputeOutCode(x1, y1);
        }
      }
    }
    return result
  }

  //····················································································································

  func intersectsStrokeBezierPath (_ inPath: NSBezierPath) -> Bool {
    var intersect = self.intersects (inPath.bounds)
    if intersect {
      intersect = false
      var points = [NSPoint] (repeating: .zero, count: 3)
      var currentPoint = NSPoint ()
      let flattenedPath = inPath.flattened
      var idx = 0
      while (idx < flattenedPath.elementCount) && !intersect {
        let type = flattenedPath.element (at: idx, associatedPoints: &points)
        idx += 1
        switch type {
        case .moveTo:
          currentPoint = points [0]
        case .lineTo:
          let p = points [0]
          let possibleResultSegment = self.clippedSegment (p1: currentPoint, p2: p)
          intersect = possibleResultSegment != nil
          currentPoint = p
        case .curveTo, .closePath: // Flattened path has no element of theses types
          ()
        }
      }
    }
    return intersect
  }

  //····················································································································

  func intersectsFilledBezierPath (_ inPath: NSBezierPath) -> Bool {
    var intersect = self.intersects (inPath.bounds)
    if intersect {
      intersect = inPath.contains (self.origin) // Bottom left
      if !intersect {
        intersect = inPath.contains (NSPoint (x: self.minX, y: self.maxY)) // Top left
      }
      if !intersect {
        intersect = inPath.contains (NSPoint (x: self.maxX, y: self.maxY)) // Top right
      }
      if !intersect {
        intersect = inPath.contains (NSPoint (x: self.maxX, y: self.minY)) // Bottom right
      }
      if !intersect {
        var points = [NSPoint] (repeating: .zero, count: 3)
        var currentPoint = NSPoint ()
        let flattenedPath = inPath.flattened
        var idx = 0
        while (idx < flattenedPath.elementCount) && !intersect {
          let type = flattenedPath.element (at: idx, associatedPoints: &points)
          idx += 1
          switch type {
          case .moveTo:
            currentPoint = points [0]
          case .lineTo:
            let p = points [0]
            let possibleResultSegment = self.clippedSegment (p1: currentPoint, p2: p)
            intersect = possibleResultSegment != nil
            currentPoint = p
          case .curveTo, .closePath: // Flattened path has no element of theses types
            ()
          }
        }
      }
    }
    return intersect
  }

  //····················································································································
  //   Protocol Hashable: hashValue
  //····················································································································

  public var hashValue : Int {
    return self.origin.x.hashValue ^ self.origin.y.hashValue ^ self.size.width.hashValue ^ self.size.height.hashValue
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————