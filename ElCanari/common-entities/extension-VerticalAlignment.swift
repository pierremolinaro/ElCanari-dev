//
//  extension-VerticalAlignment.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 13/10/2019.
//
//----------------------------------------------------------------------------------------------------------------------

extension VerticalAlignment {

  //····················································································································

  var ebTextShapeVerticalAlignment : EBTextVerticalAlignment {
    switch self {
      case .above :
        return EBTextVerticalAlignment.above
      case .center :
        return EBTextVerticalAlignment.center
      case .base :
        return EBTextVerticalAlignment.baseline
      case .below :
        return EBTextVerticalAlignment.below
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
