//
//  CanariSlavePadAssignmentPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/12/2018.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   CanariSlavePadAssignmentPopUpButton
//----------------------------------------------------------------------------------------------------------------------

class CanariSlavePadAssignmentPopUpButton : NSPopUpButton, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
  }

  //····················································································································
  // MARK: -
  //····················································································································

  private weak var mDocument : CustomizedPackageDocument? = nil //Should be weak

  //····················································································································

  func register (document inDocument : CustomizedPackageDocument?) {
    self.mDocument = inDocument
  }

  //····················································································································

  private func buildMenu () {
    self.enableFromValueBinding (self.mDocument != nil)
    self.removeAllItems ()
    self.autoenablesItems = false
    if self.mReferencedMasterPadArray.count == 1 {
      var idx = 0
      for pad in self.mMasterPadArray {
        self.addItem (withTitle: "\(pad.padNameWithZoneName!)")
        if pad == self.mReferencedMasterPadArray [0] {
          self.selectItem (at: idx)
        }
        let menuItem = self.lastItem!
        menuItem.isEnabled = true
        menuItem.target = self
        menuItem.action = #selector (CanariSlavePadAssignmentPopUpButton.performAssignment (_:))
        menuItem.tag = idx
        idx += 1
      }
    }else if self.mReferencedMasterPadArray.count > 1 {
      self.addItem (withTitle: "Multiple")
      self.selectItem (at: 0)
      var idx = 0
      for pad in self.mMasterPadArray {
        self.addItem (withTitle: "\(pad.padNameWithZoneName!)")
        let menuItem = self.lastItem!
        menuItem.isEnabled = true
        menuItem.target = self
        menuItem.action = #selector (CanariSlavePadAssignmentPopUpButton.performAssignment (_:))
        menuItem.tag = idx
        idx += 1
      }
    }
  }

  //····················································································································

  @objc func performAssignment (_ inSender : NSMenuItem) {
    let masterPad = self.mMasterPadArray [inSender.tag]
    for slavePad in self.mSelectedSlavePadArray {
      slavePad.master = masterPad
    }
  }

  //····················································································································
  // SLAVE PAD INDEX binding
  //····················································································································

  private var mSlavePadIndexController : EBReadOnlyPropertyController? = nil
  private var mSelectedSlavePadArray = [PackageSlavePad] ()
  private var mReferencedMasterPadArray = [PackagePad] ()

 //····················································································································

  func bind_masterPadName (_ inObject : EBGenericReadOnlyProperty <String>) {
    self.mSlavePadIndexController = EBReadOnlyPropertyController (
      observedObjects: [inObject],
      callBack: { self.update (fromMasterPadName: inObject) }
    )
  }

  //····················································································································

  func unbind_masterPadName () {
    self.mSlavePadIndexController?.unregister ()
    self.mSlavePadIndexController = nil
    self.mSelectedSlavePadArray.removeAll ()
    self.mReferencedMasterPadArray.removeAll ()
  }

  //····················································································································

  private func update (fromMasterPadName inObject : EBGenericReadOnlyProperty <String>) {
    _ = inObject.selection
    self.mSelectedSlavePadArray.removeAll ()
    self.mReferencedMasterPadArray.removeAll ()
    if let document = self.mDocument {
      for selectedObject in document.mPackageObjectsController.selectedArray {
        if let slavePad = selectedObject as? PackageSlavePad {
          self.mSelectedSlavePadArray.append (slavePad)
        }
      }
    }
    var masterPadSet = Set <PackagePad> ()
    for slavePad in self.mSelectedSlavePadArray {
      masterPadSet.insert (slavePad.master!)
    }
    self.mReferencedMasterPadArray = Array (masterPadSet).sorted (by: { $0.padNameWithZoneName! < $1.padNameWithZoneName!})
    self.buildMenu ()
  }

  //····················································································································
  // MASTER PAD INDEX ARRAY binding
  //····················································································································

  private var mMasterPadIndexArrayIndexController : EBReadOnlyPropertyController? = nil
  private var mMasterPadArray = [PackagePad] ()

 //····················································································································

  func bind_masterPadObjectIndexArray (_ inObject : EBGenericReadOnlyProperty <IntArray>) {
    self.mMasterPadIndexArrayIndexController = EBReadOnlyPropertyController (
      observedObjects: [inObject],
      callBack: { self.update (fromMasterPadIndexArray: inObject) }
    )
  }

  //····················································································································

  func unbind_masterPadObjectIndexArray () {
    self.mMasterPadIndexArrayIndexController?.unregister ()
    self.mMasterPadIndexArrayIndexController = nil
    self.mMasterPadArray.removeAll ()
  }

  //····················································································································

  private func update (fromMasterPadIndexArray inObject : EBGenericReadOnlyProperty <IntArray>) {
    self.mMasterPadArray.removeAll ()
    if let document = self.mDocument {
      switch inObject.selection {
      case .empty, .multiple :
        ()
      case .single (let v) :
        let indexSet = Set (v)
        for object in document.rootObject.packageObjects {
          if indexSet.contains (object.ebObjectIndex), let masterPad = object as? PackagePad {
            self.mMasterPadArray.append (masterPad)
          }
        }
      }
    }
    self.mMasterPadArray.sort (by: { $0.padNameWithZoneName! < $1.padNameWithZoneName!})
    self.buildMenu ()
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
