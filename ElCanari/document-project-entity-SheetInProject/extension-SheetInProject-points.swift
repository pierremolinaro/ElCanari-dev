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

  func netSetFor (points : [PointInSchematic]) -> EBReferenceSet <NetInProject> {
    var netSet = EBReferenceSet <NetInProject> ()
    for p in points {
      if let net = p.mNet {
        netSet.insert (net)
      }
    }
    return netSet
  }

  //····················································································································

  func removeUnusedSchematicsPoints (_ ioErrorList : inout [String]) {
  //--- Remove unused points
    for point in self.mPoints.values {
      var used = (point.mLabels.count + point.mWiresP1s.count + point.mWiresP2s.count) > 0
      if !used {
        used = point.mNC != nil
      }
      if !used {
        if let symbol = point.mSymbol {
          used = symbol.mSheet != nil
        }
      }
      if !used { // Remove
        point.mNet = nil
        point.mSheet = nil
        point.mSymbol = nil
      }
    }
  //--- Check points
    var exploreSet = EBReferenceSet <PointInSchematic> ()
    for point in self.mPoints.values {
      if point.mNC != nil {
        var errorFlags : UInt32 = 0
        if point.mSymbol == nil { errorFlags |= 1 }
        if point.mSymbolPinName.isEmpty { errorFlags |= 2 }
        if point.mWiresP1s.count > 0 { errorFlags |= 4 }
        if point.mWiresP2s.count > 0 { errorFlags |= 8 }
        if point.mLabels.count > 0 { errorFlags |= 16 }
        if point.mNet != nil { errorFlags |= 32 }
        if errorFlags != 0 {
          ioErrorList.append ("Error 0x\(String (errorFlags, radix: 16, uppercase: true)) for NC point 0x\(String (point.objectIndex, radix: 16, uppercase: true))")
        }
      }else{
        var errorFlags : UInt32 = 0
        if (point.mSymbol == nil) != (point.mSymbolPinName.isEmpty) { errorFlags |= 1 }
        var connectionCount = point.mWiresP1s.count + point.mWiresP2s.count + point.mLabels.count
        if point.mSymbol != nil { connectionCount += 1 }
        if connectionCount == 0 { errorFlags |= 2 }
        if errorFlags != 0 {
          ioErrorList.append ("Error 0x\(String (errorFlags, radix: 16, uppercase: true)) for point 0x\(String (point.objectIndex, radix: 16, uppercase: true))")
        }
        exploreSet.insert (point)
      }
    //--- Explore subnet for checking that net setting is consistent
      while exploreSet.count > 0 {
        let point = exploreSet.removeFirst ()
        let net = point.mNet
        var wiresToExplore = EBReferenceSet <WireInSchematic> (point.mWiresP1s.values + point.mWiresP2s.values)
        var exploredWires = EBReferenceSet <WireInSchematic> ()
        while wiresToExplore.count > 0 {
          let wire = wiresToExplore.removeFirst ()
          exploredWires.insert (wire)
          let p2 = wire.mP2!
          if exploreSet.contains (p2) {
            exploreSet.remove (p2)
            if p2.mNet !== net {
              ioErrorList.append ("Error p2.mNet != net for net \(net?.objectIndex ?? 0)")
            }
            for reachableWire in p2.mWiresP1s.values + p2.mWiresP2s.values {
              if !exploredWires.contains (reachableWire) {
                exploredWires.insert (reachableWire)
                wiresToExplore.insert (reachableWire)
              }
            }
          }
          let p1 = wire.mP1!
          if exploreSet.contains (p1) {
            exploreSet.remove (p1)
            if p1.mNet !== net {
              ioErrorList.append ("Error p1.mNet != net for net \(net?.objectIndex ?? 0)")
            }
            for reachableWire in p1.mWiresP1s.values + p1.mWiresP2s.values {
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

  func buildSubnet (from inPoint : PointInSchematic) -> EBReferenceSet <PointInSchematic> {
    var exploreSet = EBReferenceSet (inPoint)
    var result = EBReferenceSet <PointInSchematic> ()
    while let point = exploreSet.first {
      _ = exploreSet.removeFirst ()
      result.insert (point)
      for wire in point.mWiresP1s.values {
        if let p2 = wire.mP2, !result.contains (p2) {
          exploreSet.insert (p2)
        }
      }
      for wire in point.mWiresP2s.values {
        if let p1 = wire.mP1, !result.contains (p1) {
          exploreSet.insert (p1)
        }
      }
    }
    return result
  }

  //····················································································································

  func buildSubnetsFrom (_ inPointSet : EBReferenceSet <PointInSchematic>) -> [EBReferenceSet <PointInSchematic>] {
    var result = [EBReferenceSet <PointInSchematic>] ()
    var currentPointSet = inPointSet
    while let point = currentPointSet.first {
      let subnet = self.buildSubnet (from: point)
      currentPointSet.subtract (subnet)
      result.append (subnet)
    }
    return result
  }

  //····················································································································

  func buildLabelArrayFromSubnet (_ inSubnet : EBReferenceSet <PointInSchematic>) -> [LabelInSchematic] {
    var result = [LabelInSchematic] ()
    for point in inSubnet.values {
      for label in point.mLabels.values {
        result.append (label)
      }
    }
    return result
  }

  //····················································································································

  func buildSymbolArrayFromSubnet (_ inSubnet : EBReferenceSet <PointInSchematic>) -> [ComponentSymbolInProject] {
    var result = [ComponentSymbolInProject] ()
    for point in inSubnet.values {
      if let symbol = point.mSymbol {
        result.append (symbol)
      }
    }
    return result
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
