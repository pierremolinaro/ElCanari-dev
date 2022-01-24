//
//  AutoLayoutCanariSlavePadAssignPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutCanariSlavePadAssignPopUpButton
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariSlavePadAssignPopUpButton : NSPopUpButton, EBUserClassNameProtocol {

  //····················································································································

  init () {
    super.init (frame: NSRect (), pullsDown: false)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.bezelStyle = autoLayoutCurrentStyle ().buttonStyle
    self.controlSize = .small
    self.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override func updateAutoLayoutUserInterfaceStyle () {
    super.updateAutoLayoutUserInterfaceStyle ()
    self.bezelStyle = autoLayoutCurrentStyle ().buttonStyle
  }

  //····················································································································
  // MARK: -
  //····················································································································

  private weak var mDocument : AutoLayoutPackageDocument? = nil // Should be weak

  //····················································································································

  func register (document inDocument : AutoLayoutPackageDocument) {
    self.mDocument = inDocument
  }

  //····················································································································

  private func buildMenu () {
    self.enable (fromValueBinding: self.mDocument != nil, nil)
    self.removeAllItems ()
    self.autoenablesItems = false
    if self.mReferencedMasterPadArray.count == 1 {
      var idx = 0
      for pad in self.mMasterPadArray {
        self.addItem (withTitle: "\(pad.padNameWithZoneName!)")
        if pad === self.mReferencedMasterPadArray [0] {
          self.selectItem (at: idx)
        }
        let menuItem = self.lastItem!
        menuItem.isEnabled = true
        menuItem.target = self
        menuItem.action = #selector (Self.performAssignment (_:))
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
        menuItem.action = #selector (Self.performAssignment (_:))
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

  private var mSlavePadIndexController : EBObservablePropertyController? = nil
  private var mSelectedSlavePadArray = [PackageSlavePad] ()
  private var mReferencedMasterPadArray = [PackagePad] ()

 //····················································································································

  final func bind_masterPadName (_ inObject : EBObservableProperty <String>) -> Self {
    self.mSlavePadIndexController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.update (fromMasterPadName: inObject) }
    )
    return self
  }

  //····················································································································

  private func update (fromMasterPadName inObject : EBObservableProperty <String>) {
    _ = inObject.selection
    self.mSelectedSlavePadArray.removeAll ()
    self.mReferencedMasterPadArray.removeAll ()
    if let document = self.mDocument {
      for selectedObject in document.mPackageObjectsController.selectedArray.values {
        if let slavePad = selectedObject as? PackageSlavePad {
          self.mSelectedSlavePadArray.append (slavePad)
        }
      }
    }
    var masterPadSet = EBReferenceSet <PackagePad> ()
    for slavePad in self.mSelectedSlavePadArray {
      masterPadSet.insert (slavePad.master!)
    }
    self.mReferencedMasterPadArray = Array (masterPadSet.values).sorted (by: { $0.padNameWithZoneName! < $1.padNameWithZoneName!})
    self.buildMenu ()
  }

  //····················································································································
  // MASTER PAD INDEX ARRAY binding
  //····················································································································

  private var mMasterPadIndexArrayIndexController : EBObservablePropertyController? = nil
  private var mMasterPadArray = [PackagePad] ()

 //····················································································································

  final func bind_masterPadObjectIndexArray (_ inObject : EBObservableProperty <IntArray>) -> Self {
    self.mMasterPadIndexArrayIndexController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.update (fromMasterPadIndexArray: inObject) }
    )
    return self
  }

  //····················································································································

  private func update (fromMasterPadIndexArray inObject : EBObservableProperty <IntArray>) {
    self.mMasterPadArray.removeAll ()
    if let document = self.mDocument {
      switch inObject.selection {
      case .empty, .multiple :
        ()
      case .single (let v) :
        let indexSet = Set (v)
        for object in document.rootObject.packageObjects.values {
          if indexSet.contains (object.objectIdentifier), let masterPad = object as? PackagePad {
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
