//
//  ProjectDocument-customized-nets.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CustomizedProjectDocument {

  //····················································································································
  // Remove unused nets
  //····················································································································

  internal func removeUnusedNets () {
    for netClass in self.rootObject.mNetClasses {
      for net in netClass.mNets {
        if net.mPoints.count == 0 {
          net.mNetClass = nil
        }
      }
    }
  }

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

  @IBAction func renameNetFromSelectedLabelAction (_ sender : NSObject?) { // Bound in IB
     let selectedLabels = self.mSchematicLabelSelectionController.selectedArray
     if selectedLabels.count == 1, let net = selectedLabels [0].mPoint?.mNet {
       self.dialogForRenaming (net: net)
     }
  }

  //····················································································································

  @IBAction func newAutomaticNetNameFromSelectedLabelAction (_ sender : NSObject?) { // Bound in IB
     var netSet = Set <NetInProject> ()
     for label in self.mSchematicLabelSelectionController.selectedArray {
       if let net = label.mPoint?.mNet {
         netSet.insert (net)
       }
     }
     for net in netSet {
       net.mNetName = self.rootObject.findUniqueNetName ()
     }
  }

  //····················································································································

  @IBAction func mergeSubnetIntoExistingNetFromSelectedLabelAction (_ sender : NSObject?) { // Bound in IB
    let selectedLabels = self.mSchematicLabelSelectionController.selectedArray
    if selectedLabels.count == 1 {
      let label = selectedLabels [0]
      let point = label.mPoint!
      self.dialogForMergingSubnetFrom (point: point)
    }
  }

  //····················································································································
  //  Rename net dialog
  //····················································································································

  internal func dialogForRenamingNet (named inNetName : String) {
//    NSLog ("inNetName \(inNetName)")
  //--- Find net from its name
    var possibleNetForRenamingOperation : NetInProject? = nil
    for netClass in self.rootObject.mNetClasses {
      for net in netClass.mNets {
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
    if let window = self.windowForSheet, let panel = self.mRenameNetPanel {
      self.mRenameNetTextField?.stringValue = inNet.mNetName
      self.mRenameNetErrorTextField?.stringValue = ""
    //---
      self.mRenameNetTextField?.mUserInfo = inNet
      self.mRenameNetTextField?.target = self
      self.mRenameNetTextField?.action = #selector (CustomizedProjectDocument.newNameDidChange (_:))
      self.mRenameNetTextField?.setSendContinously (true)
      self.mRenameNetOkButton?.isEnabled = true
      self.mRenameNetOkButton?.title = "Rename as '\(inNet.mNetName)'"
    //--- Dialog
      window.beginSheet (panel) { inResponse in
        self.mRenameNetTextField?.mUserInfo = nil
        if inResponse == .stop {
          self.performRenameNet (inNet)
        }
      }
    }
  }

  //····················································································································

  @objc internal func newNameDidChange (_ inSender : NSTextField) {
    if let netForRenamingOperation = self.mRenameNetTextField?.mUserInfo as? NetInProject {
      let newNetName = inSender.stringValue
      if newNetName == "" {
        self.mRenameNetOkButton?.isEnabled = false
        self.mRenameNetErrorTextField?.stringValue = "Empty Net Name"
        self.mRenameNetOkButton?.title = "Rename"
      }else{
        var nameIsUnique = true
        for netClass in self.rootObject.mNetClasses {
          for net in netClass.mNets {
            if net !== netForRenamingOperation, net.mNetName == newNetName {
              nameIsUnique = false
            }
          }
        }
        self.mRenameNetOkButton?.isEnabled = nameIsUnique
        self.mRenameNetErrorTextField?.stringValue = nameIsUnique ? "" : "Name already exists"
        self.mRenameNetOkButton?.title = nameIsUnique ? "Rename as '\(newNetName)'" : "Rename"
      }
    }
  }

  //····················································································································

  internal func performRenameNet (_ inNet : NetInProject) {
    if let newNetName = self.mRenameNetTextField?.stringValue {
      inNet.mNetName = newNetName
    }
  }

  //····················································································································
  //   DIALOG FOR MERGING SUBNET
  //····················································································································

  internal func dialogForMergingSubnetFrom (point inPoint : PointInSchematic) {
    if let window = self.windowForSheet, let panel = self.mMergeNetDialog, let popup = self.mMergeNetPopUpButton {
      let initialNetName = inPoint.mNet!.mNetName
      popup.removeAllItems ()
      var selectedIndex : Int? = nil
      var idx = 0
      for netClass in self.rootObject.mNetClasses {
        for net in netClass.mNets {
          popup.addItem (withTitle: net.mNetName)
          popup.lastItem?.representedObject = net
          if initialNetName == net.mNetName {
            selectedIndex = idx
          }
          idx += 1
        }
      }
      if let idx = selectedIndex {
        popup.selectItem (at: idx)
      }
    //--- Dialog
      window.beginSheet (panel) { inResponse in
        if inResponse == .stop {
          if let net = popup.selectedItem?.representedObject as? NetInProject {
            inPoint.mNet = net
            inPoint.propagateNetToAccessiblePointsThroughtWires ()
          }
        }
      }
    }

  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
