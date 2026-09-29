//
//  extension-SheetInProject-disconnect.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/05/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension SheetInProject {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func disconnect (points inPoints : [PointInSchematic]) {
  //--- Perform disconnection
    let pointSet = self.performDisconnection (points: inPoints)
  //--- Update connections
    self.updateConnections (pointSet: pointSet)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateConnections (pointSet inPointSet : EBReferenceSet <PointInSchematic>) {
    if let root = self.mRoot {
    //--- Find subnets
      let subnets : [EBReferenceSet <PointInSchematic>] = self.buildSubnetsFrom (inPointSet)
    //--- Classify subnets
      var subnetsWithSymbolPin = [EBReferenceSet <PointInSchematic>] ()
      var subnetsWithLabelsNoSymbolPin = [EBReferenceSet <PointInSchematic>] ()
      var subnetsWithNoLabelNoSymbolPin = [EBReferenceSet <PointInSchematic>] ()
      for subnet in subnets {
        let symbolArray = self.buildSymbolArrayFromSubnet (subnet)
        if symbolArray.count > 0 {
          subnetsWithSymbolPin.append (subnet)
        }else{
          let labelArray = self.buildLabelArrayFromSubnet (subnet)
          if labelArray.count > 0 {
            subnetsWithLabelsNoSymbolPin.append (subnet)
          }else{
            subnetsWithNoLabelNoSymbolPin.append (subnet)
          }
        }
      }
    //--- Reassign nets
      var usedNets = EBReferenceSet <NetInProject> ()
      // Swift.print ("subnetsWithSymbolPin \(subnetsWithSymbolPin.count)")
      for subnet in subnetsWithSymbolPin {
        // Swift.print ("subnet \(subnet.count)")
        let point = subnet.first!
        let noConnection = (point.mLabels.count + point.mWiresP1s.count + point.mWiresP2s.count) == 0
        // Swift.print ("noConnection \(noConnection)")
        if noConnection { // Remove from net
          // Swift.print ("netName \(point.mNet?.mNetName)")
          point.mNet = nil
        }else{
          var net = point.mNet!
          if usedNets.contains (net) {
            net = root.createNetWithAutomaticName ()
          }else{
            usedNets.insert (net)
          }
          for p in subnet.values {
            p.mNet = net
          }
        }
      }
      for subnet in subnetsWithLabelsNoSymbolPin {
        var net = subnet.first!.mNet!
        if usedNets.contains (net) {
          net = root.createNetWithAutomaticName ()
        }else{
          usedNets.insert (net)
        }
        for point in subnet.values {
          point.mNet = net
        }
      }
    //--- Remove any net for subnets without pin, without label
      for subnet in subnetsWithNoLabelNoSymbolPin {
        for point in subnet.values {
          point.mNet = nil
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func performDisconnection (points inPoints : [PointInSchematic]) -> EBReferenceSet <PointInSchematic> {
    var pointSet = EBReferenceSet <PointInSchematic> ()
    for p in inPoints {
      let location = p.location!
    //--- Remove NC ?
      if let nc = p.mNC {
        nc.mPoint = nil
        nc.mSheet = nil
      }
    //--- Remove labels ?
      for label in p.mLabels.values {
        let newPoint = PointInSchematic (self.undoManager)
        newPoint.mX = location.x
        newPoint.mY = location.y
        label.mPoint = newPoint
        newPoint.mNet = p.mNet
        self.mPoints.append (newPoint)
        pointSet.insert (newPoint)
      }
    //--- Remove wires ?
      for wire in p.mWiresP1s.values {
        let newPoint = PointInSchematic (self.undoManager)
        newPoint.mX = location.x
        newPoint.mY = location.y
        wire.mP1 = newPoint
        newPoint.mNet = p.mNet
        self.mPoints.append (newPoint)
        pointSet.insert (newPoint)
      }
      for wire in p.mWiresP2s.values {
        let newPoint = PointInSchematic (self.undoManager)
        newPoint.mX = location.x
        newPoint.mY = location.y
        wire.mP2 = newPoint
        newPoint.mNet = p.mNet
        self.mPoints.append (newPoint)
        pointSet.insert (newPoint)
      }
    //---
      p.mNet = nil
    }
  //---
    return pointSet
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

