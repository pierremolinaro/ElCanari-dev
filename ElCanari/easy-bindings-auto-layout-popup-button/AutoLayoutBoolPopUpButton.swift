//
//  AutoLayoutBoolPopUpButton.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 16/01/2022.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class AutoLayoutBoolPopUpButton : ALB_NSPopUpButton {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mTitle0 : String
  private let mTitle1 : String

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (title0 inTitle0 : String, title1 inTitle1 : String) {
    self.mTitle0 = inTitle0
    self.mTitle1 = inTitle1
    super.init (pullsDown: false, size: .small)
    self.addItem (withTitle: inTitle0)
    self.addItem (withTitle: inTitle1)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func updateOutlet (_ inObject : EBObservableProperty <Bool>) {
    self.removeAllItems ()
    switch inObject.selection {
    case .empty :
      self.addItem (withTitle: "No Selection")
      self.enable (fromValueBinding: false, self.enabledBindingController ())
    case .multiple :
      self.addItem (withTitle: self.mTitle0)
      self.lastItem?.state = .mixed
      self.addItem (withTitle: self.mTitle1)
      self.lastItem?.state = .mixed
      self.enable (fromValueBinding: true, self.enabledBindingController ())
    case .single (let v) :
      self.addItem (withTitle: self.mTitle0)
      self.addItem (withTitle: self.mTitle1)
      self.selectItem (at: v ? 1 : 0)
      self.enable (fromValueBinding: true, self.enabledBindingController ())
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    self.mValueController?.updateModel (withValue: self.indexOfSelectedItem > 0)
    return super.sendAction (action, to: to)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $value binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mValueController : EBGenericReadWritePropertyController <Bool>? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_value (_ inObject : EBObservableMutableProperty <Bool>) -> Self {
    self.mValueController = EBGenericReadWritePropertyController <Bool> (
      observedObject: inObject,
      callBack: { [weak self] in self?.updateOutlet (inObject) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
