//
//  extension-PointlInSchematic.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION PointInSchematic
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PointInSchematic {

  //····················································································································

  func propagateNetToAccessiblePointsThroughtWires () {
    var reachedPointSet = Set <PointInSchematic> ([self])
    var exploreArray = [self]
    while let point = exploreArray.last {
      exploreArray.removeLast ()
      for wire in point.mWiresP1s.values + point.mWiresP2s.values {
        let p1 = wire.mP1!
        if !reachedPointSet.contains (p1) {
          reachedPointSet.insert (p1)
          exploreArray.append (p1)
          p1.mNet = self.mNet
        }
        let p2 = wire.mP2!
        if !reachedPointSet.contains (p2) {
          reachedPointSet.insert (p2)
          exploreArray.append (p2)
          p2.mNet = self.mNet
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
