
import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

extension BoardModel {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func boardLimitsSegments () -> MergerSegmentArray {
    let left = CanariLength.zero
    let bottom = CanariLength.zero
    let right = self.modelWidth
    let top = self.modelHeight

    var segments = [CanariSegment] ()
    segments.append (CanariSegment (x1:left,  y1:bottom, x2:left,  y2:top,    width: BOARD_LIMIT_WIDTH, endStyle: .round))
    segments.append (CanariSegment (x1:left,  y1:top,    x2:right, y2:top,    width: BOARD_LIMIT_WIDTH, endStyle: .round))
    segments.append (CanariSegment (x1:right, y1:top,    x2:right, y2:bottom, width: BOARD_LIMIT_WIDTH, endStyle: .round))
    segments.append (CanariSegment (x1:right, y1:bottom, x2:left,  y2:bottom, width: BOARD_LIMIT_WIDTH, endStyle: .round))

    return MergerSegmentArray (segments)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
