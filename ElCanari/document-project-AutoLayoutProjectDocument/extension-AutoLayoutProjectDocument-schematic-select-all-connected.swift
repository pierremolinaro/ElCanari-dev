//
//  ProjectDocument-schematic-select-all-connected.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/06/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {

  //····················································································································

  func selectAllConnectedElementsInSchematics () -> (EBReferenceSet <SchematicObject>, EBReferenceSet <PointInSchematic>) {
    var objectExploreSet = EBReferenceSet (self.schematicObjectsController.selectedArray.values)
    var objectSet = EBReferenceSet <SchematicObject> ()
    var pointExploreSet = EBReferenceSet <PointInSchematic> ()
    var pointSet = EBReferenceSet <PointInSchematic> ()
    var loop = true
    while loop {
      if let object = objectExploreSet.first {
        _ = objectExploreSet.removeFirst ()
        objectSet.insert (object)
        if let nc = object as? NCInSchematic, let point = nc.mPoint, !pointSet.contains (point) {
          pointExploreSet.insert (point)
        }else if let label = object as? LabelInSchematic, let point = label.mPoint, !pointSet.contains (point) {
          pointExploreSet.insert (point)
        }else if let symbol = object as? ComponentSymbolInProject {
          for point in symbol.mPoints.values {
            if !pointSet.contains (point) {
              pointExploreSet.insert (point)
            }
          }
        }else if let wire = object as? WireInSchematic {
          if let p1 = wire.mP1, !pointSet.contains (p1) {
            pointExploreSet.insert (p1)
          }
          if let p2 = wire.mP2, !pointSet.contains (p2) {
            pointExploreSet.insert (p2)
          }
        }
      }else if let point = pointExploreSet.first {
        _ = pointExploreSet.removeFirst ()
        pointSet.insert (point)
        if let nc = point.mNC {
          objectSet.insert (nc)
        }
        if let symbol = point.mSymbol {
          if !objectSet.contains (symbol) {
            objectExploreSet.insert (symbol)
          }
        }
        for label in point.mLabels.values {
          objectSet.insert (label)
        }
        for wire in point.mWiresP1s.values + point.mWiresP2s.values {
          if !objectSet.contains (wire) {
            objectExploreSet.insert (wire)
          }
        }
      }else{
        loop = false
      }
    }
    self.schematicObjectsController.setSelection (Array (objectSet.values))
    return (objectSet, pointSet)
  }

  //····················································································································


}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
