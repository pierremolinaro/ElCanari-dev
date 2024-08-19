//
//  enum-extension-TextAlignment.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/06/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension TextAlignment {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var cocoaAlignment : NSTextAlignment {
    switch self {
    case .left : return .left
    case .right : return .right
    case .center : return .center
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
