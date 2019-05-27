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

  internal func netSetFor (points : [PointInSchematic]) -> Set <NetInProject> {
    var netSet = Set <NetInProject> ()
    for p in points {
      if let net = p.mNet {
        netSet.insert (net)
      }
    }
    return netSet
  }

  //····················································································································

  internal func removeUnusedSchematicsPoints (_ ioErrorList : inout [String]) {
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
    var exploreSet = Set <PointInSchematic> ()
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
          ioErrorList.append ("Error \(errorFlags) for NC point \(string (point))")
        }
      }else{
        var errorFlags : UInt32 = 0
        if (point.mSymbol == nil) != (point.mSymbolPinName == "") { errorFlags |= 1 }
        var connectionCount = point.mWiresP1s.count + point.mWiresP2s.count + point.mLabels.count
        if point.mSymbol != nil { connectionCount += 1 }
        if connectionCount == 0 { errorFlags |= 2 }
        if errorFlags != 0 {
          ioErrorList.append ("Error \(errorFlags) for point \(string (point))")
        }
        exploreSet.insert (point)
      }
    //--- Explore subnet for checking that net setting is consistent
      while exploreSet.count > 0 {
        let point = exploreSet.removeFirst ()
        let net = point.mNet
        var wiresToExplore = Set (point.mWiresP1s + point.mWiresP2s)
        var exploredWires = Set <WireInSchematic> ()
        while wiresToExplore.count > 0 {
          let wire = wiresToExplore.removeFirst ()
          exploredWires.insert (wire)
          let p2 = wire.mP2!
          if exploreSet.contains (p2) {
            exploreSet.remove (p2)
            if p2.mNet != net {
              ioErrorList.append ("Error p2.mNet != net for net \(string (net))")
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
              ioErrorList.append ("Error p1.mNet != net for net \(string (net))")
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

  internal func buildSubnet (from inPoint : PointInSchematic) -> Set <PointInSchematic> {
    var exploreSet = Set ([inPoint])
    var result = Set <PointInSchematic> ()
    while let point = exploreSet.first {
      _ = exploreSet.removeFirst ()
      result.insert (point)
      for wire in point.mWiresP1s {
        if let p2 = wire.mP2, !result.contains (p2) {
          exploreSet.insert (p2)
        }
      }
      for wire in point.mWiresP2s {
        if let p1 = wire.mP1, !result.contains (p1) {
          exploreSet.insert (p1)
        }
      }
    }
    return result
  }

  //····················································································································

  internal func buildSubnetsFrom (_ inPointSet : Set <PointInSchematic>) -> [Set <PointInSchematic>] {
    var result = [Set <PointInSchematic>] ()
    var currentPointSet = inPointSet
    while let point = currentPointSet.first {
      let subnet = self.buildSubnet (from: point)
      currentPointSet.subtract (subnet)
      result.append (subnet)
    }
    return result
  }

  //····················································································································

  internal func buildLabelArrayFromSubnet (_ inSubnet : Set <PointInSchematic>) -> [LabelInSchematic] {
    var result = [LabelInSchematic] ()
    for point in inSubnet {
      for label in point.mLabels {
        result.append (label)
      }
    }
    return result
  }

  //····················································································································

  internal func buildSymbolArrayFromSubnet (_ inSubnet : Set <PointInSchematic>) -> [ComponentSymbolInProject] {
    var result = [ComponentSymbolInProject] ()
    for point in inSubnet {
      if let symbol = point.mSymbol {
        result.append (symbol)
      }
    }
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
