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

  internal func newNetWithAutomaticName () -> NetInProject {
  //--- Find a new net name
    var newNetName = ""
    var idx = 1
    while newNetName == "" {
      let tentativeNetName = "$\(idx)"
      var ok = true
      for netClass in self.rootObject.mNetClasses {
        for net in netClass.mNets {
          if net.mNetName == tentativeNetName {
            ok = false
          }
        }
      }
      if ok {
        newNetName = tentativeNetName
      }else{
        idx += 1
      }
    }
  //--- Create new
    let newNet = NetInProject (self.ebUndoManager)
    newNet.mNetName = newNetName
    newNet.mNetClass = self.rootObject.mNetClasses [0]
  //---
    return newNet
  }

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

  @IBAction func renameNetAction (_ sender : NSObject?) { // Bound in IB
    if let netInfoTableView = self.mNetInfoTableView {
      let idx = netInfoTableView.selectedRow
      if idx >= 0 {
        let netInfo = netInfoTableView.object (at: idx)
        let netName = netInfo.netName
        self.dialogFroRenamingNet (named: netName)
      }
    }
  }

  //····················································································································
  //  Rename net dialog
  //····················································································································

  internal func dialogFroRenamingNet (named inNetName : String) {
//    NSLog ("inNetName \(inNetName)")
  //--- Find net from its name
    self.mPossibleNetForRenamingOperation = nil
    for netClass in self.rootObject.mNetClasses {
      for net in netClass.mNets {
        if net.mNetName == inNetName {
          self.mPossibleNetForRenamingOperation = net
        }
      }
    }
  //--- Edit net
    if let net = self.mPossibleNetForRenamingOperation, let window = self.windowForSheet, let panel = self.mRenameNetPanel {
      self.mRenameNetTextField?.stringValue = net.mNetName
      self.mRenameNetErrorTextField?.stringValue = ""
    //---
      self.mRenameNetTextField?.target = self
      self.mRenameNetTextField?.action = #selector (CustomizedProjectDocument.newNameDidChange (_:))
      self.mRenameNetTextField?.setSendContinously (true)
      self.mRenameNetOkButton?.isEnabled = true
      self.mRenameNetOkButton?.title = "Rename as '\(net.mNetName)'"
    //--- Dialog
      window.beginSheet (panel) { inResponse in
        if inResponse == .stop {
          self.performRenameNet ()
        }
        self.mPossibleNetForRenamingOperation = nil
      }
    }
  }

  //····················································································································

  @objc internal func newNameDidChange (_ inSender : NSTextField) {
    if let netForRenamingOperation = self.mPossibleNetForRenamingOperation {
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

  internal func performRenameNet () {
    if let netForRenamingOperation = self.mPossibleNetForRenamingOperation, let newNetName = self.mRenameNetTextField?.stringValue {
      netForRenamingOperation.mNetName = newNetName
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
