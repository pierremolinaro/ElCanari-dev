//
//  AutoLayoutCanariUnitPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

final class AutoLayoutCanariUnitPopUpButton : ALB_NSPopUpButton {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (size inSize : EBControlSize) {
    super.init (pullsDown: false, size: inSize.cocoaControlSize)

    self.addItem (forUnit: .mil)
    self.addItem (forUnit: .inch)
    self.addItem (forUnit: .µm)
    self.addItem (forUnit: .mm)
    self.addItem (forUnit: .cm)
    self.addItem (forUnit: .m)
    self.addItem (forUnit: .pt)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func addItem (forUnit inUnit : CanariLengthUnit) {
    let unitString = inUnit.unitString
    self.addItem (withTitle: unitString)
    self.lastItem?.tag = inUnit.cuValue
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateTag (from inObject : EBObservableMutableProperty <CanariLengthUnit>?) {
    if let selection = inObject?.selection {
      switch selection {
      case .single (let v) :
        self.enable (fromValueBinding: true, self.enabledBindingController ())
        _ = self.selectItem (withTag: v.cuValue)
      case .empty :
        self.enable (fromValueBinding: false, self.enabledBindingController ())
      case .multiple :
        self.enable (fromValueBinding: false, self.enabledBindingController ())
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    self.mSelectedUnitController?.updateModel (withValue: CanariLengthUnit (fromNearestLength: self.selectedTag ()))
    return super.sendAction (action, to: to)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $selectedUnit binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mSelectedUnitController : EBGenericReadWritePropertyController <CanariLengthUnit>? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_unit (_ inObject : EBObservableMutableProperty <CanariLengthUnit>) -> Self {
    self.mSelectedUnitController = EBGenericReadWritePropertyController <CanariLengthUnit> (
      observedObject: inObject,
      callBack: { [weak self, weak inObject] in self?.updateTag (from: inObject) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
