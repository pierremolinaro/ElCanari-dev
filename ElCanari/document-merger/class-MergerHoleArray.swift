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

  func shapeBezierPathes () -> BezierPathArray {
    var result = BezierPathArray ()
    for hole in self.holeArray {
      let x = canariUnitToCocoa (hole.x)
      let y = canariUnitToCocoa (hole.y)
      let diameter = canariUnitToCocoa (hole.holeDiameter)
      let r = CGRect (x: x - diameter / 2.0 , y: y - diameter / 2.0, width: diameter, height: diameter)
      let bp = NSBezierPath (ovalIn: r)
      result.append (bp)
    }
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

  func enterHolesIn (array ioHoleDiameterArray : inout [Int : [(Int, Int)]],
                     dx inDx : Int,
                     dy inDy: Int,
                     modelWidth inModelWidth : Int,
                     modelHeight inModelHeight : Int,
                     instanceRotation inInstanceRotation : QuadrantRotation) {
    for hole in self.holeArray {
      var x = inDx
      var y = inDy
      switch inInstanceRotation {
      case .rotation0 :
        x += hole.x
        y += hole.y
      case .rotation90 :
        x += inModelHeight - hole.y
        y += hole.x
      case .rotation180 :
        x += inModelWidth  - hole.x
        y += inModelHeight - hole.y
      case .rotation270 :
        x += hole.y
        y += inModelWidth - hole.x
      }
      if let array : [(Int, Int)] = ioHoleDiameterArray [hole.holeDiameter] {
        var a = array
        a.append ((x, y))
        ioHoleDiameterArray [hole.holeDiameter] = a
      }else{
        ioHoleDiameterArray [hole.holeDiameter] = [(x, y)]
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
