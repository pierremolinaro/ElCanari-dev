//
//  FProjectDocument-schematic-hot-keys.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································

  fileprivate func color (_ inEnabled : Bool) -> NSColor {
    return inEnabled ? .black : .disabledControlTextColor
  }

  //····················································································································

  internal func mouseMovedInSchematic (_ inMouseLocation : NSPoint) {
    if let selectedSheet = self.rootObject.mSelectedSheet {
      let canariMouseDownLocation = inMouseLocation.canariPoint
      let canariAlignedMouseDownLocation = canariMouseDownLocation.point (alignedOnGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
      let points = selectedSheet.pointsInSchematics (at: canariAlignedMouseDownLocation)
    //--- Connect
      self.mConnectSchematicHotKeyTextField?.textColor = self.color (self.canConnect (points: points))
      self.mConnectAllSymbolPinsSchematicHotKeyTextField?.textColor = self.color (self.canConnectSymbolPins (at: canariMouseDownLocation).count > 0)
    //--- Disconnect
      self.mDisconnectSchematicHotKeyTextField?.textColor = self.color (self.canDisconnect (points: points))
      self.mDisconnectAllSymbolPinsSchematicHotKeyTextField?.textColor = self.color (self.canDisconnectAllSymbolPins (at: canariMouseDownLocation).count > 0)
    //--- Add Point to wire
      let wires = selectedSheet.wiresStrictlyContaining (point: canariMouseDownLocation)
      self.mAddWirePointSchematicHotKeyTextField?.textColor = self.color (self.canCreateWirePoint (wires: wires))
    //--- Remove Point from wire
      self.mRemoveWirePointSchematicHotKeyTextField?.textColor = self.color (self.canRemovePointFromWire (points: points))
    //--- Create label
      let createLabelTextColor = self.color (self.canCreateLabels (points: points))
      self.mAddLeftLabelSchematicHotKeyTextField?.textColor = createLabelTextColor
      self.mAddRightLabelSchematicHotKeyTextField?.textColor = createLabelTextColor
      self.mAddTopLabelSchematicHotKeyTextField?.textColor = createLabelTextColor
      self.mAddBottomSchematicHotKeyTextField?.textColor = createLabelTextColor
    //--- Create NC
      self.mAddNCSchematicHotKeyTextField?.textColor = self.color (self.canCreateNC (points: points))
      self.mAddNCToAllSymbolPinsSchematicHotKeyTextField?.textColor = self.color (self.canAddNCToSymbolPins (at: canariMouseDownLocation).count > 0)
    }
  }

  //····················································································································

  internal func mouseExitInSchematic () {
  //--- Connect
    self.mConnectSchematicHotKeyTextField?.textColor = .disabledControlTextColor
    self.mConnectAllSymbolPinsSchematicHotKeyTextField?.textColor = .disabledControlTextColor
  //--- Disconnect
    self.mDisconnectSchematicHotKeyTextField?.textColor = .disabledControlTextColor
    self.mDisconnectAllSymbolPinsSchematicHotKeyTextField?.textColor = .disabledControlTextColor
  //--- Add Point to wire
    self.mAddWirePointSchematicHotKeyTextField?.textColor = .disabledControlTextColor
  //--- Remove Point from wire
    self.mRemoveWirePointSchematicHotKeyTextField?.textColor = .disabledControlTextColor
  //--- Create label
    self.mAddLeftLabelSchematicHotKeyTextField?.textColor = .disabledControlTextColor
    self.mAddRightLabelSchematicHotKeyTextField?.textColor = .disabledControlTextColor
    self.mAddTopLabelSchematicHotKeyTextField?.textColor = .disabledControlTextColor
    self.mAddBottomSchematicHotKeyTextField?.textColor = .disabledControlTextColor
  //--- Create NC
    self.mAddNCSchematicHotKeyTextField?.textColor = .disabledControlTextColor
    self.mAddNCToAllSymbolPinsSchematicHotKeyTextField?.textColor = .disabledControlTextColor
  }

  //····················································································································

  internal func keyDownInSchematic (_ inUnalignedMouseLocation : NSPoint, _ inKey : UnicodeScalar) {
    if let selectedSheet = self.rootObject.mSelectedSheet {
      let canariUnalignedMouseDownLocation = inUnalignedMouseLocation.canariPoint
      let canariAlignedMouseDownLocation = canariUnalignedMouseDownLocation.point (alignedOnGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
      let points = selectedSheet.pointsInSchematics (at: canariAlignedMouseDownLocation)
      let wires = selectedSheet.wiresStrictlyContaining (point: canariUnalignedMouseDownLocation)
    //--- Connect
      let connectableSymbols = self.canConnectSymbolPins (at: canariUnalignedMouseDownLocation)
      if ((inKey == UnicodeScalar ("A")) || (inKey == UnicodeScalar ("a"))) && (connectableSymbols.count > 0) {
        self.connectPins (ofSymbols: connectableSymbols)
      }
      if ((inKey == UnicodeScalar ("C")) || (inKey == UnicodeScalar ("c"))) && self.canConnect (points: points) {
        self.connectInSchematic (points: points)
      }
    //--- Disconnect
      if ((inKey == UnicodeScalar ("D")) || (inKey == UnicodeScalar ("d"))) && self.canDisconnect (points: points) {
        self.disconnectInSchematic (points: points)
      }
      let disconnectableSymbols = self.canDisconnectAllSymbolPins (at: canariUnalignedMouseDownLocation)
      if ((inKey == UnicodeScalar ("E")) || (inKey == UnicodeScalar ("e"))) && (disconnectableSymbols.count > 0) {
        self.disconnectAllPins (ofSymbols: disconnectableSymbols)
      }
    //--- Add Point to wire
      if ((inKey == UnicodeScalar ("W")) || (inKey == UnicodeScalar ("w"))) && self.canCreateWirePoint (wires: wires) {
        self.addPointToWireInSchematic (at: canariUnalignedMouseDownLocation)
      }
    //--- Remove Point from wire
      if ((inKey == UnicodeScalar ("P")) || (inKey == UnicodeScalar ("p"))) && self.canRemovePointFromWire (points: points) {
        self.removePointFromWireInSchematic (points: points)
      }
    //--- Create label
      if self.canCreateLabels (points: points) {
        if (inKey == UnicodeScalar ("L")) || (inKey == UnicodeScalar ("l")) {
          self.addLabelInSchematic (at: canariAlignedMouseDownLocation, orientation: .rotation180)
        }else if (inKey == UnicodeScalar ("R")) || (inKey == UnicodeScalar ("r")) {
          self.addLabelInSchematic (at: canariAlignedMouseDownLocation, orientation: .rotation0)
        }else if (inKey == UnicodeScalar ("B")) || (inKey == UnicodeScalar ("b")) {
          self.addLabelInSchematic (at: canariAlignedMouseDownLocation, orientation: .rotation270)
        }else if (inKey == UnicodeScalar ("T")) || (inKey == UnicodeScalar ("t")) {
          self.addLabelInSchematic (at: canariAlignedMouseDownLocation, orientation: .rotation90)
        }
      }
    //--- Create NC
      if ((inKey == UnicodeScalar ("N")) || (inKey == UnicodeScalar ("n"))) && self.canCreateNC (points: points) {
        _ = selectedSheet.addNCToPin (toPoint: points [0])
        // self.schematicObjectsController.setSelection ([nc])
      }
      let symbolsForAddingNS = self.canAddNCToSymbolPins (at: canariUnalignedMouseDownLocation)
      if ((inKey == UnicodeScalar ("M")) || (inKey == UnicodeScalar ("m"))) && (symbolsForAddingNS.count > 0) {
        self.addNCToUnconnectedPins (ofSymbols: symbolsForAddingNS)
      }
    }
  //--- For updating hot key labels
    self.mouseMovedInSchematic (inUnalignedMouseLocation)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
