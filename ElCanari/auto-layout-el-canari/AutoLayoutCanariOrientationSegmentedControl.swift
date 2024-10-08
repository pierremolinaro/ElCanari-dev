//
//  AutoLayoutCanariOrientationSegmentedControl.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/07/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class AutoLayoutCanariOrientationSegmentedControl : ALB_NSSegmentedControl {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (size inSize : EBControlSize) {
    super.init (equalWidth: true, size: inSize.cocoaControlSize)

    self.segmentCount = 4
    self.setLabel ("0°",   forSegment: 0)
    self.setLabel ("90°",  forSegment: 1)
    self.setLabel ("180°", forSegment: 2)
    self.setLabel ("270°", forSegment: 3)
    self.trackingMode = .selectOne
    self.selectedSegment = 0
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateTag (from inObject : EBReadWriteProperty_QuadrantRotation) {
    switch inObject.selection {
    case .single (let v) :
      self.enable (fromValueBinding: true, self.enabledBindingController ())
      self.selectedSegment = v.rawValue
    case .empty :
      self.enable (fromValueBinding: false, self.enabledBindingController ())
    case .multiple :
      self.enable (fromValueBinding: false, self.enabledBindingController ())
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    let orientation = QuadrantRotation (rawValue: self.selectedSegment)!
    self.mSelectedOrientationController?.updateModel (withCandidateValue: orientation)
    return super.sendAction (action, to: to)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $orientation binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mSelectedOrientationController : EBEnumGenericReadWritePropertyController <QuadrantRotation>? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_orientation (_ inObject : EBReadWriteProperty_QuadrantRotation) -> Self {
    self.mSelectedOrientationController = EBEnumGenericReadWritePropertyController <QuadrantRotation> (
      observedObject: inObject,
      callBack: { [weak self] in self?.updateTag (from: inObject) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
