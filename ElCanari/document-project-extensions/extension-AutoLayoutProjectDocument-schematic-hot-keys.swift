//
//  FProjectDocument-schematic-hot-keys.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/05/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func color (forEnabledState inEnabled : Bool) -> NSColor {
    return inEnabled ? .black : .disabledControlTextColor
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func keyDownInSchematic (_ inUnalignedMouseLocation : NSPoint, _ inKey : UnicodeScalar) {
    if let selectedSheet = self.rootObject.mSelectedSheet {
      let canariUnalignedMouseDownLocation = inUnalignedMouseLocation.canariPoint
      let canariAlignedMouseDownLocation = canariUnalignedMouseDownLocation.point (alignedOnGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
      switch inKey {
      case UnicodeScalar ("A"), UnicodeScalar ("a") :
        let connectableSymbols = self.canConnectSymbolPins (at: canariUnalignedMouseDownLocation)
        if connectableSymbols.count > 0 {
          self.connectPins (ofSymbols: connectableSymbols)
        }
      case UnicodeScalar ("B"), UnicodeScalar ("b") :
        let points = selectedSheet.pointsInSchematics (at: canariAlignedMouseDownLocation)
        if self.canCreateLabels (points: points) {
          self.addLabelInSchematic (at: canariAlignedMouseDownLocation, orientation: .rotation270)
        }
      case UnicodeScalar ("C"), UnicodeScalar ("c") :
        let points = selectedSheet.pointsInSchematics (at: canariAlignedMouseDownLocation)
        let wires = selectedSheet.wiresStrictlyContaining (point: canariUnalignedMouseDownLocation)
        if self.canConnect (points: points, wires: wires) {
          self.connectInSchematic (points: points)
        }
      case UnicodeScalar ("D"), UnicodeScalar ("d") :
        let points = selectedSheet.pointsInSchematics (at: canariAlignedMouseDownLocation)
        if self.canDisconnect (points: points) {
          self.disconnectInSchematic (points: points)
        }
      case UnicodeScalar ("E"), UnicodeScalar ("e") :
        let disconnectableSymbols = self.canDisconnectAllSymbolPins (at: canariUnalignedMouseDownLocation)
        if disconnectableSymbols.count > 0 {
          self.disconnectAllPins (ofSymbols: disconnectableSymbols)
        }
      case UnicodeScalar ("F"), UnicodeScalar ("f") :
        let symbolsForAddingNCorLabel = self.canAddNCToSymbolPins (at: canariUnalignedMouseDownLocation)
        if symbolsForAddingNCorLabel.count > 0 {
          self.addLabelToUnconnectedPins (ofSymbols: symbolsForAddingNCorLabel)
        }
      case UnicodeScalar ("L"), UnicodeScalar ("l") :
        let points = selectedSheet.pointsInSchematics (at: canariAlignedMouseDownLocation)
        if self.canCreateLabels (points: points) {
          self.addLabelInSchematic (at: canariAlignedMouseDownLocation, orientation: .rotation180)
        }
      case UnicodeScalar ("M"), UnicodeScalar ("m") :
        let symbolsForAddingNCorLabel = self.canAddNCToSymbolPins (at: canariUnalignedMouseDownLocation)
        if symbolsForAddingNCorLabel.count > 0 {
          self.addNCToUnconnectedPins (ofSymbols: symbolsForAddingNCorLabel)
        }
      case UnicodeScalar ("N"), UnicodeScalar ("n") :
        let points = selectedSheet.pointsInSchematics (at: canariAlignedMouseDownLocation)
        if self.canCreateNC (points: points) {
          _ = selectedSheet.addNCToPin (toPoint: points [0])
        }
      case UnicodeScalar ("P"), UnicodeScalar ("p") :
       let points = selectedSheet.pointsInSchematics (at: canariAlignedMouseDownLocation)
       if self.canRemovePointFromWire (points: points) {
          self.removePointFromWireInSchematic (points: points)
        }
      case UnicodeScalar ("R"), UnicodeScalar ("r") :
       let points = selectedSheet.pointsInSchematics (at: canariAlignedMouseDownLocation)
       if self.canCreateLabels (points: points) {
          self.addLabelInSchematic (at: canariAlignedMouseDownLocation, orientation: .rotation0)
        }
      case UnicodeScalar ("T"), UnicodeScalar ("t") :
       let points = selectedSheet.pointsInSchematics (at: canariAlignedMouseDownLocation)
       if self.canCreateLabels (points: points) {
          self.addLabelInSchematic (at: canariAlignedMouseDownLocation, orientation: .rotation90)
        }
      case UnicodeScalar ("V"), UnicodeScalar ("v") :
        let symbolsUnderMouse = self.schematicSymbols (at: canariUnalignedMouseDownLocation)
        for symbol in symbolsUnderMouse {
          symbol.mDisplayComponentValue = !symbol.mDisplayComponentValue
        }
      case UnicodeScalar ("X"), UnicodeScalar ("x") :
        if let symbol = self.canExchangeSymbol (at: canariUnalignedMouseDownLocation) {
          self.runExchangeDialog (forSymbol: symbol)
        }
      case UnicodeScalar ("W"), UnicodeScalar ("w") :
        let wires = selectedSheet.wiresStrictlyContaining (point: canariUnalignedMouseDownLocation)
        if self.canCreateWirePoint (wires: wires) {
          self.addPointToWireInSchematic (at: canariUnalignedMouseDownLocation)
        }
      case _ :
        ()
      }
    }
  //--- For updating hot key labels
    self.mouseMovedOrFlagsChangedInSchematic (inUnalignedMouseLocation)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func mouseMovedOrFlagsChangedInSchematic (_ inUnalignedMouseLocation : NSPoint) {
    if let selectedSheet = self.rootObject.mSelectedSheet {
      let canariUnalignedMouseDownLocation = inUnalignedMouseLocation.canariPoint
      let canariAlignedMouseDownLocation = canariUnalignedMouseDownLocation.point (alignedOnGrid: SCHEMATIC_GRID_IN_CANARI_UNIT)
      let points = selectedSheet.pointsInSchematics (at: canariAlignedMouseDownLocation)
      let wires = selectedSheet.wiresStrictlyContaining (point: canariUnalignedMouseDownLocation)
    //--- Connect
      for outlet in self.mConnectSchematicHotKeyTextField.values {
        outlet.textColor = self.color (forEnabledState: self.canConnect (points: points, wires: wires))
      }
      for outlet in self.mConnectAllSymbolPinsSchematicHotKeyTextField.values {
        outlet.textColor = self.color (forEnabledState: self.canConnectSymbolPins (at: canariUnalignedMouseDownLocation).count > 0)
      }
    //--- Disconnect
      for outlet in self.mDisconnectSchematicHotKeyTextField.values {
        outlet.textColor = self.color (forEnabledState: self.canDisconnect (points: points))
      }
      for outlet in self.mDisconnectAllSymbolPinsSchematicHotKeyTextField.values {
        outlet.textColor = self.color (forEnabledState: self.canDisconnectAllSymbolPins (at: canariUnalignedMouseDownLocation).count > 0)
      }
    //--- Add Point to wire
      for outlet in self.mAddWirePointSchematicHotKeyTextField.values {
        outlet.textColor = self.color (forEnabledState: self.canCreateWirePoint (wires: wires))
      }
    //--- Remove Point from wire
      for outlet in self.mRemoveWirePointSchematicHotKeyTextField.values {
        outlet.textColor = self.color (forEnabledState: self.canRemovePointFromWire (points: points))
      }
    //--- Create label
      let createLabelTextColor = self.color (forEnabledState: self.canCreateLabels (points: points))
      for outlet in self.mAddLeftLabelSchematicHotKeyTextField.values {
        outlet.textColor = createLabelTextColor
      }
      for outlet in self.mAddRightLabelSchematicHotKeyTextField.values {
        outlet.textColor = createLabelTextColor
      }
      for outlet in self.mAddTopLabelSchematicHotKeyTextField.values {
        outlet.textColor = createLabelTextColor
      }
      for outlet in self.mAddBottomSchematicHotKeyTextField.values {
        outlet.textColor = createLabelTextColor
      }
    //--- Show / Hide symbol value
      let symbolsUnderMouse = self.schematicSymbols (at: canariUnalignedMouseDownLocation)
      for outlet in self.mShowHideSymbolValueSchematicHotKeyTextField.values {
        outlet.textColor = self.color (forEnabledState: symbolsUnderMouse.count > 0)
      }
    //--- Create NC
      for outlet in self.mAddNCSchematicHotKeyTextField.values {
        outlet.textColor = self.color (forEnabledState: self.canCreateNC (points: points))
      }
    //--- Create NC to all symbol pins
      for outlet in self.mAddNCToAllSymbolPinsSchematicHotKeyTextField.values {
        outlet.textColor = self.color (forEnabledState: self.canAddNCToSymbolPins (at: canariUnalignedMouseDownLocation).count > 0)
      }
    //--- Create Label to all symbol pins
      for outlet in self.mAddLabelToAllSymbolPinsSchematicHotKeyTextField.values {
        outlet.textColor = self.color (forEnabledState: self.canAddNCToSymbolPins (at: canariUnalignedMouseDownLocation).count > 0)
      }
    //--- Exchange symbol
      for outlet in self.mExchangeSymbolSchematicHotKeyTextField.values {
        outlet.textColor = self.color (forEnabledState: self.canExchangeSymbol (at: canariUnalignedMouseDownLocation) != nil)
      }
    }
  //---
    self.mBoardView?.mGraphicView.mOptionalFrontShape = nil
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func mouseExitInSchematic () {
  //--- Connect
    for outlet in self.mConnectSchematicHotKeyTextField.values {
      outlet.textColor = .disabledControlTextColor
    }
    for outlet in self.mConnectAllSymbolPinsSchematicHotKeyTextField.values {
      outlet.textColor = .disabledControlTextColor
    }
  //--- Disconnect
    for outlet in self.mDisconnectSchematicHotKeyTextField.values {
      outlet.textColor = .disabledControlTextColor
    }
    for outlet in self.mDisconnectAllSymbolPinsSchematicHotKeyTextField.values {
      outlet.textColor = .disabledControlTextColor
    }
  //--- Add Point to wire
    for outlet in self.mAddWirePointSchematicHotKeyTextField.values {
      outlet.textColor = .disabledControlTextColor
    }
  //--- Remove Point from wire
    for outlet in self.mRemoveWirePointSchematicHotKeyTextField.values {
      outlet.textColor = .disabledControlTextColor
    }
  //--- Create label
    for outlet in self.mAddLeftLabelSchematicHotKeyTextField.values {
      outlet.textColor = .disabledControlTextColor
    }
    for outlet in self.mAddRightLabelSchematicHotKeyTextField.values {
      outlet.textColor = .disabledControlTextColor
    }
    for outlet in self.mAddTopLabelSchematicHotKeyTextField.values {
      outlet.textColor = .disabledControlTextColor
    }
    for outlet in self.mAddBottomSchematicHotKeyTextField.values {
      outlet.textColor = .disabledControlTextColor
    }
  //--- Create NC
    for outlet in self.mAddNCSchematicHotKeyTextField.values {
      outlet.textColor = .disabledControlTextColor
    }
    for outlet in self.mAddNCToAllSymbolPinsSchematicHotKeyTextField.values {
      outlet.textColor = .disabledControlTextColor
    }
  //--- Create Label to all symbol pins
    for outlet in self.mAddLabelToAllSymbolPinsSchematicHotKeyTextField.values {
      outlet.textColor = .disabledControlTextColor
    }
  //--- Exchange symbol
    for outlet in self.mExchangeSymbolSchematicHotKeyTextField.values {
      outlet.textColor = .disabledControlTextColor
    }
  //--- Show / Hide component value
    for outlet in self.mShowHideSymbolValueSchematicHotKeyTextField.values {
      outlet.textColor = .disabledControlTextColor
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
