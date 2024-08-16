import AppKit

//--------------------------------------------------------------------------------------------------

extension HorizontalAlignment {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var ebTextShapeHorizontalAlignment : EBBezierPath.TextHorizontalAlignment {
    switch self {
      case .onTheRight :
        return .onTheRight
      case .center :
        return .center
      case .onTheLeft :
        return .onTheLeft
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
