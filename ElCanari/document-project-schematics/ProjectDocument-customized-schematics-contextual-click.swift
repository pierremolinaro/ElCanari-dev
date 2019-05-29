//
//  ProjectDocument-customized-contextual-click.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  internal func populateContextualClickOnSchematics (_ inMouseDownPoint : CanariPoint) -> NSMenu {
    let menu = NSMenu ()
    if let selectedSheet = self.rootObject.mSelectedSheet {
      let canariAlignedMouseDownLocation = inMouseDownPoint.point (alignedOnGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
      let points = selectedSheet.pointsInSchematics (at: canariAlignedMouseDownLocation)
    //--- Add NC ?
      self.appendCreateNCItemTo (menu: menu, points: points)
    //--- Add Connect ? (only if no NC)
      self.appendCreateConnectItemTo (menu: menu, points: points)
    //--- Add Point to wire ?
      let wires = selectedSheet.wiresStrictlyContaining (point: canariAlignedMouseDownLocation)
      self.appendCreateWirePointItemTo (menu : menu, canariAlignedMouseDownLocation, wires: wires)
    //--- Add Remove point from wire ?
      self.appendRemovePointFromWireItemTo (menu: menu, points: points)
    //--- Add disconnect ?
      self.appendDisconnectItemTo (menu: menu, points: points)
    //--- Add Labels
      self.appendCreateLabelsItemTo (menu: menu, mouseDownLocation: inMouseDownPoint)
    }
  //---
    return menu
  }

  //····················································································································
  // NC
  //····················································································································

  private func appendCreateConnectItemTo (menu : NSMenu, points inPoints : [PointInSchematic]) {
    if inPoints.count > 1 {
      var hasNC = false
      var pinCount = 0
      for p in inPoints {
        if p.mNC != nil {
          hasNC = true
        }
        if p.mSymbol != nil {
          pinCount += 1
        }
      }
      if !hasNC && (pinCount <= 1) {
        if menu.numberOfItems > 0 {
          menu.addItem (.separator ())
        }
        let menuItem = NSMenuItem (title: "Connect…", action: #selector (CustomizedProjectDocument.connectAction (_:)), keyEquivalent: "")
        menuItem.target = self
        menuItem.representedObject = inPoints
        menu.addItem (menuItem)
      }
    }
  }

  //····················································································································

  @objc private func connectAction (_ inSender : NSMenuItem) {
    if let points = inSender.representedObject as? [PointInSchematic],
       let selectedSheet = self.rootObject.mSelectedSheet,
       let window = self.windowForSheet,
       let mergeSeveralSubnetsPanel = self.mMergeSeveralSubnetsPanel,
       let mergeSeveralSubnetsPopUpButton = self.mMergeSeveralSubnetsPopUpButton {
      selectedSheet.connect (
        points: points,
        window,
        panelForMergingSeveralSubnet: mergeSeveralSubnetsPanel,
        popUpButtonForMergingSeveralSubnet: mergeSeveralSubnetsPopUpButton
      )
      self.updateSchematicsPointsAndNets ()
    }
  }

  //····················································································································
  // Disconnect
  //····················································································································

  private func appendDisconnectItemTo (menu : NSMenu, points inPoints : [PointInSchematic]) {
    var canDisconnect = false
    for point in inPoints {
      if point.mNC != nil {
        canDisconnect = true
        break
      }else if (point.mWiresP1s.count + point.mWiresP2s.count) >= 2 {
        canDisconnect = true
        break
      }else if point.mLabels.count > 1 {
        canDisconnect = true
        break
      }else if (point.mLabels.count == 1) && ((point.mWiresP1s.count + point.mWiresP2s.count) == 1) {
        canDisconnect = true
        break
      }
    }
    if canDisconnect {
      let menuItem = NSMenuItem (title: "Disconnect", action: #selector (CustomizedProjectDocument.disconnectAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = inPoints
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func disconnectAction (_ inSender : NSMenuItem) {
    if let points = inSender.representedObject as? [PointInSchematic], let selectedSheet = self.rootObject.mSelectedSheet {
      selectedSheet.disconnect (points: points)
      self.updateSchematicsPointsAndNets ()
    }
  }


  //····················································································································
  // Remove Point From Wire
  //····················································································································

  private func appendRemovePointFromWireItemTo (menu : NSMenu, points inPoints : [PointInSchematic]) {
    if inPoints.count == 1 {
      let point = inPoints [0]
      if point.mNC == nil, point.mLabels.count == 0, (point.mWiresP1s.count + point.mWiresP2s.count) == 2 {
        if menu.numberOfItems > 0 {
          menu.addItem (.separator ())
        }
        let menuItem = NSMenuItem (title: "Remove Point from Wire", action: #selector (CustomizedProjectDocument.removePointFromWireAction (_:)), keyEquivalent: "")
        menuItem.target = self
        menuItem.representedObject = point
        menu.addItem (menuItem)
      }
    }
  }

  //····················································································································

  @objc private func removePointFromWireAction (_ inSender : NSMenuItem) {
    if let point = inSender.representedObject as? PointInSchematic,
       let selectedSheet = self.rootObject.mSelectedSheet,
       let window = self.windowForSheet {
      selectedSheet.removeFromWire (point: point, window)
      self.updateSchematicsPointsAndNets ()
    }
  }

  //····················································································································
  // NC
  //····················································································································

  private func appendCreateNCItemTo (menu : NSMenu, points inPoints : [PointInSchematic]) {
    if inPoints.count == 1 {
      let point = inPoints [0]
      if point.mNC == nil, point.mLabels.count == 0, point.mWiresP1s.count == 0, point.mWiresP2s.count == 0 {
        if menu.numberOfItems > 0 {
          menu.addItem (.separator ())
        }
        let menuItem = NSMenuItem (title: "Add NC", action: #selector (CustomizedProjectDocument.addNCToPinAction (_:)), keyEquivalent: "")
        menuItem.target = self
        menuItem.representedObject = point
        menu.addItem (menuItem)
      }
    }
  }

  //····················································································································

  @objc private func addNCToPinAction (_ inSender : NSMenuItem) {
    if let point = inSender.representedObject as? PointInSchematic, let selectedSheet = self.rootObject.mSelectedSheet {
      let nc = selectedSheet.addNCToPin (toPoint: point)
      self.mSchematicObjectsController.setSelection ([nc])
    }
  }

  //····················································································································
  // Insert point into wire
  //····················································································································

  private func appendCreateWirePointItemTo (menu : NSMenu, _ inCanariAlignedMouseDownLocation : CanariPoint, wires inWires : [WireInSchematic]) {
    if inWires.count == 1 {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      let menuItem = NSMenuItem (title: "Add Point to Wire…", action: #selector (CustomizedProjectDocument.addPointToWireAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = inCanariAlignedMouseDownLocation
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func addPointToWireAction (_ inSender : NSMenuItem) {
    if let location = inSender.representedObject as? CanariPoint, let selectedSheet = self.rootObject.mSelectedSheet {
      selectedSheet.addPointToWire (at: location)
    }
  }

  //····················································································································
  // Labels
  //····················································································································

  private func appendCreateLabelsItemTo (menu : NSMenu, mouseDownLocation inMouseDownPoint : CanariPoint) {
     if menu.numberOfItems > 0 {
       menu.addItem (.separator ())
     }
     var menuItem = NSMenuItem (title: "Add Label with right flag", action: #selector (CustomizedProjectDocument.addLabelInSchematics (_:)), keyEquivalent: "")
     menuItem.target = self
     menuItem.tag = 0 // Right
     menuItem.representedObject = inMouseDownPoint
     menu.addItem (menuItem)
     menuItem = NSMenuItem (title: "Add Label with top flag", action: #selector (CustomizedProjectDocument.addLabelInSchematics (_:)), keyEquivalent: "")
     menuItem.target = self
     menuItem.tag = 1 // Top
     menuItem.representedObject = inMouseDownPoint
     menu.addItem (menuItem)
     menuItem = NSMenuItem (title: "Add Label with left flag", action: #selector (CustomizedProjectDocument.addLabelInSchematics (_:)), keyEquivalent: "")
     menuItem.target = self
     menuItem.tag = 2 // Left
     menuItem.representedObject = inMouseDownPoint
     menu.addItem (menuItem)
     menuItem = NSMenuItem (title: "Add Label with bottom flag", action: #selector (CustomizedProjectDocument.addLabelInSchematics (_:)), keyEquivalent: "")
     menuItem.target = self
     menuItem.tag = 3 // Bottom
     menuItem.representedObject = inMouseDownPoint
     menu.addItem (menuItem)
  }

  //····················································································································

  @objc private func addLabelInSchematics (_ inSender : NSMenuItem) {
    if let mouseLocation = inSender.representedObject as? CanariPoint, let selectedSheet = self.rootObject.mSelectedSheet {
    //--- Orientation
      let orientation : QuadrantRotation
      if inSender.tag == 1 {
        orientation = .rotation90
      }else if inSender.tag == 2 {
        orientation = .rotation180
      }else if inSender.tag == 3 {
        orientation = .rotation270
      }else{
        orientation = .rotation0
      }
    //--- Aligned mouse down location
      let canariAlignedMouseDownLocation = mouseLocation.point (alignedOnGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
    //--- Add label
      let possibleLabel = selectedSheet.addLabelInSchematics (
        at: canariAlignedMouseDownLocation,
        orientation: orientation,
        newNetCreator: self.rootObject.createNetWithAutomaticName
      )
      if let label = possibleLabel {
        self.mSchematicObjectsController.setSelection ([label])
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
