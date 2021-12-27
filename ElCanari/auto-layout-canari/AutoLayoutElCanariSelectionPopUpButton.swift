//
//  AutoLayoutElCanariSelectionPopUpButton.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 27/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutElCanariSelectionPopUpButton : AutoLayoutPopUpButton {

  //····················································································································
  //  format binding
  //····················································································································

  fileprivate func updateOutlet (_ inSelectedName : EBReadOnlyProperty_String,
                                 _ inNameArray : EBReadOnlyProperty_StringArray) {
    switch (inSelectedName.selection, inNameArray.selection) {
    case (.single (let selectedName), .single (let netArray)) :
      self.removeAllItems ()
      do{
        self.addItem (withTitle: "—")
        self.lastItem?.target = self
        self.lastItem?.action = #selector (Self.nameSelectionAction (_:))
        self.lastItem?.isEnabled = true
        self.select (self.lastItem)
      }
      let sortedNetArray = netArray.sorted ()
      for name in sortedNetArray {
        self.addItem (withTitle: name)
        self.lastItem?.target = self
        self.lastItem?.action = #selector (Self.nameSelectionAction (_:))
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

  private var mController : Controller_ElCanariSelectionPopUpButton_selectedNameInArray? = nil

  //····················································································································

  final func bind_selectedNameInArray (_ inSelectedName : EBReadWriteProperty_String, _ inNameArray : EBReadOnlyProperty_StringArray) -> Self {
    self.mController = Controller_ElCanariSelectionPopUpButton_selectedNameInArray (inSelectedName, inNameArray, outlet: self)
    return self
  }

  //····················································································································

  final func unbind_selectedNameInArray () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_ElCanariSelectionPopUpButton_selectedNameInArray
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_ElCanariSelectionPopUpButton_selectedNameInArray : EBObservablePropertyController {

  //····················································································································

  private let mSelectedName : EBReadWriteProperty_String
  private let mNameArray : EBReadOnlyProperty_StringArray
  private let mOutlet : AutoLayoutElCanariSelectionPopUpButton

  //····················································································································

  init (_ inSelectedName : EBReadWriteProperty_String, _ inNameArray : EBReadOnlyProperty_StringArray, outlet : AutoLayoutElCanariSelectionPopUpButton) {
    self.mSelectedName = inSelectedName
    self.mNameArray = inNameArray
    self.mOutlet = outlet
    super.init (observedObjects: [inSelectedName, inNameArray], callBack: { outlet.updateOutlet (inSelectedName, inNameArray) })
    self.mOutlet.target = self
    self.mOutlet.action = #selector (updateModelAction (_:))
  }

  //····················································································································

  @objc func updateModelAction (_ inSender : NSMenuItem) {
    _ = self.mSelectedName.validateAndSetProp (inSender.title, windowForSheet: nil)
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
