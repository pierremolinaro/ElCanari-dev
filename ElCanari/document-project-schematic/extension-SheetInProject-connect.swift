//
//  extension-SheetInProject-connect.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 09/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SheetInProject {

  //····················································································································

  func removeFromWire (point inPoint : PointInSchematic, _ inWindow : NSWindow) {
    if inPoint.mNC == nil, inPoint.mLabels.count == 0, (inPoint.mWiresP1s.count + inPoint.mWiresP2s.count) == 2 {
      if inPoint.mWiresP1s.count == 2 {
        let removedWire = inPoint.mWiresP1s [0]
        let conservedWire = inPoint.mWiresP1s [1]
        conservedWire.mP1 = removedWire.mP2
        removedWire.mP1 = nil
        removedWire.mP2 = nil
        inPoint.mNet = nil
      }else if inPoint.mWiresP2s.count == 2 {
        let removedWire = inPoint.mWiresP2s [0]
        let conservedWire = inPoint.mWiresP2s [1]
        conservedWire.mP2 = removedWire.mP1
        removedWire.mP1 = nil
        removedWire.mP2 = nil
        inPoint.mNet = nil
      }else{
        let removedWire = inPoint.mWiresP2s [0]
        let conservedWire = inPoint.mWiresP1s [0]
        conservedWire.mP1 = removedWire.mP1
        removedWire.mP1 = nil
        removedWire.mP2 = nil
        inPoint.mNet = nil
      }
    }
  }
  
  //····················································································································

  func canConnectWithoutDialog (points inPoints : [PointInSchematic]) -> Bool {
    let wires = self.wiresStrictlyContaining (point: inPoints [0].location!)
    var netSet = Set <NetInProject> ()
    for wire in wires {
      if let net = wire.mP1?.mNet {
        netSet.insert (net)
      }
    }
    for point in inPoints {
      if let net = point.mNet {
        netSet.insert (net)
      }
    }
  //---
    return (inPoints.count > 1) && (netSet.count < 2)
  }

  //····················································································································

  func connectWithoutDialog (points inPoints : [PointInSchematic]) -> ([PointInSchematic], [NetInProject]) {
    let optionalPoint = self.addPointToWire (at: inPoints [0].location!)
    var points = inPoints
    if let newPoint = optionalPoint {
      points.append (newPoint)
    }
    var netSet = Set <NetInProject> ()
    for point in points {
      if let net = point.mNet {
        netSet.insert (net)
      }
    }
  //---
    let netArray = Array (netSet).sorted { $0.mNetName < $1.mNetName }
    if netArray.count == 0 { // Allocate a new net if a point has a label or a pin
      var hasPinOrLabel = false
      for p in points {
        if (p.mSymbol != nil) || (p.mLabels.count > 0) {
          hasPinOrLabel = true
          break
        }
      }
      let newNet : NetInProject? = hasPinOrLabel ? self.mRoot?.createNetWithAutomaticName () : nil
      self.propagateAndMerge (net: newNet, to: points)
      return ([], []) // For indicating connection is done
    }else if netArray.count == 1 {
      self.propagateAndMerge (net: netArray [0], to: points)
      return ([], []) // For indicating connection is done
    }else{
      return (points, netArray)
    }
  }

  //····················································································································

  func connect (points inPoints : [PointInSchematic],
                window inWindow : NSWindow,
                panelForMergingSeveralSubnet inPanel : NSPanel,
                popUpButtonForMergingSeveralSubnet inPopUp : EBPopUpButton) {
    let (points, netArray) = self.connectWithoutDialog (points: inPoints)
//    let optionalPoint = self.addPointToWire (at: inPoints [0].location!)
//    var points = inPoints
//    if let newPoint = optionalPoint {
//      points.append (newPoint)
//    }
//    var netSet = Set <NetInProject> ()
//    for point in points {
//      if let net = point.mNet {
//        netSet.insert (net)
//      }
//    }
//  //---
//    let netArray = Array (netSet).sorted { $0.mNetName < $1.mNetName }
//    if netArray.count == 0 { // Allocate a new net if a point has a label or a pin
//      var hasPinOrLabel = false
//      for p in points {
//        if (p.mSymbol != nil) || (p.mLabels.count > 0) {
//          hasPinOrLabel = true
//          break
//        }
//      }
//      let newNet : NetInProject? = hasPinOrLabel ? self.mRoot?.createNetWithAutomaticName () : nil
//      self.propagateAndMerge (net: newNet, to: points)
//    }else if netArray.count == 1 {
//      self.propagateAndMerge (net: netArray [0], to: points)
//    }else
    if netArray.count == 2 {
      let alert = NSAlert ()
      alert.messageText = "Performing connection will merge two nets."
      for net in netArray {
        alert.addButton (withTitle: net.mNetName)
      }
      alert.addButton (withTitle: "Cancel")
      alert.beginSheetModal (for: inWindow) { (response : NSApplication.ModalResponse) in
        self.handleAlertResponseForMergingNets (response, points, netArray)
      }
    }else if netArray.count == 3 {
      let alert = NSAlert ()
      alert.messageText = "Performing connection will merge three nets."
      for net in netArray {
        alert.addButton (withTitle: net.mNetName)
      }
      alert.addButton (withTitle: "Cancel")
      alert.beginSheetModal (for: inWindow) { (response : NSApplication.ModalResponse) in
        self.handleAlertResponseForMergingNets (response, points, netArray)
      }
    }else if netArray.count > 3 {
      self.connectionWillMergeSeveralSubnets (points: points, netArray, inWindow, inPanel, inPopUp)
    }
  }

  //····················································································································

  private func connectionWillMergeSeveralSubnets (points inPoints : [PointInSchematic],
                                                  _ netArray : [NetInProject],
                                                  _ inWindow : NSWindow,
                                                  _ inPanel : NSPanel,
                                                  _ inPopUp : EBPopUpButton) {
    inPopUp.removeAllItems ()
    for net in netArray {
      inPopUp.addItem (withTitle: net.mNetName)
      inPopUp.lastItem?.representedObject = net
    }
    inWindow.beginSheet (inPanel) { (_ inModalResponse : NSApplication.ModalResponse) in
      if inModalResponse == .stop, let net = inPopUp.selectedItem?.representedObject as? NetInProject {
        self.propagateAndMerge (net: net, to: inPoints)
      }
    }
  }

  //····················································································································

  private func handleAlertResponseForMergingNets (_ inResponse : NSApplication.ModalResponse,
                                                   _ inPoints : [PointInSchematic],
                                                   _ inNetArray : [NetInProject]) {
    let responseIndex = inResponse.rawValue - NSApplication.ModalResponse.alertFirstButtonReturn.rawValue
    if responseIndex < inNetArray.count {
      // NSLog ("responseIndex \(responseIndex)")
      let newNet = inNetArray [responseIndex]
      self.propagateAndMerge (net: newNet, to: inPoints)
    }
  }

  //····················································································································
  //  Propagate and merge net
  //····················································································································

  private func propagateAndMerge (net inNet : NetInProject?, to inPoints : [PointInSchematic]) {
  //--- All points should be at the same location
  //    Only one point should be bound to a symbol pin
    if inPoints.count == 1 {
      inPoints [0].mNet = inNet
      inPoints [0].propagateNetToAccessiblePointsThroughtWires ()
    }else if inPoints.count > 1 {
      var symbol : ComponentSymbolInProject? = nil
      var symbolPinName = ""
      let location = inPoints [0].location!
      var ok = true
      for point in inPoints {
        if point.mNC != nil {
          ok = false
        }else if point.location! != location {
          ok = false
        }else if let sp = point.mSymbol {
          if symbol != nil {
            ok = false
          }
          symbol = sp
          symbolPinName = point.mSymbolPinName
        }
      }
      if ok {
        let newPoint = PointInSchematic (self.ebUndoManager)
        newPoint.mSymbol = symbol
        newPoint.mSymbolPinName = symbolPinName
        newPoint.mNet = inNet
        newPoint.mX = location.x
        newPoint.mY = location.y
        self.mPoints.append (newPoint)
        for point in inPoints {
          let wireP1s = point.mWiresP1s
          point.mWiresP1s = []
          newPoint.mWiresP1s += wireP1s
          let wireP2s = point.mWiresP2s
          point.mWiresP2s = []
          newPoint.mWiresP2s += wireP2s
          let labels = point.mLabels
          point.mLabels = []
          newPoint.mLabels += labels
          point.mNet = nil
        }
        for point in inPoints {
          point.mSymbol = nil
          let idx = self.mPoints.firstIndex (of: point)!
          self.mPoints.remove (at: idx)
        }
        newPoint.propagateNetToAccessiblePointsThroughtWires ()
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
