//
//  AutoLayoutCanariDefaultNetClassPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 01/10/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariDefaultNetClassPopUpButton : AutoLayoutBase_NSPopUpButton {

  //····················································································································

  init () {
    super.init (pullsDown: false, size: .small)
  }

  //····················································································································

  required init? (coder inCoder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  private var mController : Controller_CanariDefaultNetClassPopUpButton? = nil

  //····················································································································

  final func bind_netClasses (_ inSelectedNetClassName : EBReadWriteProperty_String,
                              _ inNetClassNames : EBReadOnlyProperty_StringArray) -> Self {
    self.mController = Controller_CanariDefaultNetClassPopUpButton (inSelectedNetClassName, inNetClassNames, self)
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariDefaultNetClassPopUpButton
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class Controller_CanariDefaultNetClassPopUpButton : EBObservablePropertyController {

  private let mObject : EBReadWriteProperty_String
  private weak var mOutlet : AutoLayoutCanariDefaultNetClassPopUpButton? = nil

  //····················································································································

  init (_ inSelectedNetClassName : EBReadWriteProperty_String,
        _ inNetClassNames : EBReadOnlyProperty_StringArray,
        _ inOutlet : AutoLayoutCanariDefaultNetClassPopUpButton) {
    self.mObject = inSelectedNetClassName
    self.mOutlet = inOutlet
    super.init (
      observedObjects: [inSelectedNetClassName, inNetClassNames],
      callBack: nil // self cannot be captured before init completed
    )
    self.mEventCallBack = { [weak self] in self?.updateOutlet (inSelectedNetClassName, inNetClassNames) }
  }

  //····················································································································

  fileprivate func updateOutlet (_ inSelectedNetClassName : EBReadWriteProperty_String,
                                 _ inNetClassNames : EBReadOnlyProperty_StringArray) {
    if let outlet = self.mOutlet {
      outlet.removeAllItems ()
      switch (inSelectedNetClassName.selection, inNetClassNames.selection) {
      case (.single (let selectedName), .single (let netClassNames)) :
        for name in netClassNames.sorted () {
          outlet.addItem (withTitle: name)
          outlet.lastItem?.target = self
          outlet.lastItem?.action = #selector (self.nameSelectionAction (_:))
          outlet.lastItem?.isEnabled = true
          if name == selectedName {
            outlet.select (outlet.lastItem)
          }
        }
        outlet.enable (fromValueBinding: true, outlet.enabledBindingController)
      default :
        outlet.enable (fromValueBinding: false, outlet.enabledBindingController)
      }
    }
  }

 //····················································································································

  @objc private func nameSelectionAction (_ inSender : NSMenuItem) {
    _ = self.mObject.validateAndSetProp (inSender.title, windowForSheet: self.mOutlet?.window)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
