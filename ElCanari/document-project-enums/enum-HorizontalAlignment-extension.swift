import AppKit

//--------------------------------------------------------------------------------------------------

extension HorizontalAlignment {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var ebTextShapeHorizontalAlignment : BézierPath.TextHorizontalAlignment {
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
