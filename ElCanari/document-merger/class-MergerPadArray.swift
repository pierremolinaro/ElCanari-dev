//
//  MergerPadArray.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   MergerPad
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class MergerPad : EBSimpleClass {

  //····················································································································

  let x : Int
  let y : Int
  let width : Int
  let height : Int
  let holeDiameter : Int
  let shape : PadShape
  let rotation : Int

  //····················································································································

  init (x inX : Int,
        y inY : Int,
        width inWidth : Int,
        height inHeight : Int,
        holeDiameter inHoleDiameter : Int,
        shape inShape : PadShape,
        rotation inRotation : Int) {
    x = inX
    y = inY
    width = inWidth
    height = inHeight
    holeDiameter = inHoleDiameter
    shape = inShape
    rotation = inRotation
    super.init ()
  }

  //····················································································································

  func translatedBy (x inX : Int, y inY : Int) -> MergerPad {
    return MergerPad (x: self.x + inX,
                      y: self.y + inY,
                      width: self.width,
                      height: self.height,
                      holeDiameter: self.holeDiameter,
                      shape: self.shape,
                      rotation: self.rotation)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   MergerPadArray
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class MergerPadArray : EBSimpleClass {

  //····················································································································

  let padArray : [MergerPad]

  //····················································································································

  init (_ inArray : [MergerPad]) {
    padArray = inArray
    super.init ()
  }

  //····················································································································

  override var description : String {
    get {
      return "MergerPadArray " + String (padArray.count)
    }
  }

  //····················································································································

  func buildShape (dx inDx : Int, dy inDy : Int, color inColor : NSColor, display inDisplay : Bool) -> CALayer {
    var components = [CAShapeLayer] ()
    if inDisplay {
      for pad in self.padArray {
        let x = canariUnitToCocoa (pad.x)
        let y = canariUnitToCocoa (pad.y)
        let width = canariUnitToCocoa (pad.width)
        let height = canariUnitToCocoa (pad.height)
        let r = CGRect (x: -width / 2.0, y: -height / 2.0, width:width, height:height)
        var transform = CGAffineTransform (translationX:x, y:y).rotated (by:canariRotationToRadians (pad.rotation))
        let path : CGPath
        switch pad.shape {
        case .rectangular :
          path = CGPath (rect:r, transform:&transform)
        case .round :
          if pad.width < pad.height {
            path = CGPath (roundedRect:r, cornerWidth:width / 2.0, cornerHeight:width / 2.0, transform:&transform)
          }else if pad.width > pad.height {
            path = CGPath (roundedRect:r, cornerWidth:height / 2.0, cornerHeight:height / 2.0, transform:&transform)
          }else{
            path = CGPath (ellipseIn:r, transform:&transform)
          }
        }
        let shape = CAShapeLayer ()
        shape.path = path
        shape.position = CGPoint (x:0.0, y:0.0)
        shape.strokeColor = nil
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
