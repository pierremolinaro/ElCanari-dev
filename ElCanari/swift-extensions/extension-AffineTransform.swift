//
//  extension-AffineTransform.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

extension AffineTransform {

  var angleInDegrees : Double {
    let p1 = self.transform (NSPoint ())
    let p2 = self.transform (NSPoint (x: 1, y: 0))
    return NSPoint.angleInDegrees (p1, p2)
  }

}

//--------------------------------------------------------------------------------------------------
