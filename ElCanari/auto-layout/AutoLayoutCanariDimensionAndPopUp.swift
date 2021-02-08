//
//  AutoLayoutCanariDimensionAndPopUp.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   AutoLayoutCanariDimensionAndPopUp
//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutCanariDimensionAndPopUp : AutoLayoutHorizontalStackView {

  //····················································································································

  fileprivate let mDimensionField = AutoLayoutCanariDimensionField ()
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

  func bind__dimensionAndUnit (_ inDimension : EBReadWriteProperty_Int,
                               _ inUnit : EBReadWriteProperty_Int) -> Self {
    _ = self.mDimensionField.bind__dimensionAndUnit (inDimension, inUnit)
    _ = self.mUnitPopUpButton.bind__unit (inUnit)
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
