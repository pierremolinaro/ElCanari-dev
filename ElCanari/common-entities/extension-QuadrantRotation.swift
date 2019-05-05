//
//  extension-QuadrantRotation.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 02/05/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension QuadrantRotation {

  //····················································································································

  func ebSymbolTextShapeHorizontalAlignment (alignment inAlignment : HorizontalAlignment) -> EBTextHorizontalAlignment {
    let horizontalAlignment : EBTextHorizontalAlignment
    switch inAlignment {
    case .onTheRight :
      switch self {
      case .rotation0 :
        horizontalAlignment = .onTheRight
      case .rotation90 :
        horizontalAlignment = .onTheRight
      case .rotation180 :
        horizontalAlignment = .onTheLeft
      case .rotation270 :
        horizontalAlignment = .onTheLeft
      }
    case .center :
      horizontalAlignment = .center
    case .onTheLeft :
      switch self {
      case .rotation0 :
        horizontalAlignment = .onTheLeft
      case .rotation90 :
        horizontalAlignment = .onTheLeft
      case .rotation180 :
        horizontalAlignment = .onTheRight
      case .rotation270 :
        horizontalAlignment = .onTheRight
      }
    }
    return horizontalAlignment
  }

  //····················································································································

  func ebSymbolTextShapeVerticalAlignment (alignment inAlignment : HorizontalAlignment) -> EBTextVerticalAlignment {
    let verticalAlignment : EBTextVerticalAlignment
    switch self {
    case .rotation0 :
      verticalAlignment = .center
    case .rotation90 :
      verticalAlignment = .below
    case .rotation180 :
      verticalAlignment = .center
    case .rotation270 :
      verticalAlignment = .center
    }
    return verticalAlignment
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
