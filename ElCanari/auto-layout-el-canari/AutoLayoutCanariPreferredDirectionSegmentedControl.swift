//
//  AutoLayoutCanariPreferredDirectionSegmentedControl.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 16/01/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariPreferredDirectionSegmentedControl : AutoLayoutBase_NSSegmentedControl {

  //································································································

  init () {
    super.init (equalWidth: true, size: .small)

    self.segmentCount = 4
    self.setLabel ("➡︎",   forSegment: 0)
    self.setLabel ("⬆︎",  forSegment: 1)
    self.setLabel ("⬅︎", forSegment: 2)
    self.setLabel ("⬇︎", forSegment: 3)
  }

  //································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //································································································

  func updateTag (from inObject : EBObservableMutableProperty <Int>) {
    switch inObject.selection {
    case .single (let v) :
      self.enable (fromValueBinding: true, self.enabledBindingController)
      switch v {
      case 0 :
        self.selectedSegment = 0
      case 90_000 :
        self.selectedSegment = 1
      case 180_000 :
        self.selectedSegment = 2
      case 270_000 :
        self.selectedSegment = 3
      default:
        self.selectedSegment = -1
      }
    case .empty, .multiple :
      self.enable (fromValueBinding: false, self.enabledBindingController)
    }
  }

  //································································································

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    if self.selectedSegment >= 0 {
      let orientation = self.selectedSegment * 90_000
      self.mAngleController?.updateModel (withValue: orientation)
    }
    return super.sendAction (action, to: to)
  }

  //································································································
  //  $angle binding
  //································································································

  private var mAngleController : EBGenericReadWritePropertyController <Int>? = nil

  //································································································

  final func bind_angle (_ inObject : EBObservableMutableProperty <Int>) -> Self {
    self.mAngleController = EBGenericReadWritePropertyController <Int> (
      observedObject: inObject,
      callBack: { [weak self] in self?.updateTag (from: inObject) }
    )
    return self
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
