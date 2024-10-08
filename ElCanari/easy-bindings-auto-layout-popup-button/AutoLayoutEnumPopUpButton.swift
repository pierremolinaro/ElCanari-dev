//
//  AutoLayoutEnumPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class AutoLayoutEnumPopUpButton : ALB_NSPopUpButton {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (titles inTitles : [String], size inSize : EBControlSize) {
    super.init (pullsDown: false, size: inSize.cocoaControlSize)
    for title in inTitles {
      self.addItem (withTitle: title)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateIndex (_ object : any EBEnumReadWriteObservableProtocol) {
    if let v = object.rawValue () {
      self.enable (fromValueBinding: true, self.enabledBindingController ())
      self.selectItem (at: v)
    }else{
      self.enable (fromValueBinding: false, self.enabledBindingController ())
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    self.mSelectedIndexController?.updateModel (self.indexOfSelectedItem)
    return super.sendAction (action, to: to)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $selectedIndex binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mSelectedIndexController : Controller_AutoLayoutEnumPopUpButton_Index? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_selectedIndex (_ inObject : any EBEnumReadWriteObservableProtocol) -> Self {
    self.mSelectedIndexController = Controller_AutoLayoutEnumPopUpButton_Index (
      object: inObject,
      outlet: self
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//   Controller_EBPopUpButton_Index
//--------------------------------------------------------------------------------------------------

fileprivate final class Controller_AutoLayoutEnumPopUpButton_Index : EBObservablePropertyController {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mObject : any EBEnumReadWriteObservableProtocol

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (object : any EBEnumReadWriteObservableProtocol, outlet inOutlet : AutoLayoutEnumPopUpButton) {
    self.mObject = object
    super.init (observedObjects: [object], callBack: { [weak inOutlet] in inOutlet?.updateIndex (object) } )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateModel (_ inValue : Int) {
    self.mObject.setFrom (rawValue: inValue)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
}

//--------------------------------------------------------------------------------------------------
