//
//  CanariNewComponentFromDevicePullDownButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/04/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   CanariNewComponentFromDevicePullDownButton
//----------------------------------------------------------------------------------------------------------------------

final class CanariNewComponentFromDevicePullDownButton : NSPopUpButton, EBUserClassNameProtocol {

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

  private var mCurrentNumberController : EBReadOnlyPropertyController? = nil
  private var mCurrentPadNumber = 0

  //····················································································································

  final func bind_deviceNames (_ model : EBReadOnlyProperty_StringArray) {
    self.mCurrentNumberController = EBReadOnlyPropertyController (
      observedObjects: [model],
      callBack: { self.update (fromPadNumber: model) }
     )
  }

  //····················································································································

  final func unbind_deviceNames () {
    self.mCurrentNumberController?.unregister ()
    self.mCurrentNumberController = nil
  }

  //····················································································································

  private func update (fromPadNumber model : EBReadOnlyProperty_StringArray) {
    let array : StringArray
    switch model.selection {
    case .empty, .multiple :
      array = []
    case .single (let v) :
      array = v
    }
  //---
    self.removeAllItems ()
    self.addItem (withTitle: "Embedded Library")
    for deviceName in array.sorted () {
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

//----------------------------------------------------------------------------------------------------------------------
