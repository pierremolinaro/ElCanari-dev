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
//   MergerHole
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class MergerHole : EBSimpleClass {

  //····················································································································

  let x : Int
  let y : Int
  let holeDiameter : Int

  //····················································································································

  init (x inX : Int,
        y inY : Int,
        holeDiameter inHoleDiameter : Int) {
    x = inX
    y = inY
    holeDiameter = inHoleDiameter
    super.init ()
  }

  //····················································································································

}

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

  func add (toArchiveArray : inout [String], dx inDx : Int, dy inDy: Int) {
    for hole in self.holeArray {
      let s = "\(hole.x + inDx) \(hole.y + inDy) \(hole.holeDiameter)"
      toArchiveArray.append (s)
    }
  }

  //····················································································································

  func enterHolesIn (array ioHoleDiameterArray : inout [Int : [(Int, Int)]]) {
    for hole in self.holeArray {
      if let array : [(Int, Int)] = ioHoleDiameterArray [hole.holeDiameter] {
        var a = array
        a.append ((hole.x, hole.y))
        ioHoleDiameterArray [hole.holeDiameter] = a
      }else{
        ioHoleDiameterArray [hole.holeDiameter] = [(hole.x, hole.y)]
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
