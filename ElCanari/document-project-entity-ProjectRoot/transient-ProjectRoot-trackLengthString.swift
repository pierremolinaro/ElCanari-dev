//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_ProjectRoot_trackLengthString (
       _ self_mBoardObjects_trackLengthInCanariUnit : [any BoardObject_trackLengthInCanariUnit],
       _ self_mTrackLengthUnit : Int
) -> String {
//--- START OF USER ZONE 2
        var trackLengthInCanariUnit = 0.0
        for object in self_mBoardObjects_trackLengthInCanariUnit {
          if let length = object.trackLengthInCanariUnit {
            trackLengthInCanariUnit += length
          }
        }
        let trackLength = trackLengthInCanariUnit / Double (self_mTrackLengthUnit)
  return unsafe String (format: "%.3f", trackLength)
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
