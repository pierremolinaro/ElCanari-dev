//
//  CanariSlavePadAssignmentPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/12/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariSlavePadAssignmentPopUpButton
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

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

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  // MARK: -
  //····················································································································

  private weak var mDocument : CustomizedPackageDocument? = nil

  //····················································································································

  func register (document inDocument : CustomizedPackageDocument?) {
    self.mDocument = inDocument
  }

  //····················································································································
  // MARK: -
  //····················································································································

  private var mCurrentZoneController : EBSimpleController? = nil
  private var mCurrentSlavePad : PackageSlavePad? = nil

  //····················································································································

  func bind_masterPadName (_ model : EBReadOnlyProperty_String, file : String, line : Int) {
    self.mCurrentZoneController = EBSimpleController (
      observedObjects: [model],
      callBack: { self.update (fromMasterPadName: model) }
    )
  }

  //····················································································································

  func unbind_masterPadName () {
    self.mCurrentZoneController?.unregister ()
    self.mCurrentZoneController = nil
    self.mCurrentSlavePad = nil
  }

  //····················································································································

  private func update (fromMasterPadName model : EBReadOnlyProperty_String) {
    if let document = self.mDocument {
      switch model.prop {
      case .empty, .multiple :
        self.mCurrentSlavePad = nil
      case .single (let v) :
        let allSlavePads = document.rootObject.packageSlavePads_property.propval
        for slavePad in allSlavePads {
          if slavePad.padName == v {
            self.mCurrentSlavePad = slavePad
          }
        }
        self.buildMenu ()
      }
    }
  }

  //····················································································································

  private func buildMenu () {
    self.enableFromValueBinding (self.mDocument != nil)
    if let document = self.mDocument {
      let allPads = document.rootObject.packagePads_property.propval.sorted (by: { $0.padName! < $1.padName! } )
      self.removeAllItems ()
      self.autoenablesItems = false
      var idx = 0
      for pad in allPads {
        self.addItem (withTitle: "\(pad.padName!)")
        if self.mCurrentSlavePad?.master_property.propval === pad {
          self.selectItem (at: idx)
        }
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
   // Swift.print ("Exchange \(self.mCurrentPadNumber) <-> \(inSender.tag)")
    if let document = self.mDocument {
      let allPads = document.rootObject.packagePads_property.propval.sorted (by: { $0.padName! < $1.padName! } )
      let idx = inSender.tag
      self.mCurrentSlavePad?.master_property.setProp (allPads [idx])
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
