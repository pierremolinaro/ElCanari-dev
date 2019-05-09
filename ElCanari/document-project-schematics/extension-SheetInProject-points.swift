//
//  extension-SheetInProject-points.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SheetInProject {

  //····················································································································

  internal func removeUnusedSchematicsPoints () {
  //--- Remove unused points
    var idx = 0
    while idx < self.mPoints.count {
      let point = self.mPoints [idx]
      let unused = (point.mLabels.count == 0)
        && (point.mNC == nil)
        && (point.mWiresP1s.count == 0)
        && (point.mWiresP2s.count == 0)
        && (point.mSymbol == nil)
      if unused {
        point.mNet = nil
        self.mPoints.remove (at: idx)
      }else{
        idx += 1
      }
    }
  //--- Check points
    var exploreSet = Set <PointInSchematics> ()
    for point in self.mPoints {
      if point.mNC != nil {
        var errorFlags : UInt32 = 0
        if point.mSymbol == nil { errorFlags |= 1 }
        if point.mSymbolPinName == "" { errorFlags |= 2 }
        if point.mWiresP1s.count > 0 { errorFlags |= 4 }
        if point.mWiresP2s.count > 0 { errorFlags |= 8 }
        if point.mLabels.count > 0 { errorFlags |= 16 }
        if point.mNet != nil { errorFlags |= 32 }
        if errorFlags != 0 {
          NSLog ("Schematics NC Point Error \(errorFlags)")
        }
      }else{
        var errorFlags : UInt32 = 0
        if (point.mSymbol == nil) != (point.mSymbolPinName == "") { errorFlags |= 1 }
        var connectionCount = point.mWiresP1s.count + point.mWiresP2s.count + point.mLabels.count
        if point.mSymbol != nil { connectionCount += 1 }
        if connectionCount == 0 { errorFlags |= 2 }
        if errorFlags != 0 {
          NSLog ("Schematics Point Error \(errorFlags)")
        }
        exploreSet.insert (point)
      }
    //--- Explore subnet for checking that net setting is consistent
      while exploreSet.count > 0 {
        let point = exploreSet.removeFirst ()
        let net = point.mNet
        var wiresToExplore = Set (point.mWiresP1s + point.mWiresP2s)
        var exploredWires = Set <WireInSchematics> ()
        while wiresToExplore.count > 0 {
          let wire = wiresToExplore.removeFirst ()
          exploredWires.insert (wire)
          let p2 = wire.mP2!
          if exploreSet.contains (p2) {
            exploreSet.remove (p2)
            if p2.mNet != net {
              NSLog ("NET ERROR at p2")
            }
            for reachableWire in p2.mWiresP1s + p2.mWiresP2s {
              if !exploredWires.contains (reachableWire) {
                exploredWires.insert (reachableWire)
                wiresToExplore.insert (reachableWire)
              }
            }
          }
          let p1 = wire.mP1!
          if exploreSet.contains (p1) {
            exploreSet.remove (p1)
            if p1.mNet != net {
              NSLog ("NET ERROR at p1")
            }
            for reachableWire in p1.mWiresP1s + p1.mWiresP2s {
              if !exploredWires.contains (reachableWire) {
                exploredWires.insert (reachableWire)
                wiresToExplore.insert (reachableWire)
              }
            }
          }
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
