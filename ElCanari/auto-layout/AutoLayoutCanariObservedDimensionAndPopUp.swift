//
//  AutoLayoutCanariObservedDimensionAndPopUp.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   AutoLayoutCanariObservedDimensionAndPopUp
//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutCanariObservedDimensionAndPopUp : AutoLayoutHorizontalStackView {

  //····················································································································

  fileprivate let mDimensionField  : AutoLayoutCanariObservedDimensionField
  fileprivate let mUnitPopUpButton : AutoLayoutCanariUnitPopUpButton

  //····················································································································

  init (small inSmall : Bool) {
    self.mDimensionField  = AutoLayoutCanariObservedDimensionField (small: inSmall)
    self.mUnitPopUpButton = AutoLayoutCanariUnitPopUpButton (small: inSmall)
    super.init ()
    self.alignment = .firstBaseline
    self.appendView (self.mDimensionField)
    self.appendView (self.mUnitPopUpButton)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  final func bind_dimensionAndUnit (_ inDimension : EBReadOnlyProperty_Int,
                               _ inUnit : EBReadWriteProperty_Int) -> Self {
    _ = self.mDimensionField.bind_dimensionAndUnit (inDimension, inUnit)
    _ = self.mUnitPopUpButton.bind_unit (inUnit)
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
