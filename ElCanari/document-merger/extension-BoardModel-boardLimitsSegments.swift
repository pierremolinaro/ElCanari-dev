
import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension BoardModel {

  //····················································································································

  func boardLimitsSegments () -> MergerSegmentArray {
    let left = self.modelLimitWidth / 2
    let bottom = self.modelLimitWidth / 2
    let right = self.modelWidth - self.modelLimitWidth / 2
    let top = self.modelHeight - self.modelLimitWidth / 2

    var segments = [CanariSegment] ()
    segments.append (CanariSegment (x1:left,  y1:bottom, x2:left,  y2:top,    width:self.modelLimitWidth))
    segments.append (CanariSegment (x1:left,  y1:top,    x2:right, y2:top,    width:self.modelLimitWidth))
    segments.append (CanariSegment (x1:right, y1:top,    x2:right, y2:bottom, width:self.modelLimitWidth))
    segments.append (CanariSegment (x1:right, y1:bottom, x2:left,  y2:bottom, width:self.modelLimitWidth))

    return MergerSegmentArray (segments)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
