//
//  enum-ControlSize-extension.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/07/2021.
//
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension EBControlSize {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var cocoaControlSize : NSControl.ControlSize {
    switch self {
    case .mini : return .mini
    case .small : return .small
    case .regular : return .regular
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
