//
//  CanariRect.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/11/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Struct CanariRect
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CanariRect : Equatable, Hashable {
  var origin : CanariPoint
  var size : CanariSize

  //····················································································································
  //   init
  //····················································································································

  init () {
    origin = CanariPoint ()
    size = CanariSize ()
  }

  //····················································································································

  init (origin inOrigin : CanariPoint, size inSize : CanariSize) {
    origin = inOrigin
    size = inSize
  }

  //····················································································································

  init (p1 inP1 : CanariPoint, p2 inP2 : CanariPoint) {
    let minX = min (inP1.x, inP2.x)
    let maxX = max (inP1.x, inP2.x)
    let minY = min (inP1.y, inP2.y)
    let maxY = max (inP1.y, inP2.y)
    origin = CanariPoint (x: minX, y: minY)
    size = CanariSize (width: maxX - minX, height: maxY - minY)
  }

  //····················································································································

  init (p1 inP1 : CanariPoint, p2 inP2 : CanariPoint, p3 inP3 : CanariPoint, p4 inP4 : CanariPoint) {
    let minX = min (inP1.x, inP2.x, inP3.x, inP4.x)
    let maxX = max (inP1.x, inP2.x, inP3.x, inP4.x)
    let minY = min (inP1.y, inP2.y, inP3.y, inP4.y)
    let maxY = max (inP1.y, inP2.y, inP3.y, inP4.y)
    origin = CanariPoint (x: minX, y: minY)
    size = CanariSize (width: maxX - minX, height: maxY - minY)
  }

  //····················································································································

  init (points inPoints : [CanariPoint]) {
    if inPoints.count == 0 {
      origin = CanariPoint ()
      size = CanariSize ()
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
      origin = CanariPoint (x: xMin, y: yMin)
      size = CanariSize (width: xMax - xMin, height: yMax - yMin)
    }
  }

  //····················································································································

  init (left inLeft : Int, bottom inBottom: Int, width inWidth : Int, height inHeight : Int) {
    if (inWidth > 0) && (inHeight > 0) {
      self.origin = CanariPoint (x: inLeft, y: inBottom)
      self.size = CanariSize (width: inWidth, height: inHeight)
    }else{
      self.origin = CanariPoint ()
      self.size = CanariSize ()
    }
  }

  //····················································································································
  //   Accessors
  //····················································································································

  var left    : Int { return self.origin.x }
  var right   : Int { return self.origin.x + self.size.width }

  var bottom  : Int { return self.origin.y }
  var top     : Int { return self.origin.y + self.size.height }

  var height  : Int { return self.size.height }
  var width   : Int { return self.size.width }

  var isEmpty : Bool { return (self.size.width <= 0) || (self.size.height <= 0) }

  //····················································································································
  //   Rotation around rectangle center
  //····················································································································

  func rotated90Clockwise (_ inP : CanariPoint) -> CanariPoint {
    let x = self.origin.x + self.origin.y + self.size.height - inP.y
    let y = self.origin.x + self.origin.y + self.size.width  - inP.x
    return CanariPoint (x: x, y: y)
  }

  //····················································································································

  func rotated90CounterClockwise (_ inP : CanariPoint) -> CanariPoint {
    let x = self.origin.x + inP.y - self.origin.y
    let y = self.origin.x + self.origin.y + self.size.width - inP.x
    return CanariPoint (x: x, y: y)
  }

  //····················································································································
  //   cocoaRect
  //····················································································································

  func cocoaRect () -> NSRect {
    return NSRect (
      x: canariUnitToCocoa (self.origin.x),
      y: canariUnitToCocoa (self.origin.y),
      width: canariUnitToCocoa (self.size.width),
      height: canariUnitToCocoa (self.size.height)
    )
  }

  //····················································································································
  //   Union
  //····················································································································

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

  //····················································································································
  //   Intersection
  //····················································································································

  func intersection (_ inOtherRect : CanariRect) -> CanariRect {
    let result : CanariRect
    if self.isEmpty || inOtherRect.isEmpty {
      result = CanariRect () // Empty Rect
    }else{
      let left   = max (self.left, inOtherRect.left)
      let bottom = max (self.bottom, inOtherRect.bottom)
      let right  = min (self.left + self.width,  inOtherRect.left + inOtherRect.width)
      let top    = min (self.bottom + self.height, inOtherRect.bottom + inOtherRect.height)
      result = CanariRect (left: left, bottom: bottom, width: right - left, height: top - bottom)
    }
    return result
  }

  //····················································································································
  //   Inset
  //····················································································································

  func insetBy (dx inDx : Int, dy inDy : Int) -> CanariRect {
    let result : CanariRect
    if self.isEmpty {
      result = CanariRect () // Empty Rect
    }else{
      let right = self.left + inDx
      let bottom = self.bottom + inDy
      let left = self.left + self.width - inDx
      let top = self.bottom + self.height - inDy
      result = CanariRect (left: right, bottom: bottom, width: left - right, height: top - bottom)
    }
    return result
  }

  //····················································································································
  //   Contains point
  //····················································································································

  func contains (x inX : Int, y inY : Int) -> Bool {
    return (inX >= self.left) && (inX <= self.right) && (inY >= self.bottom) && (inY <= self.top)
  }

  //····················································································································
  //   CohenSutherlandOutcode
  //····················································································································

  func CohenSutherlandOutcode (x inX : Int, y inY : Int) -> UInt8 {
    var result : UInt8 = 0
    if inX < self.left {
      result |= CohenSutherlandOutcodeLEFT
    }else if inX > self.right {
      result |= CohenSutherlandOutcodeRIGHT
    }
    if inY < self.bottom {
      result |= CohenSutherlandOutcodeBOTTOM
    }else if inY > self.top {
      result |= CohenSutherlandOutcodeTOP
    }
    return result
  }

  //····················································································································
  // Relative location of a point from rectangle center
  //
  //    *———————————————*
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
  //    *———————————————*
  //
  //····················································································································

  enum RelativeLocation { case right ; case above ; case left ; case below}

  //····················································································································

  func relativeLocation (of inPoint : CanariPoint) -> RelativeLocation {
    if self.isEmpty {
      return .left
    }else{
      let dx = inPoint.x - self.origin.x
      let dy = inPoint.y - self.origin.y
      if (dx == 0) && (dy == 0) {
        return .left
      }else{
         let underAscendingDiagonal  = (self.size.width * dy) < (self.size.height * dx)
         let descendingDiagonalX = self.size.width
         let descendingDiagonalY = -self.size.height
         let dxFromTopLeft = dx
         let dyFromTopLeft = inPoint.y - self.origin.y - self.size.height
         let underDescendingDiagonal = (descendingDiagonalX * dyFromTopLeft) < (descendingDiagonalY * dxFromTopLeft)
         switch (underAscendingDiagonal, underDescendingDiagonal) {
         case (false, false) :
           return .above
         case (false, true) :
           return .left
         case (true, false) :
           return .right
         case (true, true) :
           return .below
         }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
