//
//  ProjectDocument-customized-nets.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument : NSTextFieldDelegate {

  //····················································································································
  //  User actions
  //····················································································································

  @IBAction func renameNetAction (_ sender : NSObject?) { // Bound in IB
    if let netInfoTableView = self.mNetInfoTableView {
      let idx = netInfoTableView.selectedRow
      if idx >= 0 {
        let netInfo = netInfoTableView.object (at: idx)
        let netName = netInfo.netName
        self.dialogForRenamingNet (named: netName)
      }
    }
  }

  //····················································································································
  //  SELECTED WIRE NET ACTIONS
  //····················································································································

  @IBAction func renameNetFromSelectedWireAction (_ sender : NSObject?) { // Bound in IB
     let selectedWires = self.wireInSchematicSelectionController.selectedArray
     if selectedWires.count == 1, let net = selectedWires [0].mP1?.mNet {
       self.dialogForRenaming (net: net)
     }
  }

  //····················································································································

  @IBAction func newAutomaticNetNameFromSelectedWireAction (_ sender : NSObject?) { // Bound in IB
     var netSet = EBReferenceSet <NetInProject> ()
     for wire in self.wireInSchematicSelectionController.selectedArray.values {
       if let net = wire.mP1?.mNet {
         netSet.insert (net)
       }
     }
     for net in netSet.values {
       net.mNetName = self.rootObject.findUniqueNetName ()
     }
     self.updateSchematicPointsAndNets ()
  }

  //····················································································································

  @IBAction func mergeSubnetIntoExistingNetFromSelectedWireAction (_ sender : NSObject?) { // Bound in IB
    let selectedWires = self.wireInSchematicSelectionController.selectedArray
    if selectedWires.count == 1, let point = selectedWires [0].mP1 {
      self.dialogForMergingSubnetFrom (point: point)
      self.updateSchematicPointsAndNets ()
    }
  }

  //····················································································································

  @IBAction func insulateSubnetFromCurrentNetFromSelectedWireAction (_ sender : NSObject?) { // Bound in IB
    let selectedWires = self.wireInSchematicSelectionController.selectedArray
    if selectedWires.count == 1, let point = selectedWires [0].mP1 {
      let newNet = self.rootObject.createNetWithAutomaticName ()
      point.mNet = newNet
      point.propagateNetToAccessiblePointsThroughtWires ()
      self.updateSchematicPointsAndNets ()
    }
  }

  //····················································································································
  //  SELECTED LABEL NET ACTIONS
  //····················································································································

  @IBAction func renameNetFromSelectedLabelAction (_ sender : NSObject?) { // Bound in IB
     let selectedLabels = self.schematicLabelSelectionController.selectedArray
     if selectedLabels.count == 1, let net = selectedLabels.values [0].mPoint?.mNet {
       self.dialogForRenaming (net: net)
     }
  }

  //····················································································································

  @IBAction func newAutomaticNetNameFromSelectedLabelAction (_ sender : NSObject?) { // Bound in IB
     var netSet = EBReferenceSet <NetInProject> ()
     for label in self.schematicLabelSelectionController.selectedArray.values {
       if let net = label.mPoint?.mNet {
         netSet.insert (net)
       }
     }
     for net in netSet.values {
       net.mNetName = self.rootObject.findUniqueNetName ()
     }
    self.updateSchematicPointsAndNets ()
  }

  //····················································································································

  @IBAction func mergeSubnetIntoExistingNetFromSelectedLabelAction (_ sender : NSObject?) { // Bound in IB
    let selectedLabels = self.schematicLabelSelectionController.selectedArray
    if selectedLabels.count == 1 {
      let label = selectedLabels [0]
      let point = label.mPoint!
      self.dialogForMergingSubnetFrom (point: point)
    }
  }

  //····················································································································

  @IBAction func insulateSubnetFromCurrentNetFromSelectedLabelAction (_ sender : NSObject?) { // Bound in IB
    let selectedLabels = self.schematicLabelSelectionController.selectedArray
    if selectedLabels.count == 1 {
      let label = selectedLabels [0]
      let point = label.mPoint!
      let newNet = self.rootObject.createNetWithAutomaticName ()
      point.mNet = newNet
      point.propagateNetToAccessiblePointsThroughtWires ()
      self.updateSchematicPointsAndNets ()
    }
  }

  //····················································································································
  // Remove unused nets
  //····················································································································

  internal func removeUnusedNets () {
    for netClass in self.rootObject.mNetClasses.values {
      for net in netClass.mNets.values {
        var suppressNet = true
        for point in net.mPoints.values {
          if point.mSheet != nil {
            suppressNet = false
          }else{ // Suppress point
            point.mNet = nil
            point.mWiresP1s = EBReferenceArray ()
            point.mWiresP2s = EBReferenceArray ()
          }
        }
        for tracks in net.mTracks.values {
          if tracks.mRoot != nil {
            suppressNet = false
            break
          }
        }
        if suppressNet {
          net.mPoints = EBReferenceArray ()
          net.mTracks = EBReferenceArray ()
          net.mNetClass = nil
        }
      }
    }
  }

  //····················································································································
  // Update Selected Net for Rasnet net display
  //····················································································································

  internal func updateSelectedNetForRastnetDisplay () {
    var netNameSet = Set <String> ()
    for netClass in self.rootObject.mNetClasses.values {
      for net in netClass.mNets.values {
        netNameSet.insert (net.mNetName)
      }
    }
    if netNameSet.count == 0 {
      self.rootObject.mRastnetDisplayedNetName = ""
    }else if !netNameSet.contains (self.rootObject.mRastnetDisplayedNetName) {
      self.rootObject.mRastnetDisplayedNetName = netNameSet.first!
    }
  }

  //····················································································································
  //  Rename net dialog
  //····················································································································

  internal func dialogForRenamingNet (named inNetName : String) {
//    NSLog ("inNetName \(inNetName)")
  //--- Find net from its name
    var possibleNetForRenamingOperation : NetInProject? = nil
    for netClass in self.rootObject.mNetClasses.values {
      for net in netClass.mNets.values {
        if net.mNetName == inNetName {
          possibleNetForRenamingOperation = net
        }
      }
    }
  //--- Edit net
    if let net = possibleNetForRenamingOperation {
      self.dialogForRenaming (net: net)
    }
  }

  //····················································································································

  internal func dialogForRenaming (net inNet : NetInProject) {
    if let window = self.windowForSheet {
      let panel = NSPanel (
        contentRect: NSRect (x: 0, y: 0, width: 500, height: 200),
        styleMask: [.titled],
        backing: .buffered,
        defer: false
      )
    //---
      let layoutView = AutoLayoutVerticalStackView ().set (margins: 20)
      let okButton = AutoLayoutSheetDefaultOkButton (title: "", size: .regular, sheet: panel, isInitialFirstResponder: true)
      let gridView = AutoLayoutGridView2 ()
    //---
      layoutView.appendViewSurroundedByFlexibleSpaces (AutoLayoutStaticLabel (title: "Rename Net", bold: true, size: .regular))
      layoutView.appendFlexibleSpace ()
    //---
      do{
        let left = AutoLayoutStaticLabel (title: "Current Net Name", bold: false, size: .regular).set (alignment: .right)
        let right = AutoLayoutStaticLabel (title: inNet.mNetName, bold: true, size: .regular).set (alignment: .left)
        _ = gridView.addFirstBaseLineAligned (left: left, right: right)
      }
      let newNameTextField = AutoLayoutTextField (minWidth: 200, size: .regular).expandableWidth().set (alignment: .left)
      do{
        let left = AutoLayoutStaticLabel (title: "New Net Name", bold: false, size: .regular).set (alignment: .right)
        _ = gridView.addFirstBaseLineAligned (left: left, right: newNameTextField)
      }
      let errorLabel = AutoLayoutStaticLabel (title: "", bold: true, size: .regular).set (alignment: .right)
         .setRedTextColor ().expandableWidth()
      _ = gridView.add (single: errorLabel)
      layoutView.appendView (gridView)
      layoutView.appendFlexibleSpace ()
    //---
      do{
        let hStack = AutoLayoutHorizontalStackView ()
        hStack.appendView (AutoLayoutSheetCancelButton (title: "Cancel", size: .regular, sheet: panel, isInitialFirstResponder: false))
        hStack.appendFlexibleSpace ()
        hStack.appendView (okButton)
        layoutView.appendView (hStack)
      }
    //---
      newNameTextField.stringValue = inNet.mNetName
      newNameTextField.mTextFieldUserInfo = (inNet, errorLabel, okButton)
      newNameTextField.mTextDidChange = { self.newNameDidChange (newNameTextField) }
      newNameTextField.isContinuous = true
      newNameTextField.delegate = self
      okButton.isEnabled = true
      okButton.title = "Rename as '\(inNet.mNetName)'"
    //---
      panel.contentView = AutoLayoutWindowContentView (view: AutoLayoutViewByPrefixingAppIcon (prefixedView: layoutView))
      window.beginSheet (panel) { inResponse in
        newNameTextField.mTextFieldUserInfo = nil
        if inResponse == .stop {
          let newNetName = newNameTextField.stringValue
          inNet.mNetName = newNetName
        }
      }
    }
  }

  //····················································································································

  @objc internal func newNameDidChange (_ inSender : NSTextField) {
    if let sender = inSender as? AutoLayoutTextField,
       let (netForRenamingOperation, errorLabel, okButton) = sender.mTextFieldUserInfo as? (NetInProject, AutoLayoutStaticLabel, AutoLayoutSheetDefaultOkButton) {
      let newNetName = sender.stringValue
      if newNetName.isEmpty {
        okButton.isEnabled = false
        errorLabel.stringValue = "Empty Net Name"
        okButton.title = "Rename"
      }else{
        var nameIsUnique = true
        for netClass in self.rootObject.mNetClasses.values {
          for net in netClass.mNets.values {
            if net !== netForRenamingOperation, net.mNetName == newNetName {
              nameIsUnique = false
            }
          }
        }
        okButton.isEnabled = nameIsUnique
        errorLabel.stringValue = nameIsUnique ? "" : "Name already exists"
        okButton.title = nameIsUnique ? "Rename as '\(newNetName)'" : "Rename"
      }
    }
  }

  //····················································································································
  //   DIALOG FOR MERGING SUBNET
  //····················································································································

  internal func dialogForMergingSubnetFrom (point inPoint : PointInSchematic) {
    if let window = self.windowForSheet, let initialNetName = inPoint.mNet?.mNetName {
      let panel = NSPanel (
        contentRect: NSRect (x: 0, y: 0, width: 500, height: 200),
        styleMask: [.titled],
        backing: .buffered,
        defer: false
      )
    //---
      let layoutView = AutoLayoutVerticalStackView ().set (margins: 20)
      let gridView = AutoLayoutGridView2 ()
    //---
      layoutView.appendViewSurroundedByFlexibleSpaces (AutoLayoutStaticLabel (title: "Merge Subnet into an Existing Net", bold: true, size: .regular))
      layoutView.appendFlexibleSpace ()
    //---
      let popUpButton = AutoLayoutBase_NSPopUpButton (pullsDown: false, size: .regular).expandableWidth ()
      var nets = [NetInProject] ()
      for netClass in self.rootObject.mNetClasses.values {
        for net in netClass.mNets.values {
          nets.append (net)
        }
      }
      nets.sort { String.numeriCaseInsensitiveCompare ($0.mNetName, $1.mNetName) }
      for net in nets {
        popUpButton.addItem (withTitle: net.mNetName)
        popUpButton.lastItem?.representedObject = net
        if initialNetName == net.mNetName {
          popUpButton.select (popUpButton.lastItem)
        }
      }
      do{
        let left = AutoLayoutStaticLabel (title: "Resulting Net Name", bold: false, size: .regular).set (alignment: .right)
        _ = gridView.addFirstBaseLineAligned (left: left, right: popUpButton)
      }
      layoutView.appendView (gridView)
      layoutView.appendFlexibleSpace ()
    //---
      do{
        let hStack = AutoLayoutHorizontalStackView ()
        hStack.appendView (AutoLayoutSheetCancelButton (title: "Cancel", size: .regular, sheet: panel, isInitialFirstResponder: false))
        hStack.appendFlexibleSpace ()
        let okButton = AutoLayoutSheetDefaultOkButton (title: "Merge", size: .regular, sheet: panel, isInitialFirstResponder: true)
        hStack.appendView (okButton)
        layoutView.appendView (hStack)
      }
    //---
      panel.contentView = AutoLayoutWindowContentView (view: AutoLayoutViewByPrefixingAppIcon (prefixedView: layoutView))
      panel.makeFirstResponder (popUpButton)
      window.beginSheet (panel) { inResponse in
        if inResponse == .stop, let net = popUpButton.selectedItem?.representedObject as? NetInProject {
          inPoint.mNet = net
          inPoint.propagateNetToAccessiblePointsThroughtWires ()
          self.updateSchematicPointsAndNets ()
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
