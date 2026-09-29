//
//  AutoLayoutCanariObservedDimensionAndPopUp.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   AutoLayoutCanariObservedDimensionAndPopUp
//--------------------------------------------------------------------------------------------------

final class AutoLayoutCanariObservedDimensionAndPopUpEx : AutoLayoutHorizontalStackView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate let mDimensionField  : AutoLayoutCanariObservedDimensionFieldEx
  fileprivate let mUnitPopUpButton : AutoLayoutCanariUnitPopUpButton

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (size inSize : EBControlSize) {
    self.mDimensionField  = AutoLayoutCanariObservedDimensionFieldEx (size: inSize)
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

  final func bind_dimensionAndUnit (_ inDimension : EBObservableProperty <Int>,
                                    _ inUnit : EBObservableMutableProperty <Int>) -> Self {
    _ = self.mDimensionField.bind_dimensionAndUnit (inDimension, inUnit)
    _ = self.mUnitPopUpButton.bind_unit (inUnit)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
