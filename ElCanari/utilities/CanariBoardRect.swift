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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
