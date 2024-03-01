//
//  AutoLayoutCanariUnitPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariUnitPopUpButton : AutoLayoutBase_NSPopUpButton {

  //································································································

  init (size inSize : EBControlSize) {
    super.init (pullsDown: false, size: inSize)

    self.addItem (forUnit: CANARI_UNITS_PER_MIL)
    self.addItem (forUnit: CANARI_UNITS_PER_INCH)
    self.addItem (forUnit: CANARI_UNITS_PER_µM)
    self.addItem (forUnit: CANARI_UNITS_PER_MM)
    self.addItem (forUnit: CANARI_UNITS_PER_CM)
    self.addItem (forUnit: CANARI_UNITS_PER_M)
    self.addItem (forUnit: CANARI_UNITS_PER_PIXEL)
    self.addItem (forUnit: CANARI_UNITS_PER_PC)
  }

  //································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //································································································

  fileprivate func addItem (forUnit inUnit : Int) {
    let unitString = unitStringFrom (displayUnit: inUnit)
    self.addItem (withTitle: unitString)
    self.lastItem?.tag = inUnit
  }

  //································································································

  func updateTag (from inObject : EBObservableMutableProperty <Int>?) {
    if let selection = inObject?.selection {
      switch selection {
      case .single (let v) :
        self.enable (fromValueBinding: true, self.enabledBindingController)
        _ = self.selectItem (withTag: v)
      case .empty :
        self.enable (fromValueBinding: false, self.enabledBindingController)
      case .multiple :
        self.enable (fromValueBinding: false, self.enabledBindingController)
      }
    }
  }

  //································································································

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    self.mSelectedUnitController?.updateModel (withValue: self.selectedTag ())
    return super.sendAction (action, to: to)
  }

  //································································································
  //  $selectedUnit binding
  //································································································

  private var mSelectedUnitController : EBGenericReadWritePropertyController <Int>? = nil

  //································································································

  final func bind_unit (_ inObject : EBObservableMutableProperty <Int>) -> Self {
    self.mSelectedUnitController = EBGenericReadWritePropertyController <Int> (
      observedObject: inObject,
      callBack: { [weak self, weak inObject] in self?.updateTag (from: inObject) }
    )
    return self
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
