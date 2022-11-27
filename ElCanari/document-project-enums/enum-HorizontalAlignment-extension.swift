import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension HorizontalAlignment {

  //····················································································································

  var ebTextShapeHorizontalAlignment : EBTextHorizontalAlignment {
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
