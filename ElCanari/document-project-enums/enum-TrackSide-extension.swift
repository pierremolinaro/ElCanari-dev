//
//  extension-TrackSide.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 19/11/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension TrackSide {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var string : String {
    switch self {
    case .front   : return "Front"
    case .back    : return "Back"
    case .inner1  : return "Inner 1"
    case .inner2  : return "Inner 2"
    case .inner3  : return "Inner 3"
    case .inner4  : return "Inner 4"
    }
  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
