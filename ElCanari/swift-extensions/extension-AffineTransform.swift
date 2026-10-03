//
//  extension-AffineTransform.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation
import CanariGeometry

//--------------------------------------------------------------------------------------------------

extension AffineTransform {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ t : CGAffineTransform) {
    self.init (
      m11: t.a,  m12: t.b,
      m21: t.c,  m22: t.d,
      tX: t.tx,  tY: t.ty
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var angle : CanariAngle {
    let p1 = self.transform (NSPoint ())
    let p2 = self.transform (NSPoint (x: 1, y: 0))
    return p1.angle (to: p2)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func rotate (by inAngle : CanariAngle) {
    self.rotate (byDegrees: inAngle.unsignedDegreeValue)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func transforming (_ inPoint : CanariPoint) -> CanariPoint {
    self.transform (inPoint.ptValue).canariPoint
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
