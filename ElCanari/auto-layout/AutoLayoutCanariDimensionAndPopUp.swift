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

final class AutoLayoutCanariDimensionAndPopUp : AutoLayoutHorizontalStackView {

  //····················································································································

  fileprivate let mDimensionField = AutoLayoutCanariDimensionField ()
  fileprivate let mUnitPopUpButton =  AutoLayoutCanariUnitPopUpButton (small: true)

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

  final func bind_dimensionAndUnit (_ inDimension : EBReadWriteProperty_Int,
                                    _ inUnit : EBReadWriteProperty_Int) -> Self {
    _ = self.mDimensionField.bind_dimensionAndUnit (inDimension, inUnit)
    _ = self.mUnitPopUpButton.bind_unit (inUnit)
    return self
  }

  //····················································································································

  final func bind_enabled (observedObjects inObjects : [EBObservableObjectProtocol],
                           computeFunction inFunction : @escaping () -> EBSelection <Bool>) -> Self {
    _ = self.mDimensionField.bind_enabled (observedObjects: inObjects, computeFunction: inFunction)
    _ = self.mUnitPopUpButton.bind_enabled (observedObjects: inObjects, computeFunction: inFunction)
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
