//
//  enum-MarginSize+extension.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 19/08/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

extension MarginSize {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var floatValue : CGFloat {
    switch self {
    case .zero    : return  0.0
    case .small   : return  4.0
    case .regular : return  8.0
    case .large   : return 12.0
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------