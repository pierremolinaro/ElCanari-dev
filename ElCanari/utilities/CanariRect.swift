//
//  CanariRect.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/11/2018.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------
//  Struct CanariRect
//--------------------------------------------------------------------------------------------------

struct CanariRect : Equatable, Hashable {
  var origin : CanariPoint
  var size : CanariSize

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static var zero : CanariRect { CanariRect (origin: .zero, size: .zero) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (origin inOrigin : CanariPoint, size inSize : CanariSize) {
    self.origin = inOrigin
    self.size = inSize
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (points inPoints : [CanariPoint]) {
    if inPoints.count == 0 {
      self.origin = .zero
      self.size = .zero
    }else{
      var xMin = Int.max
      var yMin = Int.max
      var xMax = Int.min
      var yMax = Int.min
      for p in inPoints {
        if xMin > p.x {
          xMin = p.x
        }
        if yMin > p.y {
          yMin = p.y
        }
        if xMax < p.x {
          xMax = p.x
        }
        if yMax < p.y {
          yMax = p.y
        }
      }
      self.origin = CanariPoint (x: xMin, y: yMin)
      self.size = CanariSize (width: xMax - xMin, height: yMax - yMin)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (left inLeft : Int, bottom inBottom: Int, width inWidth : Int, height inHeight : Int) {
    if (inWidth > 0) && (inHeight > 0) {
      self.origin = CanariPoint (x: inLeft, y: inBottom)
      self.size = CanariSize (width: inWidth, height: inHeight)
    }else{
      self.origin = .zero
      self.size = .zero
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Accessors
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var left    : Int { return self.origin.x }
  var midX    : Int { return self.origin.x + self.size.width / 2 }
  var maxX    : Int { return self.origin.x + self.size.width }
  var right   : Int { return self.origin.x + self.size.width }

  var bottom  : Int { return self.origin.y }
  var midY    : Int { return self.origin.y + self.size.height / 2 }
  var maxY    : Int { return self.origin.y + self.size.height }
  var top     : Int { return self.origin.y + self.size.height }

  var height  : Int { return self.size.height }
  var width   : Int { return self.size.width }

  var center : CanariPoint { return CanariPoint (x: self.left + self.width / 2, y: self.bottom + self.height / 2) }

  var bottomLeft : CanariPoint { return CanariPoint (x: self.left, y: self.bottom) }

  var bottomCenter : CanariPoint { return CanariPoint (x: self.midX, y: self.bottom) }

  var bottomRight : CanariPoint { return CanariPoint (x: self.right, y: self.bottom) }

  var topLeft : CanariPoint { return CanariPoint (x: self.left, y: self.top) }

  var topCenter : CanariPoint { return CanariPoint (x: self.midX, y: self.top) }

  var topRight : CanariPoint { return CanariPoint (x: self.right, y: self.top) }

  var middleRight : CanariPoint { return CanariPoint (x: self.right, y: self.midY) }

  var middleLeft : CanariPoint { return CanariPoint (x: self.left, y: self.midY) }

  var isEmpty : Bool { return (self.size.width <= 0) || (self.size.height <= 0) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Rotation around rectangle center
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func rotated90Clockwise (_ inP : CanariPoint) -> CanariPoint {
//    let x = self.origin.x + self.origin.y + self.size.height - inP.y
//    let y = self.origin.x + self.origin.y + self.size.width  - inP.x
//    return CanariPoint (x: x, y: y)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func rotated90CounterClockwise (_ inP : CanariPoint) -> CanariPoint {
//    let x = self.origin.x + inP.y - self.origin.y
//    let y = self.origin.x + self.origin.y + self.size.width - inP.x
//    return CanariPoint (x: x, y: y)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   cocoaRect
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var cocoaRect : NSRect {
    return NSRect (
      x: canariUnitToCocoa (self.origin.x),
      y: canariUnitToCocoa (self.origin.y),
      width: canariUnitToCocoa (self.size.width),
      height: canariUnitToCocoa (self.size.height)
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Union
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func union (_ inOtherRect : CanariRect) -> CanariRect {
    let result : CanariRect
    if self.isEmpty {
      result = inOtherRect
    }else if inOtherRect.isEmpty {
      result = self
    }else{
      let left = min (self.left, inOtherRect.left)
      let bottom = min (self.bottom, inOtherRect.bottom)
      let right = max (self.right, inOtherRect.right)
      let top = max (self.top, inOtherRect.top)
      result = CanariRect (left: left, bottom: bottom, width: right - left, height: top - bottom)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Intersection
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func intersection (_ inOtherRect : CanariRect) -> CanariRect {
    let result : CanariRect
    if self.isEmpty || inOtherRect.isEmpty {
      result = .zero // Empty Rect
    }else{
      let left   = max (self.left, inOtherRect.left)
      let bottom = max (self.bottom, inOtherRect.bottom)
      let right  = min (self.left + self.width,  inOtherRect.left + inOtherRect.width)
      let top    = min (self.bottom + self.height, inOtherRect.bottom + inOtherRect.height)
      result = CanariRect (left: left, bottom: bottom, width: right - left, height: top - bottom)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Inset
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func insetBy (dx inDx : Int, dy inDy : Int) -> CanariRect {
    let result : CanariRect
    if self.isEmpty {
      result = .zero // Empty Rect
    }else{
      let right = self.left + inDx
      let bottom = self.bottom + inDy
      let left = self.left + self.width - inDx
      let top = self.bottom + self.height - inDy
      result = CanariRect (left: right, bottom: bottom, width: left - right, height: top - bottom)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Contains point
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func contains (x inX : Int, y inY : Int) -> Bool {
    return (inX >= self.left) && (inX <= self.right) && (inY >= self.bottom) && (inY <= self.top)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   CohenSutherlandOutcode
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func cohenSutherlandOutcode (x inX : Int, y inY : Int) -> UInt8 {
//    var result : UInt8 = 0
//    if inX < self.left {
//      result |= CohenSutherlandOutcodeLEFT
//    }else if inX > self.right {
//      result |= CohenSutherlandOutcodeRIGHT
//    }
//    if inY < self.bottom {
//      result |= CohenSutherlandOutcodeBOTTOM
//    }else if inY > self.top {
//      result |= CohenSutherlandOutcodeTOP
//    }
//    return result
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Relative location of a point from rectangle center
  //
  //    *---------------*
  //    |\             /|
  //    | \   above   / |
  //    |  \         /  |
  //    |   \       /   |
  //    |    \     /    |
  //    |     \   /     |
  //    |      \ /      |
  //    | left  * right |
  //    |      / \      |
  //    |     /   \     |
  //    |    /     \    |
  //    |   /       \   |
  //    |  /         \  |
  //    | /   below   \ |
  //    |/             \|
  //    *---------------*
  //
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  enum RelativeLocation { case right ; case above ; case left ; case below}

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func relativeLocation (of inPoint : CanariPoint) -> RelativeLocation {
//    if self.isEmpty {
//      return .left
//    }else{
//      let dx = inPoint.x - self.origin.x
//      let dy = inPoint.y - self.origin.y
//      if (dx == 0) && (dy == 0) {
//        return .left
//      }else{
//         let underAscendingDiagonal  = (self.size.width * dy) < (self.size.height * dx)
//         let descendingDiagonalX = self.size.width
//         let descendingDiagonalY = -self.size.height
//         let dxFromTopLeft = dx
//         let dyFromTopLeft = inPoint.y - self.origin.y - self.size.height
//         let underDescendingDiagonal = (descendingDiagonalX * dyFromTopLeft) < (descendingDiagonalY * dxFromTopLeft)
//         switch (underAscendingDiagonal, underDescendingDiagonal) {
//         case (false, false) :
//           return .above
//         case (false, true) :
//           return .left
//         case (true, false) :
//           return .right
//         case (true, true) :
//           return .below
//         }
//      }
//    }
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func subtracting (_ inRect : CanariRect) -> [CanariRect] {
    var result = [CanariRect] ()
  //--- Compute R1
    let r1 = CanariRect (
      left: self.origin.x,
      bottom: self.origin.y,
      width: min (self.size.width, inRect.origin.x - self.origin.x),
      height: min (self.size.height, inRect.origin.y + inRect.size.height - self.origin.y)
    )
    if !r1.isEmpty {
      result.append (r1)
    }
  //--- Compute R2
    let r2 = CanariRect (
      left: max (self.origin.x, inRect.origin.x),
      bottom: self.origin.y,
      width: self.origin.x + self.size.width - max (self.origin.x, inRect.origin.x),
      height: min (self.size.height, inRect.origin.y - self.origin.y)
    )
    if !r2.isEmpty {
      result.append (r2)
    }
  //--- Compute R3
    let r3 = CanariRect (
      left: max (self.origin.x, inRect.origin.x + inRect.size.width),
      bottom: max (inRect.origin.y, self.origin.y),
      width: self.origin.x + self.size.width - max (self.origin.x, inRect.origin.x + inRect.size.width),
      height: self.origin.y + self.size.height - max (inRect.origin.y, self.origin.y)
    )
    if !r3.isEmpty {
      result.append (r3)
    }
  //--- Compute R4
    let r4 = CanariRect (
      left: origin.x,
      bottom: max (self.origin.y, inRect.origin.y + inRect.size.height),
      width: min (self.origin.x + size.width, inRect.origin.x + inRect.size.width) - self.origin.x,
      height: self.origin.y + self.size.height - max (self.origin.y, inRect.origin.y + inRect.size.height)
    )
    if !r4.isEmpty {
      result.append (r4)
    }
  //---
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

extension NSRect {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Canari Rect
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var canariRect : CanariRect {
    return CanariRect (
      left: cocoaToCanariUnit (self.origin.x),
      bottom: cocoaToCanariUnit (self.origin.y),
      width: cocoaToCanariUnit (self.size.width),
      height: cocoaToCanariUnit (self.size.height)
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
