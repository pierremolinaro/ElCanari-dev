//
//  MergerSegment.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   MergerSegment
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class MergerSegment : EBSimpleClass {

  //····················································································································

  let x1 : Int
  let y1 : Int
  let x2 : Int
  let y2 : Int
  let width : Int

  //····················································································································

  init (x1 inX1 : Int, y1 inY1 : Int, x2 inX2 : Int, y2 inY2 : Int, width inWidth : Int) {
    x1 = inX1
    y1 = inY1
    x2 = inX2
    y2 = inY2
    width = inWidth
    super.init ()
  }

  //····················································································································

  func segmentShape (color : CGColor) -> CAShapeLayer {
    let x1f : CGFloat = canariUnitToCocoa (self.x1)
    let y1f : CGFloat = canariUnitToCocoa (self.y1)
    let x2f : CGFloat = canariUnitToCocoa (self.x2)
    let y2f : CGFloat = canariUnitToCocoa (self.y2)
    let widthf : CGFloat = canariUnitToCocoa (self.width)
    let path = CGMutablePath ()
    // NSLog ("x1f \(x1f), y1f \(y1f), x2f \(x2f), y2f \(y2f), widthf \(widthf)")
    path.move (to:CGPoint (x:x1f, y:y1f))
    path.addLine (to:CGPoint (x:x2f, y:y2f))
    let shape = CAShapeLayer ()
    shape.path = path
    shape.position = CGPoint (x:0.0, y:0.0)
    shape.strokeColor = color
    shape.lineWidth = widthf
    shape.lineCap = kCALineCapRound
    return shape
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
