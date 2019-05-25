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

  func connect (points inPoints : [PointInSchematic], _ inWindow : NSWindow) {
    var netSet = Set <NetInProject> ()
    for point in inPoints {
      if let net = point.mNet {
        netSet.insert (net)
      }
    }
  //---
    let netArray = Array (netSet).sorted { $0.mNetName > $1.mNetName }
    if netArray.count == 1 {
      self.propagateAndMerge (net: netArray [0], to: inPoints)
    }else if netArray.count == 2 {
      let alert = NSAlert ()
      alert.messageText = "Performing connection will merge two nets."
      for net in netArray {
        alert.addButton (withTitle: net.mNetName)
      }
      alert.addButton (withTitle: "Cancel")
      alert.beginSheetModal (for: inWindow) { (response : NSApplication.ModalResponse) in
        self.handleAlertResponseForMergingNets (response, inPoints, netArray)
      }
    }else if netArray.count == 3 {
      let alert = NSAlert ()
      alert.messageText = "Performing connection will merge three nets."
      for net in netArray {
        alert.addButton (withTitle: net.mNetName)
      }
      alert.addButton (withTitle: "Cancel")
      alert.beginSheetModal (for: inWindow) { (response : NSApplication.ModalResponse) in
        self.handleAlertResponseForMergingNets (response, inPoints, netArray)
      }
    }else if netArray.count > 3 {
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

  private func propagateAndMerge (net inNet : NetInProject, to inPoints : [PointInSchematic]) {
  //--- All points should be at the same location
  //    Only one point should be bound to a symbol pin
    if inPoints.count == 1 {
      inPoints [0].mNet = inNet
      self.propagateNet (fromPoint: inPoints [0])
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
        var newWiresP1s = [WireInSchematics] ()
        var newWiresP2s = [WireInSchematics] ()
        var newLabels = [LabelInSchematic] ()
        for point in inPoints {
          //NSLog ("Ex point \(point.mWiresP1s.count) \(point.mWiresP2s.count) \(point.mLabels.count)")
          let wireP1s = point.mWiresP1s
          point.mWiresP1s = []
          newWiresP1s += wireP1s
          let wireP2s = point.mWiresP2s
          point.mWiresP2s = []
          newWiresP2s += wireP2s
          let labels = point.mLabels
          point.mLabels = []
          newLabels += labels
          point.mNet = nil
        }
        newPoint.mWiresP1s = newWiresP1s
        newPoint.mWiresP2s = newWiresP2s
        newPoint.mLabels = newLabels
        //NSLog ("New point \(newPoint.mWiresP1s.count) \(newPoint.mWiresP2s.count) \(newPoint.mLabels.count)")
        for point in inPoints {
          let idx = self.mPoints.firstIndex (of: point)!
          self.mPoints.remove (at: idx)
          // NSLog ("Wires \(idx) \(point.mWiresP1s.count) \(point.mWiresP2s.count) \(point.mLabels.count)")
        }
        self.propagateNet (fromPoint: newPoint)
      }
    }
  }

  //····················································································································

  internal func propagateNet (fromPoint inPoint : PointInSchematic) {
    var reachedPointSet = Set <PointInSchematic> ([inPoint])
    var exploreArray = [inPoint]
    while let point = exploreArray.last {
      exploreArray.removeLast ()
      for wire in point.mWiresP1s + point.mWiresP2s {
        let p1 = wire.mP1!
        if !reachedPointSet.contains (p1) {
          NSLog ("ADD \(p1)")
          reachedPointSet.insert (p1)
          exploreArray.append (p1)
          p1.mNet = inPoint.mNet
        }
        let p2 = wire.mP2!
        if !reachedPointSet.contains (p2) {
          NSLog ("ADD \(p2)")
          reachedPointSet.insert (p2)
          exploreArray.append (p2)
          p2.mNet = inPoint.mNet
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
