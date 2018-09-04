//
//  CanariHorizontalRect.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 02/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Struct CanariHorizontalRect
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CanariHorizontalRect : Hashable, Equatable {

  let left : Int
  let bottom : Int
  let width : Int
  let height : Int

  //····················································································································
  //   init
  //····················································································································

  init (left inLeft : Int, bottom inBottom: Int, width inWidth : Int, height inHeight : Int) {
    if (inWidth > 0) && (inHeight > 0) {
      left = inLeft
      bottom = inBottom
      width = inWidth
      height = inHeight
    }else{
      left = 0
      bottom = 0
      width = 0
      height = 0
    }
  }

  //····················································································································

  init () {
    left = 0
    bottom = 0
    width = 0 // Empty rect
    height = 0
  }

  //····················································································································
  //   Accessors
  //····················································································································

  var top     : Int { return self.bottom + self.height }
  var right   : Int { return self.left + self.width }
  var isEmpty : Bool { return (width <= 0) || (height <= 0) }

  //····················································································································
  //   Protocol Equatable
  //····················································································································

  public static func == (lhs: CanariHorizontalRect, rhs: CanariHorizontalRect) -> Bool {
    return (lhs.left == rhs.left) && (lhs.bottom == rhs.bottom) && (lhs.width == rhs.width) && (lhs.height == rhs.height)
  }

  //····················································································································
  //   Protocol Hashable: hashValue
  //····················································································································

  var hashValue : Int {
    return self.left ^ self.bottom ^ self.width ^ self.height
  }

  //····················································································································
  //   cocoaRect
  //····················································································································

  func cocoaRect () -> NSRect {
    return NSRect (
      x:canariUnitToCocoa (self.left),
      y:canariUnitToCocoa (self.bottom),
      width:canariUnitToCocoa (self.width),
      height:canariUnitToCocoa (self.height)
    )
  }

  //····················································································································
  //   Union
  //····················································································································

  func union (_ inOtherRect : CanariHorizontalRect) -> CanariHorizontalRect {
    let result : CanariHorizontalRect
    if self.isEmpty {
      result = inOtherRect
    }else if inOtherRect.isEmpty {
      result = self
    }else{
      let left = min (self.left, inOtherRect.left)
      let bottom = min (self.bottom, inOtherRect.bottom)
      let right = max (self.right, inOtherRect.right)
      let top = max (self.top, inOtherRect.top)
      result = CanariHorizontalRect (left:left, bottom:bottom, width:right - left, height:top - bottom)
    }
    return result
  }

  //····················································································································
  //   Intersection
  //····················································································································

  func intersection (_ inOtherRect : CanariHorizontalRect) -> CanariHorizontalRect {
    let result : CanariHorizontalRect
    if self.isEmpty || inOtherRect.isEmpty {
      result = CanariHorizontalRect () // Empty Rect
    }else{
      let left   = max (self.left, inOtherRect.left)
      let bottom = max (self.bottom, inOtherRect.bottom)
      let right  = min (self.left + self.width,  inOtherRect.left + inOtherRect.width)
      let top    = min (self.bottom + self.height, inOtherRect.bottom + inOtherRect.height)
      result = CanariHorizontalRect (left: left, bottom: bottom, width: right - left, height: top - bottom)
    }
    return result
  }

  //····················································································································
  //   Inset
  //····················································································································

  func insetBy (dx inDx : Int, dy inDy : Int) -> CanariHorizontalRect {
    let result : CanariHorizontalRect
    if self.isEmpty {
      result = CanariHorizontalRect () // Empty Rect
    }else{
      let right = self.left + inDx
      let bottom = self.bottom + inDy
      let left = self.left + self.width - inDx
      let top = self.bottom + self.height - inDy
      result = CanariHorizontalRect (left:right, bottom:bottom, width:left - right, height:top - bottom)
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
  //   Inset
  //····················································································································

  func clipping (segment inSegment : CanariSegment) -> CanariSegment? {
    let r = self.insetBy (dx: inSegment.width / 2, dy: inSegment.width / 2)
    if r.contains (x: inSegment.x1, y: inSegment.y2) && r.contains (x: inSegment.x2, y: inSegment.y2) {
      return inSegment
    }else{
      return nil
    }
  }


  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
