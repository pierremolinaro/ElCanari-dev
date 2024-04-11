//
//  ProjectRoot-customized-tracks.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 12/09/2020.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

extension ProjectRoot {

  //································································································

  func tracks (at inLocation : CanariPoint, trackSide inSide : TrackSide) -> [BoardTrack] {
    var result = [BoardTrack] ()
    let maxDistance = milsToCanariUnit (fromDouble: self.mControlKeyHiliteDiameter)
    for object in self.mBoardObjects.values {
      if let track = object as? BoardTrack, track.mSide == inSide,
            let p1 = track.mConnectorP1?.location,
            let p2 = track.mConnectorP2?.location {
        let segment = CanariSegment (x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y, width: maxDistance, endStyle: .round)
        if segment.strictlyContains (point: inLocation) {
          result.append (track)
        }
      }
    }
    return result
  }

  //································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————

