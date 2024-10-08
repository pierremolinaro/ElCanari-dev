//
//  enum-PadStyle-extension.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 19/09/2022.
//
//--------------------------------------------------------------------------------------------------

extension PadStyle {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var string : String {
    switch self {
      case .traversing : return "traversing" // 0
      case .surface : return "surface" // 1
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
