//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_AutoLayoutProjectDocument_componentCount (
       _ root_mComponents_count : Int
) -> String {
//--- START OF USER ZONE 2
        if root_mComponents_count == 0 {
          return "No Component"
        }else if root_mComponents_count == 1 {
          return "1 Component"
        }else{
          return "\(root_mComponents_count) Components"
        }
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------