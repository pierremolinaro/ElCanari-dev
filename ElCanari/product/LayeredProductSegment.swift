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

  init (p1 inP1 : ProductPoint,
        p2 inP2 : ProductPoint,
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

  var p1 : ProductPoint { ProductPoint (x: self.x1, y: self.y1) }

  var p2 : ProductPoint { ProductPoint (x: self.x2, y: self.y2) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func gerberPolygon () -> (ProductPoint, [ProductPoint]) {
    let p1 = ProductPoint (x: self.x1, y: self.y1).ptValue
    let p2 = ProductPoint (x: self.x2, y: self.y2).ptValue
    let w = self.width.value (in: .pt)
    let d = p1.distance (to: p2)
    let angleRadian = p1.angle (to: p2).signedRadianValue
    var t = Turtle (p: p1, angleInRadian: angleRadian)
    t.rotate270 ()
    t.forward (w / 2.0)
    t.rotate270 ()
    t.forward (w / 2.0)
    let bottomLeft = ProductPoint (ptValue: t.location)
    t.rotate180 ()
    t.forward (d + w)
    let bottomRight = ProductPoint (ptValue: t.location)
    t.rotate90 ()
    t.forward (w)
    let topRight = ProductPoint (ptValue: t.location)
    t.rotate90 ()
    t.forward (d + w)
    let topLeft = ProductPoint (ptValue: t.location)
    return (bottomLeft, [bottomRight, topRight, topLeft])
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor func boardModelPad (_ inUndoManager : UndoManager?,
                                 endStyle inEndStyle : TrackEndStyle) -> BoardModelPad {
    let center = ProductPoint (
      x: (self.x1 + self.x2) / 2,
      y: (self.y1 + self.y2) / 2
    )
    let p1 = ProductPoint (x: self.x1, y: self.y1).ptValue
    let p2 = ProductPoint (x: self.x2, y: self.y2).ptValue
    let d = p1.distance (to: p2)
    let angle = p1.angle (to: p2)

    let pad = BoardModelPad (inUndoManager)
    pad.x = center.x
    pad.y = center.y
    pad.width = CanariLength.pt (d) + self.width
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
