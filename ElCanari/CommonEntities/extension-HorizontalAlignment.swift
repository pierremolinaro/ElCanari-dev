import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension HorizontalAlignment {

  //····················································································································

  func ebTextShapeHorizontalAlignment () -> EBTextHorizontalAlignment {
    switch self {
      case .left :
        return EBTextHorizontalAlignment.left
      case .center :
        return EBTextHorizontalAlignment.center
      case .right :
        return EBTextHorizontalAlignment.right
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
