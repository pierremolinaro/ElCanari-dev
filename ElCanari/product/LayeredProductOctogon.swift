//
//  LayeredProductOctogon.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

struct LayeredProductOctogon : Codable {

  //································································································
  //  Properties
  //································································································

  let x : ProductLength // Center
  let y : ProductLength // Center
  let width : ProductLength
  let height : ProductLength
  let angle : Double // Degrees
  let layers : ProductLayerSet

  //································································································

//  init (p1 inP1 : ProductPoint,
//        p2 inP2 : ProductPoint,
//        width inWidth : ProductLength,
//        layers inLayers : ProductLayerSet) {
//    self.p1x = inP1.x
//    self.p1y = inP1.y
//    self.p2x = inP2.x
//    self.p2y = inP2.y
//    self.width = inWidth
//    self.layers = inLayers
//  }

  //································································································

//  var p1 : ProductPoint { ProductPoint (x: self.p1x, y: self.p1y) }
//
//  var p2 : ProductPoint { ProductPoint (x: self.p2x, y: self.p2y) }

  //································································································

  func productPolygon () -> (ProductPoint, [ProductPoint]) {
    let padSize = ProductSize (width: self.width, height: self.height).cocoaSize
    let w : CGFloat = padSize.width / 2.0
    let h : CGFloat = padSize.height / 2.0
    let p = ProductPoint (x: self.x, y: self.y).cocoaPoint
    let lg : CGFloat = min (w, h) / (1.0 + 1.0 / sqrt (2.0))
    var af = AffineTransform ()
    af.rotate (byDegrees: self.angle)
    af.translate (x: p.x, y: p.y)
    let p0 = ProductPoint (cocoaPoint: af.transform (NSPoint (x:  w - lg, y:  h)))
    let p1 = ProductPoint (cocoaPoint: af.transform (NSPoint (x:  w,      y:  h - lg)))
    let p2 = ProductPoint (cocoaPoint: af.transform (NSPoint (x:  w,      y: -h + lg)))
    let p3 = ProductPoint (cocoaPoint: af.transform (NSPoint (x:  w - lg, y: -h)))
    let p4 = ProductPoint (cocoaPoint: af.transform (NSPoint (x: -w + lg, y: -h)))
    let p5 = ProductPoint (cocoaPoint: af.transform (NSPoint (x: -w,      y: -h + lg)))
    let p6 = ProductPoint (cocoaPoint: af.transform (NSPoint (x: -w,      y:  h - lg)))
    let p7 = ProductPoint (cocoaPoint: af.transform (NSPoint (x: -w + lg, y:  h)))
    return (p0, [p1, p2, p3, p4, p5, p6, p7])
  }

  //································································································

}

//--------------------------------------------------------------------------------------------------
