//
//  ProjectDocument-customized-nets.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument : NSTextFieldDelegate {

  //····················································································································
  // Remove unused nets
  //····················································································································

  func removeUnusedNets () {
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

  func updateSelectedNetForRastnetDisplay () {
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

  func dialogForRenamingNet (named inNetName : String) {
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

  func dialogForRenaming (net inNet : NetInProject) {
    if let window = self.windowForSheet {
      let panel = NSPanel (
        contentRect: NSRect (x: 0, y: 0, width: 500, height: 200),
        styleMask: [.titled],
        backing: .buffered,
        defer: false
      )
    //---
      let layoutView = AutoLayoutVerticalStackView ().set (margins: 20)
      let okButton = AutoLayoutSheetDefaultOkButton (title: "", size: .regular, sheet: panel)
      let gridView = AutoLayoutGridView2 ()
    //---
      layoutView.appendViewSurroundedByFlexibleSpaces (AutoLayoutStaticLabel (title: "Rename Net", bold: true, size: .regular, alignment: .center))
      _ = layoutView.appendFlexibleSpace ()
    //---
      do{
        let left = AutoLayoutStaticLabel (title: "Current Net Name", bold: false, size: .regular, alignment: .right)
        let right = AutoLayoutStaticLabel (title: inNet.mNetName, bold: true, size: .regular, alignment: .left)
        _ = gridView.addFirstBaseLineAligned (left: left, right: right)
      }
      let newNameTextField = AutoLayoutTextField (minWidth: 200, size: .regular).set (alignment: .left)
      do{
        let left = AutoLayoutStaticLabel (title: "New Net Name", bold: false, size: .regular, alignment: .right)
        _ = gridView.addFirstBaseLineAligned (left: left, right: newNameTextField)
      }
      let errorLabel = AutoLayoutStaticLabel (title: "", bold: true, size: .regular, alignment: .right)
         .setRedTextColor ().expandableWidth()
      _ = gridView.add (single: errorLabel)
      _ = layoutView.appendView (gridView)
      _ = layoutView.appendFlexibleSpace ()
    //---
      do{
        let hStack = AutoLayoutHorizontalStackView ()
        _ = hStack.appendView (AutoLayoutSheetCancelButton (title: "Cancel", size: .regular))
        _ = hStack.appendFlexibleSpace ()
        _ = hStack.appendView (okButton)
        _ = layoutView.appendView (hStack)
      }
    //---
      newNameTextField.stringValue = inNet.mNetName
      newNameTextField.mTextFieldUserInfo = (inNet, errorLabel, okButton)
      newNameTextField.mTextDidChange = { [weak self] in self?.newNameDidChange (newNameTextField) }
      newNameTextField.isContinuous = true
      newNameTextField.delegate = self
      okButton.isEnabled = true
      okButton.title = "Rename as '\(inNet.mNetName)'"
    //---
      panel.contentView = AutoLayoutWindowContentView (view: AutoLayoutViewByPrefixingAppIcon (prefixedView: layoutView))
      window.beginSheet (panel) { inResponse in
        newNameTextField.mTextFieldUserInfo = nil
        newNameTextField.mTextDidChange = nil // Required for breaking retain cycle
        if inResponse == .stop {
          let newNetName = newNameTextField.stringValue
          inNet.mNetName = newNetName
        }
      }
    }
  }

  //····················································································································

  @objc func newNameDidChange (_ inSender : NSTextField) {
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

  func dialogForMergingSubnetFrom (point inPoint : PointInSchematic) {
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
      _ = layoutView.appendViewSurroundedByFlexibleSpaces (AutoLayoutStaticLabel (title: "Merge Subnet into an Existing Net", bold: true, size: .regular, alignment: .center))
      _ = layoutView.appendFlexibleSpace ()
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
        let left = AutoLayoutStaticLabel (title: "Resulting Net Name", bold: false, size: .regular, alignment: .right)
        _ = gridView.addFirstBaseLineAligned (left: left, right: popUpButton)
      }
      _ = layoutView.appendView (gridView)
      _ = layoutView.appendFlexibleSpace ()
    //---
      do{
        let hStack = AutoLayoutHorizontalStackView ()
        _ = hStack.appendView (AutoLayoutSheetCancelButton (title: "Cancel", size: .regular))
        _ = hStack.appendFlexibleSpace ()
        let okButton = AutoLayoutSheetDefaultOkButton (title: "Merge", size: .regular, sheet: panel)
        _ = hStack.appendView (okButton)
        _ = layoutView.appendView (hStack)
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

  func dialogForSelectingNetClassForNet (named inNetName : String) {
    if let window = self.windowForSheet {
      let panel = NSPanel (
        contentRect: NSRect (x: 0, y: 0, width: 500, height: 200),
        styleMask: [.titled],
        backing: .buffered,
        defer: false
      )
    //---
      let layoutView = AutoLayoutVerticalStackView ().set (margins: 20)
    //---
      layoutView.appendViewSurroundedByFlexibleSpaces (AutoLayoutStaticLabel (title: "Select Net Class", bold: true, size: .regular, alignment: .center))
    //---
      let popUpButton = AutoLayoutBase_NSPopUpButton (pullsDown: false, size: .regular).expandableWidth ()
      _ = layoutView.appendFlexibleSpace ()
      _ = layoutView.appendView (popUpButton)
      _ = layoutView.appendFlexibleSpace ()
    //--- Find net
      var possibleNet : NetInProject? = nil
      for netClass in self.rootObject.mNetClasses.values {
        for net in netClass.mNets.values {
          if net.mNetName == inNetName {
            possibleNet = net
            break
          }
        }
      }
    //--- Build net class popup
      if let net = possibleNet {
        var netClasses = self.rootObject.mNetClasses
        netClasses.sort (by : { $0.mNetClassName.localizedStandardCompare ($1.mNetClassName) == .orderedAscending } )
        for netClass in netClasses.values {
          popUpButton.addItem (withTitle: netClass.mNetClassName)
          popUpButton.lastItem?.representedObject = netClass
          if netClass === net.mNetClass {
            popUpButton.select (popUpButton.lastItem)
          }
        }
      //---
        do{
          let hStack = AutoLayoutHorizontalStackView ()
          _ = hStack.appendView (AutoLayoutSheetCancelButton (title: "Cancel", size: .regular))
          _ = hStack.appendFlexibleSpace ()
          let okButton = AutoLayoutSheetDefaultOkButton (title: "Select", size: .regular, sheet: panel)
          _ = hStack.appendView (okButton)
          _ = layoutView.appendView (hStack)
        }
      //---
        panel.contentView = AutoLayoutWindowContentView (view: AutoLayoutViewByPrefixingAppIcon (prefixedView: layoutView))
      //--- Dialog
        window.beginSheet (panel) { inResponse in
          if inResponse == .stop, let netClass = popUpButton.selectedItem?.representedObject as? NetClassInProject {
            net.mNetClass = netClass
          }
        }
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
