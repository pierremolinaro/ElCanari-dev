//
//  AutoLayoutCanariPreferredDirectionSegmentedControl.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 16/01/2022.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

final class AutoLayoutCanariPreferredDirectionSegmentedControl : ALB_NSSegmentedControl {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    super.init (equalWidth: true, size: .small)

    self.segmentCount = 4
    self.setLabel ("➡︎",  forSegment: 0)
    self.setLabel ("⬆︎", forSegment: 1)
    self.setLabel ("⬅︎", forSegment: 2)
    self.setLabel ("⬇︎", forSegment: 3)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateTag (from inObject : EBObservableMutableProperty <CanariAngle>) {
    switch inObject.selection {
    case .single (let v) :
      self.enable (fromValueBinding: true, self.enabledBindingController ())
      switch v {
      case .zero :
        self.selectedSegment = 0
      case .degrees90 :
        self.selectedSegment = 1
      case .degrees180 :
        self.selectedSegment = 2
      case .degrees270 :
        self.selectedSegment = 3
      default:
        self.selectedSegment = -1
      }
    case .empty, .multiple :
      self.enable (fromValueBinding: false, self.enabledBindingController ())
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    if self.selectedSegment >= 0 {
      let orientation = CanariAngle.degree (Double (self.selectedSegment * 90))
      self.mAngleController?.updateModel (withValue: orientation)
    }
    return super.sendAction (action, to: to)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $angle binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mAngleController : EBGenericReadWritePropertyController <CanariAngle>? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_angle (_ inObject : EBObservableMutableProperty <CanariAngle>) -> Self {
    self.mAngleController = EBGenericReadWritePropertyController <CanariAngle> (
      observedObject: inObject,
      callBack: { [weak self] in self?.updateTag (from: inObject) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
