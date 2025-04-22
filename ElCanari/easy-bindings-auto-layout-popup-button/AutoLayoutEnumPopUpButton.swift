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

  private let mTitles : [String]

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (titles inTitles : [String], size inSize : EBControlSize) {
    self.mTitles = inTitles
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

  fileprivate func updateOutlet (_ inObject : any EBEnumReadWriteObservableProtocol) {
    self.removeAllItems ( )
    switch inObject.rawSelection {
    case .empty :
      self.addItem (withTitle: "No Selection")
      self.enable (fromValueBinding: false, self.enabledBindingController ())
    case .multiple :
      for title in self.mTitles {
        self.addItem (withTitle: title)
      }
      self.addItem (withItalicTitle: "Multiple Selection")
      self.selectItem (at: self.numberOfItems - 1)
      self.enable (fromValueBinding: true, self.enabledBindingController ())
    case .single (let v) :
      for title in self.mTitles {
        self.addItem (withTitle: title)
      }
      self.selectItem (at: v)
      self.enable (fromValueBinding: true, self.enabledBindingController ())
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func sendAction (_ inAction : Selector?, to inTarget : Any?) -> Bool {
    if self.indexOfSelectedItem < self.mTitles.count { // Prevent selection of "Multiple Selection"
      self.mSelectedIndexController?.updateModel (self.indexOfSelectedItem)
    }
    return super.sendAction (inAction, to: inTarget)
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

  init (object inObject : any EBEnumReadWriteObservableProtocol,
        outlet inOutlet : AutoLayoutEnumPopUpButton) {
    self.mObject = inObject
    super.init (
      observedObjects: [inObject],
      callBack: { [weak inOutlet] in inOutlet?.updateOutlet (inObject) }
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateModel (_ inValue : Int) {
    self.mObject.setFrom (rawValue: inValue)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
}

//--------------------------------------------------------------------------------------------------
