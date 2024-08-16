//
//  ProjectDocument-customized-contextual-click.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 05/05/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func populateContextualClickOnSchematics (_ inUnalignedMouseDownPoint : CanariPoint) -> NSMenu? {
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
      self.appendCreateConnectItemTo (menu: menu, points: points, wires: wires)
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Exchange symbol
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canExchangeSymbol (at inUnalignedMouseDownPoint : CanariPoint) -> ComponentSymbolInProject? {
    var result : ComponentSymbolInProject? = nil
    let symbolsUnderMouse = self.schematicSymbols (at: inUnalignedMouseDownPoint)
    if symbolsUnderMouse.count == 1 {
      let symbolUnderMouse = symbolsUnderMouse [0]
      var n = 0
      for component in self.rootObject.mComponents.values {
        for symbol in component.mSymbols.values {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendExchangeSymbolItemTo (menu : NSMenu, at inUnalignedMouseDownPoint : CanariPoint) {
    if let symbol = self.canExchangeSymbol (at: inUnalignedMouseDownPoint) {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      let menuItem = NSMenuItem (title: "Exchange Symbol…", action: #selector (Self.exchangeSymbolAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = symbol
      menu.addItem (menuItem)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func exchangeSymbolAction (_ inSender : NSMenuItem) {
    if let symbolUnderMouse = inSender.representedObject as? ComponentSymbolInProject {
      self.runExchangeDialog (forSymbol: symbolUnderMouse)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func runExchangeDialog (forSymbol inSymbolUnderMouse : ComponentSymbolInProject) {
    var candidateSymbols = [ComponentSymbolInProject] ()
    for component in self.rootObject.mComponents.values {
      for symbol in component.mSymbols.values {
        if symbol.mSymbolTypeName == inSymbolUnderMouse.mSymbolTypeName {
          candidateSymbols.append (symbol)
        }
      }
    }
    if candidateSymbols.count > 1 {
      let panel = NSPanel (
        contentRect: NSRect (x: 0, y: 0, width: 500, height: 200),
        styleMask: [.titled],
        backing: .buffered,
        defer: false
      )
    //---
      let layoutView = AutoLayoutVerticalStackView ().set (margins: 20)
    //---
      let currentSymbolName = inSymbolUnderMouse.componentName! + ":" + inSymbolUnderMouse.mSymbolInstanceName
      _ = layoutView.appendViewSurroundedByFlexibleSpaces (AutoLayoutStaticLabel (title: "Exchange '\(currentSymbolName)' symbol with…", bold: true, size: .regular, alignment: .center))
    //---
      let popUpButton = ALB_NSPopUpButton (pullsDown: false, size: .regular).expandableWidth ()
      _ = layoutView.appendFlexibleSpace ()
      _ = layoutView.appendView (popUpButton)
      _ = layoutView.appendFlexibleSpace ()
    //---
      popUpButton.removeAllItems ()
      for symbol in candidateSymbols {
        if symbol !== inSymbolUnderMouse {
         let symbolName = symbol.componentName! + ":" + symbol.mSymbolInstanceName
         popUpButton.addItem (withTitle: symbolName)
          popUpButton.lastItem?.representedObject = symbol
        }
      }
    //---
      do{
        let hStack = AutoLayoutHorizontalStackView ()
        _ = hStack.appendView (AutoLayoutSheetCancelButton (title: "Cancel", size: .regular))
        _ = hStack.appendFlexibleSpace ()
        let okButton = AutoLayoutSheetDefaultOkButton (title: "Exchange", size: .regular, sheet: panel)
        _ = hStack.appendView (okButton)
        _ = layoutView.appendView (hStack)
      }
    //---
      panel.contentView = AutoLayoutWindowContentView (view: AutoLayoutViewByPrefixingAppIcon (prefixedView: layoutView))
      self.windowForSheet?.beginSheet (panel) { (inModalResponse) in
        if inModalResponse == .stop,
             let candidateSymbol = popUpButton.selectedItem?.representedObject as? ComponentSymbolInProject,
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Add NC, Label to all unconnected pins
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canAddNCToSymbolPins (at inUnalignedMouseDownPoint : CanariPoint) -> [ComponentSymbolInProject] {
    let symbolsUnderMouse = self.schematicSymbols (at: inUnalignedMouseDownPoint)
    var connectableSymbols = [ComponentSymbolInProject] ()
    for symbol in symbolsUnderMouse {
      for point in symbol.mPoints.values {
        if ((point.mLabels.count + point.mWiresP1s.count + point.mWiresP2s.count) == 0) && (point.mNC == nil) {
          connectableSymbols.append (symbol)
          break
        }
      }
    }
    return connectableSymbols
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendNCToAllUnconnectedSymbolPins (menu : NSMenu, at inUnalignedMouseDownPoint : CanariPoint) {
    let symbols = self.canAddNCToSymbolPins (at: inUnalignedMouseDownPoint)
    if symbols.count > 0 {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      var menuItem = NSMenuItem (
        title: "Add NC to All Unconnected Pins",
        action: #selector (Self.addNCToUnconnectedSymbolPinsAction (_:)),
        keyEquivalent: ""
      )
      menuItem.target = self
      menuItem.representedObject = symbols
      menu.addItem (menuItem)
      menuItem = NSMenuItem (
        title: "Add a Label to All Unconnected Pins",
        action: #selector (Self.addLabelToUnconnectedSymbolPinsAction (_:)),
        keyEquivalent: ""
      )
      menuItem.target = self
      menuItem.representedObject = symbols
      menu.addItem (menuItem)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func addNCToUnconnectedSymbolPinsAction (_ inSender : NSMenuItem) {
    if let symbols = inSender.representedObject as? [ComponentSymbolInProject] {
      self.addNCToUnconnectedPins (ofSymbols: symbols)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func addLabelToUnconnectedSymbolPinsAction (_ inSender : NSMenuItem) {
    if let symbols = inSender.representedObject as? [ComponentSymbolInProject] {
      self.addLabelToUnconnectedPins (ofSymbols: symbols)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addNCToUnconnectedPins (ofSymbols inSymbols : [ComponentSymbolInProject]) {
    if let selectedSheet = self.rootObject.mSelectedSheet {
      for symbol in inSymbols {
        for point in symbol.mPoints.values {
          _ = selectedSheet.addNCToPin (toPoint: point)
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addLabelToUnconnectedPins (ofSymbols inSymbols : [ComponentSymbolInProject]) {
    if let selectedSheet = self.rootObject.mSelectedSheet {
      for symbol in inSymbols {
        for point in symbol.mPoints.values {
          _ = selectedSheet.addLabelToPin (toPoint: point, newNetCreator: self.rootObject.createNetWithAutomaticName)
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Disconnect all pins of symbols
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canDisconnectAllSymbolPins (at inUnalignedMouseDownPoint : CanariPoint) -> [ComponentSymbolInProject] {
    let symbolsUnderMouse = self.schematicSymbols (at: inUnalignedMouseDownPoint)
    var disconnectableSymbols = [ComponentSymbolInProject] ()
    for symbol in symbolsUnderMouse {
      for point in symbol.mPoints.values {
        if (point.mNC != nil) || ((point.mLabels.count + point.mWiresP1s.count + point.mWiresP2s.count) > 0) {
          disconnectableSymbols.append (symbol)
          break
        }
      }
    }
    return disconnectableSymbols
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendDisconnectAllSymbolPins (menu : NSMenu, at inUnalignedMouseDownPoint : CanariPoint) {
    let symbols = self.canDisconnectAllSymbolPins (at: inUnalignedMouseDownPoint)
    if symbols.count > 0 {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      let menuItem = NSMenuItem (title: "Disconnect All Symbol Pins", action: #selector (Self.disconnectAllSymbolPinsAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = symbols
      menu.addItem (menuItem)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func disconnectAllSymbolPinsAction (_ inSender : NSMenuItem) {
    if let symbols = inSender.representedObject as? [ComponentSymbolInProject] {
      self.disconnectAllPins (ofSymbols: symbols)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func disconnectAllPins (ofSymbols inSymbols : [ComponentSymbolInProject]) {
    for symbol in inSymbols {
      for point in symbol.mPoints.values {
        self.disconnectInSchematic (points: [point])
      }
    }
    self.updateSchematicPointsAndNets ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Connect all pins of symbols
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canConnectSymbolPins (at inUnalignedMouseDownPoint : CanariPoint) -> [ComponentSymbolInProject] {
    let symbolsUnderMouse = self.schematicSymbols (at: inUnalignedMouseDownPoint)
    var connectableSymbols = [ComponentSymbolInProject] ()
    if let selectedSheet = self.rootObject.mSelectedSheet {
      for symbol in symbolsUnderMouse {
        for point in symbol.mPoints.values {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func schematicSymbols (at inUnalignedMouseDownPoint : CanariPoint) -> [ComponentSymbolInProject] {
    var result = [ComponentSymbolInProject] ()
    if let selectedSheet = self.rootObject.mSelectedSheet {
      for object in selectedSheet.mObjects.values {
        if let symbol = object as? ComponentSymbolInProject, let shape = symbol.objectDisplay {
          if shape.contains (point: inUnalignedMouseDownPoint.cocoaPoint) {
            result.append (symbol)
          }
        }
      }
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendConnectSymbolPins (menu : NSMenu, at inUnalignedMouseDownPoint : CanariPoint) {
    let symbols = self.canConnectSymbolPins (at: inUnalignedMouseDownPoint)
    if symbols.count > 0 {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      let menuItem = NSMenuItem (title: "Connect Symbol Pins", action: #selector (Self.connectSymbolPinsAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = symbols
      menu.addItem (menuItem)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func connectSymbolPinsAction (_ inSender : NSMenuItem) {
    if let symbols = inSender.representedObject as? [ComponentSymbolInProject] {
      self.connectPins (ofSymbols: symbols)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func connectPins (ofSymbols inSymbols : [ComponentSymbolInProject]) {
    if let selectedSheet = self.rootObject.mSelectedSheet {
      for symbol in inSymbols {
        for point in symbol.mPoints.values {
          let allPoints = selectedSheet.pointsInSchematics (at: point.location!)
          _ = selectedSheet.tryToConnectWithoutDialog (
            points: allPoints,
            updateSchematicPointsAndNets: { self.updateSchematicPointsAndNets () }
          )
        }
      }
      self.updateSchematicPointsAndNets ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Connect
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canConnect (points inPoints : [PointInSchematic], wires inWires : [WireInSchematic]) -> Bool {
    // Swift.print ("inPoints \(inPoints.count) inWires \(inWires.count)")
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
    }else if (inPoints.count == 1) && (inWires.count > 0) {
      canConnect = inPoints [0].mNC == nil
    }
    return canConnect
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendCreateConnectItemTo (menu : NSMenu, points inPoints : [PointInSchematic], wires inWires : [WireInSchematic]) {
    if self.canConnect (points: inPoints, wires: inWires) {
      var netSet = EBReferenceSet <NetInProject> ()
      for p in inPoints {
        if let net = p.mNet {
          netSet.insert (net)
        }
      }
      for w in inWires {
        if let net = w.mP1?.mNet {
          netSet.insert (net)
        }
      }
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      let menuItem = NSMenuItem (
        title: (netSet.count > 1) ? "Connect…" : "Connect",
        action: #selector (Self.connectAction (_:)),
        keyEquivalent: ""
      )
      menuItem.target = self
      menuItem.representedObject = inPoints
      menu.addItem (menuItem)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func connectAction (_ inSender : NSMenuItem) {
    if let points = inSender.representedObject as? [PointInSchematic] {
      self.connectInSchematic (points: points)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func connectInSchematic (points inPoints : [PointInSchematic]) {
    if let selectedSheet = self.rootObject.mSelectedSheet,
       let window = self.windowForSheet {
      selectedSheet.connect (
        points: inPoints,
        window: window,
        newNetCreator: self.rootObject.createNetWithAutomaticName,
        updateSchematicPointsAndNets: { self.updateSchematicPointsAndNets () }
      )
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Disconnect
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canDisconnect (points inPoints : [PointInSchematic]) -> Bool {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendDisconnectItemTo (menu : NSMenu, points inPoints : [PointInSchematic]) {
    if self.canDisconnect (points: inPoints) {
      let menuItem = NSMenuItem (title: "Disconnect", action: #selector (Self.disconnectAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = inPoints
      menu.addItem (menuItem)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func disconnectAction (_ inSender : NSMenuItem) {
    if let points = inSender.representedObject as? [PointInSchematic] {
      self.disconnectInSchematic (points: points)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func disconnectInSchematic (points inPoints : [PointInSchematic]) {
    if let selectedSheet = self.rootObject.mSelectedSheet {
      selectedSheet.disconnect (points: inPoints)
      self.updateSchematicPointsAndNets ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Remove Point From Wire
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRemovePointFromWire (points inPoints : [PointInSchematic]) -> Bool {
    var canRemove = false
    if inPoints.count == 1 {
      let point = inPoints [0]
      if point.mNC == nil, point.mLabels.count == 0, (point.mWiresP1s.count + point.mWiresP2s.count) == 2 {
        canRemove = true
      }
    }
    return canRemove
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendRemovePointFromWireItemTo (menu : NSMenu, points inPoints : [PointInSchematic]) {
    if self.canRemovePointFromWire (points: inPoints) {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      let menuItem = NSMenuItem (title: "Remove Point from Wire", action: #selector (Self.removePointFromWireAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = inPoints [0]
      menu.addItem (menuItem)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func removePointFromWireAction (_ inSender : NSMenuItem) {
    if let point = inSender.representedObject as? PointInSchematic {
      self.removePointFromWireInSchematic (points: [point])
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func removePointFromWireInSchematic (points inPoints : [PointInSchematic]) {
    if let selectedSheet = self.rootObject.mSelectedSheet, inPoints.count == 1 {
      selectedSheet.removeFromWire (point: inPoints [0])
      self.updateSchematicPointsAndNets ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // NC
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canCreateNC (points inPoints : [PointInSchematic]) -> Bool {
    var canCreate = false
    if inPoints.count == 1 {
      let point = inPoints [0]
      if point.mNC == nil, point.mLabels.count == 0, point.mWiresP1s.count == 0, point.mWiresP2s.count == 0 {
        canCreate = true
      }
    }
    return canCreate
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendCreateNCItemTo (menu : NSMenu, points inPoints : [PointInSchematic]) {
    if self.canCreateNC (points: inPoints) {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      let menuItem = NSMenuItem (title: "Add NC", action: #selector (Self.addNCToPinAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = inPoints [0]
      menu.addItem (menuItem)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func addNCToPinAction (_ inSender : NSMenuItem) {
    if let point = inSender.representedObject as? PointInSchematic, let selectedSheet = self.rootObject.mSelectedSheet {
      let possibleNC = selectedSheet.addNCToPin (toPoint: point)
      if let nc = possibleNC {
        self.schematicObjectsController.setSelection ([nc])
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Insert point into wire
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canCreateWirePoint (wires inWires : [WireInSchematic]) -> Bool {
    return inWires.count == 1
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendCreateWirePointItemTo (menu : NSMenu, _ inCanariAlignedMouseDownLocation : CanariPoint, wires inWires : [WireInSchematic]) {
    if self.canCreateWirePoint (wires: inWires) {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      let menuItem = NSMenuItem (title: "Add Point to Wire", action: #selector (Self.addPointToWireAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.representedObject = (inCanariAlignedMouseDownLocation, inWires [0])
      menu.addItem (menuItem)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func addPointToWireAction (_ inSender : NSMenuItem) {
    if let (location, wire) = inSender.representedObject as? (CanariPoint, WireInSchematic) {
      if let selectedSheet = self.rootObject.mSelectedSheet {
        _ = selectedSheet.self.addPoint (toWire: wire, at: location)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addPointToWireInSchematic (at inUnalignedLocation : CanariPoint) {
    if let selectedSheet = self.rootObject.mSelectedSheet {
      _ = selectedSheet.addPointToWire (at: inUnalignedLocation)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Labels
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canCreateLabels (points inPoints : [PointInSchematic]) -> Bool {
  //--- Check points have no label, and are not "nc"
    var canCreate = true
    for p in inPoints {
      if (p.mLabels.count > 0) || (p.mNC != nil) {
        canCreate = false
        break
      }
    }
    return canCreate
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func appendCreateLabelsItemTo (menu : NSMenu,
                                         mouseDownLocation inAlignedMouseDownPoint : CanariPoint,
                                         points inPoints : [PointInSchematic]) {
    if self.canCreateLabels (points: inPoints) {
      if menu.numberOfItems > 0 {
        menu.addItem (.separator ())
      }
      var menuItem = NSMenuItem (title: "Add Label with right flag", action: #selector (Self.addLabelInSchematicAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.tag = 0 // Right
      menuItem.representedObject = inAlignedMouseDownPoint
      menu.addItem (menuItem)
      menuItem = NSMenuItem (title: "Add Label with top flag", action: #selector (Self.addLabelInSchematicAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.tag = 1 // Top
      menuItem.representedObject = inAlignedMouseDownPoint
      menu.addItem (menuItem)
      menuItem = NSMenuItem (title: "Add Label with left flag", action: #selector (Self.addLabelInSchematicAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.tag = 2 // Left
      menuItem.representedObject = inAlignedMouseDownPoint
      menu.addItem (menuItem)
      menuItem = NSMenuItem (title: "Add Label with bottom flag", action: #selector (Self.addLabelInSchematicAction (_:)), keyEquivalent: "")
      menuItem.target = self
      menuItem.tag = 3 // Bottom
      menuItem.representedObject = inAlignedMouseDownPoint
      menu.addItem (menuItem)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addLabelInSchematic (at inLocation : CanariPoint, orientation inOrientation : QuadrantRotation) {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
