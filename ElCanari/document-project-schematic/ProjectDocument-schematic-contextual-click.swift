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

  internal func populateContextualClickOnSchematics (_ inUnalignedMouseDownPoint : CanariPoint) -> NSMenu {
    let menu = NSMenu ()
    if let selectedSheet = self.rootObject.mSelectedSheet {
      let canariAlignedMouseDownLocation = inUnalignedMouseDownPoint.point (alignedOnGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
      let points = selectedSheet.pointsInSchematics (at: canariAlignedMouseDownLocation)
      let wires = selectedSheet.wiresStrictlyContaining (point: inUnalignedMouseDownPoint)
    //--- Add Connect symbol pins
      self.appendConnectSymbolPins (menu: menu, at: inUnalignedMouseDownPoint)
    //--- Add NC ?
      self.appendNCToAllUnconnectedSymbolPins (menu: menu, at: inUnalignedMouseDownPoint)
      self.appendCreateNCItemTo (menu: menu, points: points)
    //--- Add Connect ? (only if no NC)
      self.appendCreateConnectItemTo (menu: menu, points: points)
    //--- Add Point to wire ?
      self.appendCreateWirePointItemTo (menu : menu, canariAlignedMouseDownLocation, wires: wires)
    //--- Add Remove point from wire ?
      self.appendRemovePointFromWireItemTo (menu: menu, points: points)
    //--- Add disconnect ?
      self.appendDisconnectAllSymbolPins (menu: menu, at: inUnalignedMouseDownPoint)
      self.appendDisconnectItemTo (menu: menu, points: points)
    //--- Add Exchange
      self.appendExchangeSymbolItemTo (menu: menu, at: inUnalignedMouseDownPoint)
    //--- Add Labels
      self.appendCreateLabelsItemTo (menu: menu, mouseDownLocation: canariAlignedMouseDownLocation, points: points)
    }
  //---
    return menu
  }

  //····················································································································
  // Exchange symbol
  //····················································································································

  internal func canExchangeSymbol (at inUnalignedMouseDownPoint : CanariPoint) -> ComponentSymbolInProject? {
    var result : ComponentSymbolInProject? = nil
    let symbolsUnderMouse = self.schematicSymbols (at: inUnalignedMouseDownPoint)
    if symbolsUnderMouse.count == 1 {
      let symbolUnderMouse = symbolsUnderMouse [0]
      var n = 0
      for component in self.rootObject.mComponents {
        for symbol in component.mSymbols {
          if symbol.mSymbolTypeName == symbolUnderMouse.mSymbolTypeName {
            n += 1
          }
        }
      }
      if n > 1 {
        result = symbolUnderMouse
      }
    }
    return result
  }

  //····················································································································

  private func appendExchangeSymbolItemTo (menu : NSMenu, at inUnalignedMouseDownPoint : CanariPoint) {
    if let symbol = self.canExchangeSymbol (at: inUnalignedMouseDownPoint) {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      let menuItem = NSMenuItem (title: "Exchange Symbol…", action: #selector (CustomizedProjectDocument.exchangeSymbolAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = symbol
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func exchangeSymbolAction (_ inSender : NSMenuItem) {
    if let symbolUnderMouse = inSender.representedObject as? ComponentSymbolInProject {
      self.runExchangeDialog (forSymbol: symbolUnderMouse)
    }
  }

  //····················································································································

  internal func runExchangeDialog (forSymbol inSymbolUnderMouse : ComponentSymbolInProject) {
    var candidateSymbols = [ComponentSymbolInProject] ()
    for component in self.rootObject.mComponents {
      for symbol in component.mSymbols {
        if symbol.mSymbolTypeName == inSymbolUnderMouse.mSymbolTypeName {
          candidateSymbols.append (symbol)
        }
      }
    }
    if candidateSymbols.count > 1, let panel = self.mExchangeSymbolPanel, let popup = self.mExchangeSymbolPopUpButton {
      popup.removeAllItems ()
      for symbol in candidateSymbols {
        popup.addItem (withTitle: symbol.componentName! + ":" + symbol.mSymbolInstanceName)
        popup.lastItem?.representedObject = symbol
        if symbol === inSymbolUnderMouse {
          popup.select (popup.lastItem)
        }
      }
      self.windowForSheet?.beginSheet (panel) { (inModalResponse) in
        if inModalResponse == .stop,
             let candidateSymbol = popup.selectedItem?.representedObject as? ComponentSymbolInProject,
             candidateSymbol !== inSymbolUnderMouse {
          let symbolUnderMouseComponent = inSymbolUnderMouse.mComponent
          let symbolUnderMouseInstanceName = inSymbolUnderMouse.mSymbolInstanceName
          let candidateSymbolComponent = candidateSymbol.mComponent
          let candidateSymbolInstanceName = candidateSymbol.mSymbolInstanceName
          inSymbolUnderMouse.mComponent = candidateSymbolComponent
          inSymbolUnderMouse.mSymbolInstanceName = candidateSymbolInstanceName
          candidateSymbol.mComponent = symbolUnderMouseComponent
          candidateSymbol.mSymbolInstanceName = symbolUnderMouseInstanceName
        }
      }
    }
  }


  //····················································································································
  // Add NC to all unconnected pins
  //····················································································································

  internal func canAddNCToSymbolPins (at inUnalignedMouseDownPoint : CanariPoint) -> [ComponentSymbolInProject] {
    let symbolsUnderMouse = self.schematicSymbols (at: inUnalignedMouseDownPoint)
    var connectableSymbols = [ComponentSymbolInProject] ()
    for symbol in symbolsUnderMouse {
      for point in symbol.mPoints {
        if ((point.mLabels.count + point.mWiresP1s.count + point.mWiresP2s.count) == 0) && (point.mNC == nil) {
          connectableSymbols.append (symbol)
          break
        }
      }
    }
    return connectableSymbols
  }

  //····················································································································

  private func appendNCToAllUnconnectedSymbolPins (menu : NSMenu, at inUnalignedMouseDownPoint : CanariPoint) {
    let symbols = self.canAddNCToSymbolPins (at: inUnalignedMouseDownPoint)
    if symbols.count > 0 {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      let menuItem = NSMenuItem (title: "Add NC to All Unconnected Pins", action: #selector (CustomizedProjectDocument.addNCToUnconnectedSymbolPinsAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = symbols
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func addNCToUnconnectedSymbolPinsAction (_ inSender : NSMenuItem) {
    if let symbols = inSender.representedObject as? [ComponentSymbolInProject] {
      self.addNCToUnconnectedPins (ofSymbols: symbols)
    }
  }

  //····················································································································

  internal func addNCToUnconnectedPins (ofSymbols inSymbols : [ComponentSymbolInProject]) {
    if let selectedSheet = self.rootObject.mSelectedSheet {
      for symbol in inSymbols {
        for point in symbol.mPoints {
          _ = selectedSheet.addNCToPin (toPoint: point)
        }
      }
    }
  }

  //····················································································································
  // Disconnect all pins of symbols
  //····················································································································

  internal func canDisconnectAllSymbolPins (at inUnalignedMouseDownPoint : CanariPoint) -> [ComponentSymbolInProject] {
    let symbolsUnderMouse = self.schematicSymbols (at: inUnalignedMouseDownPoint)
    var disconnectableSymbols = [ComponentSymbolInProject] ()
    for symbol in symbolsUnderMouse {
      for point in symbol.mPoints {
        if (point.mNC != nil) || ((point.mLabels.count + point.mWiresP1s.count + point.mWiresP2s.count) > 0) {
          disconnectableSymbols.append (symbol)
          break
        }
      }
    }
    return disconnectableSymbols
  }

  //····················································································································

  private func appendDisconnectAllSymbolPins (menu : NSMenu, at inUnalignedMouseDownPoint : CanariPoint) {
    let symbols = self.canDisconnectAllSymbolPins (at: inUnalignedMouseDownPoint)
    if symbols.count > 0 {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      let menuItem = NSMenuItem (title: "Disconnect All Symbol Pins", action: #selector (CustomizedProjectDocument.disconnectAllSymbolPinsAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = symbols
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func disconnectAllSymbolPinsAction (_ inSender : NSMenuItem) {
    if let symbols = inSender.representedObject as? [ComponentSymbolInProject] {
      self.disconnectAllPins (ofSymbols: symbols)
    }
  }

  //····················································································································

  internal func disconnectAllPins (ofSymbols inSymbols : [ComponentSymbolInProject]) {
    for symbol in inSymbols {
      for point in symbol.mPoints {
        self.disconnectInSchematic (points: [point])
      }
    }
    self.updateSchematicsPointsAndNets ()
  }

  //····················································································································
  // Connect all pins of symbols
  //····················································································································

  internal func canConnectSymbolPins (at inUnalignedMouseDownPoint : CanariPoint) -> [ComponentSymbolInProject] {
    let symbolsUnderMouse = self.schematicSymbols (at: inUnalignedMouseDownPoint)
    var connectableSymbols = [ComponentSymbolInProject] ()
    if let selectedSheet = self.rootObject.mSelectedSheet {
      for symbol in symbolsUnderMouse {
        for point in symbol.mPoints {
          let allPointsAtAlignedMouseLocation = selectedSheet.pointsInSchematics (at: point.location!)
          if selectedSheet.canConnectWithoutDialog (points: allPointsAtAlignedMouseLocation) {
            connectableSymbols.append (symbol)
            break
          }
        }
      }
    }
    return connectableSymbols
  }

  //····················································································································

  private func schematicSymbols (at inUnalignedMouseDownPoint : CanariPoint) -> [ComponentSymbolInProject] {
    var result = [ComponentSymbolInProject] ()
    if let selectedSheet = self.rootObject.mSelectedSheet {
      for object in selectedSheet.mObjects {
        if let symbol = object as? ComponentSymbolInProject, let shape = symbol.objectDisplay {
          if shape.contains (point: inUnalignedMouseDownPoint.cocoaPoint) {
            result.append (symbol)
          }
        }
      }
    }
    return result
  }

  //····················································································································

  private func appendConnectSymbolPins (menu : NSMenu, at inUnalignedMouseDownPoint : CanariPoint) {
    let symbols = self.canConnectSymbolPins (at: inUnalignedMouseDownPoint)
    if symbols.count > 0 {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      let menuItem = NSMenuItem (title: "Connect Symbol Pins", action: #selector (CustomizedProjectDocument.connectSymbolPinsAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = symbols
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func connectSymbolPinsAction (_ inSender : NSMenuItem) {
    if let symbols = inSender.representedObject as? [ComponentSymbolInProject] {
      self.connectPins (ofSymbols: symbols)
    }
  }

  //····················································································································

  internal func connectPins (ofSymbols inSymbols : [ComponentSymbolInProject]) {
    if let selectedSheet = self.rootObject.mSelectedSheet {
      for symbol in inSymbols {
        for point in symbol.mPoints {
          let allPoints = selectedSheet.pointsInSchematics (at: point.location!)
          _ = selectedSheet.connectWithoutDialog (points: allPoints)
        }
      }
      self.updateSchematicsPointsAndNets ()
    }
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
        window: window,
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
      }else if point.mSymbol != nil {
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
      let possibleNC = selectedSheet.addNCToPin (toPoint: point)
      if let nc = possibleNC {
        self.schematicObjectsController.setSelection ([nc])
      }
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
      let menuItem = NSMenuItem (title: "Add Point to Wire", action: #selector (CustomizedProjectDocument.addPointToWireAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = (inCanariAlignedMouseDownLocation, inWires [0])
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func addPointToWireAction (_ inSender : NSMenuItem) {
    if let (location, wire) = inSender.representedObject as? (CanariPoint, WireInSchematic) {
      if let selectedSheet = self.rootObject.mSelectedSheet {
        _ = selectedSheet.self.addPoint (toWire: wire, at: location)
      }
    }
  }

  //····················································································································

  internal func addPointToWireInSchematic (at inUnalignedLocation : CanariPoint) {
    if let selectedSheet = self.rootObject.mSelectedSheet {
      _ = selectedSheet.addPointToWire (at: inUnalignedLocation)
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
                                         mouseDownLocation inAlignedMouseDownPoint : CanariPoint,
                                         points inPoints : [PointInSchematic]) {
    if self.canCreateLabels (points: inPoints) {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      var menuItem = NSMenuItem (title: "Add Label with right flag", action: #selector (CustomizedProjectDocument.addLabelInSchematicAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.tag = 0 // Right
      menuItem.representedObject = inAlignedMouseDownPoint
      menu.addItem (menuItem)
      menuItem = NSMenuItem (title: "Add Label with top flag", action: #selector (CustomizedProjectDocument.addLabelInSchematicAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.tag = 1 // Top
      menuItem.representedObject = inAlignedMouseDownPoint
      menu.addItem (menuItem)
      menuItem = NSMenuItem (title: "Add Label with left flag", action: #selector (CustomizedProjectDocument.addLabelInSchematicAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.tag = 2 // Left
      menuItem.representedObject = inAlignedMouseDownPoint
      menu.addItem (menuItem)
      menuItem = NSMenuItem (title: "Add Label with bottom flag", action: #selector (CustomizedProjectDocument.addLabelInSchematicAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.tag = 3 // Bottom
      menuItem.representedObject = inAlignedMouseDownPoint
      menu.addItem (menuItem)
    }
  }

  //····················································································································

  @objc private func addLabelInSchematicAction (_ inSender : NSMenuItem) {
    if let alignedMouseDownPoint = inSender.representedObject as? CanariPoint {
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
      self.addLabelInSchematic (at: alignedMouseDownPoint, orientation: orientation)
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
        self.schematicObjectsController.setSelection ([label])
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
