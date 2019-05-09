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
  //  Find a new unique name
  //····················································································································

  internal func findUniqueNetName () -> String {
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
  //---
    return newNetName
  }

  //····················································································································
  // Create a new net with automatic name
  //····················································································································

  internal func createNetWithAutomaticName () -> NetInProject {
  //--- Find a new net name
    let newNetName = self.findUniqueNetName ()
  //--- Create new
    let newNet = NetInProject (self.ebUndoManager)
    newNet.mNetName = newNetName
    newNet.mNetClass = self.rootObject.mNetClasses [0]
  //---
    return newNet
  }

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
     let selectedLabels = self.mSchematicsLabelSelectionController.selectedArray
     if selectedLabels.count == 1, let net = selectedLabels [0].mPoint?.mNet {
       self.dialogForRenaming (net: net)
     }
  }

  //····················································································································

  @IBAction func newAutomaticNetNameFromSelectedLabelAction (_ sender : NSObject?) { // Bound in IB
     var netSet = Set <NetInProject> ()
     for label in self.mSchematicsLabelSelectionController.selectedArray {
       if let net = label.mPoint?.mNet {
         netSet.insert (net)
       }
     }
     for net in netSet {
       net.mNetName = self.findUniqueNetName ()
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
  //  Propagate and merge net
  //····················································································································

  internal func propagateAndMerge (net inNet : NetInProject, to inPoints : [PointInSchematics]) {
  //--- All points should be at the same location
  //    Only one point should be bound to a symbol pin
    if inPoints.count == 1 {
      inPoints [0].mNet = inNet
      self.propagateNet (fromPoint: inPoints [0])
    }else if inPoints.count > 1 {
      var symbol : ComponentSymbolInProject? = nil
      var symbolPinName = ""
      let location = inPoints [0].location!
      var ok = true
      for point in inPoints {
        if point.mNC != nil {
          ok = false
        }else if point.location! != location {
          ok = false
        }else if let sp = point.mSymbol {
          if symbol != nil {
            ok = false
          }
          symbol = sp
          symbolPinName = point.mSymbolPinName
        }
      }
      if ok {
        let newPoint = PointInSchematics (self.ebUndoManager)
        newPoint.mSymbol = symbol
        newPoint.mSymbolPinName = symbolPinName
        newPoint.mNet = inNet
        newPoint.mX = location.x
        newPoint.mY = location.y
        self.rootObject.mSelectedSheet?.mPoints.append (newPoint)
        var newWiresP1s = [WireInSchematics] ()
        var newWiresP2s = [WireInSchematics] ()
        var newLabels = [LabelInSchematics] ()
        for point in inPoints {
          //NSLog ("Ex point \(point.mWiresP1s.count) \(point.mWiresP2s.count) \(point.mLabels.count)")
          let wireP1s = point.mWiresP1s
          point.mWiresP1s = []
          newWiresP1s += wireP1s
          let wireP2s = point.mWiresP2s
          point.mWiresP2s = []
          newWiresP2s += wireP2s
          let labels = point.mLabels
          point.mLabels = []
          newLabels += labels
          point.mNet = nil
        }
        newPoint.mWiresP1s = newWiresP1s
        newPoint.mWiresP2s = newWiresP2s
        newPoint.mLabels = newLabels
        //NSLog ("New point \(newPoint.mWiresP1s.count) \(newPoint.mWiresP2s.count) \(newPoint.mLabels.count)")
        for point in inPoints {
          let idx = self.rootObject.mSelectedSheet!.mPoints.firstIndex (of: point)!
          self.rootObject.mSelectedSheet?.mPoints.remove (at: idx)
          // NSLog ("Wires \(idx) \(point.mWiresP1s.count) \(point.mWiresP2s.count) \(point.mLabels.count)")
        }
        self.propagateNet (fromPoint: newPoint)
      }
    }
  }

  //····················································································································

  internal func propagateNet (fromPoint inPoint : PointInSchematics) {
    var reachedPointSet = Set <PointInSchematics> ([inPoint])
    var exploreArray = [inPoint]
    while let point = exploreArray.last {
      exploreArray.removeLast ()
      for wire in point.mWiresP1s + point.mWiresP2s {
        let p1 = wire.mP1!
        if !reachedPointSet.contains (p1) {
          NSLog ("ADD \(p1)")
          reachedPointSet.insert (p1)
          exploreArray.append (p1)
          p1.mNet = inPoint.mNet
        }
        let p2 = wire.mP2!
        if !reachedPointSet.contains (p2) {
          NSLog ("ADD \(p2)")
          reachedPointSet.insert (p2)
          exploreArray.append (p2)
          p2.mNet = inPoint.mNet
        }
      }
    }
    self.updateSchematicsPointsAndNets ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
