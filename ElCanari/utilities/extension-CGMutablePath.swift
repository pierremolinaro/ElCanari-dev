//
//  extension-CGMutablePath.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 13/11/2016.
//
//

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Extension CGMutablePath
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CGMutablePath {

  //····················································································································

  func addArrow (fillPath : CGMutablePath, to endPoint : CGPoint, arrowSize : CGFloat) {
    if endPoint != currentPoint {
   //--- Compute angle
      let angle = CGPoint.angleInRadian (currentPoint, endPoint)
    //--- Affine transform
      let tr = CGAffineTransform (translationX:endPoint.x, y:endPoint.y).rotated (by:angle)
    //--- Draw path
      let path = CGMutablePath ()
      path.move (to: CGPoint (x: 0.0, y: 0.0))
      path.addLine (to:CGPoint (x: -2.0 * arrowSize, y:  arrowSize))
      path.addCurve (to:CGPoint (x: -2.0 * arrowSize, y: -arrowSize),
                     control1: CGPoint (x: -arrowSize, y: -arrowSize),
                     control2: CGPoint (x: -arrowSize, y:  arrowSize),
                     transform: .identity)
      path.closeSubpath ()
    //--- Add path
      fillPath.addPath (path, transform:tr)
    //--- Draw line
      self.addLine (to:endPoint)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
