//
//  extension-VerticalAlignment.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 13/10/2019.
//
//--------------------------------------------------------------------------------------------------

extension VerticalAlignment {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var ebTextShapeVerticalAlignment : BezierPath.TextVerticalAlignment {
    switch self {
      case .above :
        return .above
      case .center :
        return .center
      case .base :
        return .baseline
      case .below :
        return .below
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
