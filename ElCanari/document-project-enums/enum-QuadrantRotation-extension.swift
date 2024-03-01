//
//  extension-QuadrantRotation.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 02/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension QuadrantRotation {

  //································································································

  func ebSymbolTextShapeHorizontalAlignment (alignment inAlignment : HorizontalAlignment, mirror inMirror : Bool) -> EBTextHorizontalAlignment {
    let horizontalAlignment : EBTextHorizontalAlignment
    switch inAlignment {
    case .onTheRight :
      switch self {
      case .rotation0 :
        horizontalAlignment = inMirror ? .onTheLeft : .onTheRight
      case .rotation90 :
        horizontalAlignment = .onTheRight
      case .rotation180 :
        horizontalAlignment = inMirror ? .onTheRight : .onTheLeft
      case .rotation270 :
        horizontalAlignment = .onTheLeft
      }
    case .center :
      horizontalAlignment = .center
    case .onTheLeft :
      switch self {
      case .rotation0 :
        horizontalAlignment = inMirror ? .onTheRight : .onTheLeft
      case .rotation90 :
        horizontalAlignment = .onTheLeft
      case .rotation180 :
        horizontalAlignment = inMirror ? .onTheLeft : .onTheRight
      case .rotation270 :
        horizontalAlignment = .onTheRight
      }
    }
    return horizontalAlignment
  }

  //································································································

  func ebSymbolTextShapeVerticalAlignment (alignment _ : HorizontalAlignment, mirror inMirror : Bool) -> EBTextVerticalAlignment {
    let verticalAlignment : EBTextVerticalAlignment
    switch self {
    case .rotation0 :
      verticalAlignment = .center
    case .rotation90 :
      verticalAlignment = inMirror ? .above : .below
    case .rotation180 :
      verticalAlignment = .center
    case .rotation270 :
      verticalAlignment = inMirror ? .below : .above
    }
    return verticalAlignment
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
