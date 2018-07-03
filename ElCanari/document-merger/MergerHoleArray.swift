//
//  MergerHoleArray.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   MergerHoleArray
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class MergerHoleArray : EBSimpleClass {

  //····················································································································

  let holeArray : [MergerHole]

  //····················································································································

  init (_ inArray : [MergerHole]) {
    holeArray = inArray
    super.init ()
  }

  //····················································································································

  override var description : String {
    get {
      return "MergerHoleArray " + String (holeArray.count)
    }
  }

  //····················································································································

  func buildShape (dx inDx : Int, dy inDy : Int, color inColor : NSColor, display inDisplay : Bool) -> CALayer {
    var components = [CAShapeLayer] ()
    if inDisplay {
      for hole in self.holeArray {
        let x = canariUnitToCocoa (hole.x)
        let y = canariUnitToCocoa (hole.y)
        let diameter = canariUnitToCocoa (hole.holeDiameter)
        let r = CGRect (x: x - diameter / 2.0 , y: y - diameter / 2.0, width: diameter, height: diameter)
        let shape = CAShapeLayer ()
        shape.path = CGPath (ellipseIn: r, transform: nil)
        shape.fillColor = inColor.cgColor
    //    shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
        shape.isOpaque = true
        components.append (shape)
      }
    }
    let result = CALayer ()
    result.position = CGPoint (x:canariUnitToCocoa (inDx), y:canariUnitToCocoa (inDy))
    result.sublayers = components
    return result
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
