//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func transient_BoardConnector_isVia (
       _ self_mTracksP1_mSide : [BoardTrack_mSide],
       _ self_mTracksP2_mSide : [BoardTrack_mSide],
       _ self_mComponent_none : Bool
) -> Bool {
//--- START OF USER ZONE 2
        var isVia = self_mComponent_none
        if isVia {
          var hasFrontTrack = false
          var hasBackTrack = false
          for track in self_mTracksP1_mSide + self_mTracksP2_mSide {
            switch track.mSide {
            case .back : hasBackTrack = true
            case .front : hasFrontTrack = true
            }
          }
          isVia = hasFrontTrack && hasBackTrack
        }
        return isVia
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————