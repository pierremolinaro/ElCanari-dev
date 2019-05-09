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
    let p1x = self.x1
    let p1y = self.y1
    let p2x = self.x2
    let p2y = self.y2
    let px  = inPoint.x
    let py  = inPoint.y
    var within = ((p1x - px) * (p1y - p2y)) == ((p1y - py) * (p1x - p2x))
    if within {
      if p1x == p2x { // vertical segment
        within = (py > min (p1y, p2y)) && (py < max (p1y, p2y))
      }else if p1y == p2y { // vertical segment
        within = (px > min (p1x, p2x)) && (px < max (p1x, p2x))
      }else{ // Other segment
        within = (px > min (p1x, p2x)) && (px < max (p1x, p2x)) && (py > min (p1y, p2y)) && (py < max (p1y, p2y))
      }
    }
    return within
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
