//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_BoardTrack_p2CanMove (
       _ self_mManualLockP2 : Bool,             
       _ self_p2ConnectedToSomePad : Bool
) -> Bool {
//--- START OF USER ZONE 2
        return !self_mManualLockP2 && !self_p2ConnectedToSomePad
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
