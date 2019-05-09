//
//  extension-SheetInProject-points-at-location.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SheetInProject {

  //····················································································································

  internal func pointsInSchematics (at inLocation : CanariPoint) -> [PointInSchematics] {
    var result = [PointInSchematics] ()
    for point in self.mPoints {
      if let location = point.location, inLocation == location {
        result.append (point)
      }
    }
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

