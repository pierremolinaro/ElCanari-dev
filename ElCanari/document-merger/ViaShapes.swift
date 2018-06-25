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

  let xArray : [Int]
  let yArray : [Int]
  let padDiameterArray : [Int]

  //····················································································································

  init (_ inXArray : [BoardModelViaEntity_x],
        _ inYArray : [BoardModelViaEntity_y],
        _ inPadDiameterArray : [BoardModelViaEntity_padDiameter]) {
    var array = [Int] ()
    for x in inXArray {
      array.append (x.x.propval)
    }
    xArray = array
    array = [Int] ()
    for y in inYArray {
      array.append (y.y.propval)
    }
    yArray = array
    array = [Int] ()
    for p in inPadDiameterArray {
      array.append (p.padDiameter.propval)
    }
    padDiameterArray = array
    super.init ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
