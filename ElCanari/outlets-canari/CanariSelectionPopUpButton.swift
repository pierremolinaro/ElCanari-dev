//
//  CanariSelectionPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 24/09/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariSelectionPopUpButton : EBPopUpButton {

  //····················································································································
  //  format binding
  //····················································································································

  fileprivate func updateOutlet (_ inSelectedName : EBReadOnlyProperty_String,
                                 _ inNameArray : EBReadOnlyProperty_StringArray) {
    switch (inSelectedName.prop, inNameArray.prop) {
    case (.single (let selectedName), .single (let netArray)) :
      self.removeAllItems ()
      do{
        self.addItem (withTitle: "—")
        self.lastItem?.target = self
        self.lastItem?.action = #selector (CanariSelectionPopUpButton.nameSelectionAction (_:))
        self.lastItem?.isEnabled = true
        self.select (self.lastItem)
      }
      let sortedNetArray = netArray.sorted ()
      for name in sortedNetArray {
        self.addItem (withTitle: name)
        self.lastItem?.target = self
        self.lastItem?.action = #selector (CanariSelectionPopUpButton.nameSelectionAction (_:))
        self.lastItem?.isEnabled = true
        if name == selectedName {
          self.select (self.lastItem)
        }
      }
      self.enableFromValueBinding (true)
    default :
      self.removeAllItems ()
      self.enableFromValueBinding (false)
    }
  }

  //····················································································································

  @objc private func nameSelectionAction (_ inSender : NSMenuItem) {
    self.mController?.updateModelAction (inSender)
  }


  //····················································································································
  //   $selectedNameInArray Binding
  //····················································································································

  private var mController : Controller_CanariSelectionPopUpButton_selectedNameInArray? = nil

  //····················································································································

  func bind_selectedNameInArray (_ inSelectedName : EBReadWriteProperty_String, _ inNameArray : EBReadOnlyProperty_StringArray, file : String, line : Int) {
    self.mController = Controller_CanariSelectionPopUpButton_selectedNameInArray (inSelectedName, inNameArray, outlet: self)
  }

  //····················································································································

  func unbind_selectedNameInArray () {
    self.mController?.unregister ()
    self.mController = nil
  }

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariSelectionPopUpButton_selectedNameInArray
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariSelectionPopUpButton_selectedNameInArray : EBSimpleController {

  private let mSelectedName : EBReadWriteProperty_String
  private let mNameArray : EBReadOnlyProperty_StringArray
  private let mOutlet : CanariSelectionPopUpButton

  //····················································································································

  init (_ inSelectedName : EBReadWriteProperty_String, _ inNameArray : EBReadOnlyProperty_StringArray, outlet : CanariSelectionPopUpButton) {
    mSelectedName = inSelectedName
    mNameArray = inNameArray
    mOutlet = outlet
    super.init (observedObjects: [inSelectedName, inNameArray], callBack: { outlet.updateOutlet (inSelectedName, inNameArray) })
    self.mOutlet.target = self
    self.mOutlet.action = #selector (Controller_CanariBoardBoardArchivePopUpButton_format.updateModel (_:))
  }

  //····················································································································

  @objc func updateModelAction (_ inSender : NSMenuItem) {
    _ = self.mSelectedName.validateAndSetProp (inSender.title, windowForSheet: nil)
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
