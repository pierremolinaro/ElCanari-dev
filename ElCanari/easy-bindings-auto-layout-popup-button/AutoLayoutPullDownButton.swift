//
//  AutoLayoutPullDownButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutPullDownButton : AutoLayoutBase_NSPopUpButton {

  //································································································

  init (title inTitle : String, size inSize : EBControlSize) {
    super.init (pullsDown: true, size: inSize)

    self.addItem (withTitle: inTitle)
  }

  //································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //································································································

  var mControllerArray = [EBObservablePropertyController] ()

  //································································································

  final func add (item inMenuItemDescriptor : AutoLayoutMenuItemDescriptor) -> Self {
    self.addItem (withTitle: inMenuItemDescriptor.title)
    self.lastItem?.target = inMenuItemDescriptor.target
    self.lastItem?.action = inMenuItemDescriptor.selector
  //--- Add Enabled binding
//    let idx = self.numberOfItems - 1
//    var modelArray = [EBObservableObjectProtocol] ()
//    inMenuItemDescriptor.enableBinding.addModelsTo (&modelArray)
//    let controller = EBObservablePropertyController (
//      observedObjects: modelArray,
//      callBack: { [weak self] in self?.enable (itemIndex: idx, from: inMenuItemDescriptor.enableBinding) }
//    )
//    self.mControllerArray.append (controller)
  //---
    return self
  }

  //································································································

  private func enable (itemIndex inIndex : Int, from inObject : EBMultipleBindingBooleanExpression) {
    let menuItem = self.item (at: inIndex)
    switch inObject.compute () {
    case .empty, .multiple :
      menuItem?.isEnabled = false
    case .single (let v) :
      menuItem?.isEnabled = v
    }
  }

  //································································································
  //  $items binding
  //································································································

  private var mItemsController : EBObservablePropertyController? = nil

  //································································································

  final func bind_items (_ inObject : EBObservableProperty <StringArray>) -> Self {
    self.mItemsController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  //································································································

  private func update (from model : EBObservableProperty <StringArray>) {
    switch model.selection {
    case .empty, .multiple :
      self.enable (fromValueBinding: false, self.enabledBindingController)
    case .single (let titleArray) :
      self.enable (fromValueBinding: true, self.enabledBindingController)
      while self.numberOfItems > 1 {
        self.removeItem (at: self.numberOfItems - 1)
      }
      for itemTitle in titleArray {
        self.addItem (withTitle: itemTitle)
      }
    }
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
