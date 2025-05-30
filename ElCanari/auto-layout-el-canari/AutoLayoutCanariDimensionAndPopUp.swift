//
//  AutoLayoutCanariDimensionAndPopUp.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   AutoLayoutCanariDimensionAndPopUp
//--------------------------------------------------------------------------------------------------

final class AutoLayoutCanariDimensionAndPopUp : AutoLayoutHorizontalStackView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate let mDimensionField  : AutoLayoutCanariDimensionField
  fileprivate let mUnitPopUpButton : AutoLayoutCanariUnitPopUpButton

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (size inSize : EBControlSize) {
    self.mDimensionField  = AutoLayoutCanariDimensionField (size: inSize)
    self.mUnitPopUpButton = AutoLayoutCanariUnitPopUpButton (size: inSize)
    self.mUnitPopUpButton.setContentHuggingPriority (.defaultLow, for: .vertical)
    super.init ()
    _ = self.appendView (self.mDimensionField).appendView (self.mUnitPopUpButton)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_dimensionAndUnit (_ inDimension : EBObservableMutableProperty <Int>,
                                    _ inUnit : EBObservableMutableProperty <Int>) -> Self {
    _ = self.mDimensionField.bind_dimensionAndUnit (inDimension, inUnit)
    _ = self.mUnitPopUpButton.bind_unit (inUnit)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_enabled (_ inExpression : MultipleBindingBooleanExpression) -> Self {
    _ = self.mDimensionField.bind_enabled (inExpression)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
