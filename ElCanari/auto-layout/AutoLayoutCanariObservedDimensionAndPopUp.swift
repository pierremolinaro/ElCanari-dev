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

class AutoLayoutCanariObservedDimensionAndPopUp : AutoLayoutHorizontalStackView {

  //····················································································································

  fileprivate let mDimensionField = AutoLayoutCanariObservedDimensionField ()
  fileprivate let mUnitPopUpButton =  AutoLayoutCanariUnitPopUpButton ()

  //····················································································································

  override init () {
    super.init ()
    self.appendView (self.mDimensionField)
    self.appendView (self.mUnitPopUpButton)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  func bind_dimensionAndUnit (_ inDimension : EBReadOnlyProperty_Int,
                               _ inUnit : EBReadWriteProperty_Int) -> Self {
    _ = self.mDimensionField.bind_dimensionAndUnit (inDimension, inUnit)
    _ = self.mUnitPopUpButton.bind_unit (inUnit)
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
