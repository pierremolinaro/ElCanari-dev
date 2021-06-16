//
//  AutoLayoutCanariPadRenumberPullDownButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/06/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   AutoLayoutCanariPadRenumberPullDownButton
//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutCanariPadRenumberPullDownButton : NSPopUpButton, EBUserClassNameProtocol {

   //····················································································································

  init () {
    super.init (frame: NSRect (), pullsDown: true)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.bezelStyle = .roundRect
    self.controlSize = .small
    self.font = NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func autoLayoutCleanUp () {
    self.mCurrentNumberController?.unregister ()
    self.mCurrentNumberController = nil
    self.mCurrentZoneController?.unregister ()
    self.mCurrentZoneController = nil
    super.autoLayoutCleanUp ()
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
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

  private var mCurrentNumberController : EBReadOnlyPropertyController? = nil
  private var mCurrentPadNumber = 0

  //····················································································································

  final func bind_currentNumber (_ model : EBReadOnlyProperty_Int) -> Self {
    self.mCurrentNumberController = EBReadOnlyPropertyController (
      observedObjects: [model],
      callBack: { self.update (fromPadNumber: model) }
     )
     return self
  }

  //····················································································································

  private func update (fromPadNumber model : EBReadOnlyProperty_Int) {
    switch model.selection {
    case .empty, .multiple :
      self.enable (fromValueBinding: false)
    case .single (let v) :
      self.mCurrentPadNumber = v
      self.buildMenu ()
    }
  }

  //····················································································································

  private func buildMenu () {
    self.enable (fromValueBinding: self.mDocument != nil)
    self.removeAllItems ()
    self.autoenablesItems = false
    if let document = self.mDocument {
      let allZones = document.rootObject.packageZones
      var myZone : PackageZone? = nil
      for zone in allZones {
        if zone.zoneName == self.mCurrentZoneName {
          myZone = zone
          break
        }
      }
      self.addItem (withTitle: "Exchange with")
      let allPads = document.rootObject.packagePads.sorted (by: { $0.padNumber < $1.padNumber } )
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

  final func bind_currentZoneName (_ model : EBReadOnlyProperty_String) -> Self {
    self.mCurrentZoneController = EBReadOnlyPropertyController (
      observedObjects: [model],
      callBack: { self.update (fromZoneName: model) }
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

//----------------------------------------------------------------------------------------------------------------------
