//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_AutoLayoutDeviceDocument_assignmentInhibitionMessage (
       _ root_inconsistentPackagePadNameSetsMessage : String,                   
       _ root_inconsistentSymbolNameSetMessage : String
) -> String {
//--- START OF USER ZONE 2
        var message = ""
        if (root_inconsistentPackagePadNameSetsMessage != "") || (root_inconsistentSymbolNameSetMessage != "") {
          message = "Cannot perform assignments."
          if root_inconsistentPackagePadNameSetsMessage != "" {
            message += "\n" + root_inconsistentPackagePadNameSetsMessage
          }
          if root_inconsistentSymbolNameSetMessage != "" {
            message += "\n" + root_inconsistentSymbolNameSetMessage
          }
        }
        return message
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
