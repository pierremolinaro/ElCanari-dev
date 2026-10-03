//
//  func-clippedSegmentEntity.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 03/12/2021.
//
//--------------------------------------------------------------------------------------------------

import Foundation
import CanariGeometry

//--------------------------------------------------------------------------------------------------
// https://en.wikipedia.org/wiki/Cohen–Sutherland_algorithm

@MainActor func clippedSegmentEntity (p1 inP1 : CanariPoint,
                                      p2 inP2 : CanariPoint,
                                      width inWith : CanariLength,
                                      clipRect inClipRect : CanariRect,
                                      _ inUndoManager : UndoManager?) -> SegmentEntity? {
  let r = inClipRect.insetBy (dx: inWith / 2.0, dy: inWith / 2.0)
  if let (p1, p2) = r.clippedSegment (p1: inP1, p2: inP2) {
    let segment = SegmentEntity (inUndoManager)
    segment.x1 = p1.x
    segment.y1 = p1.y
    segment.x2 = p2.x
    segment.y2 = p2.y
    segment.width = inWith
    return segment
  }else{
    return nil
  }
}

//--------------------------------------------------------------------------------------------------
