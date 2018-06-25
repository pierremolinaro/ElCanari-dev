//
//  ViaShapes.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   ViaShapes
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class ViaShapes : EBSimpleClass {

  //····················································································································

  let shapeArray : [CAShapeLayer]

  //····················································································································

  init (_ inXArray : [BoardModelViaEntity_x],
        _ inYArray : [BoardModelViaEntity_y],
        _ inPadDiameterArray : [BoardModelViaEntity_padDiameter]) {
    var array = [CAShapeLayer] ()
    var idx = 0
    while idx < inXArray.count {
      let x : CGFloat = canariUnitToCocoa (inXArray [idx].x.propval)
      let y : CGFloat = canariUnitToCocoa (inYArray [idx].y.propval)
      let padDiameter : CGFloat = canariUnitToCocoa (inPadDiameterArray [idx].padDiameter.propval)
      let shape = CAShapeLayer ()
      let r = NSRect (x : x - padDiameter / 2.0, y: y - padDiameter / 2.0, width:padDiameter, height:padDiameter)
      shape.path = CGPath (ellipseIn: r, transform: nil)
      shape.position = CGPoint (x:0.0, y:0.0)
      shape.fillColor = NSColor.black.cgColor
      array.append (shape)
      idx += 1
    }
    shapeArray = array
    super.init ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
