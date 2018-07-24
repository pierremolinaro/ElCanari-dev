//
//  CanariBoardRect.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 02/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Struct CanariBoardRect
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CanariBoardRect : Hashable, Equatable {

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

  var top    : Int { return self.bottom + self.height }
  var right  : Int { return self.left + self.width }

  //····················································································································
  //   Protocol Equatable
  //····················································································································

  public static func == (lhs: CanariBoardRect, rhs: CanariBoardRect) -> Bool {
    return (lhs.left == rhs.left) && (lhs.bottom == rhs.bottom) && (lhs.width == rhs.width) && (lhs.height == rhs.height)
  }

  //····················································································································
  //   Protocol Hashable: hashValue
  //····················································································································

  var hashValue : Int {
    return self.left ^ self.bottom ^ self.width ^ self.height
  }

  //····················································································································
  //   IsEmpty
  //····················································································································

  func isEmpty () -> Bool {
    return (width <= 0) || (height <= 0)
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

  func union (_ inOtherRect : CanariBoardRect) -> CanariBoardRect {
    let result : CanariBoardRect
    if self.isEmpty () {
      result = inOtherRect
    }else if inOtherRect.isEmpty () {
      result = self
    }else{
      let left = min (self.left, inOtherRect.left)
      let bottom = min (self.bottom, inOtherRect.bottom)
      let right = max (self.left + self.width, inOtherRect.left + inOtherRect.width)
      let top = max (self.bottom + self.height, inOtherRect.bottom + inOtherRect.height)
      result = CanariBoardRect (left:left, bottom:bottom, width:right - left, height:top - bottom)
    }
    return result
  }

  //····················································································································
  //   Intersection
  //····················································································································

  func intersection (_ inOtherRect : CanariBoardRect) -> CanariBoardRect {
    let result : CanariBoardRect
    if self.isEmpty () || inOtherRect.isEmpty () {
      result = CanariBoardRect () // Empty Rect
    }else{
      let left   = max (self.left, inOtherRect.left)
      let bottom = max (self.bottom, inOtherRect.bottom)
      let right  = min (self.left + self.width,  inOtherRect.left + inOtherRect.width)
      let top    = min (self.bottom + self.height, inOtherRect.bottom + inOtherRect.height)
      result = CanariBoardRect (left: left, bottom: bottom, width: right - left, height: top - bottom)
    }
    return result
  }

  //····················································································································
  //   Inset
  //····················································································································

  func inset (byX inDx : Int, byY inDy : Int) -> CanariBoardRect {
    let result : CanariBoardRect
    if self.isEmpty () {
      result = CanariBoardRect () // Empty Rect
    }else{
      let right = self.left + inDx
      let bottom = self.bottom + inDy
      let left = self.left + self.width - inDx
      let top = self.bottom + self.height - inDy
      result = CanariBoardRect (left:right, bottom:bottom, width:left - right, height:top - bottom)
    }
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
