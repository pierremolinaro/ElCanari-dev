//
//  enum-PadNumbering-extension.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 19/09/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PadNumbering {

  //····················································································································

  var string : String {
    switch self {
      case .noNumbering : return "noNumbering" // 0
      case .counterClock : return "counterClock" // 1
      case .upRight : return "upRight" // 2
      case .upLeft : return "upLeft" // 3
      case .downRight : return "downRight" // 4
      case .downLeft : return "downLeft" // 5
      case .rightUp : return "rightUp" // 6
      case .rightDown : return "rightDown" // 7
      case .leftUp : return "leftUp" // 8
      case .leftDown : return "leftDown" // 9
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
