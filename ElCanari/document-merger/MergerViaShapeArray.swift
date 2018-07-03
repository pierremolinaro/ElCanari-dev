//
//  ViaShapeArray.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   MergerViaShapeArray
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class MergerViaShapeArray : EBSimpleClass {

  //····················································································································

  let viaArray : [MergerViaShape]

  //····················································································································

  init (_ inArray : [MergerViaShape]) {
    viaArray = inArray
    super.init ()
  }

  //····················································································································

  override var description : String {
    get {
      return "MergerViaShapeArray " + String (viaArray.count)
    }
  }

  //····················································································································

  func buildPadShape (dx inDx : Int, dy inDy : Int, color inColor : NSColor, display inDisplay : Bool) -> CALayer {
    var components = [CAShapeLayer] ()
    if inDisplay {
      for via in self.viaArray {
        let x = canariUnitToCocoa (via.x)
        let y = canariUnitToCocoa (via.y)
        let diameter = canariUnitToCocoa (via.padDiameter)
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
