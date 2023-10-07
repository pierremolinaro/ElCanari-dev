//
//  AutoLayoutCanariObservedDimensionAndPopUp.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutCanariObservedDimensionAndPopUp
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariObservedDimensionAndPopUp : AutoLayoutHorizontalStackView {

  //····················································································································

  fileprivate let mDimensionField  : AutoLayoutCanariObservedDimensionField
  fileprivate let mUnitPopUpButton : AutoLayoutCanariUnitPopUpButton

  //····················································································································

  init (size inSize : EBControlSize) {
    self.mDimensionField  = AutoLayoutCanariObservedDimensionField (size: inSize)
    self.mUnitPopUpButton = AutoLayoutCanariUnitPopUpButton (size: inSize)
    self.mUnitPopUpButton.setContentHuggingPriority (.defaultLow, for: .vertical)

    super.init ()
    _ = self.setFirstBaselineAlignment ().equalWidth ()
//    self.alignment = .lastBaseline
//    _ = self.equalWidth ()
    _ = self.appendView (self.mDimensionField)
    _ = self.appendView (self.mUnitPopUpButton)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  final func bind_dimensionAndUnit (_ inDimension : EBObservableProperty <Int>,
                               _ inUnit : EBObservableMutableProperty <Int>) -> Self {
    _ = self.mDimensionField.bind_dimensionAndUnit (inDimension, inUnit)
    _ = self.mUnitPopUpButton.bind_unit (inUnit)
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
