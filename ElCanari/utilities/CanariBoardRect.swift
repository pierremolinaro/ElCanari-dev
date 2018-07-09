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

struct CanariBoardRect {
  let x : Int
  let y : Int
  let width : Int
  let height : Int

  //····················································································································
  //   init
  //····················································································································

  init (x inX : Int, y inY : Int, width inWidth : Int, height inHeight : Int) {
    x = inX
    y = inY
    width = inWidth
    height = inHeight
  }

  //····················································································································

  init () {
    x = 0
    y = 0
    width = 0 // Empty rect
    height = 0
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
      x:canariUnitToCocoa (self.x),
      y:canariUnitToCocoa (self.y),
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
      let right = min (self.x, inOtherRect.x)
      let bottom = min (self.y, inOtherRect.y)
      let left = max (self.x + self.width, inOtherRect.x + inOtherRect.width)
      let top = max (self.y + self.height, inOtherRect.y + inOtherRect.height)
      result = CanariBoardRect (x:right, y:bottom, width:left - right, height:top - bottom)
    }
    return result
  }

  //····················································································································
  //   Intersection
  //····················································································································

  func intersection (_ inOtherRect : CanariBoardRect) -> CanariBoardRect {
    let result : CanariBoardRect
    if self.isEmpty () ||  inOtherRect.isEmpty () {
      result = CanariBoardRect () // Empty Rect
    }else{
      let right = max (self.x, inOtherRect.x)
      let bottom = max (self.y, inOtherRect.y)
      let left = min (self.x + self.width, inOtherRect.x + inOtherRect.width)
      let top = min (self.y + self.height, inOtherRect.y + inOtherRect.height)
      result = CanariBoardRect (x:right, y:bottom, width:left - right, height:top - bottom)
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
      let right = self.x + inDx
      let bottom = self.y + inDy
      let left = self.x + self.width - inDx
      let top = self.y + self.height - inDy
      result = CanariBoardRect (x:right, y:bottom, width:left - right, height:top - bottom)
    }
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
