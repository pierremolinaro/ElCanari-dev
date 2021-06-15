//
//  AutoLayoutCanariAngleFieldAndSlider.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/06/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   AutoLayoutCanariAngleFieldAndSlider
//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutCanariAngleFieldAndSlider : AutoLayoutHorizontalStackView {

  //····················································································································

  fileprivate let mAngleTextField = AutoLayoutCanariAngleField ()
  fileprivate let mAngleSlider =  AutoLayoutAngleCircularSlider ()

  //····················································································································

  override init () {
    super.init ()
    self.appendView (self.mAngleTextField)
    self.appendView (self.mAngleSlider)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  final func bind_angle (_ inModel : EBReadWriteProperty_Int) -> Self {
    _ = self.mAngleTextField.bind_angle (inModel)
    _ = self.mAngleSlider.bind_angle (inModel, sendContinously: true)
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
