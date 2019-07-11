//
//  extension-SheetInProject-disconnect.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SheetInProject {

  //····················································································································

  internal func disconnect (points inPoints : [PointInSchematic]) {
  //--- Perform disconnection
    let pointSet = self.performDisconnection (points: inPoints)
  //--- Update connections
    self.updateConnections (pointSet: pointSet)
  }

  //····················································································································

  internal func updateConnections (pointSet inPointSet : Set <PointInSchematic>) {
    if let root = self.mRoot {
    //--- Find subnets
      let subnets : [Set <PointInSchematic>] = self.buildSubnetsFrom (inPointSet)
      // Swift.print ("subnets \(subnets.count)")
    //--- Classify subnets
      var subnetsWithSymbolPin = [Set <PointInSchematic>] ()
      var subnetsWithLabelsNoSymbolPin = [Set <PointInSchematic>] ()
      var subnetsWithNoLabelNoSymbolPin = [Set <PointInSchematic>] ()
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
      // Swift.print ("with pin \(subnetsWithSymbolPin.count), with labels \(subnetsWithLabelsNoSymbolPin.count), others \(subnetsWithNoLabelNoSymbolPin.count)")
    //--- Reassign nets
      var usedNets = Set <NetInProject> ()
      for subnet in subnetsWithSymbolPin {
        let point = subnet.first!
        let noConnection = (point.mLabels.count + point.mWiresP1s.count + point.mWiresP2s.count) == 0
        if noConnection { // Remove from net
          point.mNet = nil
        }else{
          var net = point.mNet!
          if usedNets.contains (net) {
            net = root.createNetWithAutomaticName ()
          }else{
            usedNets.insert (net)
          }
          for point in subnet {
            point.mNet = net
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
        for point in subnet {
          point.mNet = net
        }
      }
    //--- Remove any net for subnets without pin, without label
      for subnet in subnetsWithNoLabelNoSymbolPin {
        for point in subnet {
          point.mNet = nil
        }
      }
    }
  }

  //····················································································································

  fileprivate func performDisconnection (points inPoints : [PointInSchematic]) -> Set <PointInSchematic> {
    var pointSet = Set <PointInSchematic> ()
    for p in inPoints {
      let location = p.location!
    //--- Remove NC ?
      if let nc = p.mNC {
        nc.mPoint = nil
        nc.mSheet = nil
      }
    //--- Remove labels ?
      for label in p.mLabels {
        let newPoint = PointInSchematic (self.ebUndoManager)
        newPoint.mX = location.x
        newPoint.mY = location.y
        label.mPoint = newPoint
        newPoint.mNet = p.mNet
        self.mPoints.append (newPoint)
        pointSet.insert (newPoint)
      }
    //--- Remove wires ?
      for wire in p.mWiresP1s {
        let newPoint = PointInSchematic (self.ebUndoManager)
        newPoint.mX = location.x
        newPoint.mY = location.y
        wire.mP1 = newPoint
        newPoint.mNet = p.mNet
        self.mPoints.append (newPoint)
        pointSet.insert (newPoint)
      }
      for wire in p.mWiresP2s {
        let newPoint = PointInSchematic (self.ebUndoManager)
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

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

