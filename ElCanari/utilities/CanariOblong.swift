//
//  CanariOblong.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 19/11/2016.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Struct CanariOblong
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CanariOblong {
  let p1 : CGPoint
  let p2 : CGPoint
  let height : CGFloat

  //····················································································································
  //   init
  //····················································································································

  init (from p1 : CGPoint, to p2 : CGPoint, height : CGFloat) {
    self.p1 = p1
    self.p2 = p2
    self.height = height
  }

  //····················································································································
  //   Contains point
  //····················································································································

  func contains (point p : CGPoint) -> Bool {
  //--- p inside P1 circle
    var inside = CGPoint.distance (self.p1, p) <= (height / 2.0)
  //--- p inside P2 circle
    if !inside {
      inside = CGPoint.distance (self.p2, p) <= (height / 2.0)
    }
  //--- p inside rectangle
    if !inside {
      let r = CanariRect (from: self.p1, to: self.p2, height: self.height)
      inside = r.contains (point: p)
    }
    return inside
  }

  //····················································································································

  func intersects (rect : CanariRect) -> Bool {
  //--- rect intersects P1 circle
    let c1 = CanariCircle (center: self.p1, radius: self.height / 2.0)
    var intersects = rect.intersects (circle: c1)
  //--- rect intersects P2 circle
    if !intersects {
      let c2 = CanariCircle (center: self.p2, radius: self.height / 2.0)
      intersects = rect.intersects (circle: c2)
    }
  //--- rect intersects rectangle
    if !intersects {
      let r = CanariRect (from: self.p1, to: self.p2, height: self.height)
      intersects = rect.intersects (rect: r)
    }
    return intersects
  }
  
  //····················································································································

  func shape () -> CAShapeLayer {
    let mutablePath = CGMutablePath ()
    mutablePath.move (to: self.p1)
    mutablePath.addLine (to: self.p2)
    let newLayer = CAShapeLayer ()
    newLayer.path = mutablePath
    newLayer.lineWidth = self.height
    newLayer.lineCap = kCALineCapRound
    return newLayer
  }

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
