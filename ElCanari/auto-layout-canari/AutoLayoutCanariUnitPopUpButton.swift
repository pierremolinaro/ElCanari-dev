//
//  AutoLayoutCanariUnitPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariUnitPopUpButton : AutoLayoutBase_NSPopUpButton {

  //····················································································································

  init (size inSize : EBControlSize) {
    super.init (pullsDown: false, size: inSize)

    self.add (title: "inch", withTag: 2_286_000)
    self.add (title: "mil", withTag: 2_286)
    self.add (title: "pt", withTag: 31_750)
    self.add (title: "cm", withTag: 900_000)
    self.add (title: "mm", withTag: 90_000)
    self.add (title: "µm", withTag: 90)
    self.add (title: "pc", withTag: 381_000)
    self.add (title: "m", withTag: 90_000_000)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  fileprivate func add (title inTitle : String, withTag inTag : Int) {
    self.addItem (withTitle: inTitle)
    self.lastItem?.tag = inTag
  }

  //····················································································································

  func updateTag (from inObject : EBObservableMutableProperty <Int>?) {
    if let selection = inObject?.selection {
      switch selection {
      case .single (let v) :
        self.enable (fromValueBinding: true, self.enabledBindingController)
        self.selectItem (withTag: v)
      case .empty :
        self.enable (fromValueBinding: false, self.enabledBindingController)
      case .multiple :
        self.enable (fromValueBinding: false, self.enabledBindingController)
      }
    }
  }

  //····················································································································

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    _ = self.mSelectedUnitController?.updateModel (withCandidateValue: self.selectedTag (), windowForSheet: self.window)
    return super.sendAction (action, to: to)
  }

  //····················································································································
  //  $selectedUnit binding
  //····················································································································

  private var mSelectedUnitController : EBGenericReadWritePropertyController <Int>? = nil

  //····················································································································

  final func bind_unit (_ inObject : EBObservableMutableProperty <Int>) -> Self {
    self.mSelectedUnitController = EBGenericReadWritePropertyController <Int> (
      observedObject: inObject,
      callBack: { [weak self, weak inObject] in self?.updateTag (from: inObject) }
    )
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
