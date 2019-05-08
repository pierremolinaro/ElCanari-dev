//
//  ProjectDocument-customized-schematics-points.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  internal func pointsInSchematics (at inLocation : CanariPoint) -> [PointInSchematics] {
     var result = [PointInSchematics] ()
     for point in self.rootObject.mSelectedSheet?.mPoints ?? [] {
       if let location = point.location, inLocation == location {
         result.append (point)
       }
     }
     return result
  }

  //····················································································································

  internal func removeUnusedSchematicsPoints () {
    if let selectedSheet = self.rootObject.mSelectedSheet {
      var idx = 0
      while idx < selectedSheet.mPoints.count {
        let point = selectedSheet.mPoints [idx]
        let unused = (point.mLabels.count == 0) && (point.mNC == nil) && (point.mWiresP1s.count == 0) && (point.mWiresP2s.count == 0)
        if unused {
          point.mNet = nil
          selectedSheet.mPoints.remove (at: idx)
        }else{
          idx += 1
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
