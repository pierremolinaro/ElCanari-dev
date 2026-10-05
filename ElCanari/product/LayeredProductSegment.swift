//
//  LayeredProductSegment.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation
import CanariGeometry

//--------------------------------------------------------------------------------------------------

struct LayeredProductSegment : Codable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let x1 : CanariLength
  let y1 : CanariLength
  let x2 : CanariLength
  let y2 : CanariLength
  let width : CanariLength
  let layers : ProductLayerSet

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (p1 inP1 : CanariPoint,
        p2 inP2 : CanariPoint,
        width inWidth : CanariLength,
        layers inLayers : ProductLayerSet) {
    self.x1 = inP1.x
    self.y1 = inP1.y
    self.x2 = inP2.x
    self.y2 = inP2.y
    self.width = inWidth
    self.layers = inLayers
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var p1 : CanariPoint { CanariPoint (x: self.x1, y: self.y1) }

  var p2 : CanariPoint { CanariPoint (x: self.x2, y: self.y2) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func gerberPolygon () -> (CanariPoint, [CanariPoint]) {
    let p1 = CanariPoint (x: self.x1, y: self.y1)
    let p2 = CanariPoint (x: self.x2, y: self.y2)
    let w = self.width
    let d = p1.distance (to: p2)
    var t = Turtle (p: p1, angle: p1.angle (to: p2))
    t.rotate270 ()
    t.forward (w / 2.0)
    t.rotate270 ()
    t.forward (w / 2.0)
    let bottomLeft = t.location
    t.rotate180 ()
    t.forward (d + w)
    let bottomRight = t.location
    t.rotate90 ()
    t.forward (w)
    let topRight = t.location
    t.rotate90 ()
    t.forward (d + w)
    let topLeft = t.location
    return (bottomLeft, [bottomRight, topRight, topLeft])
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor func boardModelPad (_ inUndoManager : UndoManager?,
                                 endStyle inEndStyle : TrackEndStyle) -> BoardModelPad {
    let center = CanariPoint (
      x: (self.x1 + self.x2) / 2,
      y: (self.y1 + self.y2) / 2
    )
    let p1 = CanariPoint (x: self.x1, y: self.y1)
    let p2 = CanariPoint (x: self.x2, y: self.y2)
    let d = p1.distance (to: p2)
    let angle = p1.angle (to: p2)

    let pad = BoardModelPad (inUndoManager)
    pad.x = center.x
    pad.y = center.y
    pad.width = d + self.width
    pad.height = self.width
    pad.rotation = angle
    switch inEndStyle {
    case .round :
      pad.shape = .round
    case .square :
      pad.shape = .rect
    }
    return pad
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
