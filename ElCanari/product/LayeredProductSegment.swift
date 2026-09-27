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
    let p1 = ProductPoint (x: self.x1, y: self.y1).cocoaPoint
    let p2 = ProductPoint (x: self.x2, y: self.y2).cocoaPoint
    let w = self.width.value (in: .pt)
    let d = NSPoint.distance (p1, p2)
    let angleRadian = NSPoint.angleInRadian (p1, p2)
    var t = Turtle (p: p1, angleInRadian: angleRadian)
    t.rotate270 ()
    t.forward (w / 2.0)
    t.rotate270 ()
    t.forward (w / 2.0)
    let bottomLeft = ProductPoint (cocoaPoint: t.location)
    t.rotate180 ()
    t.forward (d + w)
    let bottomRight = ProductPoint (cocoaPoint: t.location)
    t.rotate90 ()
    t.forward (w)
    let topRight = ProductPoint (cocoaPoint: t.location)
    t.rotate90 ()
    t.forward (d + w)
    let topLeft = ProductPoint (cocoaPoint: t.location)
    return (bottomLeft, [bottomRight, topRight, topLeft])
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor func boardModelPad (_ inUndoManager : UndoManager?,
                                 endStyle inEndStyle : TrackEndStyle) -> BoardModelPad {
    let center = ProductPoint (
      x: (self.x1 + self.x2) / 2,
      y: (self.y1 + self.y2) / 2
    )
    let p1 = ProductPoint (x: self.x1, y: self.y1).cocoaPoint
    let p2 = ProductPoint (x: self.x2, y: self.y2).cocoaPoint
    let d = NSPoint.distance (p1, p2)
    let angleInDegrees = NSPoint.angleInDegrees (p1, p2)

    let pad = BoardModelPad (inUndoManager)
    pad.x = center.x.cuValue
    pad.y = center.y.cuValue
    pad.width = cocoaToCanariUnit (d) + self.width.cuValue
    pad.height = self.width.cuValue
    pad.rotation = Int (angleInDegrees * 1000.0)
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
