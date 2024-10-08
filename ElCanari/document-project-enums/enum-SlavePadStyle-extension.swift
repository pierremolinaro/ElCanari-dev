//
//  enum-SlavePadStyle-extension.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 19/09/2022.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension SlavePadStyle {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var string : String {
    switch self {
      case .traversing : return "traversing" // 0
      case .componentSide : return "componentSide" // 1
      case .oppositeSide : return "oppositeSide" // 2
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
