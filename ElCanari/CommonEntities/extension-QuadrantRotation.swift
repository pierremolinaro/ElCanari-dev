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
    case .left :
      switch self {
      case .rotation0 :
        horizontalAlignment = .left
      case .rotation90 :
        horizontalAlignment = .left
      case .rotation180 :
        horizontalAlignment = .right
      case .rotation270 :
        horizontalAlignment = .right
      }
    case .center :
      horizontalAlignment = .center
    case .right :
      switch self {
      case .rotation0 :
        horizontalAlignment = .right
      case .rotation90 :
        horizontalAlignment = .right
      case .rotation180 :
        horizontalAlignment = .left
      case .rotation270 :
        horizontalAlignment = .left
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
