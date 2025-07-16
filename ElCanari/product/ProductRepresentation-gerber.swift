//--------------------------------------------------------------------------------------------------
//  Created by Pierre Molinaro on 28/05/2024.
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension ProductRepresentation {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Get Gerber representation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func gerber (items inItemSet : ProductLayerSet,
               mirror inMirror : ProductHorizontalMirror) -> GerberRepresentation {
    var gerber = GerberRepresentation ()
  //--- Add round segments
    for segment in self.roundSegments {
      if !inItemSet.intersection (segment.layers).isEmpty {
        gerber.addRoundSegment (
          p1: inMirror.mirrored (segment.p1),
          p2: inMirror.mirrored (segment.p2),
          width: segment.width
        )
      }
    }
  //--- Add square segments
    for segment in self.squareSegments {
      if !inItemSet.intersection (segment.layers).isEmpty {
        let (origin, points) = segment.gerberPolygon ()
        gerber.addPolygon (
          origin: inMirror.mirrored (origin),
          points: inMirror.mirrored (points)
        )
      }
    }
  //--- Add rectangles
    for rect in self.rectangles {
      if !inItemSet.intersection (rect.layers).isEmpty {
        let (origin, points) = rect.polygon ()
        gerber.addPolygon (
          origin: inMirror.mirrored (origin),
          points: inMirror.mirrored (points)
        )
      }
    }
  //--- Add pads
    for pad in self.componentPads {
      if !inItemSet.intersection (pad.layers).isEmpty {
        pad.addGerberFor (&gerber, mirror: inMirror)
      }
    }
  //--- Add circles
    for circle in self.circles {
      if !inItemSet.intersection (circle.layers).isEmpty {
        gerber.addCircle (center: inMirror.mirrored (circle.center), diameter: circle.d)
      }
    }
  //---
    return gerber
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Get Excellon Drill String
  //     https://www.artwork.com/gerber/drl2laser/excellon/index.htm
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func excellonDrillString (unit inUnit : GerberUnit) -> String {
    var s = "M48\n" // indicates the start of the header, should always be the first line in the header
    switch inUnit {
    case .imperial :
      s += "INCH\n"
    case .metric :
      s += "METRIC\n"
    }
 //--- Make inventory of apertures
    var apertureSet = Set <ProductLength> ()
    for circle in self.circles {
      if circle.layers.contains (.hole) {
        apertureSet.insert (circle.d)
      }
    }
    for segment in self.roundSegments {
      if segment.layers.contains (.hole) {
        apertureSet.insert (segment.width)
      }
    }
    let apertureArray = Array (apertureSet).sorted ()
 //--- Write apertures
    var idx = 0
    for aperture in apertureArray {
      idx += 1
      s += "T" + "\(idx)C" + aperture.excellonLengthString (inUnit) + "\n"
    }
 //--- Write holes
    s += "M95\n" // End of the header. Data that follows will be drill and/or route commands.
    s += "G05\n" // Drill Mode
    switch inUnit {
    case .imperial :
      s += "M72\n" // Inch Measuring Mode
    case .metric :
      s += "M71\n" // Metric Measuring Mode
    }
    idx = 0
    for aperture in apertureArray {
      idx += 1
      s += "T\(idx)\n" // Tool selection
      for circle in self.circles {
        if circle.layers.contains (.hole) && (circle.d == aperture) {
          s += circle.center.excellonPointString (inUnit) + "\n"
        }
      }
      for segment in self.roundSegments {
        if segment.layers.contains (.hole) && (segment.width == aperture) {
          s += segment.p1.excellonPointString (inUnit) + "\n"
          s += "G85" // Slot: drill until next point (NO CARRIAGE RETURN)
          s += segment.p2.excellonPointString (inUnit) + "\n"
        }
      }
    }
  //--- End of file
    s += "M30\n" // End code
  //---
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate extension ProductLength {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func excellonLengthString (_ inUnit : GerberUnit) -> String {
    switch inUnit {
    case .imperial :
      return unsafe String (format: "%.4f", self.value (in: .inch))
    case .metric :
      return unsafe String (format: "%.6f", self.value (in: .mm))
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate extension ProductPoint {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func excellonPointString (_ inUnit : GerberUnit) -> String {
    return "X\(self.x.excellonLengthString (inUnit))Y\(self.y.excellonLengthString (inUnit))"
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

