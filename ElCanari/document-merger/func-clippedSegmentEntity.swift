//
//  func-clippedSegmentEntity.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// https://en.wikipedia.org/wiki/Cohen–Sutherland_algorithm

@MainActor func clippedSegmentEntity (p1_mm inP1 : NSPoint,
                                      p2_mm inP2 : NSPoint,
                                      width_mm inWith : CGFloat,
                                      clipRect_mm inClipRect: NSRect,
                                      _ inUndoManager : UndoManager?,
                                      file : String,
                                      _ inLine : Int) -> SegmentEntity? {
  let r : NSRect = inClipRect.insetBy (dx: inWith / 2.0, dy: inWith / 2.0)
  if let (p1, p2) = r.clippedSegment (p1: inP1, p2: inP2) {
    let segment = SegmentEntity (inUndoManager)
    segment.x1 = millimeterToCanariUnit (p1.x)
    segment.y1 = millimeterToCanariUnit (p1.y)
    segment.x2 = millimeterToCanariUnit (p2.x)
    segment.y2 = millimeterToCanariUnit (p2.y)
    segment.width = millimeterToCanariUnit (inWith)
    return segment
  }else{
    return nil
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
