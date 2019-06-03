//
//  CanariSegment.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 04/09/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariSegment
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CanariSegment {

  //····················································································································

  let x1 : Int
  let y1 : Int
  let x2 : Int
  let y2 : Int
  let width : Int

  //····················································································································

  func strictlyContains (point inPoint : CanariPoint) -> Bool {
    let x1 = Double (self.x1)
    let y1 = Double (self.y1)
    let x2 = Double (self.x2)
    let y2 = Double (self.y2)
    let x = Double (inPoint.x)
    let y = Double (inPoint.y)
    let hw = Double (self.width / 2)
    let within : Bool
    if self.x1 == self.x2 { // vertical segment
      within = (y > min (y1, y2)) && (y < max (y1, y2)) && (x >= (x1 - hw)) && (x <= (x1 + hw))
    }else if self.y1 == self.y2 { // horizontal segment
      within = (x > min (x1, x2)) && (x < max (x1, x2)) && (y >= (y1 - hw)) && (y <= (y1 + hw))
    }else if (x > min (x1, x2)) && (x < max (x1, x2)) && (y > min (y1, y2)) && (y < max (y1, y2)) { // Other segment
      let p2 = (x1 - x)  * (x1 - x)  + (y1 - y)  * (y1 - y)
      let q2 = (x2 - x)  * (x2 - x)  + (y2 - y)  * (y2 - y)
      let d2 = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)
      let s = 2.0 * p2 + 2.0 * q2 - d2 - (p2 - q2) * (p2 - q2) / d2
      within = s <= Double (self.width * self.width)
    }else{
      within = false
    }
    return within
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
