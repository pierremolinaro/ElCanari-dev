//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_ProjectRoot_boardBoundBox (
       _ self_interiorBoundBox : CanariRect,         
       _ self_mBoardLimitsWidth : Int,               
       _ self_mBoardClearance : Int
) -> CanariRect {
//--- START OF USER ZONE 2
        let extend = -self_mBoardClearance - self_mBoardLimitsWidth
        return self_interiorBoundBox.insetBy (dx: extend, dy: extend)
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
