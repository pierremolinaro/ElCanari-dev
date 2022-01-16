//
//  AutoLayoutBoolPopUpButton.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 16/01/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutBoolPopUpButton : AutoLayoutBase_NSPopUpButton {

  //····················································································································

  init (title0 inTitle0 : String, title1 inTitle1 : String) {
    super.init (pullsDown: false, size: .small)
    self.addItem (withTitle: inTitle0)
    self.addItem (withTitle: inTitle1)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

//  override func ebCleanUp () {
//    self.mValueController?.unregister ()
//    self.mValueController = nil
//    super.ebCleanUp ()
//  }

  //····················································································································

  func updateIndex (_ inObject : EBObservableProperty <Bool>) {
    switch inObject.selection {
    case .empty, .multiple :
      self.enable (fromValueBinding: false, self.enabledBindingController)
    case .single (let v) :
      self.selectItem (at: v ? 1 : 0)
      self.enable (fromValueBinding: true, self.enabledBindingController)
    }
  }

  //····················································································································

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    _ = self.mValueController?.updateModel (withCandidateValue: self.indexOfSelectedItem > 0, windowForSheet: self.window)
    return super.sendAction (action, to: to)
  }

  //····················································································································
  //  $value binding
  //····················································································································

  private var mValueController : EBGenericReadWritePropertyController <Bool>? = nil

  //····················································································································

  final func bind_value (_ inObject : EBReadWriteProperty_Bool) -> Self {
    self.mValueController = EBGenericReadWritePropertyController <Bool> (
      observedObject: inObject,
      callBack: { [weak self] in self?.updateIndex (inObject) }
    )
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
