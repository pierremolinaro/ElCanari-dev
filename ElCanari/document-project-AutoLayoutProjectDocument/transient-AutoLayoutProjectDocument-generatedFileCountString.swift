//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_AutoLayoutProjectDocument_generatedFileCountString (
       _ self_mDataController_sortedArray_count : Int
) -> String {
//--- START OF USER ZONE 2
       var s : String
        if 0 == self_mDataController_sortedArray_count {
          s = "This artwork generates no data file"
        }else if 1 == self_mDataController_sortedArray_count {
          s = "This artwork generates 1 data file"
        }else{
          s = "This artwork generates \(self_mDataController_sortedArray_count) data files"
        }
        return s
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
