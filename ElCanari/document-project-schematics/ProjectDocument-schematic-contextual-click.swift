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
      self.appendCreateLabelsItemTo (menu: menu, mouseDownLocation: inMouseDownPoint, points: points)
    }
  //---
    return menu
  }

  //····················································································································
  // Connect
  //····················································································································

  internal func canConnect (points inPoints : [PointInSchematic]) -> Bool {
    var canConnect = false
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
      canConnect = !hasNC && (pinCount <= 1)
    }
    return canConnect
  }

  //····················································································································

  private func appendCreateConnectItemTo (menu : NSMenu, points inPoints : [PointInSchematic]) {
    if self.canConnect (points: inPoints) {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      let menuItem = NSMenuItem (title: "Connect…", action: #selector (CustomizedProjectDocument.connectAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = inPoints
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func connectAction (_ inSender : NSMenuItem) {
    if let points = inSender.representedObject as? [PointInSchematic] {
      self.connectInSchematic (points: points)
    }
  }

  //····················································································································

  internal func connectInSchematic (points inPoints : [PointInSchematic]) {
    if let selectedSheet = self.rootObject.mSelectedSheet,
       let window = self.windowForSheet,
       let mergeSeveralSubnetsPanel = self.mMergeSeveralSubnetsPanel,
       let mergeSeveralSubnetsPopUpButton = self.mMergeSeveralSubnetsPopUpButton {
      selectedSheet.connect (
        points: inPoints,
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

  internal func canDisconnect (points inPoints : [PointInSchematic]) -> Bool {
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
    return canDisconnect
  }

  //····················································································································

  private func appendDisconnectItemTo (menu : NSMenu, points inPoints : [PointInSchematic]) {
    if self.canDisconnect (points: inPoints) {
      let menuItem = NSMenuItem (title: "Disconnect", action: #selector (CustomizedProjectDocument.disconnectAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = inPoints
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func disconnectAction (_ inSender : NSMenuItem) {
    if let points = inSender.representedObject as? [PointInSchematic] {
      self.disconnectInSchematic (points: points)
    }
  }

  //····················································································································

  internal func disconnectInSchematic (points inPoints : [PointInSchematic]) {
    if let selectedSheet = self.rootObject.mSelectedSheet {
      selectedSheet.disconnect (points: inPoints)
      self.updateSchematicsPointsAndNets ()
    }
  }

  //····················································································································
  // Remove Point From Wire
  //····················································································································

  internal func canRemovePointFromWire (points inPoints : [PointInSchematic]) -> Bool {
    var canRemove = false
    if inPoints.count == 1 {
      let point = inPoints [0]
      if point.mNC == nil, point.mLabels.count == 0, (point.mWiresP1s.count + point.mWiresP2s.count) == 2 {
        canRemove = true
      }
    }
    return canRemove
  }

  //····················································································································

  private func appendRemovePointFromWireItemTo (menu : NSMenu, points inPoints : [PointInSchematic]) {
    if self.canRemovePointFromWire (points: inPoints) {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      let menuItem = NSMenuItem (title: "Remove Point from Wire", action: #selector (CustomizedProjectDocument.removePointFromWireAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = inPoints [0]
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func removePointFromWireAction (_ inSender : NSMenuItem) {
    if let point = inSender.representedObject as? PointInSchematic {
      self.removePointFromWireInSchematic (points: [point])
    }
  }

  //····················································································································

  internal func removePointFromWireInSchematic (points inPoints : [PointInSchematic]) {
    if let selectedSheet = self.rootObject.mSelectedSheet,
       let window = self.windowForSheet,
       inPoints.count == 1 {
      selectedSheet.removeFromWire (point: inPoints [0], window)
      self.updateSchematicsPointsAndNets ()
    }
  }

  //····················································································································
  // NC
  //····················································································································

  internal func canCreateNC (points inPoints : [PointInSchematic]) -> Bool {
    var canCreate = false
    if inPoints.count == 1 {
      let point = inPoints [0]
      if point.mNC == nil, point.mLabels.count == 0, point.mWiresP1s.count == 0, point.mWiresP2s.count == 0 {
        canCreate = true
      }
    }
    return canCreate
  }

  //····················································································································

  private func appendCreateNCItemTo (menu : NSMenu, points inPoints : [PointInSchematic]) {
    if self.canCreateNC (points: inPoints) {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      let menuItem = NSMenuItem (title: "Add NC", action: #selector (CustomizedProjectDocument.addNCToPinAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = inPoints [0]
      menu.addItem (menuItem)
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

  internal func canCreateWirePoint (wires inWires : [WireInSchematic]) -> Bool {
    return inWires.count == 1
  }

  //····················································································································

  private func appendCreateWirePointItemTo (menu : NSMenu, _ inCanariAlignedMouseDownLocation : CanariPoint, wires inWires : [WireInSchematic]) {
    if self.canCreateWirePoint (wires: inWires) {
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
    if let location = inSender.representedObject as? CanariPoint {
      self.addPointToWireInSchematic (at: location)
    }
  }

  //····················································································································

  internal func addPointToWireInSchematic (at inLocation : CanariPoint) {
    if let selectedSheet = self.rootObject.mSelectedSheet {
      selectedSheet.addPointToWire (at: inLocation)
    }
  }

  //····················································································································
  // Labels
  //····················································································································

  internal func canCreateLabels (points inPoints : [PointInSchematic]) -> Bool {
  //--- Check points have no label
    var pointsHaveLabel = false
    for p in inPoints {
      if p.mLabels.count > 0 {
        pointsHaveLabel = true
        break
      }
    }
    return !pointsHaveLabel
  }

  //····················································································································

  private func appendCreateLabelsItemTo (menu : NSMenu,
                                         mouseDownLocation inMouseDownPoint : CanariPoint,
                                         points inPoints : [PointInSchematic]) {
    if self.canCreateLabels (points: inPoints) {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      var menuItem = NSMenuItem (title: "Add Label with right flag", action: #selector (CustomizedProjectDocument.addLabelInSchematicAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.tag = 0 // Right
      menuItem.representedObject = inMouseDownPoint
      menu.addItem (menuItem)
      menuItem = NSMenuItem (title: "Add Label with top flag", action: #selector (CustomizedProjectDocument.addLabelInSchematicAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.tag = 1 // Top
      menuItem.representedObject = inMouseDownPoint
      menu.addItem (menuItem)
      menuItem = NSMenuItem (title: "Add Label with left flag", action: #selector (CustomizedProjectDocument.addLabelInSchematicAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.tag = 2 // Left
      menuItem.representedObject = inMouseDownPoint
      menu.addItem (menuItem)
      menuItem = NSMenuItem (title: "Add Label with bottom flag", action: #selector (CustomizedProjectDocument.addLabelInSchematicAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.tag = 3 // Bottom
      menuItem.representedObject = inMouseDownPoint
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func addLabelInSchematicAction (_ inSender : NSMenuItem) {
    if let mouseLocation = inSender.representedObject as? CanariPoint {
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
      self.addLabelInSchematic (at: mouseLocation, orientation: orientation)
    }
  }

  //····················································································································

  internal func addLabelInSchematic (at inLocation : CanariPoint, orientation inOrientation : QuadrantRotation) {
    if let selectedSheet = self.rootObject.mSelectedSheet {
    //--- Aligned mouse down location
      let canariAlignedMouseDownLocation = inLocation.point (alignedOnGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
    //--- Add label
      let possibleLabel = selectedSheet.addLabelInSchematics (
        at: canariAlignedMouseDownLocation,
        orientation: inOrientation,
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
