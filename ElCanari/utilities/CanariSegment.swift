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
    let hw = self.width / 2
    let within : Bool
    if p1x == p2x { // vertical segment
      within = (py > min (p1y, p2y)) && (py < max (p1y, p2y)) && (px >= (p1x - hw)) && (px <= (p1x + hw))
    }else if p1y == p2y { // horizontal segment
      within = (px > min (p1x, p2x)) && (px < max (p1x, p2x)) && (py >= (p1y - hw)) && (py <= (p1y + hw))
    }else if (px > min (p1x, p2x)) && (px < max (p1x, p2x)) && (py > min (p1y, p2y)) && (py < max (p1y, p2y)) { // Other segment
      let squareDistance_P1_P = CGFloat ((p1x - px) * (p1x - px) + (p1y - py) * (p1y - py))
      let squareDistance_P2_P = CGFloat ((p2x - px) * (p2x - px) + (p2y - py) * (p2y - py))
      let squareDistance_P1_P2 = CGFloat ((p2x - p1x) * (p2x - p1x) + (p2y - p1y) * (p2y - p1y))
      let s =
          2.0 * squareDistance_P1_P
        + 2.0 * squareDistance_P2_P
        - squareDistance_P1_P2
        - (squareDistance_P1_P - squareDistance_P2_P) * (squareDistance_P1_P - squareDistance_P2_P) / squareDistance_P1_P2
      within = s <= (CGFloat (self.width) * CGFloat (self.width))
    }else{
      within = false
    }
    return within
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
