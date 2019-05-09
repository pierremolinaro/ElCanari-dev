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
    //--- Remove unused points
      var idx = 0
      while idx < selectedSheet.mPoints.count {
        let point = selectedSheet.mPoints [idx]
        let unused = (point.mLabels.count == 0)
          && (point.mNC == nil)
          && (point.mWiresP1s.count == 0)
          && (point.mWiresP2s.count == 0)
          && (point.mSymbol == nil)
        if unused {
          point.mNet = nil
          selectedSheet.mPoints.remove (at: idx)
        }else{
          idx += 1
        }
      }
    //--- Check points
      var exploreSet = Set <PointInSchematics> ()
      for point in selectedSheet.mPoints {
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
  }

  //····················································································································

  internal func performAddWireDragOperation (_ inDraggingLocationInDestinationView : NSPoint) {
    let p = inDraggingLocationInDestinationView.canariPointAligned (onCanariGrid: SCHEMATICS_GRID_IN_CANARI_UNIT)
    let wire = WireInSchematics (self.ebUndoManager)
    let p1 = CanariPoint (x: p.x, y: p.y)
    let p2 = CanariPoint (x: p.x + WIRE_DEFAULT_SIZE_ON_DRAG_AND_DROP, y: p.y + WIRE_DEFAULT_SIZE_ON_DRAG_AND_DROP)
  //--- Find points at p1 and p2
    let pointsAtP1 = self.pointsInSchematics (at: p1)
    let pointsAtP2 = self.pointsInSchematics (at: p2)
  //---
    if (pointsAtP1.count == 1) && (pointsAtP2.count == 1) && (pointsAtP1 [0].mNet === pointsAtP2 [0].mNet) {
      wire.mP1 = pointsAtP1 [0]
      wire.mP2 = pointsAtP2 [0]
      if pointsAtP1 [0].mNet == nil {
        let newNet = self.createNetWithAutomaticName ()
        wire.mP1?.mNet = newNet
        wire.mP2?.mNet = newNet
      }
    }else if pointsAtP1.count == 1 { // Use point at p1, create a point at p2
      wire.mP1 = pointsAtP1 [0]
      if pointsAtP1 [0].mNet == nil {
        let newNet = self.createNetWithAutomaticName ()
        wire.mP1?.mNet = newNet
      }
      let point = PointInSchematics (self.ebUndoManager)
      point.mX = p2.x
      point.mY = p2.y
      point.mNet = wire.mP1?.mNet
      wire.mP2 = point
      self.rootObject.mSelectedSheet?.mPoints.append (point)
    }else if pointsAtP2.count == 1 { // Use point at p2, create a point at p1
      wire.mP2 = pointsAtP2 [0]
      if pointsAtP2 [0].mNet == nil {
        let newNet = self.createNetWithAutomaticName ()
        wire.mP2?.mNet = newNet
      }
      let point = PointInSchematics (self.ebUndoManager)
      point.mX = p1.x
      point.mY = p1.y
      point.mNet = wire.mP2?.mNet
      wire.mP1 = point
      self.rootObject.mSelectedSheet?.mPoints.append (point)
    }else{ // Assign no net
      let point1 = PointInSchematics (self.ebUndoManager)
      point1.mX = p1.x
      point1.mY = p1.y
      wire.mP1 = point1
      self.rootObject.mSelectedSheet?.mPoints.append (point1)
      let point2 = PointInSchematics (self.ebUndoManager)
      point2.mX = p2.x
      point2.mY = p2.y
      wire.mP2 = point2
      self.rootObject.mSelectedSheet?.mPoints.append (point2)
    }
  //--- Enter wire and select it
    self.rootObject.mSelectedSheet?.mObjects.append (wire)
    self.mSchematicsObjectsController.setSelection ([wire])
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
