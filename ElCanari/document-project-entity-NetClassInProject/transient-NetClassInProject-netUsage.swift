//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_NetClassInProject_netUsage (
       _ self_mNets_count : Int
) -> String {
//--- START OF USER ZONE 2
        if self_mNets_count == 0 {
          return "No net"
        }else if self_mNets_count == 1 {
          return "1 net"
        }else{
          return "\(self_mNets_count) nets"
        }
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
