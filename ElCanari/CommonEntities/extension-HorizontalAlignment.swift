import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension HorizontalAlignment {

  //····················································································································

  func ebTextShapeHorizontalAlignment () -> EBTextHorizontalAlignment {
    switch self {
      case .onTheRight :
        return EBTextHorizontalAlignment.onTheRight
      case .center :
        return EBTextHorizontalAlignment.center
      case .onTheLeft :
        return EBTextHorizontalAlignment.onTheLeft
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
