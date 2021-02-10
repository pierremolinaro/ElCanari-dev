//
//  CanariPadRenumberingPullDownButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/12/2018.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   CanariPadRenumberingPullDownButton
//----------------------------------------------------------------------------------------------------------------------

class CanariPadRenumberingPullDownButton : NSPopUpButton, EBUserClassNameProtocol {

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

  private var mCurrentNumberController : EBReadOnlyPropertyController? = nil
  private var mCurrentPadNumber = 0

  //····················································································································

  func bind_currentNumber (_ model : EBReadOnlyProperty_Int) {
    self.mCurrentNumberController = EBReadOnlyPropertyController (
      observedObjects: [model],
      callBack: { self.update (fromPadNumber: model) }
     )
  }

  //····················································································································

  func unbind_currentNumber () {
    self.mCurrentNumberController?.unregister ()
    self.mCurrentNumberController = nil
  }

  //····················································································································

  private func update (fromPadNumber model : EBReadOnlyProperty_Int) {
    switch model.selection {
    case .empty, .multiple :
      self.enableFromValueBinding (false)
    case .single (let v) :
      self.mCurrentPadNumber = v
      self.buildMenu ()
    }
  }

  //····················································································································

  private func buildMenu () {
    self.enableFromValueBinding (self.mDocument != nil)
    if let document = self.mDocument {
      let allZones = document.rootObject.packageZones
      var myZone : PackageZone? = nil
      for zone in allZones {
        if zone.zoneName == self.mCurrentZoneName {
          myZone = zone
          break
        }
      }
      let allPads = document.rootObject.packagePads.sorted (by: { $0.padNumber < $1.padNumber } )
      self.removeAllItems ()
      self.autoenablesItems = false
      self.addItem (withTitle: "Exchange with")
      for pad in allPads {
        if pad.zone === myZone {
          self.addItem (withTitle: pad.padNameWithZoneName ?? "?")
          let menuItem = self.lastItem!
          menuItem.isEnabled = pad.padNumber != self.mCurrentPadNumber
          menuItem.target = self
          menuItem.action = #selector (CanariPadRenumberingPullDownButton.performRenumbering (_:))
          menuItem.tag = pad.padNumber
        }
      }
    }
  }

  //····················································································································

  @objc func performRenumbering (_ inSender : NSMenuItem) {
   // Swift.print ("Exchange \(self.mCurrentPadNumber) <-> \(inSender.tag)")
    if let document = self.mDocument {
      let allPads = document.rootObject.packagePads
      for pad in allPads {
        if pad.padNumber == self.mCurrentPadNumber {
          pad.padNumber = inSender.tag
        }else if pad.padNumber == inSender.tag {
          pad.padNumber = self.mCurrentPadNumber
        }
      }
    }
  }

  //····················································································································
  // MARK: -
  //····················································································································

  private var mCurrentZoneController : EBReadOnlyPropertyController? = nil
  private var mCurrentZoneName = ""

  //····················································································································

  func bind_currentZoneName (_ model : EBReadOnlyProperty_String) {
    self.mCurrentZoneController = EBReadOnlyPropertyController (
      observedObjects: [model],
      callBack: { self.update (fromZoneName: model) }
     )
  }

  //····················································································································

  func unbind_currentZoneName () {
    self.mCurrentZoneController?.unregister ()
    self.mCurrentZoneController = nil
  }

  //····················································································································

  private func update (fromZoneName model : EBReadOnlyProperty_String) {
    switch model.selection {
    case .empty, .multiple :
      self.mCurrentZoneName = ""
    case .single (let v) :
      self.mCurrentZoneName = v
      self.buildMenu ()
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
