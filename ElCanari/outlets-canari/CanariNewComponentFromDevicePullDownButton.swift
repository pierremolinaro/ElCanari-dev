//
//  CanariNewComponentFromDevicePullDownButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/04/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariNewComponentFromDevicePullDownButton
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariNewComponentFromDevicePullDownButton : NSPopUpButton, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  // MARK: -
  //····················································································································

  private weak var mDocument : CustomizedProjectDocument? = nil

  //····················································································································

  func register (document inDocument : CustomizedProjectDocument?) {
    self.mDocument = inDocument
  }

  //····················································································································
  // MARK: -
  //····················································································································

  private var mCurrentNumberController : EBSimpleController? = nil
  private var mCurrentPadNumber = 0

  //····················································································································

  func bind_deviceNames (_ model : EBReadOnlyProperty_StringArray, file : String, line : Int) {
    self.mCurrentNumberController = EBSimpleController (
      observedObjects: [model],
      callBack: { self.update (fromPadNumber: model) }
     )
  }

  //····················································································································

  func unbind_deviceNames () {
    self.mCurrentNumberController?.unregister ()
    self.mCurrentNumberController = nil
  }

  //····················································································································

  private func update (fromPadNumber model : EBReadOnlyProperty_StringArray) {
    let array : StringArray
    switch model.prop {
    case .empty, .multiple :
      array = []
    case .single (let v) :
      array = v
    }
  //---
    self.removeAllItems ()
    self.addItem (withTitle: "Embedded Library")
    for deviceName in array {
      self.addItem (withTitle: deviceName)
      let menuItem = self.lastItem!
      menuItem.target = self
      menuItem.action = #selector (CanariNewComponentFromDevicePullDownButton.addComponentFromEmbeddedLibrary (_:))
    }
    self.isEnabled = array.count > 0
  }

  //····················································································································

  @objc func addComponentFromEmbeddedLibrary (_ inSender : NSMenuItem) {
    let deviceName = inSender.title
    //Swift.print ("deviceName \(deviceName)")
    self.mDocument?.addComponent (fromEmbeddedLibraryDeviceName: deviceName)
  }

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
