//
//  CanariDefaultNetClassPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 01/10/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class CanariDefaultNetClassPopUpButton : EBPopUpButton {

  //····················································································································

  private var mController : Controller_CanariDefaultNetClassPopUpButton? = nil

  //····················································································································

  func bind_netClasses (_ inSelectedNetClassName : EBReadWriteProperty_String,
                        _ inNetClassNames : EBReadOnlyProperty_StringArray) {
    self.mController = Controller_CanariDefaultNetClassPopUpButton (inSelectedNetClassName, inNetClassNames, self)
  }

  //····················································································································

  func unbind_netClasses () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
//   Controller_CanariDefaultNetClassPopUpButton
//----------------------------------------------------------------------------------------------------------------------

final class Controller_CanariDefaultNetClassPopUpButton : EBReadOnlyPropertyController {

  private let mObject : EBReadWriteProperty_String
  private let mOutlet : EBPopUpButton

  //····················································································································

  init (_ inSelectedNetClassName : EBReadWriteProperty_String,
        _ inNetClassNames : EBReadOnlyProperty_StringArray,
        _ inOutlet : EBPopUpButton) {
    mObject = inSelectedNetClassName
    mOutlet = inOutlet
    super.init (
      observedObjects: [inSelectedNetClassName, inNetClassNames],
      callBack: { } // self cannot be captured before init completed
    )
    self.mEventCallBack = { self.updateOutlet (inSelectedNetClassName, inNetClassNames) }
  }

  //····················································································································

  fileprivate func updateOutlet (_ inSelectedNetClassName : EBReadWriteProperty_String,
                                 _ inNetClassNames : EBReadOnlyProperty_StringArray) {
    self.mOutlet.removeAllItems ()
    switch (inSelectedNetClassName.selection, inNetClassNames.selection) {
    case (.single (let selectedName), .single (let netClassNames)) :
      for name in netClassNames.sorted () {
        self.mOutlet.addItem (withTitle: name)
        self.mOutlet.lastItem?.target = self
        self.mOutlet.lastItem?.action = #selector (self.nameSelectionAction (_:))
        self.mOutlet.lastItem?.isEnabled = true
        if name == selectedName {
          self.mOutlet.select (self.mOutlet.lastItem)
        }
      }
      self.mOutlet.enableFromValueBinding (true)
    default :
      self.mOutlet.enableFromValueBinding (false)
    }
  }

 //····················································································································

  @objc private func nameSelectionAction (_ inSender : NSMenuItem) {
    _ = self.mObject.validateAndSetProp (inSender.title, windowForSheet: self.mOutlet.window)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
