//
//  AutoLayoutCanariPadRenumberPullDownButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutCanariPadRenumberPullDownButton
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariPadRenumberPullDownButton : AutoLayoutBase_NSPopUpButton {

   //····················································································································

  init () {
    super.init (pullsDown: true, size: .small)

    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································
  // MARK: -
  //····················································································································

  private weak var mDocument : AutoLayoutPackageDocument? = nil // SHOULD BE WEAK

  //····················································································································

  func register (document inDocument : AutoLayoutPackageDocument) {
    self.mDocument = inDocument
  }

  //····················································································································
  // MARK: -
  //····················································································································

  private var mCurrentNumberController : EBObservablePropertyController? = nil
  private var mCurrentPadNumber = 0

  //····················································································································

  final func bind_currentNumber (_ model : EBReadOnlyProperty_Int) -> Self {
    self.mCurrentNumberController = EBObservablePropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (fromPadNumber: model) }
     )
     return self
  }

  //····················································································································

  private func update (fromPadNumber model : EBReadOnlyProperty_Int) {
    switch model.selection {
    case .empty, .multiple :
      self.enable (fromValueBinding: false, self.enabledBindingController)
    case .single (let v) :
      self.mCurrentPadNumber = v
      self.buildMenu ()
    }
  }

  //····················································································································

  private func buildMenu () {
    self.enable (fromValueBinding: self.mDocument != nil, self.enabledBindingController)
    self.removeAllItems ()
    self.autoenablesItems = false
    if let document = self.mDocument {
      let allZones = document.rootObject.packageZones
      var myZone : PackageZone? = nil
      for zone in allZones.values {
        if zone.zoneName == self.mCurrentZoneName {
          myZone = zone
          break
        }
      }
      self.addItem (withTitle: "Exchange with")
      let allPads = document.rootObject.packagePads.values.sorted (by: { $0.padNumber < $1.padNumber } )
      for pad in allPads {
        if pad.zone === myZone {
          self.addItem (withTitle: pad.padNameWithZoneName ?? "?")
          let menuItem = self.lastItem!
          menuItem.isEnabled = pad.padNumber != self.mCurrentPadNumber
          menuItem.target = self
          menuItem.action = #selector (Self.performRenumbering (_:))
          menuItem.tag = pad.padNumber
        }
      }
    }else{
      self.addItem (withTitle: "No Document")
    }
  }

  //····················································································································

  @objc func performRenumbering (_ inSender : NSMenuItem) {
   // Swift.print ("Exchange \(self.mCurrentPadNumber) <-> \(inSender.tag)")
    if let document = self.mDocument {
      let allPads = document.rootObject.packagePads
      for pad in allPads.values {
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

  private var mCurrentZoneController : EBObservablePropertyController? = nil
  private var mCurrentZoneName = ""

  //····················································································································

  final func bind_currentZoneName (_ model : EBReadOnlyProperty_String) -> Self {
    self.mCurrentZoneController = EBObservablePropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (fromZoneName: model) }
     )
     return self
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
